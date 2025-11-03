%% Script to automate SABCOND V5
% depth first search esque way of finding best candidate

%% VARIABLE SETUP
target_images = {'40FF'};
skip_hitran = false; % whether you want to skip HITRAN or not, only eligible
                    % if HITRAN profiles are already generated
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
        
        %% Turn ddr_list into viable candidates cell array consisting of ids
        
        for i=1:length(ddr_list)
        
            bland_candidate = ddr_list(i).dirname;
            bland_candidate = regexprep(bland_candidate, '^[A-Z]*0+', ''); % Get rid of leading 0s and descriptor
        
            viable_candidates{i} = bland_candidate;
        
        end
        
        % Get rid of target_image id itself if in cell array
        viable_candidates(strcmp(viable_candidates, target_image)) = [];
        
        %% Run elevation check on candidates
        
        compatible = [];
        
        for i=1:length(viable_candidates)

            try
        
                compatible(i) = compare_elevation(target_image, viable_candidates{i});

            catch % If error thrown, just ignore candidate

                disp("Comparison threw error. Ignoring candidate.")
                
                compatible(i) = 0;

            end
        
        end
        
        viable_candidates = viable_candidates(logical(compatible));

        %% If no candidates, loop back with new toleraences
    
        if isempty(viable_candidates)
            continue; % jump back to beginning of loop
        end
        
        %% Determine blandness and compatibility of candidates
        % Choose the first bland and compatible candidate
        
        compatible = [];
        bland = [];
        
        for i=1:length(viable_candidates)

            try
                [compatible(i), ~] = script_compare_images(target_image, viable_candidates{i});
            catch
                disp("Compatibility check threw error. Ignoring candidate.")
                compatible(i) = 0;
                bland(i) = 0;
                continue;
            end

            if ~compatible(i)
                disp("Image not compatible. Bad candidate.")
                bland(i) = 0;
                continue;
            end

            try
                bland(i) = script_determine_blandness(viable_candidates{i});
            catch
                disp("Bland check threw error. Ignoring candidate")
                bland(i) = 0;
                % Don't continue bc need to delete image from v3_results
            end

    
            if logical(bland(i)) && logical(compatible(i))
                compatible_candidate = viable_candidates{i};
                break;
            end

            %% Delete everything in v3_results

            % MAKE SURE YOU'RE POINTING TO CORRECT FOLDER
            folders = dir('./v3_results');
    
            for k=3:length(folders)
    
                if ~ismember(folders(k).name, {'.','..'})
                    rmdir(fullfile(folders(k).folder, folders(k).name), 's')
                end
    
            end

        end

        viable_candidates = viable_candidates(logical(bland) & logical(compatible));
    
        %% If no candidates, loop back with new toleraences
    
        if isempty(viable_candidates)
            continue; % jump back to beginning of loop
        end
        
        
        %% Run HITRAN on valid candidate, skip if already generated
        
        if ~skip_hitran
    
            disp("Running HITRAN...");
            run_hitran(compatible_candidate);
        
        end
        
        %% Perform SABCOND algorithm on candidate
        
        disp("Performing SABCOND on " + string(target_image) + " with " + string(compatible_candidate));
        run_sabcondv5(compatible_candidate, target_image);
    
        %% Delete everything in v3_results if not already

        % MAKE SURE YOU'RE POINTING TO CORRECT FOLDER
        folders = dir('./v3_results');

        for k=3:length(folders)

            if ~ismember(folders(k).name, {'.','..'})
                rmdir(fullfile(folders(k).folder, folders(k).name), 's')
            end

        end
        
        

        %% Break out of while loop since everything ran completely
        break;
    
    end

end