global crism_env_vars
obs_ids = {'47A3'};

for i=1:length(obs_ids)

    obs_id = obs_ids{i};

    obs_info = crism_get_obs_info_v2(obs_id, 'SENSOR_ID', 'L', ...
        'Download_DDR_CS', 2, 'DOWNLOAD_TRRIF', 2, 'Download_TRRIF_CS', 2, ...
        'Download_TRRRA_CS', 2, 'DOWNLOAD_TRRHKP_CS', 2, ...
        'DOWNLOAD_EDR_CS_CSDF', 2, ...
        'DOWNLOAD_DDR', 2);
    
    % Central scan index
    csi = obs_info.central_scan_info.indx;
    % filename (w/o extension) or the central scan image.
    basename_trrif_cs = obs_info.sgmnt_info(csi).L.trr.IF{1};
    TRRIFdata = CRISMdata(basename_trrif_cs, '');
    TRRIFdata.load_basenamesCDR('dwld', 2);
    TRRIFdata.readWAi();
    
    crism_calibration_IR_v2(obs_id,'save_memory',true,'mode','yuki4', ...
        'version','D','skip_ifexist',1,'force',0,'save_file',1,'dwld',2, ...
        'DWLD_INDEX_CACHE_UPDATE',2);
    
    tic; crism_vscor(TRRIFdata,'save_file',1,'art',1,'force',0,'skip_if_exist',1, ...
        'save_pdir',crism_env_vars.dir_TRRX,'SAVE_DIR_YYYY_DOY',true); toc;
    
    % Central scan index
    csi = obs_info.central_scan_info.indx;
    % filename (w/o extension) or the central scan image.
    basename_trrif_cs = obs_info.sgmnt_info(csi).L.trr.IF{1};
    TRRIFdata = CRISMdata(basename_trrif_cs, '');
    TRRIFdata.load_basenamesCDR('dwld', 2);
    TRRIFdata.readWAi();

end