import operator


def fileToDicts(file, ProcToClaimDiff):
    with open(file) as f:
        header = f.readline()
        for line in f:
            listOfEntries = line.split(',')
            key = listOfEntries[0]
            val = float(listOfEntries[len(listOfEntries) - 2]) - float(listOfEntries[len(listOfEntries) - 1])
    #        print key, val, listOfEntries[1]
            if not ProcToClaimDiff.has_key(key):
               ProcToClaimDiff[key] = {}
               ProcToClaimDiff[key][val] = int(listOfEntries[1])
            else:
               ProcToClaimDiff[key][val] = int(listOfEntries[1])
    return ProcToClaimDiff



def numProcForProviders(ProcToClaimDiff):   
#    print len(ProcToClaimDiff)   
    ProvidersToNumProcWithMaxCost = {}
    for proc in ProcToClaimDiff:
#        print proc, sorted(ProcToClaimDiff[proc])
        ClaimDiff = max(ProcToClaimDiff[proc])
#        print ClaimDiff
        if not ProvidersToNumProcWithMaxCost.has_key(ProcToClaimDiff[proc][ClaimDiff]):
            ProvidersToNumProcWithMaxCost[ProcToClaimDiff[proc][ClaimDiff]] = 1    
        else:
            ProvidersToNumProcWithMaxCost[ProcToClaimDiff[proc][ClaimDiff]] += 1
#    print ProvidersToNumProcWithMaxCost       
    return ProvidersToNumProcWithMaxCost



if __name__ == "__main__":
    
    ProcToClaimDiff = {}
    ProcToClaimDiff = fileToDicts("../preProcessedData/Medicare_Provider_Charge_Inpatient_DRG100_FY2011.csv", ProcToClaimDiff)
    
    ProcToClaimDiff = fileToDicts("../preProcessedData/Medicare_Provider_Charge_Outpatient_APC30_CY2011_v2.csv", ProcToClaimDiff)
    
 #   print(numProcForProviders(ProcToClaimDiff))
    numProcToProviders = numProcForProviders(ProcToClaimDiff)
        
    sorted_numProcToProviders = sorted(numProcToProviders.iteritems(), key=operator.itemgetter(1))
    sorted_numProcToProviders.reverse()
#    print sorted_numProcToProviders
    i = 0
    for Provider, numProc in sorted_numProcToProviders:
        if i < 3:
            print Provider 
            i = i + 1    
