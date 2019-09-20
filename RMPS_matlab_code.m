%%%%%%%%%%%%%%%%%%%%% Citation information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Das, P. (2019+), Black-box optimization on hyper-rectangle using Recursive Modified Pattern
% Search and application to ROC-based Classification Problem, https://arxiv.org/pdf/1604.08616.pdf


clear all

%%%%%%%%%%%% USER input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(1)
print_output = 1;             % 0 for no update print, 1 to print.
M = 10;                        % Dimension
lb = (-33)*ones(M,1);             % lower bound
ub = (33)*ones(M,1);              % upper bound
starting_point = 20*(2*rand(M,1)-1); % uniformly from (-20,20) interval.

%%%%%%%%%%%%% function input (M-dimensional Ackley's function) %%%%%%%%%%

fun = @(theta) (-20*exp(-0.2*sqrt(1/M*sum(theta.^2)))-exp(1/M*sum(cos(2*pi*theta)))...
    +20+exp(1));

start_value = fun(starting_point);
%%%%%%%% RMPSSP parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

no_loops = 1000;
maximum_iteration = 10000;
tol_fun = 10^-6;
rho_1 = 2;
rho_2 = 2;
tol_fun_2 = 10^-20;
epsilon_cut_off = 10^(-20);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% RMPS algorithm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

transformation = @(theta)(theta.*(ub - lb)+ lb);
anti_transformation = @(theta)((theta-lb)./(ub - lb));

tic;
array_of_values = zeros(maximum_iteration,1);
theta_array = zeros(no_loops, M);
Loop_solution = zeros(no_loops, 1);

for iii = 1:no_loops
    epsilon = 1;
    epsilon_decreasing_factor = rho_1; 
    if(iii == 1)
        epsilon_decreasing_factor = rho_2;
        theta = anti_transformation(starting_point);
    else
        theta = transpose(theta_array((iii-1),:));
    end
    
    
    for i = 1:maximum_iteration
        
        current_lh_1 = fun(transformation(theta));
        if(min(ge(theta,0)) == 0)
            stop('error')
        end
        
        temp_possibility_pos = zeros(M,1);
        temp_possibility_neg = zeros(M,1);
        total_lh_pos = zeros(M,1);
        total_lh_neg = zeros(M,1);
        
        
        total_lh = zeros(2*M,1);
        matrix_update_at_h = zeros(M,2*M);
        
        
       for location_number = 1:(2*M)           % can be parallelized using 'parfor'
            change_loc  = ceil(location_number/2);
            epsilon_temp = ((-1)^location_number)*epsilon;
            possibility = theta;
            value_at_position = possibility(change_loc);
            possibility_temp = value_at_position + epsilon_temp;
            
            if(possibility_temp > 1 && value_at_position < 1 - epsilon_cut_off)
                ff = log(epsilon_temp/(1-value_at_position))/log(epsilon_decreasing_factor);
                f = ceil(ff);
                epsilon_temp = epsilon_temp/(epsilon_decreasing_factor)^f;
                possibility_temp = value_at_position + epsilon_temp;
            else
                if(possibility_temp < 0 && value_at_position > epsilon_cut_off)
                    ff = log(-epsilon_temp/value_at_position)/log(epsilon_decreasing_factor);
                    f = ceil(ff);
                    epsilon_temp = epsilon_temp/(epsilon_decreasing_factor)^f;
                    possibility_temp = value_at_position + epsilon_temp;
                end
            end

            if(possibility_temp < 0 || possibility_temp > 1)
                total_lh(location_number) = current_lh_1;
                matrix_update_at_h(:,location_number) = theta;
            else
                possibility(change_loc) = possibility_temp;
                total_lh(location_number) = fun(transformation(possibility));
                matrix_update_at_h(:,location_number) = possibility;
            end
        end
       
        [candidate,I] = min(total_lh);
    
        if(candidate < current_lh_1)
            theta = matrix_update_at_h(:,I);
        end
        array_of_values(i) =  min(candidate,current_lh_1);
        if (mod(i,10)==0 && print_output == 1)
            fprintf('%d th run...%d iterations finished, current obj. fun value %d \n', iii, i, array_of_values(i))
        end
        
        
        if(i > 1)
            if(abs(array_of_values(i) - array_of_values(i-1)) < tol_fun)
                if(epsilon > epsilon_cut_off)
                    epsilon = epsilon/epsilon_decreasing_factor;
                else
                    break
                end
            end
        end
        
    end
    theta_array(iii,:) = transpose(theta);
    Loop_solution(iii) = fun(transformation(theta));
    transpose(theta);
    if(iii > 1)
        old_soln = theta_array(iii-1,:);
        new_soln = theta_array(iii,:);
        if(norm(old_soln - new_soln) <tol_fun_2)
            break
        end
    end
end
required_time = toc;
final_solution_point = transformation(theta);
final_value = fun(final_solution_point); 

fprintf('Starting value %d, final value %d, obtained in %d seconds\n', start_value, final_value, required_time)
fprintf('Global optimum is achieved at \n')
final_solution_point'


