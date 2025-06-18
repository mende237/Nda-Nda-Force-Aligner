import sys
import re
import argparse
import os
import logging
import string

# Configure the logging module
logging.basicConfig(filename='../../../logs/error.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(filename)s - Line %(lineno)d - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')



def generate_text_file(data_path, output_folder, nbr_speaker = None, lm_data_output_file = None) -> None:
    data = {}
    speaker_cmpt = 0
    translator = str.maketrans('', '', string.punctuation.replace("'", ""))

    
    for region in os.listdir(data_path):
        if nbr_speaker is not None and speaker_cmpt >= int(nbr_speaker):
            break
        speackers_path = os.path.join(data_path, region)
        for speaker in os.listdir(speackers_path):
            if nbr_speaker is not None and speaker_cmpt >= int(nbr_speaker):
                break
            files_path = os.path.join(speackers_path, speaker)
            for file in os.listdir(files_path):
                if file.endswith('.TXT'):
                    file_path = os.path.join(files_path, file)
                    with open(file_path, 'r') as f:
                        lines = f.readlines()
                        start, end, text = lines[0].strip().split(sep=None, maxsplit=2)
                        data[f"{region}_{speaker}_{file[:-4]}"] = {
                            'file_path': f"{file_path[:-4]}.WAV",
                            'text_file_name': file[:-4],
                            'speaker_id': f"{region}_{speaker}",
                            'text': text.translate(translator).strip().lower(),
                            'start': start.strip(),
                            'end': end.strip()
                        }
                        # print(lines[0].strip().translate(translator).split(sep=None, maxsplit=2)[2].strip().lower())
            speaker_cmpt += 1
    
    # print(data[key])
    with open(os.path.join(output_folder, 'text'), 'w') as text_file:
        for utterance_id in data:
            text_file.write(f"{utterance_id} {data[utterance_id]['text']}\n")
        
    with open(os.path.join(output_folder, 'segment'), 'w') as segment_file:
        for utterance_id in data:
            segment_file.write(f"{utterance_id} {utterance_id} {data[utterance_id]['start']} {data[utterance_id]['end']}\n")
        
    with open(os.path.join(output_folder, 'wav.scp'), 'w') as wav_scp_file:
        for utterance_id in data:
            wav_scp_file.write(f"{utterance_id} {data[utterance_id]['file_path']}\n")
        
    with open(os.path.join(output_folder, 'utt2spk'), 'w') as utt2spk_file:
        for utterance_id in data:
            utt2spk_file.write(f"{utterance_id} {data[utterance_id]['speaker_id']}\n")
    
    is_sa1_file_added = False
    is_sa2_file_added = False
            
    if lm_data_output_file:
        with open(lm_data_output_file, 'w') as file:
            for utterance_id in data:
                if not is_sa1_file_added and data[utterance_id]['text_file_name'] == 'SA1':
                    file.write(f"{data[utterance_id]['text']}\n")
                    is_sa1_file_added = True
                elif not is_sa2_file_added and data[utterance_id]['text_file_name'] == 'SA2':
                    file.write(f"{data[utterance_id]['text']}\n")
                    is_sa2_file_added = True
                elif data[utterance_id]['text_file_name'] != 'SA1' and data[utterance_id]['text_file_name'] != 'SA2':
                    file.write(f"{data[utterance_id]['text']}\n")
            
try:
    parser = argparse.ArgumentParser()
    parser.add_argument('data_root_folder', help='the root data path')
    parser.add_argument('output_folder', help='output folder file which contains text, segment, wav.scp, utt2spk files')

    parser.add_argument('--test', action="store_true", help='put this option if you want to load that for testing')
    parser.add_argument('--lm', help='the path to the file containing the language model training data')
    parser.add_argument('--nbr-speaker', help='indicates the number of speakers for which the data should be loaded')

    args = parser.parse_args()



    data_path = None
    output_folder=None
    if args.test :
        data_path = f"{args.data_root_folder}/TEST"
        output_folder=f"{args.output_folder}/test"
    else:
        data_path = f"{args.data_root_folder}/TRAIN"
        output_folder=f"{args.output_folder}/train"

    generate_text_file(data_path, output_folder, nbr_speaker = args.nbr_speaker, lm_data_output_file = args.lm)
except Exception as error:
    logging.error(str(error))
    sys.exit(1)
    pass


