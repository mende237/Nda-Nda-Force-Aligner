import argparse

# Function to extract triphones from a file
def extract_triphones_from_file(file_path):
    triphone_dict = {}
    
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            # Strip whitespace and split the line into parts
            parts = line.strip().split()
            if len(parts) < 2:
                continue
            
            # Ignore "SIL" and "oov"
            word = parts[0]
            if word in {"!SIL", "oov"}:
                continue
            
            phonemes = parts[1:]
            
            # Generate triphones
            for i in range(len(phonemes) - 2):
                triphone = (phonemes[i], phonemes[i + 1], phonemes[i + 2])
                if word not in triphone_dict:
                    triphone_dict[word] = []
                triphone_dict[word].append(triphone)
    
    return triphone_dict

def main():
    parser = argparse.ArgumentParser(description='Extract triphones from a file.')
    parser.add_argument('file_path', type=str, help='Path to the input file')
    args = parser.parse_args()

    # Extract triphones
    triphones = extract_triphones_from_file(args.file_path)

    # Print the extracted triphones
    for word, triphone_list in triphones.items():
        print(f"{word}: {triphone_list}")

if __name__ == "__main__":
    main()