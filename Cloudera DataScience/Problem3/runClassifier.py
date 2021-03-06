import sys
import numpy as np
#import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
#from sklearn.linear_model import LogisticRegression
from sklearn.metrics import precision_recall_fscore_support
import csv
import pickle
from sklearn.naive_bayes import GaussianNB
#from sklearn import svm
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.datasets import make_hastie_10_2



def load_medicare_data(path):
    f = open(path)
    lines = f.readlines()
    f.close()
    
    examples = []
    
    for l in lines:
        spt = l.split(',')
        if '?' not in spt:
            examples.append(spt)
        
    return np.array(examples, dtype = 'float_')


def read_classifier(classifier):
    filename = classifier+".pkl"
    f = open(filename, 'rb')
    estimator = pickle.load( f)
    f.close()
    return estimator


def classify_actual_data(estimator):

    X = load_medicare_data('TEST_DATA')
    X_test = X[0:][0:]
    print np.shape(X_test)
     
    X_test = np.delete(X_test,(0), axis=1)    
    print np.shape(X_test)
    
    y_pred = estimator.predict(X_test)
#    y_pred_log_prob = estimator.predict_log_proba(X_test)
    y_pred_prob =  estimator.predict_proba(X_test)
    write_output(X,  y_pred_prob, y_pred) 




def write_output(X, y_pred_prob, y_pred):
 
#    for i in range(1, len(y_pred)):
#        print X[i][0], y_pred_prob[i], y_pred[i]
     f=open('/x/home/hduser/ds/data/RF_train/'+classifier+'_prediction.out','w');
     for i in range(1, len(y_pred)):
        str=`X[i][0]`+','+','+`y_pred_prob[i,1]`+','+ `y_pred[i]`+'\n'
        f.write(str)
     f.close()



if __name__ == '__main__':



# svm and gbc shall not be included since they do not have predict_prob methods. But it shall be used later.
#   classifier_set = ['rf', 'sgd', 'nb', 'svm', 'gbc']

   classifier = 'nb' 
   estimator =  read_classifier(classifier) 

   classify_actual_data(estimator)
    #the following important_Features_method exists only for random forests . Hence commenting it out.
    #   print_important_features(estimator)

   

