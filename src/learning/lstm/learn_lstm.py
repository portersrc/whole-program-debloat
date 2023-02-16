#!/usr/bin/env python3
import sys
import pandas
import numpy
import argparse
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM

#
# FIXME
# FIXME
# FIXME
# This could needs attention before being reused. Yes, it was generating
# results, but they weren't good. Some choices were arbitrary (e.g. the
# architecture of the LSTM) that should be reconsidered and experimented with.
# Other choices might just be wrong and causing issues (e.g. setting to 0
# any elements that were equal to numpy.isnan).
# FIXME
# FIXME
# FIXME
#
 
 


def read_csv_get_dataframe(csvFilename):
    print('Working with csv file: {}'.format(csvFilename))
    #csvData = pandas.read_csv(csvFilename, header=0)
    #csvData = pandas.read_csv(csvFilename, header=0, sep='\n')
    # trying this with test and train outsmall. Manually deleted the column
    # headers.
    csvData = pandas.read_csv(csvFilename, header=None, sep='\n')
    csvData = csvData[0].str.split(',', expand=True)
    #print(csvData.astype('float32'))
    #print(csvData.head())
    #sys.exit(42)
    return csvData


def train_and_test(train_dataset, test_dataset):

    # ensure all data is float
    train_values = train_dataset.values.astype('float32')
    test_values  = test_dataset.values.astype('float32')
    #train_values = train_dataset.astype('float32')
    #test_values  = test_dataset.astype('float32')
    train_values[numpy.isnan(train_values)] = 0
    test_values[numpy.isnan(test_values)] = 0
    #print(train_values[:5,:])
    #sys.exit(42)

    # normalize features
    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_train = scaler.fit_transform(train_values)
    scaled_test  = scaler.fit_transform(test_values)

    # slice the 1st column to the last one (our features), over all rows
    train_x = scaled_train[:,1:]
    # slice the 0th column (we want to predict) over all rows
    train_y = scaled_train[:,0]
    # fit only on training data
    # apply same transformation to test data
    test_x = scaled_test[:,1:]
    test_y = scaled_test[:,0]

    # reshape input to be 3D [samples, timesteps, features]
    train_x = train_x.reshape((train_x.shape[0], 1, train_x.shape[1]))
    test_x = test_x.reshape((test_x.shape[0], 1, test_x.shape[1]))
    #print(train_x.shape, train_y.shape, test_x.shape, test_y.shape)

    # design network
    model = Sequential()
    model.add(LSTM(50, input_shape=(train_x.shape[1], train_x.shape[2])))
    model.add(Dense(1))
    model.compile(loss='mae', optimizer='adam')
    # fit network
    history = model.fit(train_x,
                        train_y,
                        epochs=50,
                        batch_size=72,
                        validation_data=(test_x, test_y),
                        verbose=2,
                        shuffle=False)


def train_only(train_dataset):
    # ensure all data is float
    train_values = train_dataset.values.astype('float32')
    #train_values = train_dataset.astype('float32')
    train_values[numpy.isnan(train_values)] = 0
    #print(train_values[:5,:])
    #sys.exit(42)

    # normalize features
    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_train = scaler.fit_transform(train_values)

    # slice the 1st column to the last one (our features), over all rows
    train_x = scaled_train[:,1:]
    # slice the 0th column (we want to predict) over all rows
    train_y = scaled_train[:,0]
    # fit only on training data

    # reshape input to be 3D [samples, timesteps, features]
    train_x = train_x.reshape((train_x.shape[0], 1, train_x.shape[1]))
    #print(train_x.shape, train_y.shape)

    # design network
    model = Sequential()
    model.add(LSTM(50, input_shape=(train_x.shape[1], train_x.shape[2])))
    model.add(Dense(1))
    model.compile(loss='mae', optimizer='adam')
    # fit network
    history = model.fit(train_x,
                        train_y,
                        epochs=50,
                        batch_size=72,
                        verbose=2,
                        shuffle=False)
    #from kerasify import export_model
    #export_model(model, 'kerasified.model')



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
    parser.add_argument('-save_plots',
                        dest='save_plots',
                        type=str,
                        required=False,
                        help='Save plots to file',
                        default="")
    # hack... take these params and drop them... allows learn.sh to blindly
    # pass them to this script without checking. learn-dt makes use of them
    # also note: do-accuracy is sort of enabled for the lstm even without
    # executing the train-and-test stuff. It doesn't show the accuracy
    # for test data, of course, but with just the train data we at least
    # see the loss.
    parser.add_argument('-func_sets_file_name',
                        dest='func_sets_file_name',
                        type=str,
                        required=False,
                        help='Ignored. Not used.',
                        default=None)
    parser.add_argument('-do_accuracy',
                        dest='do_accuracy',
                        type=bool,
                        required=False,
                        help='Calculate accuracy (requires test logs/data)',
                        default=False)

    args = parser.parse_args()
    save_plots = args.save_plots
    train_dataframe = read_csv_get_dataframe(args.csv_file_name)

    #test_dataframe  = read_csv_get_dataframe(args.test_csv_file_name)
    #train_and_test(train_dataframe, test_dataframe)

    train_only(train_dataframe)
