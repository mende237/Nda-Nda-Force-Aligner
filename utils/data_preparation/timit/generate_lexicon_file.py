import logging
import argparse
import sys

# Configure the logging module
logging.basicConfig(filename='../../../logs/error.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(filename)s - Line %(lineno)d - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')


def generate_lexicon(input_path, output_folder, word_list_lm_output_file = None):
    lexicon_file_path = f"{output_folder}/lang/lexicon.txt"
    
    if word_list_lm_output_file is not None:
        word_list_file = open(word_list_lm_output_file, 'w', encoding='utf-8')

    with open(input_path, 'r', encoding='utf-8') as infile, \
         open(lexicon_file_path, 'w', encoding='utf-8') as outfile:
        outfile.write("!SIL sil\noov spn\n")
        for line in infile:
            line = line.strip()
            if not line or line.startswith(';'):
                continue  # Skip comments and empty lines
            if '/' in line:
                # Extract word and phoneme sequence
                word, phones, _ = line.split('/')
                
                if not word or not phones:
                    continue
                
                phones = phones.strip()
                word = word.strip()
                outfile.write(f"{word} {phones}\n")
                if word_list_file is not None:
                    word_list_file.write(f"{word}\n")
                
                
    if word_list_file is not None:
        word_list_file.close()

try:
    parser = argparse.ArgumentParser()
    parser.add_argument('data_root_folder', help='the root data path')
    parser.add_argument('output_folder', help='output folder file which contains lexicon')
    
    parser.add_argument('--lm', help='the path to the file containing the language model training data')
    
    args = parser.parse_args()

    input_path = f"{args.data_root_folder}/DOC/TIMITDIC.TXT"
    

    generate_lexicon(input_path, args.output_folder, word_list_lm_output_file = args.lm)
except Exception as error:
    logging.error(str(error))
    sys.exit(1)
    pass
