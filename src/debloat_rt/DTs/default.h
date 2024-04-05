//
// cporter 2023.04.08
// Hand-written "default" decision tree code.
// The point is to have a switch-case that has only a default case which
// returns -1. The runtime will interpret -1 as "no prediction available",
// and will then map the whole deck.
//


static inline
int debrt_decision_tree(const int *feature_vector)
{
    switch(feature_vector[1]){
    default:
        return -1;
    }
}
