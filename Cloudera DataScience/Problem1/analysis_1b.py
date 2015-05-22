import operator

def fileToDicts(file, ProcToAvgCost):
    with open(file) as f:
        header = f.readline()
        for line in f:
            listOfEntries = line.split(',')
            key = listOfEntries[0]
            val = float(listOfEntries[len(listOfEntries) - 2])
    #        print key, val, listOfEntries[1]
            if not ProcToAvgCost.has_key(key):
               ProcToAvgCost[key] = {}
               ProcToAvgCost[key][val] = int(listOfEntries[1])
            else:
               ProcToAvgCost[key][val] = int(listOfEntries[1])
#        print ProcToAvgCost 
    return ProcToAvgCost



def numProcForProviders(ProcToAvgCost):   
#    print len(ProcToAvgCost)   
    for proc in ProcToAvgCost:
#        print ProcToAvgCost[proc]
        cost = max(ProcToAvgCost[proc])
#        print cost
        if not ProvidersToNumProcWithMaxCost.has_key(ProcToAvgCost[proc][cost]):
            ProvidersToNumProcWithMaxCost[ProcToAvgCost[proc][cost]] = 1    
        else:
            ProvidersToNumProcWithMaxCost[ProcToAvgCost[proc][cost]] += 1

#    print ProvidersToNumProcWithMaxCost       
    return ProvidersToNumProcWithMaxCost

if __name__ == "__main__":
    
    ProcToAvgCost = {}
    ProvidersToNumProcWithMaxCost = {}
    ProcToAvgCost = fileToDicts("../preProcessedData/Medicare_Provider_Charge_Inpatient_DRG100_FY2011.csv", ProcToAvgCost)
    
    ProcToAvgCost = fileToDicts("../preProcessedData/Medicare_Provider_Charge_Outpatient_APC30_CY2011_v2.csv", ProcToAvgCost)
    
   # print(numProcForProviders(ProcToAvgCost))
    numProcToProviders = numProcForProviders(ProcToAvgCost)
        
    sorted_numProcToProviders = sorted(numProcToProviders.iteritems(), key=operator.itemgetter(1))
    sorted_numProcToProviders.reverse()
#    print sorted_numProcToProviders
    i = 0
    for Provider, numProc in sorted_numProcToProviders:
        if i < 3:
            print Provider 
            i = i + 1
