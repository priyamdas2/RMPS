
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RMPSH

<!-- badges: start -->
<!-- badges: end -->

The goal of RMPSH is to …

## Installation

You can install the development version of RMPSH from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("priyamdas2/RMPS")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(RMPSH)
## basic example code

g <- function(y)
return(-20 * exp(-0.2 * sqrt(0.5 * (y[1] ^ 2 + y[2] ^ 2)))
 - exp(0.5 * (cos(2 * pi * y[1]) + cos(2 * pi * y[2])))
 + exp(1) + 20)

par0 <- rep(1,10)
g(par0)
#> [1] 3.625385
solution <- RMPSH_opt(par0,g, rep(-33,10), rep(33,10))
g(solution)
#> [1] 0.0001221199

# Will print the updates after each iteration
RMPSH_opt(c(2,4,6,2,1),g,rep(-3,5), rep(23,5), verbose = 1)
#> 
#>  Run no.  1 ,iteration no. 1 , current fun value =  9.000985
#>  Run no.  1 ,iteration no. 2 , current fun value =  8.076006
#>  Run no.  1 ,iteration no. 3 , current fun value =  7.976954
#>  Run no.  1 ,iteration no. 4 , current fun value =  7.972332
#>  Run no.  1 ,iteration no. 5 , current fun value =  7.972332
#>  Run no.  1 ,iteration no. 6 , current fun value =  7.972332
#>  Run no.  1 ,iteration no. 7 , current fun value =  7.972332
#>  Run no.  1 ,iteration no. 8 , current fun value =  7.972332
#>  Run no.  1 ,iteration no. 9 , current fun value =  6.123136
#>  Run no.  1 ,iteration no. 10 , current fun value =  5.079548
#>  Run no.  1 ,iteration no. 11 , current fun value =  5.079548
#>  Run no.  1 ,iteration no. 12 , current fun value =  3.315198
#>  Run no.  1 ,iteration no. 13 , current fun value =  3.315198
#>  Run no.  1 ,iteration no. 14 , current fun value =  3.315198
#>  Run no.  1 ,iteration no. 15 , current fun value =  1.920521
#>  Run no.  1 ,iteration no. 16 , current fun value =  0.8632236
#>  Run no.  1 ,iteration no. 17 , current fun value =  0.8632236
#>  Run no.  1 ,iteration no. 18 , current fun value =  0.3342784
#>  Run no.  1 ,iteration no. 19 , current fun value =  0.3342784
#>  Run no.  1 ,iteration no. 20 , current fun value =  0.1989223
#>  Run no.  1 ,iteration no. 21 , current fun value =  0.1989223
#>  Run no.  1 ,iteration no. 22 , current fun value =  0.1271946
#>  Run no.  1 ,iteration no. 23 , current fun value =  0.08250923
#>  Run no.  1 ,iteration no. 24 , current fun value =  0.08250923
#>  Run no.  1 ,iteration no. 25 , current fun value =  0.04795357
#>  Run no.  1 ,iteration no. 26 , current fun value =  0.04162336
#>  Run no.  1 ,iteration no. 27 , current fun value =  0.04162336
#>  Run no.  1 ,iteration no. 28 , current fun value =  0.01774076
#>  Run no.  1 ,iteration no. 29 , current fun value =  0.01774076
#>  Run no.  1 ,iteration no. 30 , current fun value =  0.003119905
#>  Run no.  1 ,iteration no. 31 , current fun value =  0.003119905
#>  Run no.  1 ,iteration no. 32 , current fun value =  0.003119905
#>  Run no.  1 ,iteration no. 33 , current fun value =  0.002227056
#>  Run no.  1 ,iteration no. 34 , current fun value =  0.002227056
#>  Run no.  1 ,iteration no. 35 , current fun value =  0.001482223
#>  Run no.  1 ,iteration no. 36 , current fun value =  0.00100999
#>  Run no.  1 ,iteration no. 37 , current fun value =  0.00100999
#>  Run no.  1 ,iteration no. 38 , current fun value =  0.0005801463
#>  Run no.  1 ,iteration no. 39 , current fun value =  0.0005801463
#>  Run no.  1 ,iteration no. 40 , current fun value =  0.0002627515
#>  Run no.  1 ,iteration no. 41 , current fun value =  0.0002627515
#>  Run no.  1 ,iteration no. 42 , current fun value =  4.826028e-05
#>  Run no.  1 ,iteration no. 43 , current fun value =  4.826028e-05
#>  Run no.  1 ,iteration no. 44 , current fun value =  4.826028e-05
#>  Run no.  1 ,iteration no. 45 , current fun value =  3.454752e-05
#>  Run no.  1 ,iteration no. 46 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 1 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 2 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 3 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 4 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 5 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 6 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 7 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 8 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 9 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 10 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 11 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 12 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 13 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 14 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 15 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 16 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 17 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 18 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 19 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 20 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 21 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 22 , current fun value =  3.454752e-05
#>  Run no.  2 ,iteration no. 23 , current fun value =  3.454752e-05
#> [1] -7.629395e-06  9.536743e-06  6.000000e+00  2.000000e+00  1.000000e+00

# Will exit and return result after 2 seconds
g <- function(y) { return(sum(y^2)) }
RMPSH_opt(rep(2.3,100),g, rep(-11,100), rep(13,100), max_time = 2, verbose = 0)
#> [1] "Time's up"
#>   [1]  1.220703e-05  1.220703e-05  1.037598e-04 -3.356934e-05 -1.068115e-05
#>   [6] -7.934570e-05  1.220703e-05  1.037598e-04  5.798340e-05  8.087158e-05
#>  [11] -1.251221e-04  1.220703e-05  1.037598e-04  1.037598e-04  1.266479e-04
#>  [16] -5.645752e-05  1.220703e-05  1.037598e-04  1.266479e-04 -3.356934e-05
#>  [21]  1.220703e-05  1.220703e-05  1.037598e-04  5.798340e-05 -1.068115e-05
#>  [26] -7.934570e-05  1.220703e-05  1.037598e-04  1.037598e-04  8.087158e-05
#>  [31] -1.251221e-04  1.220703e-05  1.037598e-04  1.266479e-04  1.266479e-04
#>  [36] -1.022339e-04  1.220703e-05  1.037598e-04 -3.356934e-05  5.798340e-05
#>  [41]  1.220703e-05  1.220703e-05  1.037598e-04  1.037598e-04 -1.068115e-05
#>  [46] -7.934570e-05  1.220703e-05  1.037598e-04  1.266479e-04  8.087158e-05
#>  [51] -1.251221e-04  1.220703e-05  1.037598e-04 -3.356934e-05  1.266479e-04
#>  [56] -1.251221e-04  1.220703e-05  1.037598e-04  5.798340e-05  1.037598e-04
#>  [61]  1.220703e-05  1.220703e-05  1.037598e-04  1.266479e-04 -1.068115e-05
#>  [66] -7.934570e-05  1.220703e-05  1.037598e-04 -3.356934e-05  8.087158e-05
#>  [71] -1.251221e-04  1.220703e-05  1.037598e-04  5.798340e-05  1.266479e-04
#>  [76] -1.480103e-04  1.220703e-05  1.037598e-04  1.037598e-04  1.266479e-04
#>  [81]  1.220703e-05  1.220703e-05  1.037598e-04 -3.356934e-05 -1.068115e-05
#>  [86] -7.934570e-05  1.220703e-05  1.037598e-04  5.798340e-05  8.087158e-05
#>  [91] -1.251221e-04  1.220703e-05  1.037598e-04  1.037598e-04  1.266479e-04
#>  [96] -1.480103e-04  1.220703e-05  1.037598e-04  1.266479e-04 -3.356934e-05
```
