#Classify_Ensemble - Classification Model which combines the existing classification models and outputs the best of them
# More classification models can be added
# These existing models are combined into one single model with the following flags
# Author:  Arava Sai Kumar (sai@scalend.com)





import glob
import sys
import numpy as np
import matplotlib.pyplot as plt
import csv
import pickle
from sklearn.naive_bayes import GaussianNB

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import precision_recall_fscore_support
import csv
import pickle
from sklearn.naive_bayes import GaussianNB
from sklearn import svm
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.datasets import make_hastie_10_2

labels = pd.read_csv('data/TrainLabels.csv')
submission = pd.read_csv('data/SampleSubmission.csv')


def get_clf(classifier):      
    clf_dict = dict()
    clf_dict['rf']  = RandomForestClassifier(n_jobs = -1, random_state=42)
    clf_dict['sgd'] = LogisticRegression(penalty='l2', dual=False, tol=0.0001, C=1.0, fit_intercept=True, intercept_scaling=1, class_weight=None, random_state=None)
    clf_dict['nb']  = GaussianNB()
    clf_dict['svm'] = svm.SVC(C=1.0, cache_size=200, class_weight=None, coef0=0.0, degree=3, gamma=0.0, kernel='rbf', max_iter=-1, probability=False, shrinking=True, tol=0.001, verbose=False)
    clf_dict['gbc'] = GradientBoostingClassifier(learning_rate=1.0, max_depth=1, random_state=0) 
    
    return clf_dict[classifier] 

def write_classifier(clf, classifier):
    filename = classifier+".pkl"
    output = open(filename, 'wb')
    pickle.dump(clf, output)
    output.close()

def read_classifier(classifier):
    filename = classifier+".pkl"
    f = open(filename, 'rb')
    clf = pickle.load( f)
    f.close()
    return clf

'''
def classify_test_data(clf):

    X,y = load_medicare_data('test_data')
    X_test = X[0:][0:]
    y_test = y[0:][0:]
    print np.shape(X_test), np.shape(y_test)

    X_test = np.delete(X_test,(0), axis=1)
    print "Loaded ", len(y), " examples"
    print np.shape(X_test), np.shape(y_test)

    y_pred = clf.predict(X_test)
    y_pred_log_prob = clf.predict_log_proba(X_test)
    y_pred_prob =  clf.predict_proba(X_test)
    precision, recall, f1_score, _ = precision_recall_fscore_support(y_test, y_pred)
#   reg_f1_scores.append(f1_score[1])
    print "F1 score: ", f1_score[1]
    print "Precision: ", precision[1]
    print "Recall: ", recall[1]
    print
    write_output(X, y_pred_log_prob, y_pred_prob, y_pred, y_test)
'''

def read_data():
    path = 'data/train/*'
    files = glob.glob(path)
    for i, filename in enumerate(files):
        print i, filename
        df = pd.read_csv(filename)
        df = df[df.FeedBackEvent != 0]
        df = df.drop('FeedBackEvent', axis = 1)
        if i == 0:
            train = np.array(df)
        else:
            train = np.vstack((train, np.array(df)))

    path = 'data/test/*'
    files = glob.glob(path)
    for i, filename in enumerate(files):
        print i, filename
        df = pd.read_csv(filename)
        df = df[df.FeedBackEvent != 0]
        df = df.drop('FeedBackEvent', axis = 1)
        if i == 0:
            test = np.array(df)
        else:
            test = np.vstack((test, np.array(df)))
    return train, test


def read_all_data():
    training_files = []
    for filename in labels.IdFeedBack.values:
        training_files.append(filename[:-6])  

    testing_files = []
    for filename in submission.IdFeedBack.values:
        testing_files.append(filename[:-6])  

    for i, filename in enumerate(np.unique(training_files)):
        print i, filename
        path = 'data/train/Data_' + str(filename) + '.csv'
        df = pd.read_csv(path)
        df = df[df.FeedBackEvent != 0]
        df = df.drop('FeedBackEvent', axis = 1)
        if i == 0:
            train = np.array(df)
        else:
            train = np.vstack((train, np.array(df)))

    for i, filename in enumerate(np.unique(testing_files)):
        print i, filename
        path = 'data/test/Data_' + str(filename) + '.csv'
        df = pd.read_csv(path)
        df = df[df.FeedBackEvent != 0]
        df = df.drop('FeedBackEvent', axis = 1)
        if i == 0:
            test = np.array(df)
        else:
            test = np.vstack((test, np.array(df)))
    return train, test

def classify_training_data(classifier, train):
    clf = get_clf(classifier)
    clf.fit(train, labels.Prediction.values)
    write_classifier(clf, classifier)
    return clf



def classify_test_data(clf, test, classifier):
    preds =  clf.predict_proba(test)[:,1]

    submission['Prediction'] = preds
    outfileName = 'benchmark' + str(classifier) + '.csv'
    submission.to_csv ( outfileName, index = False)


    '''
    y_pred = clf.predict(test)
    y_pred_log_prob = clf.predict_log_proba(test)
    y_pred_prob =  clf.predict_proba(test)
    precision, recall, f1_score, = precision_recall_fscore_support(y_test, y_pred)
#   reg_f1_scores.append(f1_score[1])
    print "F1 score: ", f1_score[1]
    print "Precision: ", precision[1]
    print "Recall: ", recall[1]
    print
    write_output(X, y_pred_log_prob, y_pred_prob, y_pred, y_test)





    clf = ensemble.RandomForestClassifier(n_jobs = -1, 
                         n_clfs=150, 
                             random_state=42)

    clf = LogisticRegression(penalty='l2', dual=False, tol=0.0001, C=1.0, fit_intercept=True, intercept_scaling=1, class_weight=None, random_state=None)

    clf.fit(train, labels.Prediction.values)
    preds = clf.predict_proba(test)[:,1]

    submission['Prediction'] = preds
    submission.to_csv('benchmark.csv', index = False)
    '''


if __name__ == '__main__':

# svm and gbc shall not be included since they do not have predict_prob methods. But it shall be used later.
#   classifier_set = ['rf', 'sgd', 'nb', 'svm', 'gbc']
   classifier_set = ['rf', 'sgd', 'nb']
   train, test = read_data()
#   classifier_set = ['sgd']
#   classifier_set = [ str(sys.argv[1]) ]
   hadTraining =  'False'
   for classifier in classifier_set:
       if hadTraining == "True":
           clf =  read_classifier(classifier)
       else:
           clf  =  classify_training_data(classifier, train)

       classify_test_data(clf, test, classifier)
    #the following important_Features_method exists only for random forests . Hence commenting it out.
#       print_important_features(clf)




