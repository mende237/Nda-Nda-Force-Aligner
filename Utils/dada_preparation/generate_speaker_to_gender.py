import sys

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
else:
    output_file = sys.argv[1]
    generate_speaker2gender(output_file + "/spk2gender")