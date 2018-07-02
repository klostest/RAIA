function [] = plot_tree_mask_time_series()
%For all trees, plot various color indices for all the dates. Collect all
%dates into one file for phenology date estimation in later step.
fnames = {'4_29_15', '5_4_15', '5_8_15', '5_14_15',...
    '5_21_15', '5_26_15', '5_29_15', '6_3_15',...
    '6_10_15', '6_17_15',...
    '7_23_15', '9_2_15', '9_8_15', '9_15_15',...
    '9_21_15', '9_28_15', '10_8_15', '10_15_15',...
    '10_23_15', '10_27_15', '11_16_15'};

for i = 1:length(fnames)
    %Load color data
    color_data_fname = ['./output/' ...
        fnames{i} '_tree_color_data'];
    color_data{i} = load(color_data_fname, 'color_mean', 'gcc',...
        'this_ROI_x',...
        'this_ROI_y', 'species_name', 'stem_tag');
    
    R_DN = color_data{i}.color_mean(1,:);
    G_DN = color_data{i}.color_mean(2,:);
    B_DN = color_data{i}.color_mean(3,:);
    
    %Put GCC in matrix
    all_dates_gcc(i,:) = color_data{i}.gcc;
    
    %Calculate RCC, do the same
    all_dates_rcc(i,:) = R_DN ./ ...
        sum(color_data{i}.color_mean,1);
    
    %GRVI
    all_dates_grvi(i,:) = (G_DN - R_DN) ./ (G_DN + R_DN);
    
    %ExG, aka 2G_RBi
    all_dates_exg(i,:) = 2 * G_DN - (R_DN + B_DN);
    
    %Hue
    %Following Nagai et al 2011
    %Need one value per tree, per date. For each tree, find the max and min
    %DN, and note their index to remember whether it's R, G, or B

    [max_DN, max_ix] = max(color_data{i}.color_mean, [], 1);
    min_DN = min(color_data{i}.color_mean, [], 1);
    
    r_DN = (max_DN - R_DN) ./ (max_DN - min_DN);
    g_DN = (max_DN - G_DN) ./ (max_DN - min_DN);
    b_DN = (max_DN - B_DN) ./ (max_DN - min_DN);
    
    for j = 1:size(color_data{i}.color_mean, 2)
        switch max_ix(j)
            case 1 %Red is the max
                all_dates_hue(i,j) = 60 * (b_DN(j) - g_DN(j));
            case 2 %Green
                all_dates_hue(i,j) = 60 * (2 + r_DN(j) - b_DN(j));
            case 3 %Green
                all_dates_hue(i,j) = 60 * (4 + g_DN(j) - r_DN(j));
        end
    end
    
    %No hues < 0, checked
%     sum(sum(all_dates_hue<0))
    
    %Make time for interpolation
    %month and day number separated by underscore must come first in fnames
    fname_parts = regexp(fnames{i}, '\_', 'split');
    time_string{i} = [fname_parts{1} '_' fname_parts{2} '_2015'];
    x_tick_labels{i} = strrep(fnames{i}, '_', '/');
    time_num(i) = datenum(time_string{i}, 'mm_dd_yyyy');
end

% %Create artificial data point on DOY 310, assume same value as on DOY 320
% time_num = [time_num(1:20) doy2date(310, 2015) ...
%     time_num(21)];
% time_string{22} = time_string{21}; time_string{21} = '11_6_2015';
% x_tick_labels{22} = x_tick_labels{21}; x_tick_labels{21} = '11/6/2015';
% all_dates_gcc = [all_dates_gcc(1:20,:)
%     all_dates_gcc(21,:)
%     all_dates_gcc(21,:)];
% all_dates_rcc = [all_dates_rcc(1:20,:)
%     all_dates_rcc(21,:)
%     all_dates_rcc(21,:)];

%% Need to work in evergreen mask here?
%Would be nice to view all series, colored by land cover type.

%Plot all GCC time series
figure;
subplot(3,2,1); hold on
for i = 1:size(all_dates_gcc,2)
    plot(time_num, all_dates_gcc(:,i), 'DisplayName',...
        color_data{1}.stem_tag{i});
    set(gca, 'XTick', time_num, 'XTickLabel', x_tick_labels,...
        'XGrid', 'on', 'XTickLabelRotation', 45);
    title('GCC');
end

subplot(3,2,2); hold on
for i = 1:size(all_dates_rcc,2)
    plot(time_num, all_dates_rcc(:,i), 'DisplayName',...
            color_data{1}.stem_tag{i});
    set(gca, 'XTick', time_num, 'XTickLabel', x_tick_labels,...
        'XGrid', 'on', 'XTickLabelRotation', 45);
    title('RCC');
end

subplot(3,2,3); hold on
for i = 1:size(all_dates_grvi,2)
    plot(time_num, all_dates_grvi(:,i), 'DisplayName',...
            color_data{1}.stem_tag{i});
    set(gca, 'XTick', time_num, 'XTickLabel', x_tick_labels,...
        'XGrid', 'on', 'XTickLabelRotation', 45);
    title('GRVI');
end

subplot(3,2,4); hold on
for i = 1:size(all_dates_exg,2)
    plot(time_num, all_dates_exg(:,i), 'DisplayName',...
            color_data{1}.stem_tag{i});
    set(gca, 'XTick', time_num, 'XTickLabel', x_tick_labels,...
        'XGrid', 'on', 'XTickLabelRotation', 45);
    title('ExG');
end

subplot(3,2,5); hold on
for i = 1:size(all_dates_hue,2)
    plot(time_num, all_dates_hue(:,i), 'DisplayName',...
            color_data{1}.stem_tag{i});
    set(gca, 'XTick', time_num, 'XTickLabel', x_tick_labels,...
        'XGrid', 'on', 'XTickLabelRotation', 45);
    title('Hue');
end

subplot(3,2,6); hold on
for i = 1:size(all_dates_gcc,2)
    plot(time_num, all_dates_gcc(:,i)+all_dates_rcc(:,i),...
        'DisplayName',...
            color_data{1}.stem_tag{i});
    set(gca, 'XTick', time_num, 'XTickLabel', x_tick_labels,...
        'XGrid', 'on', 'XTickLabelRotation', 45);
    title('GCC+RCC');
end


%Also save for direct use in VI_curve
decid_gcc = all_dates_gcc;

save(['./output/all_dates_indices_tree_masks'],...
    'all_dates_gcc', 'decid_gcc',...
    'all_dates_rcc',...
    'all_dates_grvi',...
    'all_dates_exg',...
    'all_dates_hue',...
    'fnames', 'time_num',...
    'color_data');