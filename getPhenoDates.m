function [six_dates] = ...
    getPhenoDates(model_name, params, model_t, model_y,...
    date_method, percentiles,...
    cut_off_dates, data_frac,...
    fhandle,...
    time_num, index_data,...
    species_name, stem_tag)
%============================================
%
%% description
% This function uses a modeled timeseries of a vegetation index to estimate
% phenological transition dates.  Results are saved in the directory where
% the data and modeled time series results are.
%
%% inputs
% loadName is a string which is the filename of a .mat file in the current
% directory containing information about the site, the type of vegetation
% index, and where the data is stored.  See 'example arguments' below for
% appropriate arguments to work with the sample data.
% loadName = 'phenocam-siteInfo-BoundaryWaters';
% loadName = 'phenocam-siteInfo-HarvardTree3';
% loadName = 'ArbutusBroad-EVI-siteInfo';
% model_name is a string used to indicate which model the data has been fit
% to.  Possible arguments are 'separateSigmoids'.
% model_name = 'separateSigmoids';
% model_name = 'greenDownSigmoid';
%
% date_method is a string indicating the method used to extract phenology
% dates 'secondDeriv' and 'CCR'
% date_method = 'CCR';
% 
% percentiles are used by the 'percentiles' and 'dataPercentiles'
% date_methods.  If using other methods, this variable must be assigned a
% value but it will be ignored.
%if using 'percentiles' date_method, specify 4 percentiles for beginning of
%spring, middle of spring, middle of fall, and end of fall.  CCR is used
%for end of spring and beginning of fall.  Dates are calculated as the date
%of crossing the value at this percentile between baseline and CCR value.
% e.g.
% percentiles = [0.10 0.50 0.50 0.10];
%if using 'dataPercentiles' date_method, specify 3 percentiles for
%beginning, middle, and end of spring, e.g.
% percentiles = [0.10 0.50 0.90];   %for dataPercentiles
%
%% notes
% The functions secondDeriv.m and CCR.m produce the .mat files containing
% the formulas used to extract phenology dates, secondDeriv_formula.mat and
% CCR_formula.mat.
%
%============================================
% Stephen Klosterman
% 11/20/2011
% steve.klosterman@gmail.com
%============================================

switch model_name
    case 'separateSigmoids'
        switch date_method
            case 'CCR'
                load('CCR_formula.mat', 'Kprime');
        end
end
    
%% get pheno dates
%For investigation of which cells have no dates
% load('./output/land_cover_strings', 'land_cover_strings');
nan_count = 1;
time_num = date2doy(time_num);
figure;

%For each ROI
for i = 1:size(index_data,2)
    switch model_name
        case 'separateSigmoids'
            switch date_method
                case 'percentiles'
                        six_dates(1:3,i) = ...
                            percentileDates(params{i}(1,:), ...
                            model_t{i}( model_t{i} <= cut_off_dates{i}(1) ),...
                            fhandle, percentiles, model_name);
                        %fall
%                         percentiles = [0.10 0.50 0.50 0.10];
                        six_dates(4:6,i) = ...
                            percentileDates(params{i}(2,:), ...
                            model_t{i}( model_t{i} >= cut_off_dates{i}(2) ),...
                            fhandle, percentiles, model_name);
                case 'secondDeriv'
                    six_dates(:,i) = secondDeriv(params{i}, minMax,...
                        T{i}, cut_off_dates{i});

                case 'CCR'
                    subplot(5,6,i);
                    %spring
                    temp = CCR(params{i}(1,:),...
                        model_t{i}( model_t{i} <= cut_off_dates{i}(1) ),...
                        Kprime, fhandle, time_num, index_data(:,i))';
                    six_dates(1:3,i) = temp;
                    %fall
%                     temp = CCR(params{i}(2,:),...
%                         model_t{i}( model_t{i} >= cut_off_dates{i}(2) ),...
%                         Kprime, fhandle)';
                    six_dates(4:6,i) = NaN*ones(1,3);
            end
        case 'greenDownSigmoid'
            switch date_method
                case 'percentiles'
                    six_dates(:,i) = percentileDates(params{i}, model_t{i},...
                        fhandle, percentiles, model_name);

                case 'secondDeriv'
                    tempParams = [params{i}(3)/params{i}(4)...
                        -1/params{i}(4);
                        -params{i}(5)/params{i}(6)...
                        1/params{i}(6)];

                    six_dates(:,i) = secondDeriv(tempParams, minMax,...
                        T{i}, cut_off_dates{i});

                case 'CCR'
                    subplot(5,6,i);
%                     if i == 13
%                         0;
%                     end
                    six_dates(:,i) = CCRgd(params{i}, model_t{i},...
                        fhandle, time_num, index_data(:,i));

%                         , time_num, index_data(:,i), nan_count,...
%                             land_cover_strings{i});

                    if isnan((six_dates(1,i)))
                        nan_count = nan_count+1;
                    end
                    title([species_name{i} ' '...
                        stem_tag{i}]);
                    xlim([1 365]);
                    
                    %Print tree tag number if there are spring
                    six_dates;
            end   
        case 'smoothInterp'
            switch date_method
                case 'spring_fall_red'
                    subplot(5,6,i);
%                     if i == 10
%                         0;
%                     end

                    six_dates(:,i) = spring_fall_red(time_num,...
                        index_data(:,i), percentiles, data_frac);
                    title([species_name{i} ' '...
                        stem_tag{i} ', ' num2str(max(index_data(1:12,i)))]);
                    if max(index_data(1:12,i)) > 0.4
                        fprintf(1, [stem_tag{i} ' > 0.4 RCC\n']);
                    end
                    xlim([1 365]);
                    0;
                case 'percentiles'
                    subplot(5,6,i);
                    [six_dates(:,i), base_green(i)]...
                        = dataPercentileDates({i},...
                        model_y{i},...
                        percentiles);

                    %% Temporary fix to throw out year with missing
                    %fall data from Bartlett
                    if i == 3
                        six_dates(4,i) = NaN*ones(1,1);
                    end
                case 'fallRedMax'
                    six_dates(:,i) = fallRedMax({i},...
                        model_y{i});
            end     
                
    end
    disp(i);
end
0;

% %% Perhaps here print results to CSV file
% data_out = six_dates;
% year_nums = cellfun(@str2num, years);
% data_out = vertcat(year_nums, six_dates);
% data_out = num2cell(data_out);
% row_headers = {'year'; 'SOS'; 'MOS'; 'EOS'; 'SOF'; 'MOF'; 'EOF'};
% data_out = [row_headers, data_out];
% xlswrite(['.' filesep 'output' filesep ...
%     index '_phenology_dates_' site '_' ROI '_' model_name], data_out);
% 
% save(['.' filesep 'output' filesep ...
%     index '_phenology_dates_' site '_' ROI '_' model_name], 'six_dates');