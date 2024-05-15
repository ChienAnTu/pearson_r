#!/bin/bash

calculate_pearson() {
    local n=$1
    local x_sum=$2
    local y_sum=$3
    local x_sq_sum=$4
    local y_sq_sum=$5
    local xy_sum=$6

    local mean_x=$(echo "$x_sum / $n" | bc -l)
    local mean_y=$(echo "$y_sum / $n" | bc -l)
    local numerator=$(echo "$xy_sum - $n * $mean_x * $mean_y" | bc -l)
    local denominator=$(echo "sqrt(($x_sq_sum - $n * $mean_x * $mean_x) * ($y_sq_sum - $n * $mean_y * $mean_y))" | bc -l)

    if (( $(echo "$denominator == 0" | bc -l) )); then
        echo 0
    else
        echo $(echo "$numerator / $denominator" | bc -l)
    fi
}

calculate_pearson "$@"

