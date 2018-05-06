function [] = species_color_guide()
%Plots species legend, matching up species mnemonics and common names to
%the colors used in the species plot
mnemonics = {'querru'
'acerru'
'tsugca'
'pinust'
'betual'
'fagugr'
'pinure'
'querve'
'betupa'
'prunse'
'fraxam'
'betule'};

%Species common names
common_names_list =     {
'Red oak'
'Red maple'
'Eastern hemlock'
'White pine'
'Yellow birch'
'American beech'
'Red pine'
'Black oak'
'Paper birch'
'Black cherry'
'White ash'
'Black birch'};

%Arbitrary, based on earlier work
color_order = [
8%querru
10%acerru
12%tsugca
4%betual
1%fagugr
5%pinust
6%querve
9%pinure
7%prunse
11%betupa
3%fraxam
2%betule
];

%% Plot species legend
% figure;
cmap = colormap('jet');

for i = 1:length(mnemonics)
    color_index = round( (color_order(i)/length(mnemonics)) * 64 );
    SpeciesColor(i,:) = cmap(color_index, :);
end

%Patch coordinates for stand alone legend
x_1 = 0.6;
x_2 = 0.8;

%Add an entry for other species
SpeciesColor(size(SpeciesColor,1)+1, :) = [1 1 1];
common_names_list{length(common_names_list)+1} = 'Other';

for i = 1:length(common_names_list)
%     text_string = [common_names_list{i} ', ' mnemonics{i}];
    text_string = common_names_list{i};
    text(0.1, -i,...
        text_string,...
        'FontSize', 14); hold on;
    patch([x_1 x_1 x_2 x_2], [-i-0.5 -i+0.5 -i+0.5 -i-0.5],...
        SpeciesColor(i,:));
end

xlim([0 1]);
set(gca, 'Visible', 'off');