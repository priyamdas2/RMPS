clear all

which_algo = 1; % 1 = EHUM, 2 = ULBA

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

M = num_total_covs;
rng(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(which_algo == 1)
    fun = @(theta)-fun_EHUM(theta, sample_sizes, X_mat);
else
    if(which_algo == 2)
        fun = @(theta)-fun_ULBA(theta, sample_sizes, X_mat);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
neg_individual_EHUM = zeros(num_total_covs,1);
for ii = 1:num_total_covs
    dummy_theta = zeros(num_total_covs,1);
    dummy_theta(ii) = 1;
    neg_individual_EHUM(ii) = -max(fun_EHUM(dummy_theta, sample_sizes, X_mat),...
        fun_EHUM(-dummy_theta, sample_sizes, X_mat));
end

[values, order_var] = sort(neg_individual_EHUM);
rev_order_var = zeros(length(order_var),1);
rev_order_var(order_var) = 1:length(order_var);

lambdas = ones(num_total_covs,1);
if(fun_EHUM(1, sample_sizes, X_mat(order_var(1),:)) >...
        fun_EHUM(-1, sample_sizes, X_mat(order_var(1),:)))
    lambdas(1) = 1;
else
    lambdas(1) = -1;
end

starting_points = ones(num_total_covs,1);
solutions = ones(num_total_covs,1);
solutions(1) = -999;
rng(1)
for ii = 2:num_total_covs
    X_mat_here = X_mat(order_var(1:ii),:);
    starting_points(ii) = rand(1,1);
    if(which_algo == 1)
        fun = @(x)-fun_EHUM([lambdas(1:(ii-1)); x], sample_sizes, X_mat_here);
    else
        if(which_algo == 2)
            fun = @(x)-fun_ULBA([lambdas(1:(ii-1)); x], sample_sizes, X_mat_here);
        end
    end
    lambda_now = fminsearch(fun,starting_points(ii));
    lambdas(ii) = lambda_now;
    solutions(ii) = fun(lambdas(ii));
end

theta = lambdas(rev_order_var);
solution = -fun_EHUM(lambdas, sample_sizes, X_mat_here)
-fun_EHUM(theta, sample_sizes, X_mat)

algo_times = toc;
output =[-fun_EHUM(theta, sample_sizes, X_mat); algo_times;theta];


if(which_algo == 1)
    filename = ['AL_EHUM_STEPDOWN.csv'];
else
    if(which_algo == 2)
        filename = ['AL_ULBA_STEPDOWN.csv'];
    end
end

csvwrite(filename,output)

















