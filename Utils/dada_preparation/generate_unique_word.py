# import sys


# def generate_unique_word():
#     ref = dict()
#     phones = dict()

#     with open("../lexicon") as f:
#         for line in f:
#             line = line.strip()
#             columns = line.split(" ", 1)
#             word = columns[0]
#             pron = columns[1]
#             try:
#                 ref[word].append(pron)
#             except:
#                 ref[word] = list()
#                 ref[word].append(pron)


#     lex = open("data/local/lang/lexicon.txt", "wb")

#     with open("data/train/words.txt") as f:
#         for line in f:
#             line = line.strip()
#             if line in ref.keys():
#                 for pron in ref[line]:
#                     lex.write(line + " " + pron+"\n")
#             else:
#                 print("Word not in lexicon:" + line)



# if len(sys.argv) != 3:
#     print("Usage: python script.py <input_file_path> <output_file_path>")
# else:
#     input_file = sys.argv[1]
#     output_file = sys.argv[2]
#     generate_text_file(input_file, output_file + "/text")