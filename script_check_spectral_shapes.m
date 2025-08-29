function [h] = script_check_spectral_shapes(obs_id_test)

%% Check the overall spectral shapes ... to see if the spectra are bland or not.
% crism_init;

%% Set up some inputs
global crism_env_vars

% Enter observation ID you want to test (case-insensitive)
% obs_id_test = 'c2fc';

% Set dwld option to 2 if you need to download the data
dwld = 2; 

% If there is any update of the remote folder or you need to update
% index.html in the folder, set this to true
DWLD_INDEX_CACHE_UPDATE = false;

%% Main processing
% Get observation info
% CS: Central Scan
obs_info = crism_get_obs_info_v2(obs_id_test, 'SENSOR_ID', 'L', ...
    'Download_DDR_CS', dwld, 'Download_TRRIF_CS', dwld, ...
    'Download_TRRRA_CS', dwld, 'DOWNLOAD_TRRHKP_CS', dwld, ...
    'DWLD_INDEX_CACHE_UPDATE', DWLD_INDEX_CACHE_UPDATE);

% Central scan index
csi = obs_info.central_scan_info.indx;
% filename (w/o extension) or the central scan image.
basename_trrif_cs = obs_info.sgmnt_info(csi).L.trr.IF{1};
TRRIFdata = CRISMdata(basename_trrif_cs, '');
basename_trrra_cs = obs_info.sgmnt_info(csi).L.trr.RA{1};
TRRRAdata = CRISMdata(basename_trrra_cs,'');
TRRIFdata.readWAi();
TRRIFdata.set_rgb();

% Calibration in our code
% -----------------------
obs_info = crism_get_obs_info_v2(obs_id_test, 'SENSOR_ID', 'L', ...
    'Download_DDR_CS', dwld, 'Download_TRRIF_CS', dwld, ...
    'Download_TRRRA_CS', dwld, 'DOWNLOAD_TRRHKP_CS', dwld, ...
    'DOWNLOAD_EDR_CS_CSDF', dwld, ...
    'DWLD_INDEX_CACHE_UPDATE', DWLD_INDEX_CACHE_UPDATE);
% TRRD I/F:
% calibration processed by our own code with mode 'yuki4', no bad pixel 
% interpolation is applied to SPdata, too. Flat field correction is not 
% applied, neither. This is the default option used for sabcond v5 
% correction.
crism_calibration_IR_v2(obs_id_test,'save_memory',true,'mode','yuki4', ...
    'version','D','skip_ifexist',1,'force',0,'save_file',1,'dwld',dwld, ...
    'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);

% CRISM standard processing
% radiance to I/F
% tic; crism_r2if(TRRRAdata,'save_file',1,'force',0,'skip_if_exist',1, ...
%     'save_pdir',crism_env_vars.dir_TRRX,'SAVE_DIR_YYYY_DOY',true); toc;
% TRRRAIFdata = CRISMdataCAT([basename_trrra_cs '_IF'], joinPath(crism_env_vars.dir_TRRX,obs_info.yyyy_doy,obs_info.dirname));
% TRRRAIFdata.readWAi_fromCRISMdata_parent();
% % volcano scan correction on RA_IF
% tic; crism_vscor(TRRRAIFdata,'save_file',1,'art',1,'force',0,'skip_if_exist',1, ...
%     'save_pdir',crism_env_vars.dir_TRRX,'SAVE_DIR_YYYY_DOY',true); toc;
% volcano scan correction on TRR3 I/F
tic; crism_vscor(TRRIFdata,'save_file',1,'art',1,'force',0,'skip_if_exist',1, ...
    'save_pdir',crism_env_vars.dir_TRRX,'SAVE_DIR_YYYY_DOY',true); toc;

% Load relevant data
TRR3dataset = CRISMTRRdataset(basename_trrif_cs,'');
TRR3dataset.trr3if.readWAi();
TRR3dataset.catif.readWAi_fromCRISMdata_parent();
% TRR3dataset.catraif.readWAi_fromCRISMdata_parent();

% Show in the interactive window
h = ENVIRasterMultview({TRRIFdata.RGB.CData_Scaled}, ...
    {{TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[3,3]},...
     ...{TRR3dataset.catraif,'name','CAT RA IF','AVERAGE_WINDOW',[1,1]},...
     ...{TRR3dataset.trr3raif,'name','TRR3RAIF','AVERAGE_WINDOW',[1,1]},...
     ...{TRR3dataset.trrdif,'name','TRRDIF','AVERAGE_WINDOW',[3,3]}, ...
     ...{TRR3dataset.trr3if,'name','TRRIF','AVERAGE_WINDOW',[3,3]} ...
     } ,...
    'SPC_XLim',[1000 2660],'VARARGIN_IMAGESTACKVIEW',{'Ydir','reverse'});


end