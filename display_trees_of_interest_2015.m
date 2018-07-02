function [center, x_lims, y_lims] = ...
    display_trees_of_interest_2015(stem_tag, Subset,...
    corrected_x, corrected_y, SpeciesColor, SpeciesIndex, radius)

%% Updated 4/24/15 to include select stem tags from species map
    
%8/24/2015 Mask not necessary?
MnemonicOut = Subset.Mnemonic;

%Do I bother with deciduous trees in swamp?  Probably not for many small
%ROIs analysis.

%% map species
DBH_scaling = 0.3;
DBH_lim = 8;   %cm
    
%% Plotting
for j = 1:length(Subset.DBH)
    
    %Get corrected coordinates of tree of interest
    if strcmp(Subset.StemTag{j}, stem_tag)
        center = [corrected_x(j) corrected_y(j)];
        
        offset = 5;
        %Show the stem tag number
        text(corrected_x(j)+offset,...
        corrected_y(j),...
        [Subset.StemTag{j} ': '...
            MnemonicOut{j}],...
        'Color', 'white',...
        'FontSize', 12);
    end
    
end

%Define x and y limits for zooming
x_lims = [center(1)-radius center(1)+radius];
y_lims = [center(2)-radius center(2)+radius];

for j = 1:length(Subset.DBH)
    
%     % Plot only trees in obervation list
%     if ismember(str2num(Subset.StemTag{j}), observation_list)
    % Plot only trees in certain radius
    if inpolygon(corrected_x(j),corrected_y(j),...
            [x_lims(1) x_lims(1) x_lims(2) x_lims(2)],...
            [y_lims(1) y_lims(2) y_lims(2) y_lims(1)]) && ...
            (Subset.DBH(j) >= DBH_lim)
        
	MarkerSize = DBH_scaling*Subset.DBH(j);
    %Minimum marker size, to see the marker
    MarkerSize = max(2, MarkerSize);
	plot(corrected_x(j),...
        corrected_y(j),...
        'Marker', 'o',...
        'MarkerSize', MarkerSize,...
        'LineWidth', 1,...
        'MarkerFaceColor', 'None',...
        'MarkerEdgeColor', SpeciesColor(SpeciesIndex(j),:),...
        'DisplayName', [Subset.StemTag{j} ': '...
        MnemonicOut{j}]); hold on;
    
    end
    
%     %% Plot all trees in X and Y limits of zoomed in part of picture
%     if (corrected_x(j) > x_lims(1)) && (corrected_x(j) < x_lims(2)) && ...
%             (corrected_y(j) > y_lims(1)) && (corrected_y(j) < y_lims(2))
%         
% 	MarkerSize = DBH_scaling*Subset.DBH(j);
%     %Minimum marker size, to see the marker
%     MarkerSize = max(2, MarkerSize);
% 	plot(corrected_x(j),...
%         corrected_y(j),...
%         'Marker', 'o',...
%         'MarkerSize', MarkerSize,...
%         'LineWidth', 3,...
%         'MarkerFaceColor', 'None',...
%         'MarkerEdgeColor', SpeciesColor(SpeciesIndex(j),:),...
%         'DisplayName', [Subset.StemTag{j} ': '...
%         MnemonicOut{j}]); hold on;
%     
%     end
    
%     offset = 5;
%     if ismember(str2num(Subset.StemTag{j}), left_list)
%         offset = -35;
%     end
%     
%     text(corrected_x(j)+offset,...
%         corrected_y(j),...
%         [Subset.StemTag{j} ': '...
%             MnemonicOut{j}],...
%         'Color', 'white',...
%         'FontSize', 12);
%    
%     end
    
end

%for debug
center;
%%

% %% Only plot species in the list.
% %Final list 8/24/2015
% %Actually maybe plot all trees within radius of center tree, but only above
% %a certain DBH.
% observation_list = [
% 281273
% 281280
% 281278
% 281357  %1
% 291488
% 291484
% 291417
% 291458
% 291485
% 291500
% 291499
% 291498  %2
% 282598
% 282517
% 282593	%3
% 311754
% 311822
% 311821
% 311817
% 301810
% 301817
% 301823  %4
% 340761
% 350677
% 350683
% 350736
% 350754
% 350632
% 350633
% 350630  %5
% 341048
% 341047
% 341092
% 341091
% 341090
% 341088
% 341086
% 341097
% 341108
% 341109  %6
% 331069
% 331066
% 331003
% 331029  %7
% 310896
% 310895
% 310894
% 310889	%8
% ];  
% 
% 
% %Move these labels to the left for easier reading
% left_list = [
% 330993
% 331040
% 281280
% 281278
% 291458
% 291485
% 282517
% 311754
% 341109
% 341048
% 331029];