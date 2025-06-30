function [] = startup_addpath()
toolbox_root_dir = '/home/imadk/Documents/MATLAB/CRISM/toolbox';
data_root_dir = '/home/imadk/Documents/MATLAB/CRISM/data';

addpath(fullfile(toolbox_root_dir,'base'));
addpath(fullfile(toolbox_root_dir,'sc'));
addpath(fullfile(toolbox_root_dir,'export_fig'));
addpath(fullfile(toolbox_root_dir,'relab_toolbox'));
addpath(fullfile(toolbox_root_dir,'optProp'));
addpath(fullfile(toolbox_root_dir,'tetracorder'));

% addpath('/Users/itohy1/data/MCD/MCD_v5_3/MCD5.3/mcd/matlab/',...
%         fullfile(toolbox_root_dir,'mcd_toolbox/'));

% reference for mcd data:
% addpath('/Users/itohy1/data/MCD/MCD_v6_1/MCD_6.1/mcd/interfaces/matlab',...
%        '/Users/itohy1/data/MCD/MCD_v5_3/MCD5.3/mcd/matlab/', ...
%        fullfile(toolbox_root_dir,'mcd_toolbox/'));

addpath(fullfile(data_root_dir, 'MCD_6.1/mcd/interfaces/matlab'),...
        fullfile(toolbox_root_dir, 'mcd_toolbox'));

% addpath(fullfile(toolbox_root_dir,'quaternions-1.3/quaternions/'));

addpath(fullfile(toolbox_root_dir,'crism_conv_hitran'));

run(fullfile(toolbox_root_dir,'envi','envi_startup_addpath'));
run(fullfile(toolbox_root_dir,'continuumRemoval','cntrmvl_toolbox_startup_addpath'));
run(fullfile(toolbox_root_dir,'pds3_toolbox','pds3_startup_addpath'));
run(fullfile(toolbox_root_dir,'suwab_toolbox','suwab_toolbox_startup_addpath'));
run(fullfile(toolbox_root_dir,'crism_toolbox','crism_startup_addpath'));
run(fullfile(toolbox_root_dir,'crism_calibration','crism_calibration_startup_addpath'));
run(fullfile(toolbox_root_dir,'crism_sabcond','crism_sabcond_startup_addpath'));


end
