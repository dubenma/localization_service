function eval_all_queries(outputDir, datasetSize)

allQueries = dir("/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/*.jpg");
C_dists = zeros(1,numel(allQueries));
R_dists = zeros(1,numel(allQueries));
for q=1:numel(allQueries)
    [~ ,queryNum, ~] = fileparts(allQueries(q).name);
    
    queryResultDir = fullfile(outputDir, ""+datasetSize,"queries", queryNum);
    top_cuts_info = load(fullfile(queryResultDir, "densePV_top10_shortlist.mat"));
    topCameraPose = top_cuts_info.ImgList.Ps(1);
    topCameraPose = cell2mat(topCameraPose{1});
    %realQueryCameraPose =
    
    truePosePath = fullfile("/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/poses/", ""+queryNum+".txt");
    Px = load(truePosePath);
    Px = Px(1:3, :);
    [Ktrue, Rtrue, Ctrue] = P2KRC(Px);
    [K_est, R_est, C_est] = P2KRC(topCameraPose);
    C_dists(q) = norm(Ctrue - C_est);
    R_dists(q) = rotationDistance(Rtrue, R_est);
end

fprintf("Avg c.dist for dataset size %d = %f\n", datasetSize, mean(C_dists));
%fprintf("Stddev of c.dist for dataset size %d = %f\n", datasetSize, std(C_dists));
fprintf("Avg r.dist for dataset size %d = %f\n", datasetSize, mean(R_dists));
%fprintf("Stddev of r.dist for dataset size %d = %f\n", datasetSize, std(R_dists));
disp("Evaluace ukoncena\n");
end

