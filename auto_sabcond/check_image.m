
%% check the results
obs_id = '9A81';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v3_test_results/';
dir_sab3 = joinPath(pdir5,TRR3dataset.trrbif.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1');
% TRR3dataset.catif.readWAi_fromCRISMdata_parent();

% add_model_residual_absorption(sabcond_data3, obs_id)

obs_id2 = '9A0A';
crism_obs2 = CRISMObservation(obs_id2,'sensor_id','L');
TRR3dataset2 = CRISMTRRdataset(crism_obs2.info.basenameIF,'');
pdir5 = './v3_test_results/';
dir_sab3_2 = joinPath(pdir5,TRR3dataset2.trrbif.dirname);
sabcond_data3_2 = SABCONDdataset(TRR3dataset2.trrbif.basename, dir_sab3_2,...
    'suffix', 'sabcondpub_v1');



%%
sabcond_data3.cor.set_rgb();
sabcond_data3.AB.wa = TRR3dataset.trrbif.wa;
%sabcond_data3.absorption.wa = TRR3dataset.trrbif.wa;


h1 = ENVIRasterMultview({sabcond_data3.cor.RGB.CData_Scaled},{ ...
    ...{TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data3.cor,'name','9A81 AB','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data3_2.cor,'name','9A0A AB','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data3.cor,'name','v3 cor','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    ...{sabcond_data3.residual,'name','v3 residual','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data3.absorption,'name','v3 absorption','AVERAGE_WINDOW',[1,1]}, ...
    },...
'SPC_XLIM',[1100 2600],...
'varargin_ImageStackView',{'Ydir','reverse'});

%%
absorption = sabcond_data3.absorption.readimg();
residuals = sabcond_data3.residual.readimg();

rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));



% Calculate an average absorption
absorption_rows = squeeze(prctile(absorption, 95, 1)); % Take highest percentile
% of columns (across track)
absorption_avg = squeeze(median(absorption_rows, 1, 'omitnan')); % From best columns,
% get the median absorption for all wavelengths across rows
absorption_avg = mean(absorption_avg, 'omitnan'); % get mean of wavelengths

%%
obs_info = crism_get_obs_info_v2(obs_id,'download_trrif_cs',2);
csi = obs_info.central_scan_info.indx;
TRR3dataset = CRISMTRRdataset(obs_info.sgmnt_info(csi).L.trr.IF{1},'');
TRR3dataset.trr3if.load_basenamesCDR();
WAdata = TRR3dataset.trr3if.readCDR('WA'); WAdata.readimgi();
bands = crmsab_genBands_v2(WAdata.prop.wavelength_filter,6,WAdata.prop.binning,WAdata.prop.sclk);

pdir3 = '/home/imadk/Documents/MATLAB/CRISM/crism_sabcond_main/auto_sabcond/v3_test_results';
dir_sab3 = joinPath(pdir3,TRR3dataset.trr3if.dirname);
sabcond_data3_1 = SABCONDdataset(TRR3dataset.trrbif.basename,dir_sab3,...
    'suffix','sabcondpub_v1');
%% photometric correction
DEdata = CRISMDDRdata(obs_info.sgmnt_info(csi).L.ddr.DE{1}, '');
crism_photocor_wrapper(sabcond_data3_1.nr_ds, DEdata);

%% Replace values
sabcond3_1_nr_ds_pht1 = CRISMdataCAT(...
    [sabcond_data3_1.nr_ds.basename, '_phot1'], ...
    sabcond_data3_1.nr_ds.dirpath);

crism_replace_value_wrapper(sabcond3_1_nr_ds_pht1);
