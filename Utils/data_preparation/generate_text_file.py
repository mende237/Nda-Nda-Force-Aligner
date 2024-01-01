import sys
import re

def generate_text_file(input_file, text_output_file, lm_data_output_file, nbr_locuteur):
    data = []
    for _ in range(nbr_locuteur):
        data.append({})

    with open(input_file, 'r') as file:      
        except_area = False
        abscent_area = False
        loc_number = None
        for line in file:
            line = line.strip()
            # print(line)
            if not line.startswith("#EXCEPT") and not line.startswith("#ABSCENT"):
                if line.startswith("enonce_"):
                    if not except_area and not abscent_area:
                        ID , utterance = line.split(':')
                        for i in range(nbr_locuteur):
                            data[i][ID.strip()] = utterance.strip().lower()
                    elif except_area:
                        ID , utterance = line.split(':')
                        if loc_number < nbr_locuteur and loc_number != None:
                            data[loc_number][ID.strip()] = utterance.strip().lower()
                    else:
                        data[loc_number][line.strip()] = None
                        
            elif line.startswith("#EXCEPT"):
                except_area = True
                loc_number = int(re.search(r'\d+', line).group()) - 1
            else:
                abscent_area = True
                except_area = False
                loc_number = int(re.search(r'\d+', line).group()) - 1

    with open(text_output_file, 'w') as file:
        for i in range(nbr_locuteur):
            for key in data[i]:
                if data[i][key] != None:
                    file.write(f"loc_{i+1}_{key} {data[i][key]}\n")

    with open(lm_data_output_file, 'w') as file:
        for i in range(nbr_locuteur):
            for key in data[i]:
                if data[i][key] != None:
                    file.write(f"{data[i][key]}\n")


if len(sys.argv) != 5:
    print("Usage: python script.py <root_data_path> <text_output_file> <lm_data_output_file> <nbr_locuteur>")
    sys.exit(1)
else:
    input_file = f"{sys.argv[1]}/utterance.txt"
    text_output_file = sys.argv[2]
    lm_data_output_file = sys.argv[3]
    nbr_loc = int(sys.argv[4])
    try:
        generate_text_file(input_file, text_output_file, lm_data_output_file, nbr_loc)
    except:
        sys.exit(1)