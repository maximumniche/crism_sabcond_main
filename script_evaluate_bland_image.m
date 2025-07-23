%% Bland Image Selection
% crism_init crismToolbox_legacy.json;
prop_name = 'trrdif';


%% Get/download and process target image

% Specify the observation ID of the image you want to test.
obs_id_interest = '47A3';

% Set this to 2 if you need to download data, 0 otherwise.
dwld = 2;

% If there is any update of the remote folder or you need to update
% index.html in the folder, set this to true
DWLD_INDEX_CACHE_UPDATE = false;

% Get and download the image data
% -------------------------------
obs_info_interest = crism_get_obs_info_v2(obs_id_interest, 'SENSOR_ID', 'L', ...
    'Download_DDR_CS', dwld, 'Download_TRRIF_CS', dwld, ...
    'Download_TRRRA_CS', dwld, 'DOWNLOAD_TRRHKP_CS', dwld, ...
    'DOWNLOAD_EDR_CS_CSDF', dwld, ...
    'DWLD_INDEX_CACHE_UPDATE', DWLD_INDEX_CACHE_UPDATE);
csi_interest = obs_info_interest.central_scan_info.indx;
basename_trrif_cs_interest = obs_info_interest.sgmnt_info(csi_interest).L.trr.IF{1};
TRRIFdata_interest = CRISMdata(basename_trrif_cs_interest,'');
TRRIFdata_interest.load_basenamesCDR('dwld', dwld);

% Perform the calibration of the image
% ------------------------------------
% TRRD I/F:
% calibration processed by our own code with mode 'yuki4', no bad pixel 
% interpolation is applied to SPdata, too. Flat field correction is not 
% applied, neither. This is the default option used for sabcond v5 
% correction.
crism_calibration_IR_v2(obs_id_interest,'save_memory',true,'mode','yuki4', ...
    'version','D','skip_ifexist',1,'force',0,'save_file',1,'dwld',dwld, ...
    'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);

% TRRB I/F:
% calibration processed by our own code with mode 'yuki2', no bad pixel 
% interpolation is applied. This has been used by sabcond v3 by default.
% If you want to process this, uncomment below.
% crism_calibration_IR_v2(obs_id_interest,'save_memory',true,'mode','yuki2', ...
%     'version','B','skip_ifexist',1,'force',0,'save_file',1,'dwld',dwld, ...
%     'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);

% Load different versions of TRR data as one pack
TRR3dataset_interest = CRISMTRRdataset(basename_trrif_cs_interest,'');
TRR3dataset_interest.trr3if.load_basenamesCDR('dwld',dwld);
[BKdata_int1, BKdata_int2] = crism_load_BKdata4SC(TRR3dataset_interest.trr3if);
DFdata_int1 = crism_load_DFdata4BK(BKdata_int1);
DFdata_int2 = crism_load_DFdata4BK(BKdata_int2);
[BPdata_int1, BPdata_int2, BPdata_int_post] = ...
    crism_load_BPdataSC_fromDF(...
    TRR3dataset_interest.trr3if, DFdata_int1.basename, DFdata_int2.basename);

[BP1nanfull_int] = crism_formatBPpri1nan(BPdata_int1,BPdata_int2, ...
    'band_inverse',true,'interleave','lsb');
[GP1nanfull_int] = crism_convertBP1nan2GP1nan(BP1nanfull_int);

% [BP1nanfull_int] = crism_formatBP1nan(BPdata_int_post, ...
%     'band_inverse',true,'interleave','lsb');
% [GP1nanfull_int] = crism_convertBP1nan2GP1nan(BP1nanfull_int);

% Load the target image
Yif_interest = TRR3dataset_interest.(prop_name).readimgi();
Yif_interest(Yif_interest<0) = nan;
lnYif_interest = log(Yif_interest);
% Ignore some lines where gimbal motion is stacked
[valid_lines_int,valid_samples_int] = crism_examine_valid_LinesColumns(TRR3dataset_interest.trr3if);
valid_lines_int = find(valid_lines_int);


%% Get/download and process bland image

% Specify the observation ID of the image you want to test as bland.
obs_id_bland = '4774';

% Set this to 2 if you need to download data, 0 otherwise.
dwld = 2;

% If there is any update of the remote folder or you need to update
% index.html in the folder, set this to true
DWLD_INDEX_CACHE_UPDATE = false;


% Get and download the image data
% -------------------------------
obs_info_bland = crism_get_obs_info_v2(obs_id_bland, 'SENSOR_ID', 'L', ...
    'Download_DDR_CS', dwld, 'Download_TRRIF_CS', dwld, ...
    'Download_TRRRA_CS', dwld, 'DOWNLOAD_TRRHKP_CS', dwld, ...
    'DOWNLOAD_EDR_CS_CSDF', dwld, ...
    'DWLD_INDEX_CACHE_UPDATE', DWLD_INDEX_CACHE_UPDATE);
csi_bland = obs_info_bland.central_scan_info.indx;
basename_trrif_cs_bland = obs_info_bland.sgmnt_info(csi_bland).L.trr.IF{1};
TRRIFdata_bland = CRISMdata(basename_trrif_cs_bland,'');
TRRIFdata_bland.load_basenamesCDR('dwld', dwld);


% Perform the calibration of the image
% ------------------------------------
% TRRD I/F:
% calibration processed by our own code with mode 'yuki4', no bad pixel 
% interpolation is applied to SPdata, too. Flat field correction is not 
% applied, neither. This is the default option used for sabcond v5 
% correction.
crism_calibration_IR_v2(obs_id_bland,'save_memory',true,'mode','yuki4', ...
    'version','D','skip_ifexist',1,'force',0,'save_file',1,'dwld',dwld, ...
    'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);

% TRRB I/F:
% calibration processed by our own code with mode 'yuki2', no bad pixel 
% interpolation is applied. This has been used by sabcond v3 by default.
% If you want to process this, uncomment below.
% crism_calibration_IR_v2(obs_id_bland,'save_memory',true,'mode','yuki2', ...
%     'version','B','skip_ifexist',0,'force',0,'save_file',1,'dwld',dwld, ...
%     'DWLD_INDEX_CACHE_UPDATE',DWLD_INDEX_CACHE_UPDATE);

% Load different versions of TRR data as one pack
TRR3dataset_bland = CRISMTRRdataset(basename_trrif_cs_bland,'');
TRR3dataset_bland.trr3if.load_basenamesCDR('dwld',dwld);
[BKdata_bland1, BKdata_bland2] = crism_load_BKdata4SC(TRR3dataset_bland.trr3if);
DFdata_bland1 = crism_load_DFdata4BK(BKdata_bland1);
DFdata_bland2 = crism_load_DFdata4BK(BKdata_bland2);
[BPdata_bland1, BPdata_bland2, BPdata_bland_post] = ...
    crism_load_BPdataSC_fromDF(...
    TRR3dataset_bland.trr3if, DFdata_bland1.basename, DFdata_bland2.basename);

[BP1nanfull_bland] = crism_formatBPpri1nan(BPdata_bland1,BPdata_bland2, ...
    'band_inverse',true,'interleave','lsb');
[GP1nanfull_bland] = crism_convertBP1nan2GP1nan(BP1nanfull_bland);

% [BP1nanfull_bland] = crism_formatBP1nan(BPdata_bland_post, ...
%     'band_inverse',true,'interleave','lsb');
% [GP1nanfull_bland] = crism_convertBP1nan2GP1nan(BP1nanfull_bland);

% Load the bland image
Yif_bland = TRR3dataset_bland.(prop_name).readimgi();
Yif_bland(Yif_bland<0) = nan;

% Just you want to use a full spatial resolution image for the correction 
% of a half resolution image.
% This function only supports Full resolution --> Half resolution
% If the input image is already in Half resolution, then just input is
% returned.
Yif_bland = crism_bin_image_frames(Yif_bland,'binx',TRR3dataset_interest.trr3if.lbl.PIXEL_AVERAGING_WIDTH);
GP1nan_bland = crism_bin_image_frames(GP1nanfull_bland,'binx',TRR3dataset_interest.trr3if.lbl.PIXEL_AVERAGING_WIDTH);

lnYif_bland = log(Yif_bland);

% Ignore some lines where gimbal motion is stacked
[valid_lines,valid_samples] = crism_examine_valid_LinesColumns(TRR3dataset_bland.trr3if);
valid_lines = find(valid_lines);

%% Set the type of trr3 data you want to peroform ratio-test with.
% prop_name needs to be a valid property name of TRR3dataset_bland and
% TRR3dataset_interest. Possible choice would be
% trr3if: TRR3 I/F
% trr3raif: TRR3 RA converted to I/F
% trrbif: TRRB I/F (calibration processed by our own code with mode 'yuki2',
%         no bad pixel interpolation is applied.This has been used by 
%         sabcond v3 by default.)
% trrdif: TRRD I/F (calibration processed by our own code with mode 'yuki4',
%         no bad pixel interpolation is applied to SPdata, too. Flat field
%         correction is not applied, neither.) This is the default option
%         used for sabcond v5 correction.


%%
% Specify bands you want to test ratioing.
bands = 1:252;

% Specify lines used for getting denominator bland image spectra.
ld = valid_lines; % ld = 200:400;
%ld = 100:450;
% ld = 1:200;


% Specify column(s) and line(s) you want to test. 
% Same column(s) is used for the bland image.
c=210; l=100:200; %l=205:241;
c=292; l = 100:200;
c=279; l=145;
% c=134; l=51;
c=5; l=249;


c=80; l=97;
c=80; l=329;
c=80; l=202;


c=275; %l=350;
%c=189; %l=220:240;
% c=80; 
l=valid_lines_int;
%c=130; %l=76;
%c=72; l=72;
%c=88; l=201;

%c=362; l=75;
c = 122; % l=179;
c=115; % l=170:180;
c=157;
% ld=1:100;
% l=450;
% l=348:400;
% c=248:249; % l=369:374;
c=1:500;
color_order = lines(7);
color_order2 = [...         
         0         0    1.0000
         0    0.5000         0
    1.0000         0         0
         0    0.7500    0.7500
    0.7500         0    0.7500
    0.7500    0.7500         0
    0.2500    0.2500    0.2500];
color_order = [color_order; color_order2];
Nc = size(color_order, 1);

figure;
ax = subplot(1,1,1);
ax.ColorOrder = color_order;

mag_list = sort([0.7:0.025:1.2],'descend');
hold on;

gp_bland = GP1nan_bland(1,c,bands);
gp_int = GP1nanfull_int(1,c,bands);

pList = [];
for imag = 1:length(mag_list)
    mag = mag_list(imag);
    plot(mean(TRR3dataset_interest.trr3ra.wa(bands,c),[2],'omitnan'),...
        squeeze(log(mean(Yif_interest(l,c,bands),[1,2],'omitnan')) ...
                - log(mean(Yif_bland(ld,c,bands),[1,2],'omitnan'))*mag), ...
        '-', 'DisplayName', sprintf('subtrahend x %.3f',mag), 'Color', [color_order(rem(imag, Nc)+1, :), 0.2], 'LineWidth',0.3);
    pList(imag) = plot(mean(TRR3dataset_interest.trr3ra.wa(bands,c),[2],'omitnan'),...
        squeeze(log(mean(Yif_interest(l,c,bands) .* gp_int,[1,2],'omitnan')) ...
                - log(mean(Yif_bland(ld,c,bands) .* gp_bland,[1,2],'omitnan'))*mag), ...
        '.-', 'DisplayName', sprintf('subtrahend x %.3f',mag), 'Markersize', 5, 'Color', color_order(rem(imag, Nc)+1, :));
end

legend(pList,'Location','EastOutside');

is_focus = 0; focus_plot_id = 4;
if is_focus
    % focus_plot_id = 4;
    nonfocus_idxes = setdiff(1:length(mag_list),focus_plot_id);
    tp = 0.9;
    for imag = nonfocus_idxes
    %     mag = mag_list(mi);
        pList(imag).Color = pList(imag).Color*(1-tp) + ax.Color*tp;
    end

    uistack(pList(focus_plot_id),'up',length(mag_list)-focus_plot_id);
end
title({sprintf('(ln%s c%0d:%03d,l%03d:%03d) sub. by' ,TRR3dataset_interest.(prop_name).basename,c(1),c(end),l(1),l(end)),...
    sprintf('(ln%s c%03d:%03d,l%03d:%03d)',TRR3dataset_bland.(prop_name).basename,c(1),c(end),ld(1),ld(end))},'Interpreter','none');
xlim([1000 2660]);
% xlim([0 253]);
% xlabel('Wavelength [nm]');
ylabel('Ratioed I/F');
set(gca,'FontSize',10);
set(gca,'XTick',[1000 2600]);
grid on

fname = sprintf('ln%s_c%03dt%03d_l%03dt%03d_sub_ln%s_c%03dt%03d_l%03dt%03d', ...
    TRR3dataset_interest.(prop_name).basename,c(1),c(end),l(1),l(end), ...
    TRR3dataset_bland.(prop_name).basename,c(1),c(end),ld(1),ld(end));

% export_fig(gcf,[fname '.png'],'-transparent','-r300');


