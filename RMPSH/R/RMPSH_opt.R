#' Recursive Modified Direct Search on Hyper-rectangle
#'
#' `RMPSH_opt` can be used to minimize any non-convex blackbox function where each parameter
#' has an upper and lower bound.
#'
#'
#' @param x0 vector of initial guess provided by user.
#' @param func the function to be optimized, should be provided by the user.
#' @param lb vector of lower bounds, of same dimension as 'x0'.
#' @param ub vector of upper bound, of same dimension as 'x0'.
#' @param rho_1 'step decay rate' for the first run only (default is 2).
#' @param rho_2 'step decay rate' for second run onwards (default is 2).
#' @param phi lower bound of 'global step size'. Default value is \eqn{10^{-6}}.
#' @param no_runs max number of 'runs'. Default Value is 1000.
#' @param max_iter max number of iterations in each 'run'. Default Value is 10000.
#' @param s_init initial  'global step size'. Default Value is 2. It must be set less than or equal to 2.
#' @param tol_fun termination tolerance on when to decrease the 'global step size'. Default Value is \eqn{10^{-6}}. For more accuracy, user may set it to smaller value
#' e.g., \eqn{10^{-20}}. However, for expensive objective functions, for faster computation, user should set it to a larger value e.g, \eqn{10^{-3}}.
#' @param tol_fun_2 termination tolerance on the difference of norms of solution points in two consecutive runs. Default Value is \eqn{10^{-20}}.
#' However, for expensive objective functions, for faster computation, user should set it to a larger value e.g, \eqn{10^{-6}}.
#' @param max_time time alloted (in seconds) for execution of RMPSH. Default is 36000 secs (10 hours).
#' @param verbose Binary Command to print optimized value of objective function after each interation, 0 = no print, 1 = print. Default is 0.
#' @return the optimal solution point.
#'
#' @examples
#' g <- function(y)
#' return(-20 * exp(-0.2 * sqrt(0.5 * (y[1] ^ 2 + y[2] ^ 2)))
#'  - exp(0.5 * (cos(2 * pi * y[1]) + cos(2 * pi * y[2])))
#'  + exp(1) + 20)
#'
#' starting_point <- rep(1,10)
#' g(starting_point)
#' solution <- RMPSH_opt(starting_point,g, rep(-33,10), rep(33,10))
#' g(solution)
#'
#' # Will print the updates after each iteration
#' RMPSH_opt(c(2,4,6,2,1),g,rep(-3,5), rep(23,5), verbose = 1)
#'
#' # Will exit and return result after 2 seconds
#' g <- function(y) { return(sum(y^2)) }
#' RMPSH_opt(rep(2.3,100),g, rep(-11,100), rep(13,100), max_time = 2, verbose = 1)
#'@name RMPSH_opt
NULL

#' @rdname RMPSH_opt
#' @export
RMPSH_opt <-
  function(x0,
           func,
           lb,
           ub,
           rho_1 = 2,
           rho_2 = 2,
           phi = 10 ^ (-6),
           no_runs = 1000,
           max_iter = 10000,
           s_init = 2,
           tol_fun = 10 ^ (-6),
           tol_fun_2 = 10 ^ (-20),
           max_time = 36000,
           verbose = 0)
  {

    M <- length(x0)
    start_value <- func(x0)
    start_time <- Sys.time()

    theta_array <- matrix(0, no_runs, M)
    each_run_solution <- array(0, no_runs)

    ill_condition <- 0
    for (iii in 1:no_runs)
    {
      epsilon <- s_init
      if (iii == 1)
      {
        rho <- rho_1
        theta <- anti_transformation(x0, lb, ub)
        if(min(ub-lb) <0 )
        {
          print("upper bound should be greater than lower bound")
          break
        }
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
      if(ill_condition == 1)
      {
        break
      }

      array_of_values <- array(0, max_iter)
      for (i in 1:max_iter)
      {
        current_lh <- func(transformation(theta, lb, ub))
        possible_x_coords <-
          update_x(theta, epsilon, rho, phi)
        total_lh <- rep(1, 2 * M)

        for (kk in 1:(2 * M))
        {
          candidate_theta <- theta
          coord_number <- ceiling(kk / 2)
          if (possible_x_coords[kk] == theta[coord_number])
          {
            total_lh[kk] <- current_lh
          }
          else
          {
            candidate_theta[coord_number] <- possible_x_coords[kk]
            total_lh[kk] <-
              func(transformation(candidate_theta, lb, ub))
          }
        }
        new_min <- min(total_lh)
        if (new_min < current_lh)
        {
          position_new_min <- which.min(total_lh)
          pos_of_theta <- ceiling(position_new_min / 2)
          theta[pos_of_theta] <- possible_x_coords[position_new_min]
        }
        array_of_values[i] <- min(new_min, current_lh)

        if (verbose == 1)
        {
          cat(
            '\n',
            'Run no. ',
            iii,
            ',iteration no.',
            i,
            ', current fun value = ',
            array_of_values[i]
          )
        }

        if (i > 1)
        {
          if (abs(array_of_values[i] - array_of_values[i - 1]) < tol_fun)
          {
            if (abs(epsilon) > phi)
            {
              epsilon <- epsilon / rho
            }
            else
            {
              break
            }
          }

        }
        now_time <- Sys.time()
        now_time_spent <- as.numeric(now_time - start_time)

        if (now_time_spent > max_time)
        {
          print("Time's up")
          paste0("Starting objective function value:  ", start_value)
          paste0("Final objective function value:  ", current_lh)
          ill_condition <- 1
          break
        }
      }

      theta_array[iii, ] <- t(theta)
      each_run_solution[iii] <- func(transformation(theta, lb, ub))

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
    final_value <- func(transformation(theta, lb, ub))

    paste0("Starting objective function value:  ", start_value)
    paste0("Final objective function value:  ", final_value)
    paste0("Total time required (in secs):  ", time_spent)
    paste0("Obtained minima point is :  ")
    transformation(theta, lb, ub)
    return(transformation(theta, lb, ub))
  }
