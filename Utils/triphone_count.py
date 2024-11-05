import argparse
from extract_triphone_in_unique_word import extract_triphones_from_file
from word_count_occurence import count_word_occurrences


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
    
    return triphone_count_result

    
def main():
    parser = argparse.ArgumentParser(description="Process two file paths.")
    parser.add_argument("lexicon_file_path", help="Path to lexicon file")
    parser.add_argument("utterance_file_path", help="Path to utterance file")

    args = parser.parse_args()

    triphone_count_result = triphone_count(args.lexicon_file_path, args.utterance_file_path)

    for triphone, count in triphone_count_result.items():
        print(f"{triphone} - {count}")

if __name__ == "__main__":
    main()