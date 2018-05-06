function [] = display_species_map()
%This file plots an aerial image and the locations of tree stems and their
%species, according to a preprocessed version of the SIGEO (now called CTFS
%ForestGEO) species map
%(http://harvardforest.fas.harvard.edu:8080/exist/apps/datasets/showData.html?id=hf253)
%Change the image file path and name to work with your system
%Path to directory where image files are stored
im_path = '../../../images/';
%Image file name
im_fname = '5_21_15_2015_study_area.tif';

%% Load data
%Species map
load('./metadata/Subset_SIGEO_data_3_1_2015', 'Subset');
%Species color code
load('./metadata/SpeciesGuide_3_1_2015', 'SpeciesColor', 'SpeciesIndex',...
    'legend_species_list');

%Study area extent, defined as a polygon
%2015 study area
load('./metadata/2015_study_area', 'poly_x', 'poly_y');
X = poly_x; Y = poly_y;
%2013/4 study area (MODIS pixel)
% [X, Y] = plot_MODIS();

%% Plot image
%Set up figure and axes limits, load and show image
fig_h = figure;
X_lims = [min(X) max(X)];
Y_lims = [min(Y) max(Y)];
[temp_im, temp_ref] = geotiffread([im_path im_fname]);
mapshow(temp_im, temp_ref); hold on;
xlim(X_lims); ylim(Y_lims);
set(gca, 'Color', 'none');
set(gca, 'visible', 'off');

%% Make correction to map to correspond with image
%Species map coordinates do not appear to be sufficiently accurate. Here a
%correction is made based on the location of a tree in the image, and on
%the map

%Large Oak tree base on image:
image_tree_x = 144820.506907298;
image_tree_y = 921013.181223044;
%Nearby large oak tree on species map
SIGEO_tree_x = 144819.924322259;
SIGEO_tree_y = 921017.718534268;

correction_X = image_tree_x-SIGEO_tree_x;
correction_Y = image_tree_y-SIGEO_tree_y;
CorrectedX = Subset.MapX + correction_X;
CorrectedY = Subset.MapY + correction_Y;
%This appears to results in reasonably accurate tree coordinates

%% Mask for study area, species, DBH, dead stems
%Here various masks can be applied to the species map. There are a lot of
%stems in the map and plotting them all makes the plot window slow to work
%with.

%Subset to study area after having made coordinate correction
%This is the most important mask and only plots trees that are within the
%image area.
in_poly = inpolygon(CorrectedX, CorrectedY, X, Y);

%Species masks can be used to only plot certain species
% species_mask = strcmp('querru', Subset.Mnemonic) | ...
%     strcmp('acerru', Subset.Mnemonic) | ...
%     strcmp('betual', Subset.Mnemonic) | ...
%     strcmp('pinust', Subset.Mnemonic) | ...
%     strcmp('tsugca', Subset.Mnemonic);

% species_mask = strcmp('ilexve', Subset.Mnemonic) | ...
%     strcmp('vaccco', Subset.Mnemonic) | ...
%     strcmp('lyonli', Subset.Mnemonic);

%A DBH mask can be used to only plot larger trees
DBH_mask = Subset.DBH > 5; %cm

%Combine all masks, and also don't plot trees that are dead.
% combined_mask = species_mask & DBH_mask & in_poly & ~Subset.Dead;
combined_mask = DBH_mask & in_poly & ~Subset.Dead;

%Mask the stems
Subset.DBH = Subset.DBH(combined_mask);
CorrectedX = CorrectedX(combined_mask);
CorrectedY = CorrectedY(combined_mask);
SpeciesIndex = SpeciesIndex(combined_mask);
Subset.StemTag = Subset.StemTag(combined_mask);
MnemonicOut = Subset.Mnemonic(combined_mask);

%% Show the species
%marker size proportional to stem diameter according to this parameter
DBH_scaling = 0.1;

for j = 1:length(Subset.DBH)        
	MarkerSize = DBH_scaling*Subset.DBH(j);
	plot(CorrectedX(j),...
        CorrectedY(j),...
        'Marker', 'o',...
        'MarkerSize', MarkerSize,...
        'LineWidth', 2,...
        'MarkerFaceColor', 'None',...
        'MarkerEdgeColor', SpeciesColor(SpeciesIndex(j),:),...
        'DisplayName', [Subset.StemTag{j} ': '...
        MnemonicOut{j}]); hold on;
end

%% Click to get stem tag #
%This creates interactive plot functionality so that entering "data cursor
%mode" (click on plus sign in plot window) allows the user to click on a
%stem and see the tree number (used to identify the tree in the SIGEO data
%set as well as physical tags on the trees themselves) and species.

%Based on
%http://www.mathworks.com/help/matlab/ref/datacursormode.html
dcm_obj = datacursormode(fig_h);
set(dcm_obj,'UpdateFcn',@myupdatefcn)

function name = myupdatefcn(empt,event_obj)
% Customizes text of data tips
tar = get(event_obj,'Target');
name = get(tar,'DisplayName');
end

end