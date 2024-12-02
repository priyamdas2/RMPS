############### Citation information ########################################
# Das, P. Black-box optimization on hyper-rectangle using Recursive Modified Pattern Search
# and application to ROC-based Classification Problem. Sankhya B 85, 365–404 (2023). 
# https://doi.org/10.1007/s13571-023-00312-w

rm(list = ls())
# install.packages("pracma")
# install.packages("Rcpp")
setwd("~/RMPS")
library(Rcpp)
library(pracma)

############# USER input ####################################################

print_output <- 1             # 0 for no update print, 1 to print.
M <- 2                        # Dimension
lb <- (-33) * rep(1, M)       # lower bound
ub <- (33) * rep(1, M)        # upper bound
starting_point <- c(10, -10)

########### Function input ##################################################
f <- function(y)             # 2-dimensional ackley's function
{
  value <- -20 * exp(-0.2 * sqrt(0.5 * (y[1] ^ 2 + y[2] ^ 2))) -
    exp(0.5 * (cos(2 * pi * y[1]) + cos(2 * pi * y[2]))) + exp(1) + 20
  return(value)
}

#f(c(0,0))               # minimum occurs at y = c(0,0)

start_value <- f(starting_point)

############ RMPS Parameters ###############################################

no_loops <- 1000
max_iter <- 10000
tol_fun <- 10 ^ (-6)
rho_1 <- 2
rho_2 <- 2
tol_fun_2 <- 10 ^ (-20)
epsilon_cut_off <- 10 ^ (-20)

############################# RMPS Algorithm ##############################

cppFunction(
  'NumericVector transformation(NumericVector x, NumericVector lb, NumericVector ub) {
  int n = x.size();
  NumericVector transformed_x(n);
  for(int i = 0; i < n; ++i) {
    transformed_x[i]= x[i]*(ub[i]-lb[i])+lb[i];
  }
  return transformed_x;
}'
)

cppFunction(
  'NumericVector anti_transformation(NumericVector x, NumericVector lb, NumericVector ub) {
  int n = x.size();
  NumericVector transformed_x(n);
  for(int i = 0; i < n; ++i) {
    transformed_x[i]= (x[i]-lb[i])/(ub[i]-lb[i]);
  }
  return transformed_x;
}'
)

cppFunction(
  'NumericVector update_x(NumericVector x, double epsilon, double rho, double epsilon_cut_off) {
  int n = x.size();
  int j = 0;
  NumericVector x_updated(2*n);
  double current_value = 0;
  double updated_value = 0;
  double epsilon_temp = 0;
  float ff = 0;
  int f = 0;
  for(int i = 0; i < (2*n); ++i) {
    j = ceil(i/2);
    epsilon_temp = pow(-1,i)*epsilon;
    current_value = x[j];
    updated_value = current_value+epsilon_temp;
    if(updated_value > 1 && current_value < 1-epsilon_cut_off)
            { ff = log(epsilon_temp/(1-current_value))/log(rho);
              f = ceil(ff);
              epsilon_temp = epsilon_temp/pow(rho,f);
              updated_value = current_value+epsilon_temp;
            }
    else
            {if(updated_value < 0 && current_value > epsilon_cut_off)
            { ff = log(-epsilon_temp/current_value)/log(rho);
              f = ceil(ff);
              epsilon_temp = epsilon_temp/pow(rho,f);
              updated_value = current_value+epsilon_temp;
            }}
    if(updated_value > 1  || updated_value < 0)
            {updated_value = current_value;
            }
    x_updated[i] = updated_value;
  }
  return x_updated;
}'
)

start_time <- Sys.time()

theta_array <- matrix(0, no_loops, M)
each_run_solution <- array(0, no_loops)


for (iii in 1:no_loops)
{
  epsilon <- 0.6777
  if (iii == 1)
  {
    rho <- rho_1
    theta <- anti_transformation(starting_point, lb, ub)
    if (max(abs(theta)) > 1 ||
        max(abs(theta)) < 0)
    {
      print("Starting point is outside the domain")
      break
    }
  }
  else{
    theta <- as.array(theta_array[iii - 1, ])
    rho <- rho_2
  }
  
  array_of_values <- array(0, max_iter)
  for (i in 1:max_iter)
  {
    current_lh <- f(transformation(theta, lb, ub))
    possible_x_coords <-
      update_x(theta, epsilon, rho, epsilon_cut_off)
    total_lh <- rep(1, 2 * M)
    for (kk in 1:(2 * M))
    {
      candidate_theta <- theta
      coord_number <- ceil(kk / 2)
      if (possible_x_coords[kk] == theta[coord_number])
      {
        total_lh[kk] <- current_lh
      }
      else
      {
        candidate_theta[coord_number] <- possible_x_coords[kk]
        total_lh[kk] <- f(transformation(candidate_theta, lb, ub))
      }
    }
    new_min <- min(total_lh)
    if (new_min < current_lh)
    {
      position_new_min <- which.min(total_lh)
      pos_of_theta <- ceil(position_new_min / 2)
      theta[pos_of_theta] <- possible_x_coords[position_new_min]
    }
    array_of_values[i] <- min(new_min,current_lh)
    
    if(print_output == 1)
    {cat('\n','Run no. ', iii,',iteration no.', i,', current fun value = ',array_of_values[i])}
    
    if (i > 1)
    {
      if (abs(array_of_values[i] - array_of_values[i-1]) < tol_fun)
      {
        if (abs(epsilon) > epsilon_cut_off)
        {
          epsilon <- epsilon / rho
        }
        else
        {
          break
        }
      }
      
    }
  }
  theta_array[iii, ] <- t(theta)
  each_run_solution[iii] <- f(transformation(theta, lb, ub))
  
  if (iii > 1)
  {
    old_soln <- theta_array[iii - 1, ]
    new_soln <- theta_array[iii, ]
    if (norm(as.matrix(new_soln - old_soln)) < tol_fun_2)
    {
      break
    }
  }
  
}
end_time <- Sys.time()
time_spent <- as.numeric(end_time - start_time)
final_value <- f(transformation(theta, lb, ub))

paste0("Starting objective function value:  ", start_value)
paste0("Final objective function value:  ", final_value)
paste0("Total time required (in secs):  ", time_spent)
paste0("Obtained minima point is :  ")
transformation(theta, lb, ub)
