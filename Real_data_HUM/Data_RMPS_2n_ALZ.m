clear all

which_algo = 2; % 1 = EHUM, 2 = ULBA

%%%% DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DATA = csvread('AL_MATLAB.csv');

categories = unique(DATA(:,1));
DATA_arranged = DATA(DATA(:,1) == categories(1),:)';
sample_sizes = sum(DATA(:,1) == categories(1));
for ii = 2:length(categories)
    DATA_arranged = [DATA_arranged,DATA(DATA(:,1) == categories(ii),:)'];
    sample_sizes = [sample_sizes,sum(DATA(:,1) == categories(ii))];
end
X_mat = DATA_arranged(2:end,:);
X_mat([1,5],:) = [];  %%% Deleting covariates 1-st and 5-th 
num_total_covs = size(X_mat,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%Defining objective functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(which_algo == 1)
    fun = @(beta)-fun_EHUM(beta, sample_sizes, X_mat);
else
    if(which_algo == 2)
        fun = @(beta)-fun_ULBA(beta, sample_sizes, X_mat);
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Deciding first coordinate is +1 or -1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(fun_EHUM(-1, sample_sizes, X_mat(1,:))>...
        fun_EHUM(1, sample_sizes, X_mat(1,:)))
    first_position = -1;
else
    first_position = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%% RMPSSP parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = num_total_covs-1;   % First coeff is taken to be +1 or -1, only rest are estimated
lb = (-10)*ones(M,1);   % lower bound
ub = (10)*ones(M,1);    % upper bound
no_loops = 1000;
maximum_iteration = 10000;
tol_fun = 10^-6;
rho_1 = 2;
rho_2 = 2;
tol_fun_2 = 10^-20;
epsilon_cut_off = 10^(-20);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% Starting point %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(1)
starting_point = rand(M,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

transformation = @(theta)(theta.*(ub - lb)+ lb);


tic;
array_of_values = zeros(maximum_iteration,1);
theta_array = zeros(no_loops, M);
Loop_solution = zeros(no_loops, 1);

for iii = 1:no_loops
    epsilon = 1;
    epsilon_decreasing_factor = rho_1; % default is 2
    if(iii == 1)
        epsilon_decreasing_factor = rho_2; % default is 2
        theta = starting_point;
    else
        theta = transpose(theta_array((iii-1),:));
    end
    
    
    for i = 1:maximum_iteration
        
        current_lh_1 = fun([first_position;transformation(theta)]);
        if(min(ge(theta,0)) == 0)
            stop('error')
        end
        
        temp_possibility_pos = zeros(M,1);
        temp_possibility_neg = zeros(M,1);
        total_lh_pos = zeros(M,1);
        total_lh_neg = zeros(M,1);
        
        
        total_lh = zeros(2*M,1);
        matrix_update_at_h = zeros(M,2*M);
        
        
       for location_number = 1:(2*M)           % can be parallelized
            change_loc  = ceil(location_number/2);
            epsilon_temp = ((-1)^location_number)*epsilon;
            possibility = theta;
            value_at_position = possibility(change_loc);
            possibility_temp = value_at_position + epsilon_temp;
            
            if(possibility_temp > 1 && value_at_position < 1)
                ff = log(epsilon_temp/(1-value_at_position))/log(epsilon_decreasing_factor);
                f = ceil(ff);
                epsilon_temp = epsilon_temp/(epsilon_decreasing_factor)^f;
            else
                if(possibility_temp < 0 && value_at_position > 0)
                    ff = log(-epsilon_temp/value_at_position)/log(epsilon_decreasing_factor);
                    f = ceil(ff);
                    epsilon_temp = epsilon_temp/(epsilon_decreasing_factor)^f;
                end
            end

            if(abs(epsilon_temp)> epsilon_cut_off)
                possibility(change_loc) = value_at_position + epsilon_temp;
                total_lh(location_number) = fun([first_position;transformation(possibility)]);
                matrix_update_at_h(:,location_number) = possibility;
            else
                total_lh(location_number) = current_lh_1;
                matrix_update_at_h(:,location_number) = theta;
            end
        end
       
        [candidate,I] = min(total_lh);
    
        if(candidate < current_lh_1)
            theta = matrix_update_at_h(:,I);
        end
        array_of_values(i) =  min(candidate,current_lh_1);
        [iii, i, current_lh_1, array_of_values(i), epsilon]
        
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
    Loop_solution(iii) = fun([first_position;transformation(theta)]);
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
[first_position;transformation(theta)]           % Final coefficient vector 
-fun([first_position;transformation(theta)])     % Final EHUM value

output =[-fun([first_position;transformation(theta)]); required_time;[first_position;transformation(theta)]];

if(which_algo == 1)
    filename = ['AL_EHUM_RMPS.csv'];
else
    if(which_algo == 2)
        filename = ['AL_ULBA_RMPS.csv'];
    end
end

csvwrite(filename,output)