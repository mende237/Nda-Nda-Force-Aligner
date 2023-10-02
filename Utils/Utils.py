from HMMTopo.HMMtopo import HMMtopo
SIL = "sil"
OOV = "spn"

NBR_STATE = 4
NBR_QUESTIONS = 4


def getPdf(line:str, pdfIndex:int, length:int) -> int:
    return int(line[pdfIndex:length])

def getHMMState(line:str , hmmStateIndex:int, endIndex:int) -> int:
    return int(line[hmmStateIndex:endIndex])

def getPhoneName(line:str, phoneNameIndex:int, endIndex:int) -> str:
    return line[phoneNameIndex:endIndex]

def getRealPhoneName(phoneName:str) -> str:
    index = phoneName.find("_")
    if index == -1:
        return phoneName
    
    return phoneName[0:index]

def getPhoneSuffixe(phoneName:str) -> str:
    index = phoneName.find("_")
    return phoneName[index + 1:len(phoneName)]

def getProbabityValue(line:str, probabilityIndex:int) -> tuple[float , int , int]:
    index = line.find("[")
    probability = line[probabilityIndex:index - 1]
    if line.find("self-loop") != -1:
        return float(probability) , -1 , -1
    
    transition = line[index + 1:len(line) - 2]

    beginArrow = transition.find(" -> ")
    fromState = transition[0:beginArrow]
    toState = transition[beginArrow + len(" -> "):len(line)]

    # print(f"a{fromState}b  c{toState}d")
    # print(f"a{probability}b")
    return float(probability) , int(fromState) , int(toState) 


def averageHMM(hmm:HMMtopo):
    for i in range(NBR_STATE):
        for j in range(NBR_STATE):
            hmm.setTransition(i, j, hmm.getTransition(i, j)/NBR_QUESTIONS)


def loadTransition(filePath:str) -> list[HMMtopo]:
    with open(filePath, "r") as f:
        lines = f.readlines()

    firstEnter = True
    previousPhoneName = None
    previousRealPhoneName = None
    hmmList = []
    hmmState = None

    previousHMM = None
    for index, line in enumerate(lines):
        phoneNameIndex = line.find("phone = ")
        if phoneNameIndex != -1:
            hmmStateIndex = line.find("hmm-state = ")
            phoneName = getPhoneName(line, phoneNameIndex + len("phone = ") , hmmStateIndex-1)
            pdfIndex = line.find("pdf = ")
            hmmState = getHMMState(line, hmmStateIndex + len("hmm-state = "), pdfIndex - 1)
            pdf = getPdf(line, pdfIndex + len("pdf = "), len(line)-1)
            
            realPhoneName = getRealPhoneName(phoneName)
            if realPhoneName != SIL and realPhoneName != OOV:
                if firstEnter == True:
                    previousRealPhoneName = realPhoneName
                    previousHMM = HMMtopo(realPhoneName , NBR_STATE)
                    firstEnter = False
                
                if previousRealPhoneName != realPhoneName:
                    # previousPhoneName = phoneName
                    # print(f"previous {previousRealPhoneName} current {realPhoneName}")
                    previousRealPhoneName = realPhoneName
                    averageHMM(previousHMM)
                    hmmList.append(previousHMM)
                    previousHMM = HMMtopo(realPhoneName , NBR_STATE)

        probabilityIndex = line.find("p = ")
        if probabilityIndex != -1 and previousRealPhoneName != None and hmmState != None:
            prob , fromState , toState = getProbabityValue(line , probabilityIndex + len("p = "))

            if fromState >= 0 and toState >= 0:
                previousHMM.setTransition(fromState, toState , 
                                        previousHMM.getTransition(fromState, toState) + prob)
            else:
                previousHMM.setTransition(hmmState, hmmState , 
                                        previousHMM.getTransition(hmmState, hmmState) + prob)

        if index == len(lines) - 1:
            averageHMM(previousHMM)
            hmmList.append(previousHMM)
        
    return hmmList


# loadTransition("../transitions.txt")
# test = "mananpapatoto"
# print(test[0:len(test) - 1])
# print(test.find("m"))
