function ULBA = fun_ULBA(theta, sample_sizes, X_mat)
theta = theta/norm(theta);
no_varieties = length(sample_sizes);
beta_x = 999*ones(no_varieties,max(sample_sizes));
beta_cross_X_mat = transpose(theta)*X_mat;
count_here = 0;
for ii = 1:no_varieties
    for jj = 1:sample_sizes(ii)
        beta_x(ii,jj) = beta_cross_X_mat(1,count_here+jj);
    end
    count_here = count_here + sample_sizes(ii);
end

Counts_here = zeros(no_varieties-1,1);
for ii = 1:(no_varieties-1)
    Counts_here(ii) = 0;
    for jj = 1:sample_sizes(ii)
        for kk = 1:sample_sizes(ii+1)
            if(beta_x(ii,jj) < beta_x(ii+1,kk))
                Counts_here(ii) = Counts_here(ii)+1;
            end
        end
    end
    Counts_here(ii) = Counts_here(ii)/(sample_sizes(ii)*sample_sizes(ii+1));
end
ULBA = sum(Counts_here) - (no_varieties-2);

end

%size(connections{1})


