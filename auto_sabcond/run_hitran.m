%% Run HITRAN with parameters

function [] = run_hitran(obs_id)

%% Variables

hitran_path = "./mars_hitran/";
script_name = "main_script_new.py";

%% Generate atmospheric profile statistics
% obs_id = '9A98';
out = mcd_crism_create_profile(obs_id,'save', true, 'SAVE_DIR', hitran_path, 'MCD_VER', '6_1', 'scena', 1);

%% Run HITRAN script

file_args = script_name + " '" + erase(out.fpath, hitran_path) +  "'";

% Add mars_hitran to python path
pyrun(["import os", "os.chdir('" + hitran_path + "')"])

pyrunfile(file_args)

end
