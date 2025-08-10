
%% check the results
obs_id = '9A16';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './resu/';
dir_sab3 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1');
TRR3dataset.catif.readWAi_fromCRISMdata_parent();
TRR3dataset.catif.wa = TRR3dataset.catif.wa / 1000;

% Add model, residual, absorption data to sabcond_data3 object
add_model_residual_absorption(sabcond_data3, obs_id);


%%
sabcond_data3.absorption.set_rgb();
sabcond_data3.cor.wa = TRR3dataset.catif.wa;
sabcond_data3.residual.wa = TRR3dataset.catif.wa;
sabcond_data3.absorption.wa = TRR3dataset.catif.wa;
sabcond_data3.model.wa = TRR3dataset.catif.wa;
sabcond_data3.AB.wa = TRR3dataset.catif.wa;

h1 = ENVIRasterMultview({sabcond_data3.absorption.RGB.CData_Scaled},{ ...
    ...{TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data3.AB,'name','v3 AB','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data3.cor,'name','v3 cor','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    {sabcond_data3.residual,'name','v3 residual','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data3.absorption,'name','v3 absorption','AVERAGE_WINDOW',[1,1]}, ...
    },...
'SPC_XLIM',[1.100 2.600],...
'varargin_ImageStackView',{'Ydir','reverse'});

%% Calculate absorption-to-noise ratio
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