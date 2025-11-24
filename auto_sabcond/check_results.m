%% check the results
obs_id = '4509';

% generate MTRDR
crism_mtrdr_obs = crism_get_obs_info_v2(obs_id, 'DOWNLOAD_MTRDR', 2);

crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = '/mnt/data2/crism_user1/crism_sabcond_main/auto_sabcond/v5_bland_results';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');

% get MTRDR
mtrdr_data = CRISMdataCAT(crism_obs.info.basenameMTRIF, crism_obs.info.dir_mtrdr);

%% Generate cosine corrected cor product

sabcond_cor = sabcond_data5.cor;

ddr_data = CRISMdataCAT(crism_obs.info.basenameDDR, crism_obs.info.dir_ddr);

ddr_data = ddr_data.readimg();

incidence_angles = ddr_data(:,:,1);

data_coscor = sabcond_data5.cor.readimg() ./ cos(incidence_angles);

hdr = sabcond_cor.hdr;
tmp = ENVIRaster(data_coscor, hdr);   % in-memory raster
ENVIRasterMultiview(tmp);

%% check the results
obs_id = '4774';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');
pdir5 = './v5_bland_results/';
dir_sab5 = joinPath(pdir5,TRR3dataset.trr3if.dirname);
sabcond_data5 = SABCONDdataset(TRR3dataset.trrdif.basename,dir_sab5,...
    'suffix','sabcondpub_v1_mcd6_1s01');

%%
sabcond_data5.nr_ds.set_rgb();
sabcond_data5.nr_ds.wa = TRR3dataset.trrdif.wa;
%sabcond_data3.nr_ds.wa = TRR3dataset.trrdif.wa; 
%sabcond_data5.cor.wa = TRR3dataset.trrdif.wa;
%sabcond_data3.cor.wa = TRR3dataset.trrdif.wa; 

h1 = ENVIRasterMultview({sabcond_data5.nr_ds.RGB.CData_Scaled},{ ...
    ...{mtrdr_data,'name','MTRDR','AVERAGE_WINDOW',[1,1]}, ...
    ...{TRR3dataset.trrdif,'name','TRRBIF','AVERAGE_WINDOW',[1,1]}, ...
    ...{sabcond_data5.cor,'name','v5','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    {sabcond_data5.nr_ds,'name','v5','AVERAGE_WINDOW',[1,1],'shift',0.00,'varargin_plot',{'.-'}},...
    },...
'SPC_XLIM',[1100 2600],...
'varargin_ImageStackView',{'Ydir','reverse'});

%%

data1 = data_coscor;
data2 = mtrdr_data.readimg();

data1 = data1(300,200,:);
data2 = data2(300,200,172:end);
data1 = data1(:);
data2 = data2(:);

plot(data1);
hold on
plot(data2);