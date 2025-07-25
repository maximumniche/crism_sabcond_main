
%% check the results
obs_id = '9A98';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = '/home/imadk/data/results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');
TRR3dataset.catif.readWAi_fromCRISMdata_parent();
TRR3dataset.catif.wa = TRR3dataset.catif.wa / 1000;
%%
sabcond_data5.nr_ds.set_rgb();
sabcond_data5.cor.wa = TRR3dataset.catif.wa;
sabcond_data5.ori.wa = TRR3dataset.catif.wa;
h1 = ENVIRasterMultview({sabcond_data5.nr_ds.RGB.CData_Scaled},{ ...
    ...{TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data5.nr_ds,'name','v5','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    },...
'SPC_XLIM',[1.100 2.600],...
'varargin_ImageStackView',{'Ydir','reverse'});



%% check the results
obs_id = '9A16';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = '/home/imadk/data/results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01_9A16');
TRR3dataset.catif.readWAi_fromCRISMdata_parent();
TRR3dataset.catif.wa = TRR3dataset.catif.wa / 1000;
%%
sabcond_data5.nr.set_rgb();
sabcond_data5.nr.wa = TRR3dataset.catif.wa;
h1 = ENVIRasterMultview({sabcond_data5.nr.RGB.CData_Scaled},{ ...
    {sabcond_data5.nr,'name','v5 wsaice','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    },...
'SPC_XLIM',[1.000 2.600],...
'varargin_ImageStackView',{'Ydir','reverse'});


