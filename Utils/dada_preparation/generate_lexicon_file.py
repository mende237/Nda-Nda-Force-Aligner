import sys

def generate_lexicon_file(input_file, output_file):
    my_set_of_word = {}

    with open(input_file, 'r') as file:
        for line in file:
            _ , utterance = line.split(':')
            line = line.strip()
            for word in line.split(":"):
                my_set_of_word.add(word)


    with open(output_file, 'w') as file:
        for word in my_set_of_word:
            file.write(f"{word}\n")


# Check if the input and output file paths are provided
if len(sys.argv) != 3:
    print("Usage: python script.py <input_file_path> <output_file_path>")
else:
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    generate_lexicon_file(input_file, output_file + "/text")