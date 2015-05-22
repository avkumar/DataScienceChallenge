import numpy as np

def fileToDicts(file, ProcToCost):
    with open(file) as f:
        header = f.readline()
        for line in f:
            listOfEntries = line.split(',')
            key = listOfEntries[0]
            val = float(listOfEntries[len(listOfEntries) - 2])
            if not ProcToCost.has_key(key):
               ProcToCost[key] = [] 
               ProcToCost[key].append(val)
            else:
               ProcToCost[key].append(val)
#        print ProcToCost 
    return ProcToCost



def calculateRelVarToProc(ProcToCost):   
    RelVarToProc = {} 
    for proc in ProcToCost:
#           print proc, np.var(ProcToCost[proc])/np.mean(ProcToCost[proc])
           RelVarToProc[ np.var(ProcToCost[proc])/np.mean(ProcToCost[proc])] = proc 
#    print RelVarToProc
    return RelVarToProc


if __name__ == "__main__":
    
    ProcToCost = {}
    ProcToCost = fileToDicts("../preProcessedData/Medicare_Provider_Charge_Inpatient_DRG100_FY2011.csv", ProcToCost)
    
    ProcToCost = fileToDicts("../preProcessedData/Medicare_Provider_Charge_Outpatient_APC30_CY2011_v2.csv", ProcToCost)
    
    RelVarToProc =  calculateRelVarToProc(ProcToCost)    
    i = 0
    for relVar in list(reversed(sorted(RelVarToProc.keys()))):
        if i < 3: 

            print RelVarToProc[relVar].split()[0] 
#           print  RelVarToProc[relVar], relVar 
            i = i + 1
#    print sorted(RelVarToProc, key=RelVarToProc.get(), reverse = 'True')
#        print RelVarToProc[key], key

