#!/bin/bash
# This script takes a single input file from the best_predictor script
# Then calculates the Pearson Correlation Coefficient for GDP vs Cantril, Population vs Cantril, Homicide Rate vs Cantril, Life Expectancy vs Cantril
# Returns 4 r coefficients at the end of the program

# Set a variable for the input file
file=$1

# Calculator for Pearson Correlation Coefficients r1 to r4
awk -F'\t' '
{ 
    code = $2 # Country code denoted by code
    x1 = $4  # Denote GDP as x1
    x2 = $5  # Denote Population as x2
    x3 = $6  # Denote Homicide as x3
    x4 = $7  # Denote Life Expectancy as x4
    y = $8   # Denote Cantril ladder score as y

    if (y != "") { # Only count when Cantril data exists
        data[code]["x1"] = data[code]["x1"] " " x1
        data[code]["x2"] = data[code]["x2"] " " x2
        data[code]["x3"] = data[code]["x3"] " " x3
        data[code]["x4"] = data[code]["x4"] " " x4
        data[code]["y"] = data[code]["y"] " " y
        data[code]["n"]++ # The number of the sample set
    }
}
END { 
    # Step by step calculation of r
    for (code in data) {
	n = data[code]["n"] #Initialise n for each country
        if (n >= 3) {
            split(data[code]["x1"], x1_list, " ")
            split(data[code]["x2"], x2_list, " ")
            split(data[code]["x3"], x3_list, " ")
            split(data[code]["x4"], x4_list, " ")
            split(data[code]["y"], y_list, " ")

            # Collect the sum of each independent vars & dependent vars
            sum_x1 = sum_x2 = sum_x3 = sum_x4 = sum_y = 0
            
            for (i = 1; i <= n; i++) {
                sum_x1 += x1_list[i]
                sum_x2 += x2_list[i]
                sum_x3 += x3_list[i]
                sum_x4 += x4_list[i]
                sum_y += y_list[i]
            }
            # Derive the mean values
            mean_x1 = sum_x1 / n
            mean_x2 = sum_x2 / n
            mean_x3 = sum_x3 / n
            mean_x4 = sum_x4 / n
            mean_y = sum_y / n

            # Collect (xi-mean_x), (yi-mean_y) for further calculations
            # We need sigma[(xi-mean_x) * (yi-mean_y)] for numerator
            # [sigma(xi-mean_x)^2 * sigma(yi-mean_y)^2] for denominator

            numer1 = numer2 = numer3 = numer4 = 0
            denom_x1 = denom_x2 = denom_x3 = denom_x4 = denom_y = 0
            for (i = 1; i <= n; i++) {
                # diff: (xi-mean_x), (yi-mean_y)
                diff_x1 = x1_list[i] - mean_x1
                diff_x2 = x2_list[i] - mean_x2
                diff_x3 = x3_list[i] - mean_x3
                diff_x4 = x4_list[i] - mean_x4
                diff_y = y_list[i] - mean_y

                # Calculate numerator: sigma[(xi-mean_x) * (yi-mean_y)]
                numer1 += diff_x1 * diff_y
                numer2 += diff_x2 * diff_y
                numer3 += diff_x3 * diff_y
                numer4 += diff_x4 * diff_y

                # Calculate elements for denominators
                denom_x1 += diff_x1 * diff_x1
                denom_x2 += diff_x2 * diff_x2
                denom_x3 += diff_x3 * diff_x3
                denom_x4 += diff_x4 * diff_x4
                denom_y += diff_y * diff_y
            }

            # Calculate denominators
            denominator1 = sqrt(denom_x1 * denom_y)
            denominator2 = sqrt(denom_x2 * denom_y)
            denominator3 = sqrt(denom_x3 * denom_y)
            denominator4 = sqrt(denom_x4 * denom_y)

            # Calculate r for GDP, Population, Homicide, Life Expectancy vs Cantril for each country
            r1 = denominator1 == 0 ? 0 : numer1 / denominator1
            r2 = denominator2 == 0 ? 0 : numer2 / denominator2
            r3 = denominator3 == 0 ? 0 : numer3 / denominator3
            r4 = denominator4 == 0 ? 0 : numer4 / denominator4

            # Sum up all r to further calculate mean coefficient
            r1_total += r1
            r2_total += r2
            r3_total += r3
            r4_total += r4
            r1_count++
            r2_count++
            r3_count++
            r4_count++
        }
    }

    # Derive the mean of r1 to r4 and avoid ZeroDivision
    if (r1_count > 0) { r1_mean = r1_total / r1_count } else { r1_mean = 0 }
    if (r2_count > 0) { r2_mean = r2_total / r2_count } else { r2_mean = 0 }
    if (r3_count > 0) { r3_mean = r3_total / r3_count } else { r3_mean = 0 }
    if (r4_count > 0) { r4_mean = r4_total / r4_count } else { r4_mean = 0 }

    # Round up to 3 decimals
    r1_mean = sprintf("%.3f", r1_mean)
    r2_mean = sprintf("%.3f", r2_mean)
    r3_mean = sprintf("%.3f", r3_mean)
    r4_mean = sprintf("%.3f", r4_mean)

    print r1_mean, r2_mean, r3_mean, r4_mean
}
' "$file"
