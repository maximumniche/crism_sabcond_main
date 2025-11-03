%% check the results

obs_id = '47A3';

%% Do photometric correction on v3
%%
obs_info = crism_get_obs_info_v2(obs_id,'download_trrif_cs',2);
csi = obs_info.central_scan_info.indx;
TRR3dataset = CRISMTRRdataset(obs_info.sgmnt_info(csi).L.trr.IF{1},'');
TRR3dataset.trr3if.load_basenamesCDR();
WAdata = TRR3dataset.trr3if.readCDR('WA'); WAdata.readimgi();
bands = crmsab_genBands_v2(WAdata.prop.wavelength_filter,6,WAdata.prop.binning,WAdata.prop.sclk);

pdir3 = '/home/imadk/Documents/MATLAB/CRISM/crism_sabcond_main/auto_sabcond/v3_results';
dir_sab3 = joinPath(pdir3,TRR3dataset.trr3if.dirname);
sabcond_data3_1 = SABCONDdataset(TRR3dataset.trrbif.basename,dir_sab3,...
    'suffix','sabcondpub_v1');
% photometric correction
DEdata = CRISMDDRdata(obs_info.sgmnt_info(csi).L.ddr.DE{1}, '');
crism_photocor_wrapper(sabcond_data3_1.nr_ds, DEdata);

% Replace values
sabcond3_1_nr_ds_pht1 = CRISMdataCAT(...
    [sabcond_data3_1.nr_ds.basename, '_phot1'], ...
    sabcond_data3_1.nr_ds.dirpath);

crism_replace_value_wrapper(sabcond3_1_nr_ds_pht1);

%% Photometric correction on v5
pdir5 = '/home/imadk/Documents/MATLAB/CRISM/crism_sabcond_main/auto_sabcond/v5_results';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5_1 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');
% photometric correction
DEdata = CRISMDDRdata(obs_info.sgmnt_info(csi).L.ddr.DE{1}, '');
crism_photocor_wrapper(sabcond_data5_1.nr_ds, DEdata);

% Replace values
sabcond5_1_nr_ds_pht1 = CRISMdataCAT(...
    [sabcond_data5_1.nr_ds.basename, '_phot1'], ...
    sabcond_data5_1.nr_ds.dirpath);

crism_replace_value_wrapper(sabcond5_1_nr_ds_pht1);

%%

obs_id = '47A3';

crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v5_results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01_nr_ds_phot1');

crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v3_results/';
dir_sab3 = joinPath(pdir5,TRR3dataset.trrbif.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1_nr_ds_phot1');

% generate MTRDR
crism_mtrdr_obs = crism_get_obs_info_v2(obs_id, 'DOWNLOAD_MTRDR', 2);

% get MTRDR
mtrdr_data = CRISMdataCAT(crism_obs.info.basenameMTRIF, crism_obs.info.dir_mtrdr);


%% check the results
obs_id = '4774';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v5_bland_results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');

%%
sabcond_data5.cor.set_rgb();
sabcond_data5.cor.wa = TRR3dataset.trrdif.wa;
sabcond_data3.cor.wa = TRR3dataset.trrdif.wa; 

h1 = ENVIRasterMultview({sabcond_data5.cor.RGB.CData_Scaled},{ ...
    {mtrdr_data,'name','MTRDR','AVERAGE_WINDOW',[1,1]}, ...
    ...{TRR3dataset.trrdif,'name','TRRBIF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data5.cor,'name','v5','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    ...{sabcond_data3.cor,'name','v3','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    },...
'SPC_XLIM',[1100 2600],...
'varargin_ImageStackView',{'Ydir','reverse'});
