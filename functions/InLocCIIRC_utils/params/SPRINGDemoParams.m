function [ params ] = SPRINGDemoParams(params)
    
    params.spaceName = sprintf('');
    params.dataset.query.space_names = {'livinglab_2'};
    params.dataset.query.dirname = sprintf('queries');
    params.dataset.query.mainDir =  fullfile(params.dataset.dir,params.dataset.query.dirname);
    params.dataset.query.dir = fullfile(params.dataset.query.mainDir,params.dataset.query.space_names,'query_all'); % NOTE: it cannot be extracted to setupParams.m, because we need it in here already
    params.dataset.query.dslevel = 8^-1;
    params.camera.sensor.size = [756 1344 3]; %height, width, 3
    params.camera.fl = 1034.0000; 
    params.blacklistedQueryInd = [];
    
end