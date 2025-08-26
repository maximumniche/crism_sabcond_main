
%% Function to create a model and residual CRISMdataCAT property and append to SABCOND dataset object

function [] = add_model_residual_absorption(dataset, obs_id)

    crism_obs = CRISMObservation(obs_id,'sensor_id','L');
    TRR3dataset = CRISMTRRdataset(crism_obs.info.basenameIF,'');

    dataset.AB.wa = TRR3dataset.trrbif.wa;
    dataset.Bg.wa = TRR3dataset.trrbif.wa;
    
    AB_data = dataset.AB.readimg();
    Bg_data = dataset.Bg.readimg();
    
    cor_data = dataset.cor.readimg();
       
    % Check for Ice data and add it to model calculated data
    if isobject(dataset.Ice)
        Ice_data = dataset.Ice.readimg();
        model_data = AB_data .* Bg_data .* Ice_data;
    else
        model_data = AB_data .* Bg_data;
    end
    
    % Model and corrected residuals in log domain
    residual_data = log(cor_data) - log(model_data);
    
    % Absorption in log domain
    absorption_data = -log(AB_data);


    % Get header data from cor
    hdr = dataset.cor.hdr;
    
    % names and paths
    
    model_name = [dataset.basename_cor, '_model'];
    model_path = fullfile(dataset.dirpath, model_name);
    
    residual_name = [dataset.basename_cor, '_residual'];
    residual_path = fullfile(dataset.dirpath, residual_name);

    absorption_name = [dataset.basename_cor, '_absorption'];
    absorption_path = fullfile(dataset.dirpath, absorption_name);
    
    % Save .img files by writing in CRISM format

    [lines, ~, bands] = size(model_data);
    
    fid = fopen([model_path '.img'], 'w');
    for l=1:lines
        for b=1:bands
            fwrite(fid, model_data(l,:,b), 'float32');
        end
    end
    fclose(fid);
    
    fid = fopen([residual_path '.img'], 'w');
    for l=1:lines
        for b=1:bands
            fwrite(fid, residual_data(l,:,b), 'float32');
        end
    end
    fclose(fid);

    fid = fopen([absorption_path '.img'], 'w');
    for l=1:lines
        for b=1:bands
            fwrite(fid, absorption_data(l,:,b), 'float32');
        end
    end
    fclose(fid);
    
    % Save .hdr files
    
    envihdrwritex(hdr, [model_path '.hdr'])
    envihdrwritex(hdr, [residual_path '.hdr'])
    envihdrwritex(hdr, [absorption_path '.hdr'])
    
    % Add to sabcond object
    dataset.appendCAT('model', dataset.basename_cor, dataset.dirpath, 'model');
    dataset.appendCAT('residual', dataset.basename_cor, dataset.dirpath, 'residual');
    dataset.appendCAT('absorption', dataset.basename_cor, dataset.dirpath, 'absorption');

end