function [] = redo_masks_spring(stem_tag)
%% Example input
stem_tag = '311519';

%% Set image directory
im_path = '../../../images/';

%% display all images for mask drawing
radius = 12;
[axesh, figh, image_data] ...
    = display_all_images(stem_tag, radius, im_path);
%save image plotting data
image_data.radius = radius;

%% Define nested function for redoing one mask at a time.
% A nested function
%seems the best way to go because it will be able to manipulate the
%variables in the nesting function, namely the mask coordinates
% http://www.mathworks.com/help/matlab/creating_guis/writing-code-for-callbacks.html#f16-1001315

%Pass i as an argument though so each button has the correct subplot
%associated with it.

function [] = push_button_redo_mask(hObh, event, i)
    %These should not be declared as arguments in order to have their scope
    %shared with the nesting function
    %, image_data, axesh, poly_h, i)
    % Button click function to redo a mask.
    % This will need to clear the polygon plot on a given axis, then have
    %the user enter it again, update the new mask coordinates in the
    %image_data variable, and plot the new mask.

    %Erase the polygon
    delete(poly_h(i));

    %Draw a new polygon and overwrite the x and y coordinates for saving
    [image_data.mask_x{i}, image_data.mask_y{i}] = getline(axesh(i),'closed');

    %Plot the new polygon
    poly_h(i) = plot(image_data.mask_x{i}, image_data.mask_y{i},...
        'Color',[1 1 1],'LineWidth',2);
end
%Load old masks and put in new variable
savename = ['./output/' stem_tag '-input_data'];
old_ROIS = load(savename, 'image_data', 'stem_tag');
if length(old_ROIS.image_data.fnames) == (length(image_data.fnames)-1)
    %If there was not an example image originally but there is one here
    image_data.mask_x{1} = [];
    image_data.mask_x = [image_data.mask_x old_ROIS.image_data.mask_x];
    image_data.mask_y{1} = [];
    image_data.mask_y = [image_data.mask_y old_ROIS.image_data.mask_y];
else
    image_data.mask_x = old_ROIS.image_data.mask_x;
    image_data.mask_y = old_ROIS.image_data.mask_y;
end
%% Apply user interface to each subplot
%First image is for display only
for i = 2:length(image_data.fnames)
    %Plot masks
    poly_h(i) = plot(image_data.mask_x{i},...
            image_data.mask_y{i},...
            'Color',[1 1 1],'LineWidth',2,'Parent',axesh(i));

    %make buttons for redo
    axes_pos(i,:) = get(axesh(i), 'Position');
    left = axes_pos(i,1);
    bottom = axes_pos(i,2) + axes_pos(i,4) + 0.02;
    width = axes_pos(i,3)/2; height = axes_pos(i,3)/4;
    uicontrol('Units', 'Normalized',...
        'Position', [left bottom width height],...
        'String', 'Redo',...
        'Callback', {@push_button_redo_mask, i});

    %Right now it's necessary to finish all masks before going back and
    %redoing one.  Probably a way around this but maybe would take more
    %time than it's worth to figure out.
end   

%% Button to be done
uicontrol('Units', 'Normalized',...
    'Position',[0.01 0.01 width height],'String','Done',...
    'Callback', 'uiresume(gcbf)');
%Stop execution of code, wait for user to redo masks, then click
%done to resume execution.
uiwait(gcf);
%Close figure
close(gcf);

%% Save
savename = ['./output/' stem_tag '-input_data'];
save(savename, 'image_data', 'stem_tag');
end