import sys 
import os
import argparse
import csv
from collections import defaultdict
import matplotlib.pyplot as plt
import numpy as np

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))) 

from extract_mono_phone_in_unique_word import extract_phone_from_file
from word_count_occurence import count_word_occurrences


def save_to_csv(phone_count_result, output_file):
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['Phone', 'Count']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for phone, count in phone_count_result.items():
            writer.writerow({'Phone': phone, 'Count': count})
            
def draw_graph(phone_count_result, output_image_file):
    # Sort phones by count in descending order
    sorted_phones = sorted(phone_count_result.items(), key=lambda item: item[1], reverse=True)
    
    phones = [phone for phone, count in sorted_phones]
    counts = [count for phone, count in sorted_phones]

    # Calculate mean and median
    mean_count = np.mean(counts)
    median_count = np.median(counts)

    plt.figure(figsize=(10, 5))
    plt.bar(phones, counts, color='#1f77b4')
    plt.axhline(y=mean_count, color='r', linestyle='-', label=f'Moyenne: {mean_count:.2f}')
    plt.axhline(y=median_count, color='g', linestyle='--', label=f'Médiane: {median_count:.2f}')
    plt.xlabel('Phones')
    plt.ylabel('Fréquence')
    plt.title('Répartition de la fréquence de chaque monophone')
    plt.xticks(rotation=90)
    plt.legend()
    plt.tight_layout()
    plt.savefig(output_image_file)
    plt.close()

def monophone_count(project_name, data_folder_root):
    word_count = count_word_occurrences(data_folder_root)
    phone_dict = extract_phone_from_file(project_name)
    
    phone_count_result = defaultdict(int)
    
    for word, phones in phone_dict.items():
        count = word_count[word]
        for phone in phones:
            try:
                phone_count_result[phone] = phone_count_result[phone] + count
            except KeyError:
                phone_count_result[phone] = count
    
    return phone_count_result

    
def main():
    parser = argparse.ArgumentParser(description="Process two file paths.")
    parser.add_argument("lexicon_file_path", help="Path to lexicon file")
    parser.add_argument("utterance_file_path", help="Path to utterance file")
    parser.add_argument("output_csv_file", help="Path to output CSV file")
    parser.add_argument("output_image_file", help="Path to output image file")

    
    args = parser.parse_args()

    phone_count_result = monophone_count(args.lexicon_file_path, args.utterance_file_path)
    save_to_csv(phone_count_result, args.output_csv_file)
    draw_graph(phone_count_result, args.output_image_file)

if __name__ == "__main__":
    main()