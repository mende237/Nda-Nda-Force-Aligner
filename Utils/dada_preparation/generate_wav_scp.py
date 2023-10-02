import sys
import re

def generate_vaw_scp(input_file_path, output_file_path, data_root_path):
    output_file_stream = open(output_file_path, 'w')
    with open(input_file_path, 'r') as file:      
        for line in file:
            line = line.strip()
            utterance_id, _ = line.split(":")
            _, loc_id, _, enonce_index = utterance_id.split('_') 
            enonce_index = enonce_index.strip()
            audio_path = f"{data_root_path}/locuteur_{loc_id}/loc_{loc_id}_enonce_{enonce_index}/loc_{loc_id}_enonce_{enonce_index}.wav"

            output_file_stream.write(f"{utterance_id} : {audio_path}\n")

    output_file_stream.close()


# Check if the input and output file paths are provided
if len(sys.argv) != 4:
    print("Usage: python script.py <input_file_path> <output_file_stream> <data_root_path>")
else:
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]
    data_root_path = sys.argv[3]
    generate_vaw_scp(input_file_path, output_file_path + "/wav.scp", data_root_path)