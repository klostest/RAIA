function [six_dates] = spring_fall_red(data_T, data_Y, percentiles,...
    data_frac)
six_dates = NaN*ones(1,6); base_red = NaN;

%Interpolate
[T, Y] = smoothInterp(data_T, data_Y, NaN);

%% Spring
springY = Y(T<180); %DOY 180 = Jun 29
springT = T(T<180);

%what is peak redness?
peak_red = max(springY);
%Minimum of 4/30 or 5/5.  Spring red only appropriate for some pixels.
[base_red, min_index] = min(data_Y(1:2));

%what are the red thresholds to be crossed?
for i = 1:length(percentiles)
    thresh(i) = base_red + percentiles(i)*(peak_red-base_red);
end

count = 1;
springFlags = ones(size(percentiles));

%when does redness first cross the thresholds? Must get past minimum of
%first two data points.
for i = 1:length(springY)
    for j = 1:length(thresh)
        if (springY(i) >= thresh(j)) && logical(springFlags(j)) && ...
                (springT(i) >= data_T(min_index))
            six_dates(count) = springT(i);
            count = count+1;
            springFlags(j) = 0;
        end
    end
end

%%  Autumn
fallY = Y(T>250);
fallT = T(T>250); %DOY

% %redo limits for percentiles using fall data... base green should probably
% %be the last date, which is leaf off:
% base_red = min(fallY);
% peak_red = max(fallY);
% 
% %what are the greenness thresholds to be crossed?
% for i = 1:length(percentiles)
%     thresh(i) = base_red + percentiles(i)*(peak_red-base_red);
% end
% 
% count = 4;
% autumnFlags = ones(size(percentiles));
% 
% %when does greenness first cross the thresholds without turning back?
% for i = 1:length(fallY)
%     for j = 1:length(thresh)
%             if (fallY(i) >= thresh(j)) && logical(autumnFlags(j))
%                 six_dates(count) = fallT(i);
%                 count = count+1;
%                 autumnFlags(j) = 0;
%             end
%     end
% end

%Choose max of raw time series versus smoothed, if looking for 100th
%percentile in fall
% if percentiles(3) == 0.9
    [~, max_index] = max(fallY);
    six_dates(6) = fallT(max_index);
% end

%% Plot
% fig_h = figure;
plot(T, Y, '-'); hold on;
plot(data_T, data_Y, 'x');
if exist('six_dates')
for i = 1:length(six_dates)
    plot([six_dates(i) six_dates(i)], [min(Y) max(Y)]);
end
end
plot(T, 0.4*ones(size(T)), 'r-');
% close(fig_h);