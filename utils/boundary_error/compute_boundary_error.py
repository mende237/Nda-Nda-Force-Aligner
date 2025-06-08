import argparse
import logging
import os
import numpy as np

# Configure the logging module
logging.basicConfig(filename='../../logs/error.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(filename)s - Line %(lineno)d - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

def load_phone_mapping(phone_mapping_file_path):
    phone_map = {}
    with open(phone_mapping_file_path, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 2:
                phone, index = parts
                phone_map[index] = phone
    return phone_map

def phone_mapping_to_ctm(align_path):
    phone_map = load_phone_mapping(f"{align_path}/phones.txt")

    
    with open(f"{align_path}/merged_alignment.ctm", 'r') as f:
        lines = f.readlines()

    with open(f"{align_path}/merged_alignment.ctm", 'w') as out:
        for line in lines:
            parts = line.strip().split()
            if not parts:
                continue
            phone_index = parts[-1]  # Get the last part (phone index)
            phone_value = phone_map.get(phone_index, phone_index)  # Default to index if not found
            
            # Split phone value by "_" and take the first part
            if '_' in phone_value:
                phone_value = phone_value.split('_')[0]

            new_line = ' '.join(parts[:-1] + [phone_value])  # Replace index with value
            out.write(new_line + '\n')

    pass

def load_alignment(align_path):
    alignments = {}
    with open(f"{align_path}/merged_alignment.ctm", 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) < 5:
                continue
            
            utt_id = parts[0]
            start_time = float(parts[2])
            duration = float(parts[3])
            
            phone = parts[4]
            if utt_id not in alignments:
                alignments[utt_id] = []
            alignments[utt_id].append((start_time, duration, phone))
    return alignments



def load_reference_alignment(align_path):
    alignment = []
    with open(align_path, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) < 5:
                continue
            
            utt_id = parts[0]
            start_time = float(parts[1])
            duration = float(parts[2])
            
            phone = parts[3]
            alignment.append((start_time, duration, phone))
    return alignment



def get_ctm_files(data_path):
    ctm_files = []
    for root, dirs, files in os.walk(data_path):
        for file in files:
            if file.endswith('.ctm'):
                ctm_files.append(os.path.join(root, file))
    return ctm_files


def equal_phone(phone1, phone2):
    """
    Check if two phones are equal, considering possible variations.
    """
    if phone1 == phone2 or (phone1 == 'pau' and phone2 == 'sil') or (phone1 == 'sil' and phone2 == 'pau'):
        return True
    # Add more conditions here if needed for specific phone variations
    return False



def compute_boundary_error(data_path, align_path):
    phone_mapping_to_ctm(align_path)
    alignments = load_alignment(align_path)
    
    ctm_files = get_ctm_files(data_path)
    
    for file in ctm_files:
        utt_id = os.path.basename(file).split('.')[0]
        if utt_id not in alignments:
            logging.error(f"Alignment for {utt_id} not found in {align_path}/merged_alignment.ctm")
            continue

        alignment = alignments[utt_id]
        reference_alignment = load_reference_alignment(file)

        # Use dynamic programming to align phones (edit distance with backtracking)

        n = len(alignment)
        m = len(reference_alignment)
        dp = np.zeros((n + 1, m + 1))
        backtrack = np.zeros((n + 1, m + 1), dtype=int)

        # Initialize DP table
        for i in range(n + 1):
            dp[i][0] = i
        for j in range(m + 1):
            dp[0][j] = j

        # Fill DP table
        for i in range(1, n + 1):
            for j in range(1, m + 1):
                if equal_phone(alignment[i - 1][2], reference_alignment[j - 1][2]):
                    cost = 0
                else:
                    cost = 1
                choices = [
                    (dp[i - 1][j] + 1, 1),      # deletion
                    (dp[i][j - 1] + 1, 2),      # insertion
                    (dp[i - 1][j - 1] + cost, 3) # substitution/match
                ]
                dp[i][j], backtrack[i][j] = min(choices, key=lambda x: x[0])

        # Backtrack to get alignment
        i, j = n, m
        aligned = []
        while i > 0 or j > 0:
            if i > 0 and j > 0 and backtrack[i][j] == 3:
                aligned.append((alignment[i - 1], reference_alignment[j - 1]))
                i -= 1
                j -= 1
            elif i > 0 and (j == 0 or backtrack[i][j] == 1):
                aligned.append((alignment[i - 1], None))
                i -= 1
            else:
                aligned.append((None, reference_alignment[j - 1]))
                j -= 1
        aligned.reverse()

        # Compute boundary errors for matched phones
        for align_item, ref_item in aligned:
            if align_item is not None and ref_item is not None:
                start_time, duration, phone = align_item
                ref_start, ref_duration, ref_phone = ref_item
                if phone == ref_phone:
                    start_error = abs(start_time - ref_start)
                    end_error = abs((start_time + duration) - (ref_start + ref_duration))
                    print(f"Boundary error for {utt_id}: Phone: {phone}, Start Error: {start_error}, End Error: {end_error}")
                else:
                    logging.error(f"Phone mismatch for {utt_id}: {phone} vs {ref_phone}")
            # Optionally, handle insertions/deletions if needed
   
   
    # print(f"Found {len(ctm_files)} CTM files in {data_path}")
    print(ctm_files[0])
    pass



def main():
    parser = argparse.ArgumentParser(description="Compute boundary error between audio and alignment.")
    parser.add_argument("data_path", type=str, help="Path to the data folder.")
    parser.add_argument("align_path", type=str, help="Path to the alignment folder.")
    args = parser.parse_args()

    try:
        compute_boundary_error(args.data_path, args.align_path)
    except Exception as error:
        logging.error(str(error))

if __name__ == "__main__":
    main()
