%% Automatic DDR search

% Function to search for close in time images within a given tolerance.
% Takes a previous list of images as input to filter duplicates

function [ddr_polygons_slctd] = ddr_search_auto(obs_id, tol_days, prev_tol)

% Load Polygons
load ddr_polygons_wutc.mat
load ddr_polygons_ATO_wutc.mat

% Specify the range of target IDs.
% Enter directory name: 3-letter observsation class type + zero padded 8 
% digit observation ID. The polygonal footprint of this image will be 
% shown in red in the map projection.

% obs_id = 'A819';
obs_info = CRISMObservation(obs_id,'SENSOR_ID','L'); 
dirname_tar = obs_info.info.dirname;

% Provide Time difference tolerance in days
% tol_days = 7;
% prev_tol = 4;

% Modify the following distance threshold value if you want to apply
% spatially close images.
% the images within the distance less than this value would be selected.
% Enter Inf if you want to skip this selection.
dst_threshold = inf;
% This distance in the map-projected coordinate system.
% For equirectangular projection, X axis is measured by longitude in
% degrees and Y axis is by latitude in degrees.
% For stereographic projection, sorry, not sure. 

% obs_class_type
% You can specify the type of observations you want to match.
% If none given, full resolution types (FRT, FRS, ATO) are selected for
% full resolution observations, and full and half resolution types (FRT,
% FRS, ATO, HRL, HRS) are selected for half resolution images.
obs_class_type_allowed = {};

% latitude range
% You can specify the range of the latitude of the candidate observations.
% if it is empty, images with latitude > 70deg for north polar images,
% latitude < -70 deg for south polar images, -70 < latitude < 70 otherwise.
% latitude_range = [60, 95];
latitude_range = [-70 70];


% Path to the MOLA image file
imgpath_mola = 'Mars_MGS_MOLA_DEM_mosaic_global_1024.jpg';
if ~exist(imgpath_mola, 'file')
    error('%s does not exist.', imgpath_mola);
end

% By default projection method is automatically selected. If the latitude
% of the center of the image is higher than 70 deg or lower than 70, 
% stereographic projection is selected. Otherwise (latitude is between -70 
% and 70 degs), equirectangular projection is selected.
idx_tar = find(strcmpi(dirname_tar, {ddr_polygons.dirname}));
if isempty(idx_tar)
    error('%s is not right.', dirname_tar);
end
polygon_tar = ddr_polygons(idx_tar);
lat_ctr_tar = polygon_tar.lat_ctr;
lon_ctr_tar = polygon_tar.lon_ctr;
if abs(lat_ctr_tar) > 70
    projection_method = 'stereographic';
    R = 1; % radius is one meter??
else
    projection_method = 'equirectangular';
end

%% Apply time tolerance

tol_duration = calendarDuration(0,0,tol_days);

prev_duration = calendarDuration(0,0,prev_tol);

% Select for indexes in tolerance range and outside of previous tolerance

% In tolerance range
idx_slctd_tol = find(and(...
    polygon_tar.time - (tol_duration) < [ddr_polygons.time], ...
    [ddr_polygons.time] < polygon_tar.time + (tol_duration) ...
    ));

% In previous tolerance range
idx_slctd_prev = find(and(...
    polygon_tar.time - (prev_duration) < [ddr_polygons.time], ...
    [ddr_polygons.time] < polygon_tar.time + (prev_duration)...
    ));

% In the tolerance range but not in previous tolerance range
idx_slctd = setxor(idx_slctd_tol, idx_slctd_prev);

ddr_polygons_slctd = ddr_polygons(idx_slctd);

% sort ddr_polygons_slctd by time
timestamps = [ddr_polygons_slctd.time];
[~, idx_srtt] = sort(timestamps);
ddr_polygons_slctd = ddr_polygons_slctd(idx_srtt);

%% Apply observation class type filter

if isempty(obs_class_type_allowed)
    switch upper(dirname_tar(1:3))
        case {'FRT', 'FRS', 'ATO'}
            obs_class_type_allowed = {'FRT', 'FRS', 'ATO'};
        case {'HRL', 'HRS'}
            obs_class_type_allowed = {'HRL', 'HRS', 'FRT', 'FRS', 'ATO'};
            % obs_class_type_allowed = {'HRL', 'HRS'};
        otherwise
            error('Unsupported observation class type %s', dirname_tar(1:3));
    end
end
obs_class_type_ptrn = ['(' strjoin(obs_class_type_allowed,'|') ')'];

mtch = regexpi({ddr_polygons_slctd.dirname}, obs_class_type_ptrn);
idx_slctd = find(~isempties(mtch));
ddr_polygons_slctd = ddr_polygons_slctd(idx_slctd);

if isempty(latitude_range)
    switch upper(projection_method)
        case 'EQUIRECTANGULAR'
            latitude_range = [-70, 70];
        case 'STEREOGRAPHIC'
            if lat_ctr_tar > 0
                latitude_range = [70, inf];
            else
                latitude_range = [-inf, -70];
            end
    end
end

idx_slctd = find(and(latitude_range(1) < [ddr_polygons_slctd.lat_ctr], ...
    [ddr_polygons_slctd.lat_ctr] < latitude_range(2)));

ddr_polygons_slctd = ddr_polygons_slctd(idx_slctd);

end