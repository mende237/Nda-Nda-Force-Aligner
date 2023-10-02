import sys
import re

def generate_text_file(input_file, output_file, nbr_locuteur):
    data = []
    for _ in range(nbr_locuteur):
        data.append({})

    with open(input_file, 'r') as file:      
        except_erea = False
        loc_number = None
        for line in file:
            line = line.strip()
            # print(line)
            if not line.startswith("#EXCEPT"):
                if line.startswith("enonce_"):
                    ID , utterance = line.split(':')
                    if not except_erea:
                        for i in range(nbr_locuteur):
                            data[i][ID.strip()] = utterance.strip()
                    else:
                        if loc_number < nbr_locuteur and loc_number != None:
                            data[loc_number][ID.strip()] = utterance.strip()
            else:
                except_erea = True
                loc_number = int(re.search(r'\d+', line).group()) - 1


    with open(output_file, 'w') as file:
        for i in range(nbr_locuteur):
            for key in data[i]:
                file.write(f"loc_{i+1}_{key} : {data[i][key]}\n")


# Check if the input and output file paths are provided
if len(sys.argv) != 4:
    print("Usage: python script.py <input_file_path> <output_file_path> <nbr_locuteur>")
else:
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    nbr_loc = int(sys.argv[3])
    generate_text_file(input_file, output_file + "/text" , nbr_loc)