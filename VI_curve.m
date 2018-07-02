function [params, modelT, modelY, cut_off_dates, fhandle,...
    resnorm, residual, jacobian, extended_t, extended_y] = ...
    VI_curve(time_num, index_data, model_name, data_frac,...
    species_name,...
    stem_tag)
%============================================
%% description
% This function fits a model to preprocessed vegetation index time series
% data.
% Results, including modeled vegetation index values and estimated
% parameters, are saved in the directory containing the data.
%
%% inputs
% 'siteInfo' is a string which is the filename of a .mat file in the current
% directory, containing information about the preprocessing session.  See
% below for 'example arguments' to work with the sample data.
% siteInfo = 'phenocam-siteInfo-BoundaryWaters';
% siteInfo = 'phenocam-siteInfo-HarvardTree3GWW';
% siteInfo = 'HarvardTowerBroad-EVI-siteInfo';
%
% 'model_name' is a string containing the type of function fit to the data.
% Possible arguments are: 'separateSigmoids'  See below for example
% arguments to work with the sample data.
% model_name = 'greenDownSigmoid';
% model_name = 'separateSigmoids';
%
%% dependencies
% This function calls model and estimator functions specified by the
% handles 'estimatorHandle' and 'fhandle'
%
%============================================
% Stephen Klosterman
% 11/20/2011
% steve.klosterman@gmail.com
%============================================

% %Approximation for uncertainty due to illumination differences.  For 5/18
% %(the 4th image) and 6/5 (the 7th), increase all GCC values by 0.01 and see
% %how the distributions of phenology dates change.
% 
% decid_gcc(4,:) = decid_gcc(4,:) + 0.01;
% decid_gcc(7,:) = decid_gcc(7,:) + 0.01;

%% assign estimator and model function handles depending on model
switch model_name
    case 'separateSigmoids'
        estimatorHandle = @estParamsSeparateSigmoids;
        fhandle = @singleSigmoid;
    case 'fullYearSigmoid'
        estimatorHandle = @estParamsFullYearSigmoid;
        fhandle = @fullYearSigmoid;
    case 'greenDownSigmoid'
        estimatorHandle = @estParamsGreenDownSigmoid;
        fhandle = @greenDownSigmoid;
    case 'piecewise'
        estimatorHandle = @estParamsPiecewise;
        fhandle = @piecewise;
    case 'greenDownRichards'
        estimatorHandle = @estParamsGreenDownRichards;
        fhandle = @greenDownRichards;
    case 'smoothInterp'
        fhandle = @smoothInterp;
    case 'rawData'
        fhandle = NaN;
end

%%
%Get model parameters a full year time series for modeled values.
%modelT may be the same as T depending on the model.

%Convert to doy
time_num = date2doy(time_num);

for i = 1:size(index_data, 2)
    if ~strcmp(model_name, 'smoothInterp')
        %Curve fitting
        
        %Remove very low fall GCC point for two red maples
        if ismember(stem_tag{i}, {'282593', '341091'})
            day_mask = time_num == 281;
            T = time_num(~day_mask);
            Y = index_data(~day_mask,i);
        else
            T = time_num;
            Y = index_data(:,i);
        end

        %Adding baseline point, using average GCC of
        %first and last points.  DOY 50 and 30 days after last point
        %For greendown sigmoid
%         T = [50 T T(end)+30];% T(end)+7 T(end)+14];
%         base_val = (Y(1)+Y(end))/2;

        %Another way for separate sigmoids
        T = [T(1)-21 T(1)-14 T(1)-7 T T(end)+30];% T(end)+7 T(end)+14];
        base_val = Y(1);
        
        Y = [base_val; base_val; base_val; Y; base_val];%; base_val; base_val];
        extended_t{i} = T;
        extended_y{i} = Y;
        [params{i}, modelT{i}, modelY{i}, cut_off_dates{i},...
            resnorm{i}, initGuess{i}, initGuessY{i}, weighting{i}...
            residual{i}, jacobian{i}] = ...
            estimatorHandle(fhandle, model_name, T, Y);
    else
        %Smoothed and interpolated model
        params = NaN;
        cut_off_dates = NaN; resnorm = NaN; residual = NaN;
        jacobian = NaN; extended_t = NaN; extended_y = NaN;
        [modelT{i}, modelY{i}] = ...
             fhandle(time_num, index_data(:,i), data_frac);
         modelY{i} = modelY{i}';
    end
    
%     Temporary plot
%     fig_h = figure;
%     plot(time_num, decid_gcc(:,i), 'x',...
%         modelT{i}, modelY{i});
%     set(gca, 'XTick', time_num, 'XTickLabel', time_string,...
%         'Xgrid', 'on');
%     close(fig_h);

%If needed some day
%         if strcmp(model_name, 'rawData')
%         params = NaN; modelT = NaN; modelY = NaN;
%         cut_off_dates = NaN; resnorm = NaN; residual = NaN;
%         jacobian = NaN;
%         extended_t = NaN;
%         extended_y = NaN; 
    
    
end
%     fprintf(...