
%% check the results

obs_ids = {'9A16', '9A98', '1EC41', '1EC69', '1EBC6', '1EBAC', '1EC9D'};
pdir = './resu/';


for i=1:length(obs_ids)

    obs_id = obs_ids{i};

    crism_obs(i) = CRISMObservation(obs_id,'sensor_id','L');
    TRR3dataset(i) = CRISMTRRdataset(crism_obs(i).info.basenameIF,'');
    dir_sab3{i} = joinPath(pdir,TRR3dataset(i).trr3if.dirname);
    sabcond_data3(i) = SABCONDdataset(TRR3dataset(i).trrbif.basename, dir_sab3{i},...
        'suffix', 'sabcondpub_v1');

    % Convert CATIF wavelengths to micrometer
    TRR3dataset(i).catif.readWAi_fromCRISMdata_parent();
    TRR3dataset(i).catif.wa = TRR3dataset(i).catif.wa / 1000;
    
    % Add model, residual, absorption data to sabcond_data3 object at i
    add_model_residual_absorption(sabcond_data3(i), obs_id);

end

%% Compare absorption and rmse noise

% Define columns
varNames = {'obs_ids', 'abs_mean', 'abs_median' 'rmse_noise', 'ANR'};
varTypes = {'char', 'double', 'double', 'double', 'double'};

% Empty table with just headers (0 rows)
T = table('Size',[0 numel(varNames)], ...
          'VariableTypes',varTypes, ...
          'VariableNames',varNames);

for i=1:length(obs_ids)

    absorption = sabcond_data3(i).absorption.readimg();
    residuals = sabcond_data3(i).residual.readimg();

    abs_flat = absorption(:);
    abs_flat = abs_flat(~isnan(abs_flat));

    absorption_mean = mean(abs_flat);
    absorption_median = median(abs_flat);

    rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));

    ANR = absorption_median/rmse_noise;

    newRow = {obs_ids(i), absorption_mean, absorption_median, rmse_noise, ANR};

    T(end+1,:) = newRow;


end

%% Compare highest absorptions and rmse using percentiles

% Define columns
varNames = {'obs_ids', 'abs_mean', 'abs_median' 'rmse_noise', 'ANR'};
varTypes = {'char', 'double', 'double', 'double', 'double'};

% Empty table with just headers (0 rows)
T = table('Size',[0 numel(varNames)], ...
          'VariableTypes',varTypes, ...
          'VariableNames',varNames);

for i=1:length(obs_ids)

    absorption = sabcond_data3(i).absorption.readimg();
    residuals = sabcond_data3(i).residual.readimg();


    % Get array of threshold value of wavelength absorptions above a
    % percentile
    abs_prctile = prctile(absorption,98,3);

    abs_flat = abs_prctile(:);
    abs_flat = abs_flat(~isnan(abs_flat));

    absorption_mean = mean(abs_flat);
    absorption_median = median(abs_flat);

    rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));

    ANR = absorption_median/rmse_noise;

    newRow = {obs_ids(i), absorption_mean, absorption_median, rmse_noise, ANR};

    T(end+1,:) = newRow;


end

%% Compare rmse absorption and rmse noise

% Define columns
varNames = {'obs_ids', 'rmse_absorption', 'rmse_noise', 'ANR'};
varTypes = {'char', 'double', 'double', 'double'};

% Empty table with just headers (0 rows)
T = table('Size',[0 numel(varNames)], ...
          'VariableTypes',varTypes, ...
          'VariableNames',varNames);

for i=1:length(obs_ids)

    absorption = sabcond_data3(i).absorption.readimg();
    residuals = sabcond_data3(i).residual.readimg();

    rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));
    rmse_absorption = sqrt(mean((absorption(:)).^2, 'omitnan'));

    ANR = rmse_absorption/rmse_noise;

    newRow = {obs_ids(i), rmse_absorption, rmse_noise, ANR};

    T(end+1,:) = newRow;


end

%% Define blandness by absorption of column percentile and rmse noise

% Define columns
varNames = {'obs_ids', 'absorption_avg', 'rmse_noise', 'ANR'};
varTypes = {'char', 'double', 'double', 'double'};

% Empty table with just headers (0 rows)
T = table('Size',[0 numel(varNames)], ...
          'VariableTypes',varTypes, ...
          'VariableNames',varNames);

for i=1:length(obs_ids)

    absorption = sabcond_data3(i).absorption.readimg();
    residuals = sabcond_data3(i).residual.readimg();

    rmse_noise = sqrt(mean((residuals(:)).^2, 'omitnan'));
    
    absorption_rows = squeeze(prctile(absorption, 95, 1));

    absorption_avg = squeeze(median(absorption_rows, 1, 'omitnan'));

    absorption_avg = mean(absorption_avg, 'omitnan');

    ANR = absorption_avg/rmse_noise;

    newRow = {obs_ids(i), absorption_avg, rmse_noise, ANR};

    T(end+1,:) = newRow;


end