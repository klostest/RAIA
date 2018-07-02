function [axesh, figh, image_data] = ...
    display_images_fall(stem_tag, radius, im_path)
%Images
fnames = {'5_21_15', '7_23_15', '9_2_15', '9_8_15', '9_15_15',...
    '9_21_15', '9_28_15', '10_8_15', '10_15_15',...
    '10_23_15', '10_27_15', '11_16_15'};
date_num = datenum(fnames, 'm_dd_yy');

%make figure window fill the screen
scrsz = get(0,'ScreenSize');
figh = figure('Position', [10 10 scrsz(3)-100 scrsz(4)-100],...
    'Name', 'All images');

%% Load species map data


%% Plot select trees, given their stem tag numbers
% Adapted from 'DisplaySpeciesMap_2_20_15.m'

%% Load specie map
load('./metadata/Subset_SIGEO_data_3_1_2015', 'Subset');
%% Species color code
load('./metadata/SpeciesGuide_3_1_2015', 'SpeciesColor', 'SpeciesIndex',...
    'legend_species_list');

%% Make correction to species map to correspond with image
%Large Oak tree base on image:
image_tree_x = 144820.506907298;
image_tree_y = 921013.181223044;
%Nearby large oak tree on specie map

%New way, based on only SW coordinate of SIGEO plot
SIGEO_tree_x = 144819.924322259;
SIGEO_tree_y = 921017.718534268;

correction_X = image_tree_x-SIGEO_tree_x;
correction_Y = image_tree_y-SIGEO_tree_y;
corrected_x = Subset.MapX + correction_X;
corrected_y = Subset.MapY + correction_Y;

%% Loop to load image and ref data, and display
for i = 1:length(fnames)
    axesh(i) = subplot(3, 4, i,...
        'FontSize', 20);
    [image, ref{i}] = ...
        geotiffread([im_path fnames{i} '_2015_study_area']);
    mapshow(image, ref{i}); hold on;
    
    %Display species map, get coordinates of tree of interest
    [center, x_lims, y_lims] = ...
        display_trees_of_interest_2015(stem_tag, Subset,...
        corrected_x, corrected_y, SpeciesColor, SpeciesIndex, radius);
    
    %set display limits
    xlim(x_lims);
    ylim(y_lims);
    
    %make title string
    title_st = strrep(fnames{i}, '_', '/');
    title(title_st, 'FontSize', 12);
    
    %If first image, plot spring mask for 5/21
    if i == 1
        savename = ['./output/' stem_tag '-input_data.mat'];
        if exist(savename, 'file')
            spring_masks = load(savename, 'image_data', 'stem_tag');
            plot(spring_masks.image_data.mask_x{5},...
                spring_masks.image_data.mask_y{5},...
                'Color', [1 1 1], 'LineWidth', 1,...
                'Parent', axesh(i));
        end
    end

    %erase image data from memory
    %Overwrite faster?
    clear image
end

%Image metadata for output
image_data.fnames = fnames;
image_data.date_num = date_num;
image_data.ref = ref;
image_data.center = center;