function [Cdists, Rdists] = eval_all_queries(outputDir, datasetSizes, is_verbose)
% is_verbose true ... vypise kompletni vysledky mereni
% false ... vypise jen prumer, minima, maxima mereni
if (exist("is_verbose", 'var') ~= 1)
    is_verbose = false;
end

addpath '/home/seberma3/_InLoc_PROD_Speedup/functions/InLocCIIRC_utils/rotationDistance';

Cdists = cell(1, numel(datasetSizes));
Rdists = cell(1, numel(datasetSizes));
Maxscores = cell(1, numel(datasetSizes));

idx = 0;
for datasetSize=datasetSizes
    idx = idx +1;
    % 1 ... bude se evaluovat nejpresnejsi odhad,
    % 10 .. bude se evaluovat 10. (tedy nejmene presny) odhad
    quality_order = 1;
    
    allQueries = dir("/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/*.jpg");
    C_dists = zeros(1,numel(allQueries));
    R_dists = zeros(1,numel(allQueries));
    Max_scores = zeros(1,numel(allQueries));
    
    for q=1:numel(allQueries)
        %[~ ,queryNum, ~] = fileparts(allQueries(q).name);
        
        queryResultDir = fullfile(outputDir, ""+datasetSize,"queries", ""+q);
        top_cuts_info = load(fullfile(queryResultDir, "densePV_top10_shortlist.mat"));
        truePosePath = fullfile("/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/poses/", ""+q+".txt");
        Px = load(truePosePath);
        Px = Px(1:3, :);
        [Ktrue, Rtrue, Ctrue] = P2KRC(Px);
        Max_scores(q) = top_cuts_info.ImgList.topNscore(quality_order);
        
        topCameraPose = top_cuts_info.ImgList.Ps(quality_order);
        topCameraPose = cell2mat(topCameraPose{1});
        %realQueryCameraPose =
        
        
        [K_est, R_est, C_est] = P2KRC(topCameraPose);
        dis = norm(Ctrue - C_est);
        C_dists(q) = dis; 
        R_dists(q) = rotationDistance(Rtrue, R_est);
    end
    
    Cdists{idx} = C_dists;
    Rdists{idx} = R_dists;
    Maxscores{idx} = Max_scores;
    
    if is_verbose
        disp("C_dists");
        disp(C_dists);
        disp("R_dists");
        disp(R_dists);
    else
        fprintf("Prumer euklei. vzd. pro ds%d = %f m\n", datasetSize, mean(C_dists));
        fprintf("Median euklei. vzd. pro ds%d = %f m\n", datasetSize, quantile(C_dists, 0.5));
        fprintf("Min c.dist for dataset size %d = %f\n", datasetSize, min(C_dists));
        fprintf("Max c.dist for dataset size %d = %f\n", datasetSize, max(C_dists));
        %fprintf("Stddev of c.dist for dataset size %d = %f\n", datasetSize, std(C_dists));
        fprintf("Prumer rotacni vzd. pro ds%d = %f °\n", datasetSize, mean(R_dists));
        fprintf("Median rotacni vzd. pro ds%d = %f °\n", datasetSize, quantile(R_dists, 0.5));
        fprintf("Min r.dist for dataset size %d = %f\n", datasetSize, min(R_dists));
        fprintf("Max r.dist for dataset size %d = %f\n", datasetSize, max(R_dists));
        %fprintf("Stddev of r.dist for dataset size %d = %f\n", datasetSize, std(R_dists));
        %fprintf("Avg max simil. score for dataset size %d = %f\n", datasetSize, mean(Max_scores));
        disp("----------------");
    end
    
end
disp("Evaluace ukoncena");
end