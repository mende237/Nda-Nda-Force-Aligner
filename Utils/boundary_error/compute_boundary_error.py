import argparse
import logging

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

def compute_boundary_error(data_path, align_path, tier_name=None, tier_index=None):
    phone_mapping_to_ctm(align_path)
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
