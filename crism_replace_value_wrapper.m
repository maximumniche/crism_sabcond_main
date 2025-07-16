function [] = crism_replace_value_wrapper(in_crismdata, varargin)
% [] = crism_replace_value_wrapper(in_crismdata, varargin)
%   Replace 
%  Input
%   in_crismdata: input CRISM data, to be projected
%   DEdata: CRISM DE data
%  Output
%   save a projected image. 
%   Default directory is the directory of the input CRISM data. Default
%   basename is the basename of the input CRISM data suffixed with suffix
%  Optional Parameters
%   'BANDS' : selected bands, boolean or array
%             (default) all the bands will be used
%   'BAND_INVERSE' : whether or not to invert bands or not
%                    (default) false
%   'DEFAULT_BANDS' : "default bands" property of the output image
%                     (default) selected using "get_default_bands.m"
%   'SUFFIX'  : suffix to the basename of the output image.
%               (default) '_rp'
%   'SAVE_DIR' : saved directory
%                (default) same as the directory of input CRISM image
%   'FORCE'   : whether or not to force processing if the image exists
%               (default) 0
%   'REP_VALUE_FROM': Value to be replaced
%               (default) nan
%   'REP_VALUE_TO' : Value to replace rep_value_from with 
%               (default) 65535
%   'HISTORY_STRING' : String appended to cat_history
%               (default) '_rp'


% default bands are all.
bands = true(in_crismdata.hdr.bands,1);
band_inverse = false;
suffix = '_rp';
rep_value_from = nan;
rep_value_to = 65535;
history_string = '_rp';
default_bands = []; % if this is empty, estimated with "get_default_bands.m"
save_dir = in_crismdata.dirpath; % default is the same directory as the input image.
force = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BANDS'
                bands = varargin{i+1};
                if islogical(bands)
                    bands = find(bands);
                end
            case 'BAND_INVERSE'
                band_inverse = varargin{i+1};
            case 'DEFAULT_BANDS'
                default_bands = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
                if ~strcmpi(suffix(1),'_')
                    suffix = ['_' suffix];
                end
            case 'SAVE_DIR'
                save_dir = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'REP_VALUE_FROM'
                rep_value_from = varargin{i+1};
            case 'REP_VALUE_TO'
                rep_value_to = varargin{i+1};
            case 'HISTORY_STRING'
                history_string = varargin{i+1};
                if ~strcmpi(history_string(1),'_')
                    history_string = ['_' history_string];
                end
            otherwise
                error('Unrecognized option: %s, ', varargin{i});
        end
    end
end

%% check the existence of the file

basename_rp = [in_crismdata.basename suffix];

fpath_hdr_rp = joinPath(save_dir, [basename_rp '.hdr']);
fpath_img_rp = joinPath(save_dir, [basename_rp '.img']);

outputs_fpath = {fpath_hdr_rp,fpath_img_rp};

% examine if all the output files exist.
exist_flg = all(cellfun(@(x) exist(x,'file'),outputs_fpath));

if exist_flg && ~force
    flg = 1;
    while flg
        prompt = sprintf( ...
            ['There exists processed images. Do you want to continue ' ...
             'to process and overwrite?(y/n)']);
        ow = input(prompt,'s');
        if any(strcmpi(ow,{'y','n'}))
            flg=0;
        else
            fprintf('Input %s is not valid.\n',ow);
        end
    end
    if strcmpi(ow,'n')
        fprintf('Process aborted...\n');
        return;
    elseif strcmpi(ow,'y')
        fprintf('processing continues and will overwrite...\n');
    end
end

if ~exist(save_dir,'dir'), mkdir(save_dir); end

%% main processing
if band_inverse
    in_crismdata.readimgi();
else
    in_crismdata.readimg();
end

img = in_crismdata.img;

if isnan(rep_value_from)
    rep_indbool = isnan(img);
else
    rep_indbool = (img == rep_value_from);
end

img_rp = img;
img_rp(rep_indbool) = rep_value_to;


%% construct header file
if (isfield(in_crismdata,'lbl') || isprop(in_crismdata, 'lbl')) ...
        && ~isempty(in_crismdata.lbl)
    % assume direct processing from pds image
    hdr_rp = crism_const_cathdr(in_crismdata,band_inverse);
else
    % assume processing from CAT or second product
    hdr_rp = in_crismdata.hdr;
    if band_inverse
        hdr_rp.wavelength = flip(hdr_rp.wavelength);
        hdr_rp.fwhm = flip(hdr_rp.fwhm);
        hdr_rp.bbl = flip(hdr_rp.bbl);
        if ischar(hdr_rp.cat_ir_waves_reversed)
            if strcmpi(hdr_rp.cat_ir_waves_reversed,'YES')
                hdr_rp.cat_ir_waves_reversed = 'NO';
            elseif strcmpi(hdr_rp.cat_ir_waves_reversed,'NO')
                hdr_rp.cat_ir_waves_reversed = 'YES';
            end
        end
    end
end

B = length(bands);
hdr_rp.wavelength = hdr_rp.wavelength(bands);
if isfield(hdr_rp,'bbl'), hdr_rp.bbl = hdr_rp.bbl(bands); end
if isfield(hdr_rp,'fwhm')
    hdr_rp.fwhm = hdr_rp.fwhm(bands);
end
hdr_rp.band_names = arrayfun(@(x) sprintf('Georef (Band %d)',x),find(bands),...
    'UniformOutput',false);
hdr_rp.bands = B;
hdr_rp.cat_history = [hdr_rp.cat_history history_string];
hdr_rp.cat_input_files = [in_crismdata.basename];

if isempty(default_bands)
    wv = hdr_rp.wavelength * 1000 ^double(strcmpi(hdr_rp.wavelength_units,'Micrometers'));
    switch upper(in_crismdata.prop.sensor_id)
        case 'L'
            hdr_rp.default_bands = crism_get_default_bands_L(wv);
        case 'S'
            hdr_rp.default_bands = crism_get_default_bands_S(wv,1);
        otherwise
            error('Unsupported sensor_id %s',in_crismdata.prop.sensor_id);
    end
else
    hdr_rp.default_bands = default_bands;
end

%% saving the image
fprintf('Saving %s ...\n',fpath_hdr_rp);
envihdrwritex(hdr_rp,fpath_hdr_rp,'OPT_CMOUT',false);
fprintf('Done\n');
fprintf('Saving %s ...\n',fpath_img_rp);
envidatawrite(single(img_rp),fpath_img_rp,hdr_rp);
fprintf('Done\n');




end