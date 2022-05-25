function [ params ] = b315Params(params)
    
    %params.spaceName = sprintf('');
    params.dynamicMode = "original"; % original, static_1, dynamic_1, dynamic_2...
    
    if params.dynamicMode == "original"
        params.dataset.name = "b315_dataset"; %TODO
    else
        error('Unrecognized mode');
    end
    
    params.dataset.query.space_names = {'b315'};
   
    params.dataset.dir = fullfile('/local1/projects/artwin/datasets/B-315_dataset/matterport_data/localization_service/Maps/', params.dataset.name); %TODO
    
    params.dataset.query.dirname = sprintf('queries');
    params.dataset.query.mainDir =  fullfile(params.dataset.dir,params.dataset.query.dirname);
    params.dataset.query.dir = fullfile(params.dataset.query.mainDir,params.dataset.query.space_names,'query_all');
    params.dataset.query.dslevel = 8^-1;
    params.camera.sensor.size = [756 1344 3]; %height, width, 3
    params.camera.fl = 1034.0000;
    params.blacklistedQueryInd = [];

    space_names_strs = string(params.dataset.query.space_names);
    str = params.dataset.name;
    for i = 1 : length(space_names_strs)   
        str = str + "_" + space_names_strs(i);
    end
    
    n_queries = 0;
    for i = 1 : length(params.dataset.query.space_names)
        n_queries = n_queries + length(dir(fullfile(params.dataset.query.dir{i}, "*.jpg"))); % number of queries   
    end
    
    params.cache.dir = fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Cache_' + params.dataset.name, params.dynamicMode, string(n_queries) + "_queries");
    params.results.dir = fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Results_' + params.dataset.name, params.dynamicMode, string(n_queries) + "_queries");
    
end