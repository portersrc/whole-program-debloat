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


def get_code(tree, function_name="debrt_decision_tree"):
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    threshold = tree.tree_.threshold
    features = tree.tree_.feature
    value = tree.tree_.value

    def recurse(left, right, threshold, features, node, tabs):
        code = ''
        if threshold[node] != -2:
            code += '%sif (feature_vector[%s] <= %s) {\n' % (tabs * '\t', features[node], int(threshold[node]))
            tabs += 1

            if left[node] != -1:
                code += recurse(left, right, threshold, features, left[node], tabs)
            tabs -= 1
            code += '%s}\n%selse {\n' % (tabs * '\t', tabs * '\t')

            tabs += 1
            if right[node] != -1:
                code += recurse(left, right, threshold, features, right[node], tabs)
            tabs -= 1
            code += '%s}\n' % (tabs * '\t')

        else:
            code += '%sreturn %s;\n' % (tabs * '\t', value[node].argmax())

        return code

    code = "inline\nint %s(const int *feature_vector)\n{\n%s}" \
           % (function_name, recurse(left, right, threshold, features, 0, 1))
    return code


def save_code(tree, function_name="debrt_decision_tree"):

    preamble = """
/*
This inline function was automatically generated using DecisionTreeToCpp Converter

Simply include this file to your project and use it
*/

"""

    code = '%s\n\n%s' % (preamble, get_code(tree, function_name))

    with open(function_name + '.h', "w") as f:
        f.write(code)
        print("File %s was written" % (function_name + '.h'))

    return 0


def main():
    print('This program was not designed to run standalone.')
    input("Press Enter to continue...")

if __name__ == "__main__":
    main()
