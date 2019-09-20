function EHUM_prob = fun_EHUM(theta, sample_sizes, X_mat)
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

connections = cell(no_varieties-1,1);
for iii = 1:(no_varieties-1)
    connections{iii} = zeros(1,2);
    for jjj = 1:sample_sizes(iii)
        for kkk = 1:sample_sizes(iii+1)
            if(beta_x(iii,jjj)<beta_x(iii+1,kkk))  %% change here than SHUM
                connections{iii} = [connections{iii};[jjj,kkk]];
            end
        end
    end
    connections{iii}(1,:) = [];
end

% for iii = 1:(no_varieties-2)
%     to_be_deleted = setdiff(connections{iii}(:,2),connections{iii+1}(:,1));
%     if(length(to_be_deleted)>=1)
%         connections{iii}(find(ismember(connections{iii}(:,2),to_be_deleted)),:) = [];
%     end
% end

if(no_varieties>2)
    for iii = 1:(no_varieties-2)
        count_here_2 = 0;
        if(iii == 1)
            connection_mat = 999*ones(size(connections{iii},1),no_varieties);
            connection_mat(:,1:2) = connections{iii};
        end
        for jjj = 1:size(connections{iii},1)
            positions = find(connections{iii+1}(:,1) == connections{iii}(jjj,2));
            if(length(positions)>=1)
                temp = repmat(connection_mat(count_here_2+1,:),length(positions),1);
                temp(:,iii+2) = connections{iii+1}(positions,2);
                if(count_here_2 == 0)
                    connection_mat = [temp;connection_mat(2:end,:)];
                else
                    connection_mat_upper = [connection_mat(1:count_here_2,:);temp];
                    connection_mat = [connection_mat_upper;connection_mat((count_here_2+2):end,:)];
                end
                count_here_2 = count_here_2+ length(positions);
            else
                connection_mat(count_here_2+1,:) = [];
            end
        end
    end
else
    connection_mat = connections{1};
end
EHUM_prob = size(connection_mat,1)/prod(sample_sizes);
end

%size(connections{1})


