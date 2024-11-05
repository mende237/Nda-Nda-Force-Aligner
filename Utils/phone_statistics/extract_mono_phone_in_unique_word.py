import argparse

# Function to extract monophones from a file
def extract_phone_from_file(file_path):
    monophone_dict = {}
    
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
            
            for i in range(len(phonemes)):
                if word not in monophone_dict:
                    monophone_dict[word] = []
                monophone_dict[word].append(phonemes[i])
    
    return monophone_dict

def main():
    parser = argparse.ArgumentParser(description='Extract monophone from a file.')
    parser.add_argument('file_path', type=str, help='Path to the input file')
    args = parser.parse_args()

    # Extract monophones
    mono_phone = extract_phone_from_file(args.file_path)

    # Print the extracted monophones
    for word, mono_phone_list in mono_phone.items():
        print(f"{word}: {mono_phone_list}")

if __name__ == "__main__":
    main()