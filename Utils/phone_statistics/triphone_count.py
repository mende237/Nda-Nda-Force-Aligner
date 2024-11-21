import sys 
import os
import argparse
import csv
import numpy as np
import matplotlib.pyplot as plt

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))) 

from extract_triphone_in_unique_word import extract_triphones_from_file
from word_count_occurence import count_word_occurrences

def save_to_csv(triphone_count_result, output_file):
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['Triphone', 'Count']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for triphone, count in triphone_count_result.items():
            triphone_str = '-'.join(triphone)
            writer.writerow({'Triphone': triphone_str, 'Count': count})



def draw_graph(triphone_count_result, output_image_file, top_n=40):
    # Sort triphones by count in descending order
    sorted_triphones = sorted(triphone_count_result.items(), key=lambda item: item[1], reverse=True)
    
    # Limit to top N triphones
    if len(sorted_triphones) > top_n:
        sorted_triphones = sorted_triphones[:top_n]
    
    triphones = ['-'.join(triphone) for triphone, count in sorted_triphones]
    counts = [count for triphone, count in sorted_triphones]

    # Calculate mean and median
    mean_count = np.mean(counts)
    median_count = np.median(counts)

    plt.figure(figsize=(15, 7))  # Increase figure size
    plt.bar(triphones, counts, color='#1f77b4')
    plt.axhline(y=mean_count, color='r', linestyle='-', label=f'Moyenne: {mean_count:.2f}')
    plt.axhline(y=median_count, color='g', linestyle='--', label=f'Médiane: {median_count:.2f}')
    plt.xlabel('Triphones')
    plt.ylabel('Fréquence')
    # plt.title(f"Distribution des {top_n} triphones les plus fréquents.")
    plt.xticks(rotation=90)
    plt.legend()
    plt.tight_layout()
    plt.savefig(output_image_file)
    plt.close()

def triphone_count(project_name, data_folder_root):
    word_count = count_word_occurrences(data_folder_root)
    triphone_dict = extract_triphones_from_file(project_name)
    
    triphone_count_result = {}
    
    for word, triphones in triphone_dict.items():
        count = word_count[word]
        for triphone in triphones:
            try:
                triphone_count_result[triphone] = triphone_count_result[triphone] + count
            except KeyError:
                triphone_count_result[triphone] = count
                
    
    counts = list(triphone_count_result.values())
    mean_count = np.mean(counts)
    median_count = np.median(counts)
    
    return triphone_count_result, mean_count, median_count

    
def main():
    parser = argparse.ArgumentParser(description="Process two file paths.")
    parser.add_argument("lexicon_file_path", help="Path to lexicon file")
    parser.add_argument("utterance_file_path", help="Path to utterance file")
    parser.add_argument("output_csv_file", help="Path to output CSV file")
    parser.add_argument("output_image_file", help="Path to output image file")

    args = parser.parse_args()

    triphone_count_result, mean_count, median_count = triphone_count(args.lexicon_file_path, args.utterance_file_path)
    
    save_to_csv(triphone_count_result, args.output_csv_file)
    draw_graph(triphone_count_result, args.output_image_file, top_n=40)
    
    print("Triphone statistics")
    print(f"mean count: {mean_count}\nmedian count: {median_count}")  
    # for triphone, count in triphone_count_result.items():
    #     print(f"{triphone} - {count}")

if __name__ == "__main__":
    main()