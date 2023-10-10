import sys
import re

def generate_utterance_to_speaker_file(input_file_path, output_file_path):
    output_file_stream = open(output_file_path, 'w')
    with open(input_file_path, 'r') as file:      
        for line in file:
            line = line.strip()
            utterance_id, _ = line.split(":")
            prefix, loc_id, _, _ = utterance_id.split('_') 
        
            output_file_stream.write(f"{utterance_id.strip()} {prefix}_{loc_id}\n")

    output_file_stream.close()


# Check if the input and output file paths are provided
if len(sys.argv) != 3:
    print("Usage: python script.py <text_file_path> <output_folder_stream>")
else:
    input_file_path = sys.argv[1]
    output_file_path = f"{sys.argv[2]}/utt2spk"
    generate_utterance_to_speaker_file(input_file_path, output_file_path)