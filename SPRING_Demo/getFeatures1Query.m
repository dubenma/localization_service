function [ queryFeatures ] = getFeatures1Query(params, queryPath)

x = load(params.input.dblist.path);
cutoutImageFilenames = x.cutout_imgnames_all;
cutoutSize = size(imread(cutoutImageFilenames{1}));
cutoutSize = [cutoutSize(2), cutoutSize(1)]; % width, height

load(params.netvlad.dataset.pretrained, 'net');
net = relja_simplenn_tidy(net);
net = relja_cropToLayer(net, 'postL2'); %original
% net = relja_cropToLayer(net, 'vlad:intranorm'); %experiment SS2021

%% query
queryFeatures = struct('queryname', {}, 'features', {});
fprintf('Finding features for query #%d/%d\n\n', 1, 1)
queryImage = load_query_image_compatible_with_cutouts(queryPath, cutoutSize);
cnn = at_serialAllFeats_convfeat(net, queryImage);
queryFeatures(1).queryname = queryPath;
queryFeatures(1).features = cnn{6}.x(:);
end