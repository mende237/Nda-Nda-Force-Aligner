import sys
import logging

# Configure the logging module
logging.basicConfig(filename='../../../logs/error.log', level=logging.ERROR,
                    format='%(asctime)s - %(levelname)s - %(filename)s - Line %(lineno)d - %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')

speaker2gender = {
    "loc_1" : "f",
    "loc_2" : "m",
    "loc_3" : "f",
    "loc_4" : "m",
    "loc_5" : "f",
    "loc_6" : "f",
    "loc_7" : "f",
    "loc_8" : "m",
    "loc_9" : "m",
    # "loc_10" : "",
}

def generate_speaker2gender(output_file):
    with open(output_file, 'w') as file:
        for key in speaker2gender:
            file.write(f"{key} {speaker2gender[key]}\n")

if len(sys.argv) != 2:
    print("Usage: python script.py <output_file_path>")
    sys.exit(1)
else:
    try:
        output_file = sys.argv[1]
        generate_speaker2gender(output_file + "/spk2gender")
    except Exception as error:
        logging.error(str(error))
        sys.exit(1)