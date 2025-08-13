%% Compare elevation of target and bland candidate.

% Compare average elevation of target scene to bland scene using DDR data.
% If average elevation exceeds given threshold, return false for
% compatibleBoolean, else return true. Since elevation is not
% deterministic, threshold should be an adequately large value.

function [compatibleBoolean] = compare_elevation(target_id, bland_id)

% Threshold for difference between altitudes
threshold = 10^3;

crism_obs_target = CRISMObservation(target_id,'SENSOR_ID','L','DOWNLOAD_DDR', 2); 
crism_obs_bland = CRISMObservation(bland_id,'SENSOR_ID','L','DOWNLOAD_DDR', 2);

switch upper(crism_obs_target.info.obs_classType)
    case {'FFC'}
        basenameDDR_target = crism_obs_target.info.basenameDDR{1};
    case {'FRT','HRL','FRS','HRS','ATO'}
        basenameDDR_target = crism_obs_target.info.basenameDDR;
    otherwise
end

switch upper(crism_obs_bland.info.obs_classType)
    case {'FFC'}
        basenameDDR_bland = crism_obs_bland.info.basenameDDR{1};
    case {'FRT','HRL','FRS','HRS','ATO'}
        basenameDDR_bland = crism_obs_bland.info.basenameDDR;
    otherwise
end

DEdata_target = CRISMDDRdata(basenameDDR_target,''); DEdata_target.readimg();
elevation_target = DEdata_target.ddr.Elevation.img;

DEdata_bland = CRISMDDRdata(basenameDDR_bland,''); DEdata_bland.readimg();
elevation_bland = DEdata_bland.ddr.Elevation.img;


% Compare altitudes

% Get average altitude of target and bland image
avg_target = sum(sum(elevation_target, 'all')) / numel(elevation_target);
avg_bland = sum(sum(elevation_bland, 'all')) / numel(elevation_target);

if abs(avg_target - avg_bland) > threshold
    compatibleBoolean = false; % Elevation difference exceeds threshold
else
    compatibleBoolean = true;  % Elevation difference is acceptable
end

end