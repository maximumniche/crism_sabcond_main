
%% check the results
obs_id = '12D5E';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v3_results/';
dir_sab3 = joinPath(pdir5,TRR3dataset.trrbif.dirname);
sabcond_data3 = SABCONDdataset(TRR3dataset.trrbif.basename, dir_sab3,...
    'suffix', 'sabcondpub_v1');
% TRR3dataset.catif.readWAi_fromCRISMdata_parent();

add_model_residual_absorption(sabcond_data3, obs_id)

%%
sabcond_data3.nr_ds.set_rgb();
sabcond_data3.AB.wa = TRR3dataset.trrbif.wa;

h1 = ENVIRasterMultview({sabcond_data3.nr_ds.RGB.CData_Scaled},{ ...
    ...{TRR3dataset.catif,'name','CAT IF','AVERAGE_WINDOW',[1,1]}, ...
    {sabcond_data3.AB,'name','v3 nr','AVERAGE_WINDOW',[1,1]}, ...
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