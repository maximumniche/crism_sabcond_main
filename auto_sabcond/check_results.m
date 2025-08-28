%% check the results
obs_id = '9A16';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v5_results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');
% TRR3dataset.catif.readWAi_fromCRISMdata_parent();
TRR3dataset.trrdif.wa = TRR3dataset.trrdif.wa / 1000;

%% check the results
obs_id = '9A16';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = '../results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5_2 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01_9A16');

%% check the results
obs_id = '9A16';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v3_results0/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename,dir_sab5,...
    'suffix','sabcondpub_v1');


%% check the results
obs_id = '9A98';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v3_results0/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrbif.basename,dir_sab5,...
    'suffix','sabcondpub_v1');
% TRR3dataset.catif.readWAi_fromCRISMdata_parent();
TRR3dataset.trrdif.wa = TRR3dataset.trrdif.wa / 1000;

%%
sabcond_data5.nr_ds.set_rgb();
sabcond_data5.nr_ds.wa = TRR3dataset.trrdif.wa;
sabcond_data5_2.nr_ds.wa = TRR3dataset.trrdif.wa;
sabcond_data3.nr_ds.wa = TRR3dataset.trrdif.wa;
% sabcond_data5.ori.wa = TRR3dataset.catif.wa;
h1 = ENVIRasterMultview({sabcond_data5.nr_ds.RGB.CData_Scaled},{ ...
    ...{sabcond_data5.cor,'name','AB_ds','AVERAGE_WINDOW',[1,1]}, ...
    ...{TRR3dataset.trrdif,'name','TRRBIF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data5_2.nr_ds,'name','v5 old','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data3.nr_ds,'name','v3','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data5.nr_ds,'name','v5 new','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    },...
'SPC_XLIM',[1.100 2.600],...
'varargin_ImageStackView',{'Ydir','reverse'});
