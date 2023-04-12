#
# cporter:
# grabbed from here:
#   https://github.com/papkov/DecisionTreeToCpp/blob/master/DecisionTreeToCpp.py
# adjusted a few things, including tips from paulkernfeld here:
#   https://stackoverflow.com/questions/20224526/how-to-extract-the-decision-rules-from-scikit-learn-decision-tree
#

# -*- coding: utf-8 -*-
# 
# DecisionTreeToCpp converter allows you to export and use sklearn decision tree in your C++ projects
# It can be useful if you want only to use decision rules produced by powerful and simple scikit 
# (you can easy create and test different models, but compile only the best one)
# 
# This code was written as a modification of Daniele's answer in StackOverflow topic "how to extract the decision rules from scikit-learn decision-tree"
# http://stackoverflow.com/questions/20224526/how-to-extract-the-decision-rules-from-scikit-learn-decision-tree
# http://stackoverflow.com/users/1885917/daniele
#
from sklearn.tree import _tree

def get_code_legacy(tree, function_name="debrt_decision_tree"):
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    threshold = tree.tree_.threshold
    features = tree.tree_.feature
    value = tree.tree_.value

    #print('tree max features: {}'.format(tree.max_features_))
    #print('tree num classes: {}'.format(tree.n_classes_))
    #print('tree classes: {}'.format(tree.classes_))
    def recurse(left, right, threshold, features, node, tabs):
        #print('hit recurse')
        code = ''
        if tree.tree_.feature[node] != _tree.TREE_UNDEFINED:
            #print('doing work')
            code += '%sif (feature_vector[%s] <= %s) {\n' % (tabs * '\t', features[node], int(threshold[node]))
            tabs += 1

            code += recurse(left, right, threshold, features, left[node], tabs)
            tabs -= 1
            code += '%s}\n%selse {\n' % (tabs * '\t', tabs * '\t')

            tabs += 1
            code += recurse(left, right, threshold, features, right[node], tabs)
            tabs -= 1
            code += '%s}\n' % (tabs * '\t')

        else:
            #print('adding return')
            #code += '%sreturn value[node]: %s;\n' % (tabs * '\t', value[node])
            #code += '%sreturn value[node].argmax(): %s;\n' % (tabs * '\t', value[node].argmax())
            #code += '%sreturn tree.classes_[value[node].argmax()]: %s;\n' % (tabs * '\t', tree.classes_[value[node].argmax()])
            code += '%sreturn %s;\n' % (tabs * '\t', int(tree.classes_[value[node].argmax()]))

        return code

    code = "static inline\nint %s(const int *feature_vector)\n{\n%s}" \
           % (function_name, recurse(left, right, threshold, features, 0, 1))

    return code

def get_case(tree):
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    threshold = tree.tree_.threshold
    features = tree.tree_.feature
    value = tree.tree_.value

    def recurse(left, right, threshold, features, node, tabs):
        code = ''
        if tree.tree_.feature[node] != _tree.TREE_UNDEFINED:
            code += '%sif (feature_vector[%s] <= %s) {\n' % (tabs * '\t', features[node], int(threshold[node]))
            tabs += 1

            code += recurse(left, right, threshold, features, left[node], tabs)
            tabs -= 1
            code += '%s}\n%selse {\n' % (tabs * '\t', tabs * '\t')

            tabs += 1
            code += recurse(left, right, threshold, features, right[node], tabs)
            tabs -= 1
            code += '%s}\n' % (tabs * '\t')

        else:
            code += '%sreturn %s;\n' % (tabs * '\t', int(tree.classes_[value[node].argmax()]))

        return code

    code = "%s\n" % (recurse(left, right, threshold, features, 0, 2))

    return code


def get_code(dts, function_name="debrt_decision_tree"):

    def get_cases():
        the_code = ''
        for deck_id in dts:
            dt = dts[deck_id]
            the_case = get_case(dt)
            the_code += '\tcase {}:\n{}'.format(deck_id, the_case)
        return the_code

    code = 'static inline\n' \
           'int %s(const int *feature_vector)\n{\n' \
           '\tswitch(feature_vector[1]){ // switch on deck_id\n' \
           '%s' \
           '\tdefault:\n' \
           '\t\treturn -1; // no prediction available; runtime should map whole deck\n' \
           '}' \
           % (function_name, get_cases())
    return code


def save_code(tree, function_name="debrt_decision_tree"):
    print('save-code is deprecated. exiting...')
    sys.exit(1)


def main():
    print('This program was not designed to run standalone.')
    input("Press Enter to continue...")

if __name__ == "__main__":
    main()
