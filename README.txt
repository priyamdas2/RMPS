Citing information : 
Das, P. (2019+), Black-box optimization on hyper-rectangle using Recursive Modified Pattern
Search and application to ROC-based Classification Problem, https://arxiv.org/pdf/1604.08616.pdf

_____________________________________________________________________________________________________________

Instructions to run R and MATLAB code:

----> Run 'RMPS_matlab_code.m' to optimize any function using RMPS in MATLAB.

----> Run 'RMPS_rcode.R' to optimize any function using RMPS in R (written using RCPP).

----> For real data analysis part, go to 'Real_data_HUM' folder and follow corresponding README file.
_____________________________________________________________________________________________________________
Instruction to run R package RMPSH:

-----> 
# Execute 

library(devtools)
install_github("priyamdas2/RMPS/RMPSH")
library(RMPSH)

# See main function

 ?RMPSH_opt
 
# RUN example code

g <- function(y)
return(-20 * exp(-0.2 * sqrt(0.5 * (y[1] ^ 2 + y[2] ^ 2)))
 - exp(0.5 * (cos(2 * pi * y[1]) + cos(2 * pi * y[2])))
 + exp(1) + 20)

starting_point <- rep(1,10)
g(starting_point)
solution <- RMPSH_opt(starting_point,g, rep(-33,10), rep(33,10))
g(solution)

RMPSH_opt(c(2,4,6,2,1),g,rep(-3,5), rep(23,5), print = 1)
# Will print the updates after each iteration

_______________________________________________________________________________________________________________
