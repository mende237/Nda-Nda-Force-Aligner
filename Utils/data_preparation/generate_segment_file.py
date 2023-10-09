import sys
import re
from pydub import AudioSegment

def is_audio_file(file_path):
    audio_extensions = [".mp3", ".wav", ".ogg"]
    return any(file_path.lower().endswith(ext) for ext in audio_extensions)


def generate_vaw_scp(input_file_path, output_file_path):
    output_file_stream = open(output_file_path, 'w')
    with open(input_file_path, 'r') as file:      
        for line in file:
            line = line.strip()
            utterance_id, file_path = line.split(":")
            utterance_id = utterance_id.strip()
            file_path = file_path.strip()
            total_duration = 0
            if is_audio_file(file_path):
                audio = AudioSegment.from_file(file_path)
                total_duration = len(audio)
                total_duration = total_duration / 1000  # Conversion en secondes
                output_file_stream.write(f"{utterance_id} : 0.0 {total_duration}\n")
    # audio = AudioSegment.from_file("/home/dimitri/Documents/memoire/splitedData/locuteur_1/loc_1_enonce_1/loc_1_enonce_1.wav")
    # total_duration = len(audio)
    # total_duration = total_duration / 1000  # Conversion en secondes
    # output_file_stream.write(f"zez : {total_duration}\n")

    output_file_stream.close()


# Check if the input and output file paths are provided
if len(sys.argv) != 3:
    print("Usage: python script.py <wav.scp_file_path> <output_folder_path>")
else:
    input_file_path = sys.argv[1]
    output_file_path = f"{sys.argv[2]}/segments"
    generate_vaw_scp(input_file_path, output_file_path)


# echo "segme