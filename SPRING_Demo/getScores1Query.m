function [score] = getScores1Query(params, featuresPath, queryPath, cutoutFeatures)

%featuresPath = fullfile(params.input.feature.dir, 'db_features.mat');
load(featuresPath, 'cutoutFeatures');
nCutouts = size(cutoutFeatures,2);
%featuresPath = fullfile(params.input.feature.dir, 'query_features.mat');
%load(featuresPath, 'queryFeatures');

queryFeatures = getFeatures1Query(params, queryPath);

% nQueries = size(queryFeatures,2);
score = struct('queryname', {}, 'scores', {});

% allCutoutFeatures = zeros(nCutouts, size(cutoutFeatures,1));
% for i=1:nCutouts
%     allCutoutFeatures(i,:) = cutoutFeatures(i).features';
% end
% allCutoutFeatures = allCutoutFeatures';
allCutoutFeatures = cutoutFeatures;

tol = 1e-6;
if ~all(abs(vecnorm(allCutoutFeatures)-1.0)<tol)
    fprintf('norm: %f\n', vecnorm(allCutoutFeatures));
    error('Features are not normalized!');
end

    fprintf('processing query %d/%d\n', 1, 1);
    thisQueryFeatures = queryFeatures(1).features';
    if ~all(abs(norm(thisQueryFeatures)-1.0)<tol)
        fprintf('norm: %f\n', norm(thisQueryFeatures));
        error('Features are not normalized!');
    end
    thisQueryFeatures = repmat(thisQueryFeatures, nCutouts, 1)';
    similarityScores = dot(thisQueryFeatures, allCutoutFeatures);
    score(1).queryname = queryFeatures(1).queryname;
    score(1).scores = single(similarityScores); % NOTE: this is not a probability distribution (and it does not have to be)

% save(params.input.scores.path, 'score');

end