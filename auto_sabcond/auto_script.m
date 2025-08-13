%% Script to automate SABCOND V5 Bland Image Selection* 
% Currently for a single image, will update for multiple images soon

function [] = auto_script()

%% VARIABLE SETUP (Will convert to function parameters later)
target_image = '9A16';
skip_hitran = true; % whether you want to skip HITRAN or not, only eligible
                    % if HITRAN profile is already generated
initial_tolerance = 1; % initial tolerance for ddr search

%% Run startup_addpath to create links to toolbox and data
startup_addpath();

%% Run crism_init to create global env_vars variable
crism_init;

%% Run ddr_search and store output list of images in variable
prev_tolerance = 0;
tolerance = initial_tolerance;

ddr_list = ddr_search_auto(target_image, tolerance, prev_tolerance);

while length(ddr_list) < 10
    prev_tolerance = tolerance;
    tolerance = tolerance + 1;
    ddr_list = ddr_search_auto(target_image, tolerance, prev_tolerance);
end


%% Turn ddr_list into ids
bland_candidates = [];

for i=1:length(ddr_list)

    bland_candidates(i) = erase(ddr_list(i).dirname, ['FRT', '0000']); 

end

%% Run elevation check on candidates

compatible = [];

for i=1:length(ddr_list)

    bland_id = ddr_list(i).dirname;

    bland_id = erase(bland_id, ['FRT', '0000']);

    compatible(i) = compare_elevation(target_image, bland_id);

end

viable_candidates = ddr_list(compatible )

%% Run script_determine_blandness on viable candidates

% Run script_compare_images on bland candidates to determine best fit

% Run HITRAN on valid candidate, skip if already generated

% Perform SABCOND algorithm on candidate


end