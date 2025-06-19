# RMPS and RMPSH: Recursive Modified Pattern Search

This repository provides implementations of the Recursive Modified Pattern Search (RMPS) algorithm for black-box optimization over hyper-rectangles, available in both MATLAB and R (via Rcpp). The method can be applied to high-dimensional, non-convex, and derivative-free optimization problems.

---

## 📚 Citation

If you use this method in your work, please cite:

> Das, P. (2023).  
> *Black-box optimization on hyper-rectangle using Recursive Modified Pattern Search and application to ROC-based Classification Problem*.  
> *Sankhya B*, 85, 365–404.  
> https://doi.org/10.1007/s13571-023-00312-w

---

## 🧩 Instructions to Run the Code

### MATLAB

To use RMPS in MATLAB:

```matlab
% Run this script to optimize any function using RMPS
RMPS_matlab_code.m
```
### R

To use RMPS in R via Rcpp:

```r
source("RMPS_rcode.R")
```

### 📦 RMPSH R Package

To install and use the RMPSH R package (RMPS on Hyper-rectangles):

```r
# Install from GitHub
library(devtools)
install_github("priyamdas2/RMPS/RMPSH")
library(RMPSH)

# Access the main function
?RMPSH_opt
```

### 🔍 Example Usage

```r
g <- function(y)
  return(-20 * exp(-0.2 * sqrt(0.5 * (y[1]^2 + y[2]^2))) 
         - exp(0.5 * (cos(2 * pi * y[1]) + cos(2 * pi * y[2]))) 
         + exp(1) + 20)

starting_point <- rep(1, 10)
g(starting_point)

# Run RMPSH on 10D hypercube
solution <- RMPSH_opt(starting_point, g, rep(-33, 10), rep(33, 10))
g(solution)

# Another run with verbose output
RMPSH_opt(c(2, 4, 6, 2, 1), g, rep(-3, 5), rep(23, 5), print = 1)
```
This will display intermediate optimization updates after each iteration when 'print_output' = 1 is specified.
