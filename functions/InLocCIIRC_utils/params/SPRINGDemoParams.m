function [ params ] = SPRINGDemoParams(params)
    
    %params.spaceName = sprintf('');
    params.dynamicMode = "dynamic_1"; % original, static, dynamic_1, dynamic_2...
    
    if params.dynamicMode == "original"
        params.dataset.name = "Broca_dataset_static";
    elseif contains(params.dynamicMode, "static")
        tmp = split("params.dynamicMode", "_")
        modeN = tmp(2);
        params.dataset.name = "Broca_dataset_dynamic" + modeN;
    elseif contains(params.dynamicMode, "dynamic")
        params.dataset.name = "Broca_dataset_" + params.dynamicMode; 
    else
        error('Unrecognized mode');
    end
    
    params.dataset.query.space_names = {'livinglab'};
   
    params.dataset.dir = fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Maps', params.dataset.name);
    
    params.dataset.query.dirname = sprintf('queries');
    params.dataset.query.mainDir =  fullfile(params.dataset.dir,params.dataset.query.dirname);
    params.dataset.query.dir = fullfile(params.dataset.query.mainDir,params.dataset.query.space_names,'query_all'); % NOTE: it cannot be extracted to setupParams.m, because we need it in here already
    
    params.dataset.query.dslevel = 8^-1;
    params.camera.sensor.size = [756 1344 3]; %height, width, 3
    params.camera.fl = 1034.0000; 
    params.blacklistedQueryInd = [];

    space_names_strs = string(params.dataset.query.space_names);
    str = params.dataset.name;
    for i = 1 : length(space_names_strs)   
        str = str + "_" + space_names_strs(i);
    end
    
    n_queries = length(dir(fullfile(params.dataset.query.dir, "*.jpg"))); % number of queries
   
    params.cache.dir = fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Cache_' + params.dataset.name, params.dynamicMode, string(n_queries) + "_queries");
    params.results.dir = fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Results_' + params.dataset.name, params.dynamicMode, string(n_queries) + "_queries");
    
end