disp("Evaluation has stared");
% Pro kazdy query zjistit jeho spravnou pozu a porovnat s odhadlou.
CamCsDists = zeros(1, numel(ImgListAllQueries));
RotDists = zeros(1, numel(ImgListAllQueries));
for i=1:numel(ImgListAllQueries)
    [~,QFname,Qsuffix] = fileparts(ImgListAllQueries(i).queryname);
    truePosePath = fullfile(params.poses.dir, ""+QFname+".txt");
    Px = load(truePosePath);
    Px = Px(1:3, :);
    [Ktrue, Rtrue, Ctrue] = P2KRC(Px);
    
    bestCdist = Inf;
    bestRdist = Inf;
    for j=1:numel(ImgListAllQueries(i).Ps)
        P_est = ImgListAllQueries(i).Ps{j}{1};
        [K_est, R_est, C_est] = P2KRC(P_est);
        bestCdist = min(bestCdist, norm(Ctrue - C_est));
        bestRdist = min(bestRdist, rotationDistance(Rtrue, R_est));     
    end
    CamCsDists(i) = bestCdist;
    RotDists(i) = bestRdist;
end
fprintf("Avg c.dist for dataset size %d = %f\n", DATASET_SIZE, mean(CamCsDists));
fprintf("Stddev of c.dist for dataset size %d = %f\n", DATASET_SIZE, std(CamCsDists));
fprintf("Avg r.dist for dataset size %d = %f\n", DATASET_SIZE, mean(RotDists));
fprintf("Stddev of r.dist for dataset size %d = %f\n", DATASET_SIZE, std(RotDists));
% function [outputArg1,outputArg2] = eval_results(inputArg1,inputArg2)
% %EVAL_RESULTS Summary of this function goes here
% %   Detailed explanation goes here
% outputArg1 = inputArg1;
% outputArg2 = inputArg2;
% end
%