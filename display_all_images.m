function [axesh, figh, image_data] = ...
    display_all_images(stem_tag, radius, im_path)
%Images
fnames = {'10_8_15', '4_29_15', '5_4_15', '5_8_15', '5_14_15',...
    '5_21_15', '5_26_15', '5_29_15', '6_3_15',...
    '6_10_15', '6_17_15'};
date_num = datenum(fnames, 'm_dd_yy');

%make figure window fill the screen
scrsz = get(0,'ScreenSize');
figh = figure('Position', [10 10 scrsz(3)-100 scrsz(4)-100],...
    'Name', 'All images');

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
    %Need to redefine image file naming convention to match Harvard Forest
    %Data Archive
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
    
    %Include a fall image, which may be helpful in isolating this tree from
    %others. If there's a mask already, plot it.
    %If first image, plot fall mask for 10/15
    if i == 1
        savename = ['./output/' stem_tag '-fall-input_data.mat'];
        if exist(savename, 'file')
            fall_masks = load(savename, 'image_data', 'stem_tag');
            plot(fall_masks.image_data.mask_x{8},...
                fall_masks.image_data.mask_y{8},...
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