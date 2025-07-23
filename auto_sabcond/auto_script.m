%% Script to automate SABCOND V5 Bland Image Selection* 
% Currently for a single image, will update for multiple images one day

%
function [] = auto_script()

% VARIABLE SETUP (Will convert to function parameters later

target_image = '9A16';


% Run startup_addpath to create links to toolbox and data
startup_addpath();

% Run ddr_search and store output list of images in variable
script_ddr_search_by_time_or_location_v2

% With list of images, fetch derived products from crism-map


% Evaluate best bland image


% Check elevation


end