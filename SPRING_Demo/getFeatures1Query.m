function [ queryFeatures ] = getFeatures1Query(params, queryPath)

% queryDirWithSlash = [];
x = load(params.input.dblist.path);
cutoutImageFilenames = x.cutout_imgnames_all;
cutoutSize = size(imread(cutoutImageFilenames{1}));
cutoutSize = [cutoutSize(2), cutoutSize(1)]; % width, height
% 
% if exist(params.input.feature.dir, 'dir') ~= 7
%     mkdir(params.input.feature.dir);
% end
load(params.netvlad.dataset.pretrained, 'net');
net = relja_simplenn_tidy(net);
net = relja_cropToLayer(net, 'postL2'); %original
% net = relja_cropToLayer(net, 'vlad:intranorm'); %experiment SS2021

%% query
% x = load(params.input.qlist.path);
% x = load(queryPath);
% queryImageFilenames = x.query_imgnames_all;

% featureLength = 32768;

%serialAllFeats(net, queryDirWithSlash, queryImageFilenames, params.input.feature.dir, 'useGPU', false, 'batchSize', 1);
% p = fullfile(params.input.feature.dir, 'query_features.mat');
% if exist(p, 'file') ~= 2
%     nQueries = 1; %size(queryImageFilenames,2);
    queryFeatures = struct('queryname', {}, 'features', {});
%     for i=1:nQueries
        fprintf('Finding features for query #%d/%d\n\n', 1, 1)
%         queryName = queryImageFilenames{1};
        %queryImage = load_query_image_compatible_with_cutouts(fullfile(queryDirWithSlash, queryPath), cutoutSize);
        queryImage = load_query_image_compatible_with_cutouts(queryPath, cutoutSize);
        cnn = at_serialAllFeats_convfeat(net, queryImage, 'useGPU', true);
        queryFeatures(1).queryname = queryPath;
        queryFeatures(1).features = cnn{6}.x(:);
%     end
%     save(p, 'queryFeatures', '-v7.3');
% end
% 
% p = fullfile(params.input.feature.dir, 'db_features.mat');
% if exist(p, 'file') ~= 2
%     
%     
%     nCutouts = size(cutoutImageFilenames,2);
%     cutoutFeatures = zeros(nCutouts, featureLength, 'single');
%     cutoutFeatures = struct('cutoutname', {}, 'features', {});
%     for i=1:nCutouts
%         fprintf('Finding features for cutout #%d/%d\n\n', i, nCutouts)
%         cutoutName = cutoutImageFilenames{i};
%         cutoutImage = imread(fullfile(params.dataset.db.cutout.dir, cutoutName));
%         cnn = at_serialAllFeats_convfeat(net, cutoutImage, 'useGPU', true);
%         cutoutFeatures(i).cutoutname = cutoutName;
%         cutoutFeatures(i).features = cnn{6}.x(:);
%     end
%     
%     %% save the features
%     
%     save(p, 'cutoutFeatures', '-v7.3');
% end
end