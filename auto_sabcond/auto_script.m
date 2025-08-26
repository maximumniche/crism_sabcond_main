%% Script to automate SABCOND V5

%% VARIABLE SETUP
target_images = {'75A9'};
skip_hitran = false; % whether you want to skip HITRAN or not, only eligible
                    % if HITRAN profile is already generated
tolerance = 1; % initial tolerance for ddr search
prev_tolerance = 0; % tolerance you don't want to go below initially
tolerance_step = 1; % step for tolerance

%% Run startup_addpath and crism_init
startup_addpath();
crism_init;

%% For loop that goes through every image

for image_index=1:length(target_images)

    target_image = target_images{image_index};

    %% While loop that reloops when there are no viable candidates
    
    while true
    
        %% Run ddr_search and store output list of images in variable
        ddr_list = ddr_search_auto(target_image, tolerance, prev_tolerance);   
    
        %% Update tolerance and previous tolerance
        prev_tolerance = tolerance;
        tolerance = prev_tolerance + tolerance_step;
        
        %% Turn ddr_list into viable candidates list consisting of ids
        
        for i=1:length(ddr_list)
        
            bland_candidate = ddr_list(i).dirname;
            bland_candidate = regexprep(bland_candidate, '^[A-Z]*0+', ''); % Get rid of leading 0s and descriptor
        
            viable_candidates{i} = bland_candidate;
        
        end
        
        %% Run elevation check on candidates
        
        compatible = [];
        
        for i=1:length(ddr_list)
        
            compatible(i) = compare_elevation(target_image, viable_candidates{i});
        
        end
        
        viable_candidates = viable_candidates(logical(compatible));
        
        %% Run script_determine_blandness on viable candidates
        
        compatible = [];
        
        for i=1:length(viable_candidates)
        
            compatible(i) = script_determine_blandness(viable_candidates{i});
        
        
        end
        
        viable_candidates = viable_candidates(logical(compatible));
        
        %% Run script_compare_images on bland candidates to determine best fit
        
        compatible = [];
        rmse = [];
        
        for i=1:length(viable_candidates)
        
            [compatible(i), rmse(i)] = script_compare_images(target_image, viable_candidates{i});
        
        end
    
    
        rmse = rmse(logical(compatible));
        viable_candidates = viable_candidates(logical(compatible));
    
        %% If no candidates, loop back with new toleraences
    
        if isempty(viable_candidates)
            continue; % jump back to beginning of loop
        end
    
       
        %% Select the best candidate based on minimum RMSE
        [~, bestIndex] = min(rmse);
        best_candidate = viable_candidates{bestIndex};
        disp("Best candidate is " + string(best_candidate));
        
        
        %% Run HITRAN on valid candidate, skip if already generated
        
        if skip_hitran == false
    
            disp("Running HITRAN...");
            run_hitran(best_candidate);
        
        end
        
        %% Perform SABCOND algorithm on candidate
    
        disp("Performing SABCOND on " + string(target_image) + " with " + string(best_candidate));
        run_sabcondv5(best_candidate, target_image);
    
        %% Delete everything in v3_results
        delete('./v3_results/*')
        
        break;
    
    end

end