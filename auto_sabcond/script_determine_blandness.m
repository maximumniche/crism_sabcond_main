%% Function to check if a given observation is bland

function [blandBool] = script_determine_blandness(obs_id)

%% Set up some inputs
global crism_env_vars

% Enter observation ID you want to test (case-insensitive)
% obs_id = '1EC41';

% Set dwld option to 2 if you need to download the data
dwld = 2; 

% If there is any update of the remote folder or you need to update
% index.html in the folder, set this to true
DWLD_INDEX_CACHE_UPDATE = false;

pdir = './v3_results/';

% Threshold values for noise rmse and absorption average
threshold_noise = 0.005;
threshold_absorption = 0.01;

%% Set up v3 correction variables
% OPTIONS for sabcond
%
% -------------------------------------------------------------------------
%                               Major options
% -------------------------------------------------------------------------
%
% ## PROCESSING OPTIONS #--------------------------------------------------
precision  = 'single'; 
% {'single','double'}
% in my test, single was much faster and result is quite similar.

proc_mode  = 'GPU_BATCH_2'; 
% {'CPU_1','GPU_1','CPU_2','GPU_2','GPU_BATCH_2'}
% 'GPU_BATCH_2' is the fastest mode, if GPU is not used by others.
% Slightly different algorithms between {'CPU_1','GPU_1'} and 
% {'CPU_2','GPU_2','GPU_BATCH_2'}. Latter is supposed to be better.

batch_size = 10; 
% column size for which processing is performed. Valid only if 
% 'GPU_BATCH_*' mode is selected.

% ## I/O OPTIONS #---------------------------------------------------------
save_pdir = pdir;
% character, string
% root directory path where the processed data are stored. The processed 
% image will be saved at <SAVE_PDIR>/CCCNNNNNNNN, where CCC the class type 
% of the obervation and NNNNNNNN is the observation id. It doesn't matter 
% if trailing slash is there or not.

save_dir_yyyy_doy = 1;
% Boolean
% if true, processed images are saved at <SAVE_PDIR>/YYYY_DOY/CCCNNNNNNNN,
% otherwise, <SAVE_PDIR>/CCCNNNNNNNN.

force = 0;
% Boolean
% if true, processing is forcefully performed and all the existing images 
% will overwritten. Otherwise, you will see a prompt asking whether or not 
% to continue and overwrite images or not when there alreadly exist 
% processed images.

skip_ifexist = 1;
% Boolean
% if true, processing will be automatically skipped if there already exist 
% processed images. No prompt asking whether or not to continue and 
% overwrite images or not.

additional_suffix = '';
% character, string
% any additional suffix added to the name of processd images.

% ## GENERAL SABCOND OPTIONS #---------------------------------------------
bands_opt    = 6;
% integer
% Magic number for wavelength channels to be used. This is the input for 
% [bands] = genBands(bands_opt)

% -------------------------------------------------------------------------
%                               Minor Options
% -------------------------------------------------------------------------

% ## I/O OPTIONS #---------------------------------------------------------
% save_file          = true;
% storage_saving_level = 'NORMAL';
% additional_suffix  = '';
% interleave_out     = 'lsb';
% interleave_default = 'lsb';
% subset_columns_out = false;
% Alib_out           = false;
% do_crop_bands      = false;

%  ## INPUT IMAGE OPTIONS #------------------------------------------------
opt_img      = 'TRRB';
% img_cube     = [];
% img_cube_band_inverse = [];
% dir_yuk      = crism_env_vars.dir_YUK; % TRRY_PDIR
% ffc_counter  = 1;

% ## GENERAL SABCOND OPTIONS #---------------------------------------------
% line_idxes   = [];                     % LINES
% column_idxes = [];
% mt           = 'sabcondpub_v1';        % METHODTYPE
optBP        = 'pri';                  %{'pri','all','none'}
% verbose      = 0;
% column_skip  = 1;
% weight_mode  = 0;
% lambda_update_rule = 'L1SUM';
% th_badspc    = 0.8;
% 
% ## TRANSMISSION SPECTRUM OPTIONS #---------------------------------------
t_mode = 2;
% obs_id_T = '';
% varargin_T = {};

% ## LIBRARY OPTIONS #-----------------------------------------------------
% cntRmvl         = 1;
% optInterpid     = 1;

% following are partially controlled by automatic detection of water ice,
% change them with caution if you want.
optCRISMspclib  = 1;
optRELAB        = 1;
optUSGSsplib    = 6;
optCRISMTypeLib = 4;
library_opt = 'full';

% opticelib       = '';
% 
% ## SABCONDC OPTIONS #----------------------------------------------------
nIter = 5;
lambda_a = 0.01;

%% Calibration
% Get observation info
% CS: Central Scan
obs_info = crism_get_obs_info_v2(obs_id, 'SENSOR_ID', 'L', ...
    'Download_DDR_CS', dwld, 'Download_TRRIF_CS', dwld, ...
    'Download_TRRRA_CS', dwld, 'DOWNLOAD_TRRHKP_CS', dwld, ...
    'DOWNLOAD_EDR_CS_CSDF', dwld, ...
    'DWLD_INDEX_CACHE_UPDATE', DWLD_INDEX_CACHE_UPDATE);

% Central scan index
csi = obs_info.central_scan_info.indx;
% filename (w/o extension) or the central scan image.
basename_trrif_cs = obs_info.sgmnt_info(csi).L.trr.IF{1};
TRRIFdata = CRISMdata(basename_trrif_cs, '');
TRRIFdata.readWAi();

% TRRB I/F:
% calibration processed by our own code with mode 'yuki4', no bad pixel 
% interpolation is applied to SPdata, too. Flat field correction is not 
% applied, neither. This is the default option used for sabcond v5 
% correction.
crism_calibration_IR_v2(obs_id,'save_memory',true,'mode','yuki4', ...
    'version','D','skip_ifexist',1,'force',0,'save_file',1,'dwld',dwld, ...
    'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);

%% CRISM SABCONDV3 Processing

if ~isfolder(fullfile('v3_results', obs_id)) % Only run v3 if processed image doesn't exist

    result = ...
        sabcondv3_pub_water_ice_test(obs_id,3,'t_mode',t_mode,'lambda_a',lambda_a,...
            'opt_img',opt_img,'OPTBP',optBP,'nIter',nIter,'Bands_Opt',bands_opt,...
            'PROC_MODE',proc_mode,'precision',precision, ...
            'library_opt',library_opt, ...
            'OPT_CRISMSPCLIB', optCRISMspclib, 'OPT_RELAB', optRELAB, ...
            'OPT_CRISMTYPELIB',optCRISMTypeLib,'OPT_SPLIBUSGS',optUSGSsplib, ...
            'WEIGHT_MODE',0,'cal_bias_cor',0);
    fprintf('water_ice_result: %d\n',result.presence_H2Oice);
    fprintf('water_ice_exist: %f\n',mean(result.presence_H2Oice_columns,'omitnan'));
    if result.presence_H2Oice
        sabcondv3_pub(obs_id,'t_mode',t_mode,'lambda_a',lambda_a,'opt_img',opt_img,...
            'OPTBP',optBP,'nIter',nIter,'Bands_Opt',bands_opt,'SAVE_PDIR',save_pdir,...
            'additional_suffix',additional_suffix,'force',force,'skip_ifexist',skip_ifexist,...
            'PROC_MODE',proc_mode,'precision',precision,'OPT_ICELIB',3, ...
            'library_opt',library_opt, ...
            'OPT_CRISMSPCLIB', optCRISMspclib, 'OPT_RELAB', optRELAB, ...
            'OPT_CRISMTYPELIB',optCRISMTypeLib,'OPT_SPLIBUSGS',optUSGSsplib, ...
            'WEIGHT_MODE',0,'cal_bias_cor',0);
    else
        sabcondv3_pub(obs_id,'t_mode',t_mode,'lambda_a',lambda_a,'opt_img',opt_img,...
           'OPTBP',optBP,'nIter',nIter,'Bands_Opt',bands_opt,'SAVE_PDIR',save_pdir,...
           'additional_suffix',additional_suffix,'force',force,'skip_ifexist',skip_ifexist,...
           'PROC_MODE',proc_mode,'precision',precision,...
           'library_opt',library_opt, ...
           'OPT_CRISMSPCLIB', optCRISMspclib, 'OPT_RELAB', optRELAB, ...
           'OPT_CRISMTYPELIB',optCRISMTypeLib,'OPT_SPLIBUSGS',optUSGSsplib, ...
           'WEIGHT_MODE',0,'cal_bias_cor',0);
    end

end

%% Determine blandness with RMSE Noise (cor - model) and absorption (Ab*Bg*Ice)

% Load data
TRR3dataset = CRISMTRRdataset(basename_trrif_cs,'');
dir_sab3 = joinPath(pdir,TRR3dataset.trr3if.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1');

% Add noise residuals and absorption data
add_model_residual_absorption(sabcond_data3, obs_id)

%% Plot data (for testing)

%{

% Convert CATIF wavelengths to micrometers
TRR3dataset.catif.wa = TRR3dataset.catif.wa / 1000;
TRR3dataset.catif.readWAi_fromCRISMdata_parent();

% Assign CATIF wavelengths to everything else
sabcond_data3.residual.wa = TRR3dataset.catif.wa;
sabcond_data3.absorption.wa = TRR3dataset.catif.wa;


% Show in the interactive window
h = ENVIRasterMultview({TRRIFdata.RGB.CData_Scaled}, ...
    {...{TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[3,3]},...
     ...{TRR3dataset.catraif,'name','CAT RA IF','AVERAGE_WINDOW',[1,1]},...
     ...{TRR3dataset.trr3raif,'name','TRR3RAIF','AVERAGE_WINDOW',[1,1]},...
     {sabcond_data3.residual,'name','SABCOND3','AVERAGE_WINDOW',[3,3]},...
     {sabcond_data3.absorption}
     } ,...
    'SPC_XLim',[1000 2660],'VARARGIN_IMAGESTACKVIEW',{'Ydir','reverse'});

%}

%% Calculate blandness by absorption of column percentile and rmse noise

% Read absorption and noise data from sabcond V3 data
absorption = sabcond_data3.absorption.readimg();
residuals = sabcond_data3.residual.readimg();

% Calculate noise RMSE
rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));

% Calculate an average absorption
absorption_rows = squeeze(prctile(absorption, 95, 1)); % Take highest percentile
% of columns (across track)
absorption_avg = squeeze(median(absorption_rows, 1, 'omitnan')); % From best columns,
% get the median absorption for all wavelengths across rows
absorption_avg = mean(absorption_avg, 'omitnan'); % get mean of wavelengths

% rmse_noise
% absorption_avg

% Determine if image is bland based on two values
if rmse_noise > threshold_noise % If noise RMSE is greater than noise threshold,
    % discard image as nonbland b/c too much noise indicates nonblandness

    blandBool = false;
    % disp("Image is too noisy, probably nonbland")

else % If not, check absorption_avg

    
    if absorption_avg < threshold_absorption % If absorption less than threshold,
        % image is bland
        blandBool = true;
        % disp("Image is bland")
    else % If not, nonbland
        blandBool = false;
        % disp("Image is nonbland")
    end

end






end