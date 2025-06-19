import sys
import re
from pydub import AudioSegment
import logging

# Configure the logging module
logging.basicConfig(filename='../../../logs/error.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(filename)s - Line %(lineno)d - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

def is_audio_file(file_path):
    audio_extensions = [".mp3", ".wav", ".ogg"]
    return any(file_path.lower().endswith(ext) for ext in audio_extensions)


def generate_segment_file(input_file_path, output_file_path):
    with open(output_file_path, 'w') as output_file_stream:
        with open(input_file_path, 'r') as file:      
            for line in file:
                line = line.strip()
                file_id, file_path = line.split(" ")
                file_id = file_id.strip()
                file_path = file_path.strip()
                total_duration = 0
                if is_audio_file(file_path):
                    audio = AudioSegment.from_file(file_path)
                    total_duration = len(audio)
                    total_duration = total_duration / 1000  # Conversion en secondes
                    # print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                    output_file_stream.write(f"{file_id[:-2]} {file_id} 0.0 {total_duration}\n")



# Check if the input and output file paths are provided
if len(sys.argv) != 3:
    print("Usage: python script.py <wav.scp_file_path> <output_folder_path>")
    sys.exit(1)
else:
    try:
        input_file_path = sys.argv[1]
        output_file_path = f"{sys.argv[2]}"
        generate_segment_file(input_file_path, output_file_path)
    except Exception as error:
        logging.error(str(error))
        sys.exit(1)
