function [] = create_tree_mask_time_series()
%After drawing masks for one or more trees, use this function to analyze
%the RGB color data for them. Can be used with one tree, but is intended to
%do all the trees at once.
%% Image file names
%Also dates to be analyzed
fnames = {'4_29_15', '5_4_15', '5_8_15', '5_14_15',...
    '5_21_15', '5_26_15', '5_29_15', '6_3_15',...
    '6_10_15', '6_17_15',...
    '7_23_15', '9_2_15', '9_8_15', '9_15_15',...
    '9_21_15', '9_28_15', '10_8_15', '10_15_15',...
    '10_23_15', '10_27_15', '11_16_15'};
% fnames = {'4_29_15', '5_4_15', '5_8_15', '5_14_15',...
%     '5_21_15', '5_26_15', '5_29_15', '6_3_15',...
%     '6_10_15', '6_17_15'};
% fnames = {'10_8_15'};

%% Tree ROIs
%Numerical array of stem tags
stem_list = [311519];
%Load both spring and fall masks
for i = 1:length(stem_list)
    ROIs_spring{i} = load(['./output/' num2str(stem_list(i))...
        '-input_data']);
    ROIs_fall{i} = load(['./output/' num2str(stem_list(i))...
        '-fall-input_data']);
    
    %Concatenate
    ROIs_all_x_coord{i} = [ROIs_spring{i}.image_data.mask_x...
        ROIs_fall{i}.image_data.mask_x];
    ROIs_all_y_coord{i} = [ROIs_spring{i}.image_data.mask_y...
        ROIs_fall{i}.image_data.mask_y];
    ROIs_all_fnames{i} = [ROIs_spring{i}.image_data.fnames...
        ROIs_fall{i}.image_data.fnames];
    
    %This calculates crown area in case of interest
    %Get area using a later spring date where tree crowns are distinct
    areas(i) = polyarea(ROIs_spring{i}.image_data.mask_x{7},...
        ROIs_spring{i}.image_data.mask_y{7});
end

%Use four cores for this; parfor on inner loop
% parpool(4);

im_path = '../../../images/';

%For plot
% Load specie map
load('./metadata/Subset_SIGEO_data_3_1_2015', 'Subset');
% Species color code
load('./metadata/SpeciesGuide_3_1_2015', 'SpeciesColor', 'SpeciesIndex',...
    'legend_species_list');

for i = 1:length(fnames)
    %make file name
    %Need to change to match local file name convention
    clipped_name = [im_path fnames{i} '_2015_study_area.tif'];
    [img, ref] = geotiffread(clipped_name);
    
    %Put image in correct coordinates
    img_ud = flipud(img);
    
    band{1} = img_ud(:,:,1);
    band{2} = img_ud(:,:,2);
    band{3} = img_ud(:,:,3);
    
    tic
    
    for j = 1:length(stem_list)%number of trees;
        %match the date to the mask in the list for this tree using file
        %name string matching since indices are not standard between all
        %trees
        date_index = strcmp(fnames{i}, ROIs_all_fnames{j});
%         date_index = strcmp('10_8_15', ROIs_all_fnames{j}); %testing
        if sum(date_index) == 1
            this_ROI_x{j} = ROIs_all_x_coord{j}{date_index};
            this_ROI_y{j} = ROIs_all_y_coord{j}{date_index};
        else
            non_zeros = find(date_index);
            for k = 1:sum(date_index)
                %The index where ROIs_all_x_coord{i}(non_zeros(k)) is not
                %empty is the one to use.  There should only be one.
                if ~isempty(ROIs_all_x_coord{j}{non_zeros(k)})
                    this_ROI_x{j} = ROIs_all_x_coord{j}{non_zeros(k)};
                    this_ROI_y{j} = ROIs_all_y_coord{j}{non_zeros(k)};
                end
            end
        end
        
        %Convert each mask to pixel coordinates using the reference info
        %for this upside down image
        pixel_mask = roipoly(ref.XLimWorld,...
            ref.YLimWorld,...
            img_ud,...
            this_ROI_x{j}, this_ROI_y{j});
        
        %Get some stats about ROI, in case of interest
        stats{j} = regionprops(pixel_mask,'Centroid',...
            'MajorAxisLength','MinorAxisLength');
        major_ax_m(j) = stats{j}.MajorAxisLength * ref.CellExtentInWorldX;
        
        %Calculate mean DNs and GCC for this mask
        temp_r = mean(band{1}(pixel_mask));
        temp_g = mean(band{2}(pixel_mask));
        temp_b = mean(band{3}(pixel_mask));
        
        color_mean(:,j) = [temp_r; temp_g; temp_b];
        gcc(j) = temp_g/sum(color_mean(:,j));
    end
    toc
    %% Plot all color-coded masks for this date
    %Can be used to save an image of the entire study area with the tree
    %masks shown. Can be helpful as a QC check, to make sure the intended
    %trees are being analyzed.
    scrsz = get(0,'ScreenSize');
    fig_h = figure('Position', [50 50 scrsz(3)/2 scrsz(4)-100]);
    mapshow(img, ref); hold on;
    %Need to paste coordinate correction code if want species map location
    for j = 1:length(stem_list)
        %Get color, species name, stem tag
        sp_list_ind = find(strcmp(num2str(stem_list(j)), Subset.StemTag));
        this_color = SpeciesColor(SpeciesIndex(sp_list_ind),:);
        species_name{j} = Subset.Mnemonic{sp_list_ind};
        tree_dbh(j) = Subset.DBH(sp_list_ind);
        stem_tag{j} = num2str(stem_list(j));
        plot(this_ROI_x{j}, this_ROI_y{j}, 'Color', this_color,...
            'DisplayName', [species_name{j} ' '...
            stem_tag{j}]);
    end
    title(strrep(fnames{i}, '_', '/'));
    pause(2);
%     savefig(fig_h, ['./graphics/' fnames{i} '_tree_masks'], 'compact');
    close(fig_h);
    
    %% Save average band values in ROI and GCC
    color_data_fname = ['./output/' ...
        fnames{i} '_tree_color_data'];
    save(color_data_fname, 'color_mean', 'gcc', 'this_ROI_x',...
        'this_ROI_y', 'species_name', 'stem_tag');
    fprintf('Image %d of %d done\n', i, length(fnames))
    clear this_ROI_x this_ROI_y
end