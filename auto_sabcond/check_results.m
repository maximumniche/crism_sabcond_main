%% check the results
obs_id = '3E12';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v5_results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');
% TRR3dataset.catif.readWAi_fromCRISMdata_parent();

%% check the results
obs_id = '37AE';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v5_bland_results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');

%%
sabcond_data5.nr_ds.set_rgb();
sabcond_data5.nr_ds.wa = TRR3dataset.trrdif.wa;
sabcond_data5.AB.wa = TRR3dataset.trrdif.wa;

h1 = ENVIRasterMultview({sabcond_data5.nr_ds.RGB.CData_Scaled},{ ...
    ...{sabcond_data5.cor,'name','AB_ds','AVERAGE_WINDOW',[1,1]}, ...
    ...{TRR3dataset.trrdif,'name','TRRBIF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data5.nr_ds,'name','v5 new','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    },...
'SPC_XLIM',[1100 2600],...
'varargin_ImageStackView',{'Ydir','reverse'});
