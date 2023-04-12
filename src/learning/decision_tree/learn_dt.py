#!/usr/bin/env python3
import sys
import pandas
import numpy as np
import argparse
from sklearn.tree import export_text
from sklearn.tree import export_graphviz
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import learning_curve
from sklearn.metrics import roc_curve
from sklearn.metrics import auc
import matplotlib.pyplot as plt
from sklearn.externals import joblib

import DecisionTreeToCpp as to_cpp

IS_CGPPROF = True


func_sets = []

def read_csv_get_dataframe(csvFilename):
    print('Working with csv file: {}'.format(csvFilename))
    csvData = pandas.read_csv(csvFilename)
    # pandas will use the header line, which I currently write out as having
    # features0-9, to get a count for the number of headers.  Then in
    # subsequent lines it pads the row with NaNs if it's missing columns Here I
    # replace NaNs with 0s.
    csvData = csvData.fillna(0)
    return csvData


def train_dt(train_x, train_y):
    #dt = DecisionTreeClassifier(presort=True, max_depth=max_tree_depth)
    dt = DecisionTreeClassifier(max_depth=max_tree_depth)
    #print('type of train_x: {}'.format(type(train_x)))
    #print('type of casted train_x: {}'.format(type(np.array(train_x))))
    #print('type of train_y: {}'.format(type(train_y)))
    #dt = dt.fit(train_x, train_y)
    dt = dt.fit(np.array(train_x), np.array(train_y))
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
        if IS_CGPPROF:
            i = 1
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
    for i in range(len(predictedY)):
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
    with open('exported-scikit-dt.txt', 'w') as f:
        f.write(export_text(dt, max_depth=1000))
    print(to_cpp.get_code(dt))
    if do_accuracy:
        verify_accuracy(predictedY, verify_y)
    to_cpp.save_code(dt)

     

def train_and_test(training_dataset, test_dataset):
    #print(training_dataset)
    # slice the 1st column to the last one (our features), over all rows
    train_x_all = training_dataset.values[:,1:]
    # slice the 0th column (we want to predict) over all rows
    train_y_all = training_dataset.values[:,0]
    # fit only on training data

    #print(train_x_all)
    #print(len(train_x_all))
    #print(train_y_all)
    #print(len(train_y_all))
    #dt = train_dt(train_x_all, train_y_all)
    #print(dt)
    #accuracy = dt.score(train_x_all, train_y_all)
    #print('accuracy on same training set: {}'.format(accuracy))
    #print(export_text(dt, max_depth=1000))
    #print(to_cpp.get_code(dt))
    #sys.exit(45)

    #print('type of original train_x_all: {}'.format(type(train_x_all)))
    #print('type of original train_y_all: {}'.format(type(train_y_all)))

    deck_id_to_train_x = {}
    deck_id_to_train_y = {}
    for idx, _ in enumerate(train_x_all):
        # func/loop ID is element 0. deck ID is element 1
        deck_id = int(train_x_all[idx][1])
        if deck_id not in deck_id_to_train_x:
            deck_id_to_train_x[deck_id] = []
            deck_id_to_train_y[deck_id] = []
        # train_x_all[idx] holds the features
        # train_y_all[idx] holds the func set ID you want to predict
        deck_id_to_train_x[deck_id].append(train_x_all[idx])
        deck_id_to_train_y[deck_id].append(train_y_all[idx])
    #print('len of deck_id_to_train_x: {}'.format(len(deck_id_to_train_x)))
    #print('len of deck_id_to_train_y: {}'.format(len(deck_id_to_train_y)))

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
            scaler.fit(train_x_all)
            train_x_all = scaler.transform(train_x_all)
            test_x = scaler.transform(test_x)

    all_dts = {}
    for deck_id in deck_id_to_train_x:
        print('working with deck_id: {}'.format(deck_id))
        train_x = deck_id_to_train_x[deck_id]
        train_y = deck_id_to_train_y[deck_id]
        assert len(train_x) == len(train_y)
        assert len(train_x) > 0
        #print(train_x)
        #print(len(train_x))
        #tmp_x = np.array(train_x)
        #print(tmp_x)
        #print(len(tmp_x))
        #print(train_y)
        #print(len(train_y))
        #tmp_y = np.array(train_y)
        #print(tmp_y)
        #print(len(tmp_y))
        dt = train_dt(train_x, train_y)
        #print(dt)
        #print(to_cpp.get_code(dt))
        #accuracy = dt.score(train_x, train_y)
        #print('accuracy on same training subset: {}'.format(accuracy))
        #print(export_text(dt, max_depth=1000))
        #print(to_cpp.get_code(dt))
        #sys.exit(41)

        # TODO Not worried about test-dt right now. Testing is online.
        # can look into this later for offline testing again, if needed.
        #test_dt(dt, test_x, test_y, verify_y)

        all_dts[deck_id] = dt

    #sys.exit(42)
    write_cpp(all_dts)


def write_cpp(dts):
    the_code = to_cpp.get_code(dts)

    with open('exported-scikit-dt.txt', 'w') as f:
        for deck_id, dt in dts.items():
            f.write('deck_id: {}\n'.format(deck_id))
            f.write(export_text(dt, max_depth=1000))
            f.write('\n\n'.format(deck_id))


    with open('debrt_decision_tree.h', 'w') as f:
        f.write(the_code)
    print(the_code)

    return 0




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
        assert False # dropping any support for this for now
        test_dataset = read_csv_get_dataframe(test_csvFileName)
        read_func_sets(func_sets_filename)

    train_and_test(training_dataset, test_dataset)
