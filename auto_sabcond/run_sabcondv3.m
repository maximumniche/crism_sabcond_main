%% Set up some inputs
global crism_env_vars

% Enter observation ID you want to test (case-insensitive)
obs_ids = {'350F'};

% Set dwld option to 2 if you need to download the data
dwld = 2; 

% If there is any update of the remote folder or you need to update
% index.html in the folder, set this to true
DWLD_INDEX_CACHE_UPDATE = false;

pdir = '/home/imadk/Documents/MATLAB/CRISM/crism_sabcond_main/auto_sabcond/v3_results';

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

for i=1:length(obs_ids)

    obs_id = obs_ids{i};

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
    TRRIFdata.load_basenamesCDR('dwld', dwld);
    TRRIFdata.readWAi();
    
    %%
    
    % TRRB I/F:
    % calibration processed by our own code with mode 'yuki4', no bad pixel 
    % interpolation is applied to SPdata, too. Flat field correction is not 
    % applied, neither. This is the default option used for sabcond v5 
    % correction.
    crism_calibration_IR_v2(obs_id,'save_memory',true,'mode','yuki4', ...
        'version','B','skip_ifexist',1,'force',0,'save_file',1,'dwld',dwld, ...
        'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);
    
    %% CRISM SABCONDV3 Processing
    
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