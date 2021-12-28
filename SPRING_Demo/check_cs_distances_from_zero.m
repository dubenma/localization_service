function check_cs_distances_from_zero(ds)
%% Spocita pro kazdy query snimek vzdalenost stredu jeho kamery od pocatku souradnic sveta.
% (neni soucast algoritmu, jen pro testovaci ucely)

query_dir = "/home/seberma3/_InLoc_PROD_Speedup/SPRING_Demo/outputs100__10/"+ds+"/queries/";

for qu=1:40
    pv = load(fullfile(query_dir, ""+qu, "densePV_top10_shortlist.mat"));

    for cam_estim_idx=1:10
        P = pv.ImgList.Ps{cam_estim_idx}{1};
        [K, R, C] = P2KRC(P);
        dist_from_zero = vecnorm(C);
        disp("DS 4, Q "+qu+", P "+cam_estim_idx+" dist = "+dist_from_zero);
    end
end


end

