import os
import sys
import shutil
from pydub import AudioSegment



def convert_stereo_to_mono(input_file, output_file):
    audio = AudioSegment.from_wav(input_file)
    mono_audio = audio.set_channels(1)
    mono_audio.export(output_file, format='wav')




directory = None

# Check if the directory argument is provided
if len(sys.argv) == 3:
    directory = sys.argv[1]
    nbr_speaker = int(sys.argv[2])
else:
    print("Usage: python script.py <data_folder_path_root> <total_speaker_number>")
    sys.exit(1)


os.makedirs(os.path.join(directory, "mono"), exist_ok=True)

mono_folder_path = os.path.join(directory, "mono")

# Check if the mono folder exists
if os.path.exists(mono_folder_path):
    shutil.rmtree(mono_folder_path)  # Delete the existing folder

os.makedirs(mono_folder_path)  # Create the new folder


for folder_name in os.listdir(directory):
    folder_path = os.path.join(directory, folder_name)
    if os.path.isdir(folder_path):  # Check if it's a subfolder
        parts = folder_name.split("_")
        if len(parts) == 2 and parts[0] == "locuteur" and parts[1].isdigit():
            speaker_index = int(parts[1])
            if speaker_index <= nbr_speaker:
                new_locuteur_folder_path = os.path.join(mono_folder_path, folder_name)
                os.makedirs(new_locuteur_folder_path)
                for folder_enonce_name in os.listdir(folder_path):
                    parts = folder_enonce_name.split("_")
                    if len(parts) == 4 and parts[0] == "loc" and parts[2].startswith("enonce"):
                        folder_path_enonce_name = os.path.join(folder_path, folder_enonce_name)
                        if os.path.isdir(folder_path_enonce_name): 
                            new_enonce_folder_path = os.path.join(new_locuteur_folder_path, folder_enonce_name)
                            os.makedirs(new_enonce_folder_path)
                            for audio_file_name in os.listdir(folder_path_enonce_name):
                                parts = audio_file_name.split("_")
                                if len(parts) == 4 and parts[0] == "loc" and parts[2].startswith("enonce"):
                                    old_audio_file_path = os.path.join(folder_path_enonce_name, audio_file_name)
                                    if os.path.isfile(old_audio_file_path):
                                        # print(audio_file_name)
                                        new_audio_file_path = os.path.join(new_enonce_folder_path, audio_file_name)
                                        convert_stereo_to_mono(old_audio_file_path, new_audio_file_path)
    else:
        if folder_name == "utterance.txt":
            shutil.copy(folder_path, mono_folder_path)
            