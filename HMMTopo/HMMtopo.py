# from State import PhoneState
import numpy as np
from numpy import ndarray

class HMMtopo:
    __transMat : ndarray = None
    __pdfIndex : ndarray = None

    def __init__(self , phoneName:str,  nbrStates:int):
        self.__phoneName = phoneName
        self.__nbrStates = nbrStates
        self.__transMat = np.zeros((self.__nbrStates , self.__nbrStates))
        self.__pdfIndex = np.zeros((self.__nbrStates - 1 , 1))

    def setTransition(self, fromState:int, toState:int, transProb:float):
        self.__transMat[fromState][toState] = transProb


    def getTransition(self, fromState:int , toState:int) -> float:
        if fromState >= self.__nbrStates or toState >= self.__nbrStates:
            print("""invalid index fromState or toState index is 
            greater or equal the number of HMM's states. They must be 
            lower than number of state""")
            exit(1)
        elif fromState < 0 or toState < 0:
            print("""invalid index fromState or toState index is 
            lower than zero. They must be greater than zero""")
            exit(1)
        return self.__transMat[fromState][toState]
    
    def __str__(self) -> str:
        chaine = "phone name " + f"{self.__phoneName}\n"

        # print(f"phone name {self.__phoneName}")
        for i in range(self.__nbrStates):
            for j in range(self.__nbrStates):
                chaine += f"{i} -> {j}: {self.__transMat[i][j]}\n"
                # print(f"{i} -> {j}: {self.__transMat[i][j]}")
        return chaine
    

    # def addState(self, phoneState:PhoneState):
    #     if(len(self.stateList) <= self.nbrStates):
    #         self.stateList.append(phoneState)