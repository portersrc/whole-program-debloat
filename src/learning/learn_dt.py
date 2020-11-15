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





def read_csv_get_dataframe(csvFilename):
    print('Working with csv file: {}'.format(csvFilename))
    csvData = pandas.read_csv(csvFilename)
    return csvData


def train_dt(train_x, train_y):
    dt = DecisionTreeClassifier(presort=True, max_depth=max_tree_depth)
    dt = dt.fit(train_x, train_y)
    return dt 


def test_dt(dt, test_x, test_y):
    if save_plots != "":
        graphName = save_plots + ".pkl"
        joblib.dump(dt, graphName)
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
     

def train_and_test(training_dataset, test_dataset, split_frac):
    # slice the 1st column to the last one (our features), over all rows
    train_x = training_dataset.values[:,1:]
    # slice the 0th column (we want to predict) over all rows
    train_y = training_dataset.values[:,0]
    # fit only on training data
    # apply same transformation to test data
    test_x = test_dataset.values[:,1:]
    test_y = test_dataset.values[:,0]
    if do_scaling == 1:
        scaler = StandardScaler()  
        scaler.fit(train_x)  
        train_x = scaler.transform(train_x)  
        test_x = scaler.transform(test_x)  
    dt = train_dt(train_x, train_y)
    test_dt(dt, test_x, test_y)


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
    parser.add_argument('-split_frac',
                        dest='split_frac',
                        type=float,
                        required=False,
                        help='Split of Test and Train',
                        default=1.0)
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

    split_frac = args.split_frac
    save_plots = args.save_plots
    do_scaling = args.do_scaling
    max_tree_depth = args.max_tree_depth

    dataframe_fromcsv = read_csv_get_dataframe(csvFileName)
    test_dataframe_fromcsv= read_csv_get_dataframe(test_csvFileName)

    training_dataset, test_dataset = dataframe_fromcsv, test_dataframe_fromcsv
    train_and_test(training_dataset, test_dataset, split_frac)
