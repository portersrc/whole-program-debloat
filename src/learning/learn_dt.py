#!/usr/bin/env python2
import sys
import pandas
import argparse
from sklearn.tree import export_graphviz
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import learning_curve
from sklearn.metrics import roc_curve
from sklearn.metrics import auc
import matplotlib.pyplot as plt
from sklearn.externals import joblib

import DecisionTreeToCpp as to_cpp


func_sets = []

def read_csv_get_dataframe(csvFilename):
    print('Working with csv file: {}'.format(csvFilename))
    csvData = pandas.read_csv(csvFilename, header=None, skiprows=1)
    return csvData


def train_dt(train_x, train_y):
    dt = DecisionTreeClassifier(presort=True, max_depth=max_tree_depth)
    dt = dt.fit(train_x, train_y)
    return dt 


# Read the all func set IDs and their corresponding func IDs into an array
# of sets called "func_sets". func_sets is indexed by the func set ID. Each
# element is a set of integers, which are the function IDs of that func set.
#
# Example input file (which is created by parse_debprof_out.py)
#   predicted_func_set_id called_func_id1,called_func_id2,...
#   0 -1292216545,-1292216556,-1292216557,
#   1 -1292216556,-1292216557,
#   2 -1292216544,-1292216556,-1292216557,
def read_func_sets(func_sets_filename):
    global func_sets
    with open(func_sets_filename) as f:
        # Construct "func_sets". It's indexed by func set ID. Each element is a
        # a set of function IDs
        f.readline() # parse out the header
        i = 0;
        for line in f:
            line = line.strip()
            elems = line.split()
            func_set_id = int(elems[0])
            assert func_set_id == i
            func_ids_str = elems[1].split(',')
            func_id_set = set()
            for func_id in func_ids_str:
                if func_id: # ignore '' elements after trailing comma
                    func_id_set.add(int(func_id))
            func_sets.append(func_id_set);
            i += 1


def verify_accuracy(predictedY, verify_y):
    correct = 0
    assert len(predictedY) == len(verify_y)
    for i in xrange(len(predictedY)):
        #print(verify_y[i])
        #print(predictedY[i])
        #print(func_sets[predictedY[i]])
        #print
        if verify_y[i] in func_sets[predictedY[i]]:
            correct += 1

    print("correct: {}".format(correct))
    print("total predictions: {}".format(len(predictedY)))
    print("accuracy: {}".format(1.0*correct / len(predictedY)))


def test_dt(dt, test_x, test_y, verify_y):
    if save_plots != "":
        graphName = save_plots + ".pkl"
        joblib.dump(dt, graphName)

    if do_accuracy:
        accuracy = dt.score(test_x, test_y)
        predictedY = dt.predict(test_x)
        pandas.DataFrame(predictedY).to_csv('prediction.csv')
        print("Accuracy: {}".format(accuracy))
        print("Depth: {}".format(dt.tree_.max_depth))
        #print("Decision tree path: {}".format(dt.decision_path(trainX[2:3,:])))
        print("Decision tree: {}".format(dt.n_classes_))

    listClassNames = []
    for cl in range(0,dt.n_classes_):
        listClassNames.append(str(cl))

    if save_plots != "":
        graphName = save_plots + ".dot"
        with open(graphName, 'w') as f:
            f = export_graphviz(dt,
                                out_file=f,
                                feature_names=list(training_dataset)[1:],
                                class_names=listClassNames)
    print(to_cpp.get_code(dt))
    if do_accuracy:
        verify_accuracy(predictedY, verify_y)
    to_cpp.save_code(dt)

     

def train_and_test(training_dataset, test_dataset):
    #print(training_dataset)
    # slice the 1st column to the last one (our features), over all rows
    train_x = training_dataset.values[:,1:]
    # slice the 0th column (we want to predict) over all rows
    train_y = training_dataset.values[:,0]
    # fit only on training data

    verify_y = None
    test_x = None
    test_y = None
    if do_accuracy:
        # apply same transformation to test data
        test_x = test_dataset.values[:,1:]
        test_y = test_dataset.values[:,0]
        verify_y = test_dataset.values[:,2] # the actual func (not set) id that got hit at runtime
        if do_scaling == 1:
            scaler = StandardScaler()
            scaler.fit(train_x)
            train_x = scaler.transform(train_x)
            test_x = scaler.transform(test_x)

    dt = train_dt(train_x, train_y)
    test_dt(dt, test_x, test_y, verify_y)


if __name__ == '__main__' :
    parser = argparse.ArgumentParser(description='learning algorithm selector' )
    parser.add_argument('-csv_file_name',
                        dest='csv_file_name',
                        type=str,required=True,
                        help='Data File in CSV Format')
    parser.add_argument('-test_csv_file_name',
                        dest='test_csv_file_name',
                        type=str,
                        required=False,
                        help='Output Data File in CSV Format',
                        default=None)
    parser.add_argument('-func_sets_file_name',
                        dest='func_sets_file_name',
                        type=str,
                        required=False,
                        help='Function set IDs to function IDs in that set',
                        default=None)
    parser.add_argument('-save_plots',
                        dest='save_plots',
                        type=str,
                        required=False,
                        help='Save plots to file',
                        default="")
    parser.add_argument('-do_scaling',
                        dest='do_scaling',
                        type=int,
                        required=False,
                        help='Normalize input data',
                        default=0)
    parser.add_argument('-do_accuracy',
                        dest='do_accuracy',
                        type=bool,
                        required=False,
                        help='Calculate accuracy (requires test logs/data)',
                        default=False)
    parser.add_argument('-max_tree_depth',
                        dest='max_tree_depth',
                        type=int,
                        required=False,
                        help='Normalize input data',
                        default=50)

    args = parser.parse_args()
    csvFileName= args.csv_file_name
    if args.test_csv_file_name is None:
        test_csvFileName = args.csv_file_name
    else: 
        test_csvFileName = args.test_csv_file_name
    func_sets_filename= args.func_sets_file_name

    save_plots = args.save_plots
    do_scaling = args.do_scaling
    max_tree_depth = args.max_tree_depth
    do_accuracy = args.do_accuracy

    training_dataset = read_csv_get_dataframe(csvFileName)
    test_dataset = None
    if do_accuracy:
        test_dataset = read_csv_get_dataframe(test_csvFileName)
    

    read_func_sets(func_sets_filename)

    train_and_test(training_dataset, test_dataset)
