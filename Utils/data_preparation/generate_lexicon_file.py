import sys
import unicodedata


def merge_characters(characters:list[str], index:int) -> list[str]:
    result:list[str] = []
    cmpt = None
    t = False
    for i in range(len(characters)):
        if i < index:
            result.append(characters[i])
        elif i == index:
            temp = f"{characters[index]}{characters[index+1]}"
            result.append(temp)
            if characters[index+1] == '’':
                # print("***********************************")
                # print(result)
                t = True
            cmpt = i
            break
    
    for i in range(cmpt + 2, len(characters)):
        result.append(characters[i])

    if t:
        print(result)
    return result


def can_merge(previous_char:str, current_char:str) -> bool:
    # if current_char == '’':
    #     print("*****************************************")
        
    if ((previous_char == 'g' and current_char == 'h') 
        or (previous_char == 's' and current_char == 'h')
        or (previous_char == 'n' and current_char == 'y') 
        or (previous_char == 'z' and current_char == 'h') 
        or current_char == '\''):
        return True
    
    return False


def decompose(string:str) -> list[str]:
    characters = []
    previous_char = None
    for char in string:
        if unicodedata.combining(char):
            characters[-1] += char
        else:
            characters.append(char)
    i = 0 
    while i < len(characters)-1:
        if can_merge(characters[i], characters[i+1]):
            characters = merge_characters(characters, i)
            i = i - 1
        i = i + 1

    return characters


def generate_lexicon_file(input_file, output_file) -> None:
    my_set_of_word = set()

    with open(input_file, 'r') as file:
        for line in file:
            _ , utterance = line.split(' ', 1)
            line = line.strip()
            for word in utterance.split():
                my_set_of_word.add(word)


    with open(output_file, 'w') as file:
        file.write("!SIL sil\noov spn\n")
        for word in my_set_of_word:
            temp = ""
            for char in decompose(word):
                temp = temp + char + " "
            temp = temp.strip()
            file.write(f"{word} {temp}\n")


# Check if the input and output file paths are provided
if len(sys.argv) != 3:
    print("Usage: python script.py <input_file_path> <output_folder_path>")
else:
    input_file = sys.argv[1]
    output_file = f"{sys.argv[2]}/lexicon.txt"
    generate_lexicon_file(input_file, output_file)