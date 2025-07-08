%% Check the elevation of the candidate bland image.

% crism_init;

% Check the overall elevation of the bland scene. If its elevation is so
% much different from that of the image of interest, the image would be
% likely to be inappropriate, but the elevation is not deterministic. Just
% a rouch check.

% Enter observation ID you want to test (case-insensitive)
obs_id_test = '9A16';

crism_obs = CRISMObservation(obs_id_test,'SENSOR_ID','L','DOWNLOAD_DDR', 2); 
switch upper(crism_obs.info.obs_classType)
    case {'FFC'}
        basenameDDR = crism_obs.info.basenameDDR{1};
    case {'FRT','HRL','FRS','HRS','ATO'}
        basenameDDR = crism_obs.info.basenameDDR;
    otherwise
end
DEdata = CRISMDDRdata(basenameDDR,''); DEdata.readimg();
figure; imagesc(DEdata.ddr.Elevation.img);