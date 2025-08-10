
%% check the results
obs_id = '47A3';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './results/';
dir_sab3 = joinPath(pdir5,TRR3dataset.trrdif.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrdif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1_trrd_cor_cbc11_nIter2_tu2_ltn0_ltnl035');
TRR3dataset.catif.readWAi_fromCRISMdata_parent();
TRR3dataset.catif.wa = TRR3dataset.catif.wa / 1000;

%%
sabcond_data3.nr_ds.set_rgb();

h1 = ENVIRasterMultview({sabcond_data3.nr_ds.RGB.CData_Scaled},{ ...
    {TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data3.nr_ds,'name','v3 nr','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data3.cor,'name','v3 cor','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    ...{sabcond_data3.residual,'name','v3 residual','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data3.absorption,'name','v3 absorption','AVERAGE_WINDOW',[1,1]}, ...
    },...
'SPC_XLIM',[1.100 2.600],...
'varargin_ImageStackView',{'Ydir','reverse'});

%%
absorption = sabcond_data3.absorption.readimg();
residuals = sabcond_data3.residual.readimg();

abs_flat = absorption(:);
abs_flat = abs_flat(~isnan(abs_flat));

rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));

% Calculate absorption-to-noise ratio

absorption_mean = mean(abs_flat);
absorption_median = median(abs_flat);

anr_mean = absorption_mean / rmse_noise
anr_median = absorption_median / rmse_noise