import argparse
import re
from collections import defaultdict

# Function to count word occurrences in a file while ignoring specific words
def count_word_occurrences(file_path):
    word_count = defaultdict(int)
    ignore_pattern = re.compile(r'enonce_\d+|#abscent|#except|locuteur_\d+')

    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            # Split the line into words, ignoring punctuation
            words = re.findall(r'\S+', line)
            for word in words:
                cleaned_word = word.strip().lower().strip(".,\"!?;:")
                # Ignore specific words
                if ignore_pattern.search(cleaned_word):
                    continue
                if cleaned_word:  # Only count non-empty words
                    word_count[cleaned_word] += 1
    
    return word_count

# Main function to handle command-line arguments
def main():
    parser = argparse.ArgumentParser(description='Count occurrences of words in a file while ignoring specific words.')
    parser.add_argument('file_path', type=str, help='Path to the input file.')
    
    args = parser.parse_args()
    
    # Count word occurrences
    occurrences = count_word_occurrences(args.file_path)
    
    # Print the occurrences
    for word, count in occurrences.items():
        print(f'{word}: {count}')

if __name__ == "__main__":
    main()