function [] = master_function()
%%
%Just used for file naming
index_type = 'rcc';
% index_type = 'gcc';
% index_type = 'gcc+rcc';
% index_type = 'grvi';
% index_type = 'exg';
% index_type = 'hue';

time_series_fname = 'all_dates_indices_tree_masks';
%%
% model_name = 'greenDownSigmoid';
% model_name = 'separateSigmoids';
model_name = 'smoothInterp';  %Linear interpolation, no smoothing here

data_frac = 0.2;
%%
% date_method = 'percentiles';
% date_method = 'CCR';
date_method = 'spring_fall_red';

% percentiles = [0.10 0.50 0.50 0.10];
percentiles = [0.1 0.5 0.9];   %for smoothInterp or spring_fall_red

%% Index data for calculating dates
imagery_data = load(['./output/' time_series_fname]);
% 'all_dates_gcc', 'decid_gcc',...
% 'all_dates_rcc',...
% 'fnames', 'time_num', 'time_string', 'x_tick_labels',...
% 'species_name', 'stem_tag');

species_name = imagery_data.color_data{1}.species_name;
stem_tag = imagery_data.color_data{1}.stem_tag;
switch index_type
    case 'gcc'
        index_data = imagery_data.all_dates_gcc;
    case 'rcc'
        index_data = imagery_data.all_dates_rcc;
    case 'gcc+rcc'
        index_data = imagery_data.all_dates_gcc + ...
            imagery_data.all_dates_rcc;
    case 'grvi'
        index_data = imagery_data.all_dates_grvi;
    case 'exg'
        index_data = imagery_data.all_dates_exg;
    case 'hue'
        index_data = imagery_data.all_dates_hue;
end

%% Curve fit
%Perform curve fit
[params, model_t, model_y, cut_off_dates, fhandle,...
    resnorm, residual, jacobian, extended_t, extended_y] = ...
    VI_curve(imagery_data.time_num, index_data,...
    model_name, data_frac, species_name,...
    stem_tag);

%Save/load old results (change "save" to "load" in next line)
% save(['./output/curve_fit_' index_type '_' model_name '_'...
%     time_series_fname],...
%     'params', 'model_t', 'model_y', 'cut_off_dates', 'fhandle',...
%     'resnorm', 'residual', 'jacobian', 'extended_t', 'extended_y',...
%     'loc_list', 'species_name', 'stem_tag');

%% Pheno dates
%Estimate phenology dates
[six_dates] = ...
    getPhenoDates(model_name, params, extended_t, extended_y,...
    date_method, percentiles,...
    cut_off_dates, data_frac,...
    fhandle, imagery_data.time_num, index_data,...
    species_name,...
    stem_tag);
0;

%Save/load old results (change "save" to "load" in next line)
% save(['./output/pheno_dates_' index_type '_' ...
%     model_name '_' date_method '_'...
%     time_series_fname],...
%     'six_dates', 'loc_list', 'species_name', 'stem_tag');

%% Monte Carlo
% Estimate dates with uncertainty
% n = 50;    %Size of MC ensemble
% cond_number_crit = 1e-30;   %throw out if condition number of matrix to be
% %inverted is smaller than this
% [R, six_dates, six_dates_MC, model_y_MC,...
%     quants, lower_quants, upper_quants, quant_interval] = ...
%     getPhenoDatesMC(model_name, params, model_t, model_y,...
%     date_method, percentiles, cut_off_dates, fhandle,...
%     resnorm, residual, jacobian, n, cond_number_crit,...
%     imagery_data.time_num, index_data);
% 
%Save/load old results (change "save" to "load" in next line)
% save(['./output/pheno_dates_MC_' ...
%     index_type '_' ...
%     model_name '_' date_method '_' time_series_fname],...
%     'R', 'six_dates', 'six_dates_MC', 'model_y_MC', 'n',...
%     'quants', 'lower_quants', 'upper_quants', 'quant_interval',...
%     'cond_number_crit',...
%     'species_name', 'stem_tag');

%% Manual save/load of dates only
% save('./output/six_dates',...
%     'six_dates');
% load('./output/six_dates',...
%     'six_dates');

% % rough examination of dates
% figure;
% six_dates(six_dates==0) = NaN;
% for i = 1:6
%     subplot(2,3,i);
%     hist(six_dates(i,:), 20);
% end