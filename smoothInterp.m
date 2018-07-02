function [smoothT, smoothY] = smoothInterp(T, Y, data_frac)
%Linear interpolation without smoothing data

%On a hunch at how this is behaving, need to exclude NaNs from both to get
%interpolation though them, I think
not_nan_indices = ~isnan(Y);
T = T(not_nan_indices); Y = Y(not_nan_indices);

%% Try smoothing Y, using built-in Matlab functions
% YY = smooth(T,Y,7,'sgolay',4);%, data_frac, 'lowess'); %lowess = 1st degree, loess = 2nd

%Try smoothing Y, spring and fall with different parameters
% YY_1 = smooth(T(1:11), Y(1:11),7,'sgolay',4);
% YY_2 = smooth(T(11:end), Y(11:end),8,'sgolay',5);  %Linear interpolation
% YY = [YY_1; YY_2(2:end)];

% YY = smooth(T, Y, 5, 'lowess');
% % plot(T, Y, 'x', T, YY, '-');
% 
% smoothT = T(1):0.1:T(end);
% smoothY = interp1(T, YY, smoothT);

%% Try package
% %Create "missing" values to express non-uniform spacing
% missing_T = min(T):max(T);
% missing_Y = NaN*ones(size(missing_T));
% count = 1;
% for i = 1:length(missing_T)
%     if ismember(missing_T(i), T)
%         missing_Y(i) = Y(count);
%         count = count + 1;
%     end
% end
% 
% %Do automatic smoothing
% [all_smooth_Y, s] = smoothn(missing_Y);
% %Catch errors (very large s), use typical S
% if s > 1e10
%     all_smooth_Y = smoothn(missing_Y, 0.0019);
% end
% 
% 
% %Retrieve just the locations of data points
% count = 1;
% for i = 1:length(missing_T)
%     if ismember(missing_T(i), T)
%         just_data_smooth_Y(count) = all_smooth_Y(i);
%         count = count + 1;
%     end
% end
% 
% smoothT = T(1):0.1:T(end);
% smoothY = interp1(T, just_data_smooth_Y, smoothT);

%% No smoothing
smoothT = T(1):0.1:T(end);
smoothY = interp1(T, Y, smoothT);