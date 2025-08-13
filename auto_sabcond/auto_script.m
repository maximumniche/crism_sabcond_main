%% Script to automate SABCOND V5 Bland Image Selection* 
% Currently for a single image, will update for multiple images one day

%
function [] = auto_script()

% VARIABLE SETUP (Will convert to function parameters later)
target_image = '9A16';
skip_hitran = true;

% Run startup_addpath to create links to toolbox and data
startup_addpath();

% Run crism_init to create global env_vars variable
crism_init;

% Run ddr_search and store output list of images in variable
script_ddr_search_by_time_or_location_v2

% Run elevation check on candidates

% Run script_determine_blandness on viable candidates

% Run script_determine_blandness for 

% Run HITRAN on valid candidate, skip if already generated

% Perform SABCOND algorithm on candidate


end