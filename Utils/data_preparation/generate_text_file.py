import sys
import re
import argparse
import os
import logging

# Configure the logging module
logging.basicConfig(filename='../../logs/error.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(filename)s - Line %(lineno)d - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')



def generate_text_file(input_file, text_output_file, speaker_list, nbr_locuteur = None, lm_data_output_file = None) -> None:
    data = {}
    all_data = []
    for speaker in speaker_list:
         data[speaker] = {}

    with open(input_file, 'r') as file:      
        except_area = False
        abscent_area = False
        loc_number = None
        for line in file:
            line = line.strip()
            # print(line)
            if not line.startswith("#EXCEPT") and not line.startswith("#ABSCENT"):
                if line.startswith("enonce_"):
                    if not except_area and not abscent_area:
                        ID, utterance = line.split(':')
                        for speaker in speaker_list:
                            data[speaker][ID.strip()] = utterance.strip().lower()
                        all_data.append(utterance.strip().lower())
                    elif except_area:
                        ID, utterance = line.split(':')
                        if loc_number != None and f"locuteur_{loc_number}" in speaker_list:
                            data[f"locuteur_{loc_number}"][ID.strip()] = utterance.strip().lower()

                        if loc_number != None:
                            all_data.append(utterance.strip().lower())
                    else:
                        if loc_number != None and f"locuteur_{loc_number}" in speaker_list:
                            data[f"locuteur_{loc_number}"][line] = None
                        
            elif line.startswith("#EXCEPT"):
                except_area = True
                abscent_area = False
                loc_number = int(re.search(r'\d+', line).group())
            else:
                abscent_area = True
                except_area = False
                loc_number = int(re.search(r'\d+', line).group())

    with open(text_output_file, 'w') as file:
        for speaker in speaker_list:
            for key in data[speaker]:
                if data[speaker][key] != None:
                    file.write(f"loc_{speaker.split('_')[1]}_{key} {data[speaker][key]}\n")

    if lm_data_output_file:
        with open(lm_data_output_file, 'w') as file:
            for i in range(len(all_data)):
                file.write(f"{all_data[i]}\n")
            
try:
    parser = argparse.ArgumentParser()
    parser.add_argument('data_root_folder', help='the root data path')
    parser.add_argument('output_text_file', help='output text file which contains the list of statements made by each speaker')

    parser.add_argument('--test', action="store_true", help='put this option if you want to load that for testing')
    parser.add_argument('--lm', help='the path to the file containing the language model training data')
    parser.add_argument('--nbr-speaker', help='indicates the number of speakers for which the data should be loaded')

    args = parser.parse_args()



    data_path = None
    if args.test :
        data_path = f"{args.data_root_folder}/test"
    else:
        data_path = f"{args.data_root_folder}/train"


    speaker_list = [name for name in os.listdir(data_path) if os.path.isdir(os.path.join(data_path, name)) and re.match(r'locuteur_\d+', name)]


    input_file = f"{args.data_root_folder}/utterance.txt"

    generate_text_file(input_file, args.output_text_file, speaker_list, nbr_locuteur = args.nbr_speaker, lm_data_output_file = args.lm)
except Exception as error:
    logging.error(str(error))
    sys.exit(1)
    pass


