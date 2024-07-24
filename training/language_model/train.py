import subprocess
import kenlm


kenlm_model_path = 'model.arpa'
order = 3  # Set the desired order of the language model

# Load the trained model
kenlm_model = kenlm.Model(kenlm_model_path)

# Score a sentence
sentence = 'the desired order of the language model'
score = kenlm_model.score(sentence)
print(score)