# RAIA (repeat aerial imagery analysis)

## Matlab code for visualization and phenology analysis of repeat aerial photography

This respository is designed for analysis of my aerial imagery of Harvard Forest, available [here](http://harvardforest.fas.harvard.edu:8080/exist/apps/datasets/showData.html?id=hf294). There is functionality to link with my preprocessed version of the Harvard Forest [species map](http://harvardforest.fas.harvard.edu:8080/exist/apps/datasets/showData.html?id=hf253), which is available here in the 'metadata' directory. This code is oriented toward analysis of individual trees, although similar principles can be used to analyze images on a regularly spaced grid (i.e. 10 m). My published work based on this code is referenced below. Please cite the data sets or references accordingly.

This code was written with Matlab R2017a and makes use of the mapping toolbox (and possibly other toolboxes). Example output files for the mask drawing and image processing have been created for stem tag 311519.

### Explore the images, find trees to analyze
- display_species_map: interactive plot of aerial image and tree stem locations, allowing identification of species and stem tag number
- species_color_guide: plot of legend with species color codes

### Draw masks on trees by stem tag numbers
May need to change image file name conventions, and path to images in these.
- create_masks: for spring time images
- create_masks_fall: fall

Auxiliary functions
- display_all_images
- display_images_fall

For redoing masks:
- redo_masks_spring
- redo_masks_fall

### Use the masks to process the images and create time series data
Time series data of color indices; see below references for context.
- create_tree_mask_time_series
- plot_tree_mask_time_series

### Analyze time series data
Estimate curve fit parameters and phenology dates for individual trees.
- master_function

The rest of the functions are auxiliary for curve fit and date calculation. This workflow has been tested with the following configurations, which can be specified in master_function, to produce curve fits (i.e. running VI_curve) and get phenology dates (getPhenoDates):

To estimate spring and fall dates using GCC -
- index_type = 'gcc';
- model_name = 'greenDownSigmoid';
- date_method = 'CCR';

or using RCC -
- index_type = 'rcc';
- model_name = 'smoothInterp';
- date_method = 'spring_fall_red'; 
- percentiles = [0.1 0.5 0.9];

## References:
This is the most pertinent reference for this library of code, reporting on phenology analysis of individual trees:
- http://www.mdpi.com/1424-8220/17/12/2852

These references use phenology analysis of aerial imagery on a square grid:
- https://www.sciencedirect.com/science/article/pii/S0168192317303350
- https://link.springer.com/article/10.1007/s00484-018-1564-9