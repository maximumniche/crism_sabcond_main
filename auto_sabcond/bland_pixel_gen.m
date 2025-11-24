% Function to generate a 2D boolean array of bland pixels for an image
function [blandPixels] = bland_pixel_gen(obs_id)

%% Run v3 on image
run_sabcondv3(obs_id)

%% Determine blandness with RMSE Noise (cor - model) and absorption (Ab*Bg*Ice)

% obs_id = '9A16';
pdir = './v3_results';

% Get observation info
obs_info = crism_get_obs_info_v2(obs_id, 'SENSOR_ID', 'L');

% Central scan index
csi = obs_info.central_scan_info.indx;
% filename (w/o extension) or the central scan image.
basename_trrif_cs = obs_info.sgmnt_info(csi).L.trr.IF{1};

% Load data
TRR3dataset = CRISMTRRdataset(basename_trrif_cs,'');
dir_sab3 = joinPath(pdir,TRR3dataset.trr3if.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1');

% Add noise residuals and absorption data
add_model_residual_absorption(sabcond_data3, obs_id)

%% Calculate blandness by absorption of column percentile and rmse noise

% Read absorption and noise data from sabcond V3 data
absorption = sabcond_data3.absorption.readimg();
residuals = sabcond_data3.residual.readimg();

% Calculate noise RMSE
% rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));

% Calculate noise l1 norm
l1_noise = mean(abs(residuals(:)), 'omitnan');
absorption_wavelengths = squeeze(mean(absorption, 3, 'omitnan')); % Calculate avg of absorption wavelengths

blandPixels = absorption_wavelengths < l1_noise;

bestCols = mean(blandPixels, 1) > 0.95;
bestCols = find(bestCols);

end