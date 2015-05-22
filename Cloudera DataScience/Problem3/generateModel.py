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
    labels = []
    
    for l in lines:
        spt = l.split(',')
        label = float(spt[-1])
        feat = spt[:-1]
        if '?' not in spt:
            examples.append(feat)
            labels.append(label)
        
    return np.array(examples, dtype = 'float_'), np.array(labels, dtype = 'float_')

def classify_training_data(classifier):
    np.random.seed(42)
    print "Loading dataset"
    print
    X,y = load_medicare_data('TRAIN_DATA')
        
    #Shuffle dataset
    print "Shuffling dataset"
    print
    permut = np.random.permutation(len(y))
    X = X[permut]
    y = y[permut]
    
    X = np.delete(X,(0), axis=1)    
    print "Loaded ", len(y), " examples"
    print len(np.where(y == -1.)[0])," are unlabeled"
    print len(np.where(y == +1.)[0])," are positive"
    print
    
    X_train = X[0:][0:]
    y_train = y[0:][0:]
    print np.shape(X_train), np.shape(y_train)
       
    
    print "Training set contains ", len(y_train), " examples"
    print len(np.where(y_train == -1.)[0])," are unlabeled"
    print len(np.where(y_train == +1.)[0])," are positive"
    print

    print classifier 
    print "Regular learning in progress..."
    estimator = get_estimator(classifier)
    estimator.fit(X_train,y_train)
    write_classifier(estimator, classifier)
    return estimator



def get_estimator(classifier):
    estimator_dict = dict()
    estimator_dict['rf']  = RandomForestClassifier(n_estimators=100, bootstrap=True, n_jobs= 1, compute_importances=True)
    #estimator_dict['sgd'] = LogisticRegression(penalty='l2', dual=False, tol=0.0001, C=1.0, fit_intercept=True, intercept_scaling=1, class_weight=None, random_state=None)
    estimator_dict['nb']  = GaussianNB()
    #estimator_dict['svm'] = svm.SVC(C=1.0, cache_size=200, class_weight=None, coef0=0.0, degree=3, gamma=0.0, kernel='rbf', max_iter=-1, probability=False, shrinking=True, tol=0.001, verbose=False)
    estimator_dict['gbc'] = GradientBoostingClassifier(n_estimators=100, learning_rate=1.0, max_depth=1, random_state=0) 
    
    return estimator_dict[classifier] 


def write_classifier(estimator, classifier):
    filename = classifier+".pkl"
    output = open(filename, 'wb')
    pickle.dump(estimator, output)
    output.close()

def read_classifier(classifier):
    filename = classifier+".pkl"
    f = open(filename, 'rb')
    estimator = pickle.load( f)
    f.close()
    return estimator


def classify_test_data(estimator,classifier):

    X,y = load_medicare_data('TEST_DATA')
    X_test = X[0:][0:]
    y_test = y[0:][0:]
    print np.shape(X_test), np.shape(y_test)
     
    X_test = np.delete(X_test,(0), axis=1)    
    print "Loaded ", len(y), " examples"
    print np.shape(X_test), np.shape(y_test)
    
    y_pred = estimator.predict(X_test)
    y_pred_log_prob = estimator.predict_log_proba(X_test)
    y_pred_prob =  estimator.predict_proba(X_test)
    precision, recall, f1_score, _ = precision_recall_fscore_support(y_test, y_pred)
#   reg_f1_scores.append(f1_score[1])
    print "F1 score: ", f1_score[1]
    print "Precision: ", precision[1]
    print "Recall: ", recall[1]
    print
    write_output(X, y_pred_log_prob, y_pred_prob, y_pred, y_test,classifier) 



def print_important_features(estimator):
    important_featureIndexes = []
#    feature_names = ['M', 'F', '65-74', '<65', '75-84', '>85', '<16000', '16000-23999', '24000-31999', '32000-47999', '48000+', '39', '57', '64', '65', '66', '69', '74', '101', '149', '176', '177', '178', '189', '190', '191', '192', '193', '194', '195', '202', '203', '207', '208', '238', '243', '244', '246', '247', '249', '251', '252', '253', '254', '280', '281', '282', '286', '287', '291', '292', '293', '300', '301', '303', '305', '308', '309', '310', '312', '313', '314', '315', '329', '330', '372', '377', '378', '379', '389', '390', '391', '392', '394', '418', '419', '439', '460', '469', '470', '473', '480', '481', '482', '491', '536', '552', '563', '602', '603', '638', '640', '641', '682', '683', '684', '689', '690', '698', '699', '811', '812', '853', '870', '871', '872', '885', '897', '917', '918', '948', '12', '13', '15', '19', '20', '73', '74', '78', '96', '203', '204', '206', '207', '209', '265', '267', '269', '270', '336', '368', '369', '377', '604', '605', '606', '607', '608', '690', '692', '698']

    for x,i in enumerate(estimator.feature_importances_):
        print x,i 
        if i>np.average(estimator.feature_importances_):
            important_featureIndexes.append((x))
    print important_featureIndexes
#    important_features = [feature_names[i] for i in important_featureIndexes]
    print estimator.feature_importances_
#    print important_features
 #   print X_test, y_test, y_pred


def write_output(X, y_pred_log_prob, y_pred_prob, y_pred, y_test,classifier):
 
#    for i in range(1, len(y_test)):
#        print X[i][0], y_pred_log_prob[i], y_pred_prob[i], y_test[i], y_pred[i]

     f=open('/x/home/hduser/ds/data/RF_train/'+classifier+'_prediction.out','w');
     for i in range(1, len(y_test)):
        str=`X[i][0]`+','+','+`y_pred_prob[i,1]`+','+`y_test[i]` +','+ `y_pred[i]`+'\n'
        f.write(str)
     f.close()


if __name__ == '__main__':


# svm and gbc shall not be included since they do not have predict_prob methods. But it shall be used later.
#   classifier_set = ['rf', 'sgd', 'nb', 'svm', 'gbc']
#   classifier_set = ['rf', 'nb']

   classifier_set = ['rf','nb']

#   classifier_set = ['gbc']
   hadTraining = str(sys.argv[1])

   for classifier in classifier_set: 
       if hadTraining == "True":
           estimator =  read_classifier(classifier) 
       else:
           estimator  =  classify_training_data(classifier)

       classify_test_data(estimator,classifier)
    #the following important_Features_method exists only for random forests . Hence commenting it out.
    #   print_important_features(estimator)

   

