from Utils.Utils import loadTransition

hmmList = loadTransition("transitions.txt")


for hmm in hmmList:
    print(hmm)