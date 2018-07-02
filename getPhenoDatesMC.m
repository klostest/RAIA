function [R, six_dates, six_dates_MC, model_y_MC,...
    quants, lower_quants, upper_quants, quant_interval] = ...
    getPhenoDatesMC(model_name, params, model_t, model_y,...
    date_method, percentiles, cut_off_dates, fhandle,...
    resnorm, residual, jacobian, n, cond_number_crit,...
    time_num, gcc)
%============================================
%Outputs:
% R:  the n sets of parameters
% 
%============================================
% Stephen Klosterman
% Original version 11/20/2011
% steve.klosterman@gmail.com
%============================================
switch model_name
    case 'greenDownSigmoid'
        n_params = size(params{1}, 2);
        n_obs = size(model_t{1}, 2);
    case 'separateSigmoids'
        n_params = size(params{1}, 2);
        n_obs = size(residual{1}{2}, 1);    %Not the full year
        load('CCR_formula.mat', 'Kprime');
    case 'smoothInterp'
        time_num = date2doy(time_num);
end

%Quantiles for interval on Monte Carlo ensemble of dates
quants = [0.025, 0.975];
    
%% get pheno dates
for i = 1:size(gcc, 2)
    %% Get n samples of parameter space
    % First calculate covariance matrix for a given year 
    %     Jacobian = full(Jacobian); 
    %lsqnonlin returns the Jacobian as a sparse matrix
    %     varp = resnorm*inv(Jacobian'*Jacobian)/N;
    switch model_name
        case 'greenDownSigmoid'
            if size(residual{i}, 1) ~= 1
                jacobian{i} = full(jacobian{i});
                temp1 = jacobian{i}' * jacobian{i};
                %As seen here:  http://www.gnu.org/software/gsl/manual/html_node/Computing-the-covariance-matrix-of-best-fit-parameters.html
                %eliminate rows and columns with a small diagonal element from
                %this matrix and set the corrsponding rows and columns of the
                %covariance matrix to zero
                %throw out rows and columns with small diag entries
                %Anything smaller than this will be flagged; make larger
                %to be more restrictive.
%                 smallCovarTol = 0;%0.0001;
% 
%                 %experiment with this.  on website
%                 %it was defined in terms of other parameter sensitivities
%                 %For greendown sigmoid, tried 1, but parameter variances wound
%                 %up being extremely small.
%                 smallDiag = diag(temp1)<smallCovarTol;
%                 nSmallDiag = sum(smallDiag);
% 
%                 if nSmallDiag > 0
%                     for k = n_params:-1:1
%                         if smallDiag(k) == 1
%                             temp1(k,:) = [];
%                             temp1(:,k) = [];
%                         end
%                     end
%                 end




                
%                 if nSmallDiag > 0
%                     %add zeros back in for insensitive parameters
%                     covarMask = ones(n_params);
%                     for k = 1:n_params
%                         if smallDiag(k) == 1
%                             covarMask(k,:) = zeros(1,n_params);
%                             covarMask(:,k) = zeros(n_params,1);
%                         end
%                     end
%                     covarMask = logical(covarMask);
%                     covar{i} = zeros(n_params);
%                     covar{i}(covarMask) = tempCovar{i};
%                 else
%                     covar{i} = tempCovar{i};
%                 end


                
                %Only try if passes condition number test
%                 rcond(temp1)
                if rcond(temp1) > cond_number_crit
                    
                    %compute possibly reduced covariance matrix
                    temp2 = inv(temp1);
                    tempCovar{i} = resnorm{i} * temp2 ... %\eye(size(jacobian{j},2)) ...
                        / (n_obs-n_params);
                
                    %Comment this if trying zero rows and columns in covar
                    %matrix
                    covar{i} = tempCovar{i};
                
                    try
                        %Uncomment to have no criteria for covariance matrix
                        R{i} = mvnrnd(params{i},covar{i},n);
                        %throw out sets where parameters 4 or 6 are negative
                        certainParamsPos = (R{i}(:,4)>0) & (R{i}(:,6)>0);
                        pos_param_mask = repmat(certainParamsPos, 1, 7);
                        R{i} = R{i}(pos_param_mask);
                        R{i} = reshape(R{i}, size(R{i},1)/7, 7);
                    catch
                        R{i} = NaN;
                    end
                
                else
                    R{i} = NaN;
                end

%                 %are any elements of the covariance matrix NaN or Inf?
%                 if sum(sum(isfinite(covar{i}))) == size(covar{i},1)*...
%                         size(covar{i},2);
% 
%         %             flag negative eigenvalues indicating mvnrnd will not work
%                     eigV = eig(covar{i});
%                     if sum(eigV<0) > 0, R{i} = NaN;
%                     else
%                         R{i} = mvnrnd(params{i},covar{i},n);
%                         %throw out sets where parameters 4 or 6 are negative
%                         certainParamsPos = (R{i}(:,4)>0) & (R{i}(:,6)>0);
%                         pos_param_mask = repmat(certainParamsPos, 1, 7);
%                         R{i} = R{i}(pos_param_mask);
%                         R{i} = reshape(R{i}, size(R{i},1)/7, 7);
%                     end
% 
%                 else
%                 R{i} = NaN;
%                 end
            end
        case 'separateSigmoids'
            %All secondary indices should be one, as only doing spring here
            if size(residual{i}{1}, 1) ~= 1
                jacobian{i}{1} = full(jacobian{i}{1});
                temp1 = jacobian{i}{1}' * jacobian{i}{1};
                if rcond(temp1) > cond_number_crit
                    
                    %compute possibly reduced covariance matrix
                    temp2 = inv(temp1);
                    tempCovar{i} = resnorm{i}(1) * temp2 ... %\eye(size(jacobian{j},2)) ...
                        / (n_obs-n_params);
                
                    %Comment this if trying zero rows and columns in covar
                    %matrix
                    covar{i} = tempCovar{i};
                
                    try
                        %Uncomment to have no criteria for covariance matrix
                        R{i} = mvnrnd(params{i}(1,:),covar{i},n);
%                         %throw out sets where parameters 4 or 6 are negative
%                         certainParamsPos = (R{i}(:,4)>0) & (R{i}(:,6)>0);
%                         pos_param_mask = repmat(certainParamsPos, 1, 7);
%                         R{i} = R{i}(pos_param_mask);
%                         R{i} = reshape(R{i}, size(R{i},1)/7, 7);
                    catch
                        R{i} = NaN;
                    end
                
                else
                    R{i} = NaN;
                end
            end
    end
    
    %% generate phenodates for each parameter sample
    %Or get CIs based on the data in the case of redness
        
    switch model_name
        case 'greenDownSigmoid'
            switch date_method
                case 'CCR'
                    six_dates(:,i) = CCRgd(params{i}, model_t{i},...
                        fhandle, time_num, gcc(:,i));
                    
                    %plot
%                     h = figure;
%                     time_num = date2doy(time_num);
%                     plot(time_num, gcc(:,i), 'x');
%                     hold on;
%                     for k = 1:6
%                         plot([six_dates(k) six_dates(k)], [0.35 0.4]);
%                     end
%                     close(h);

                %% generate phenodates for each parameter sample
                    if size(residual{i}, 1) ~= 1    %Test to see if
                        %curve fitting worked, i.e. residual should have
                        %more than one elemen?

                        six_dates_MC{i} = NaN*ones(6,size(R{i},1));
                        for j = 1:size(R{i},1)
                            if ~isnan(R{i})
                                six_dates_MC{i}(:,j) = CCRgd(R{i}(j,:),...
                                model_t{i},...
                                fhandle, time_num, gcc(:,i))';

                                model_y_MC{i}(:,j) = ...
                                    fhandle(R{i}(j,:), model_t{i});
    %                             %remove dates where parameters 4 or 6 are non positive
    %                             if (six_dates_MC{i}(4,j) <= 0) ||...
    %                                     (six_datesMC{i}(6,j) <= 0)
    %                                 six_dates_MC{i}(:,j) = NaN*ones(6,1);
    %                             end
                            else
                                six_dates_MC{i} = NaN*ones(6,1);
                                model_y_MC{i} = ...
                                    NaN*ones(length(model_t{i}),1);
                            end
                        end
                        
                        %Get quantiles on dates
                        lower_quants{i} = ...
                            quantile(six_dates_MC{i}, quants(1), 2);
                        upper_quants{i} = ...
                            quantile(six_dates_MC{i}, quants(2), 2);
                        quant_interval{i} = ...
                            upper_quants{i} - lower_quants{i};

                    end
            end
        case 'separateSigmoids'
            switch date_method
                case 'CCR'
                    temp = CCR(params{i}(1,:),...
                        model_t{i}( model_t{i} <= cut_off_dates{i}(1) ),...
                        Kprime, fhandle, time_num, gcc(:,i))';
                    six_dates(1:3,i) = temp;
                    six_dates(4:6,i) = NaN;
                    
                    %plot
%                     h = figure;
%                     time_num = date2doy(time_num);
%                     plot(time_num, gcc(:,i), 'x');
%                     hold on;
%                     for k = 1:6
%                         plot([six_dates(k) six_dates(k)], [0.35 0.4]);
%                     end
%                     close(h);

                %% generate phenodates for each parameter sample
                    if size(residual{i}{1}, 1) ~= 1    %Test to see if
                        %curve fitting worked, i.e. residual should have
                        %more than one elemen?

                        six_dates_MC{i} = NaN*ones(6,size(R{i},1));
                        for j = 1:size(R{i},1)
                            if ~isnan(R{i})
                                temp = CCR(R{i}(j,:),...
                                    model_t{i}( model_t{i} <= cut_off_dates{i}(1) ),...
                                    Kprime, fhandle, time_num, gcc(:,i))';
                                six_dates_MC{i}(1:3,j) = temp;
                                six_dates_MC{i}(4:6,j) = NaN;

                                model_y_MC{i}(:,j) = NaN;
    %                             %remove dates where parameters 4 or 6 are non positive
    %                             if (six_dates_MC{i}(4,j) <= 0) ||...
    %                                     (six_datesMC{i}(6,j) <= 0)
    %                                 six_dates_MC{i}(:,j) = NaN*ones(6,1);
    %                             end
                            else
                                six_dates_MC{i} = NaN*ones(6,1);
                                model_y_MC{i} = ...
                                    NaN*ones(length(model_t{i}),1);
                            end
                        end
                        
                        %Get quantiles on dates
                        lower_quants{i} = ...
                            quantile(six_dates_MC{i}, quants(1), 2);
                        upper_quants{i} = ...
                            quantile(six_dates_MC{i}, quants(2), 2);
                        quant_interval{i} = ...
                            upper_quants{i} - lower_quants{i};

                    end
            end
        case 'smoothInterp'
            R = NaN;
            switch date_method
                case 'spring_fall_red'
                    six_dates(:,i) = spring_fall_red(time_num,...
                        gcc(:,i), percentiles, []);
                    %Generate interval for each of six dates
                    for j = 1:6
                        %Error handling if first observation date is the
                        %transition date: throw out date (I think this is what
                        %Archetti did)
                        %Also if is NaN
                        if (six_dates(j,i) == time_num(1)) ||...
                                isnan(six_dates(j,i))
                            six_dates(j,i) = NaN;
                            lower_quants(j,i) = NaN;
                            upper_quants(j,i) = NaN;
                        else
                            %If transition is between two observation dates, the CI
                            %is the (inclusive) interval between those dates
                            [isin, loc] = ismember(six_dates(j,i), time_num);
                            if ~isin
                                %Take raw data time right before this as low end of
                                %confidence interval
                                lower_quants(j,i) = ...
                                    max(time_num(time_num<six_dates(j,i)));
                                %Take time right after as high end
                                upper_quants(j,i) = ...
                                    min(time_num(time_num>six_dates(j,i)));
                                %For checking
            %                     disp(pheno_dates(i,j,k) >= conf_int_low(i,j,k))
            %                     disp(pheno_dates(i,j,k) <= conf_int_high(i,j,k))
                            else %Use interval half-way on either side
                                lower_quants(j,i) = ...
                                    time_num(loc-1) + 0.5*(time_num(loc) - ...
                                    time_num(loc-1));
                                upper_quants(j,i) = ...
                                    time_num(loc) + 0.5*(time_num(loc+1) - ...
                                    time_num(loc));
                            end
                        end
                        
                    end
                    quant_interval(:,i) = ...
                        upper_quants(:,i) - lower_quants(:,i);
                    six_dates_MC = NaN; model_y_MC = NaN;
                    quants = NaN;
            end
    end

%         six_datesMC_low95(j,:) = quantile(six_datesMC{j}', 0.025);
%         six_datesMC_high95(j,:) = quantile(six_datesMC{j}', 0.975);
        fprintf('generated phenodates for pixel %d\n', i);
        
        %Test plot
%         plot(model_t{i}, model_y_MC{i}, 'color', 'blue'); hold on;
%         plot(model_t{i}, model_y{i}, 'LineWidth', 3, 'Color', 'red');
%         title([num2str(i) ' of ' num2str(length(model_t))]);
%         close(gcf);
end