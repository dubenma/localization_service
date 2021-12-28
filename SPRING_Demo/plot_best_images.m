function fig = ploplo(outputDir, dsetIdx, queryIdx, step)
% /home/seberma3/_InLoc_PROD_Speedup/SPRING_Demo/outputs100__10/4/queries/16/
if step == "densePE"
    path = fullfile(outputDir, ""+dsetIdx, "queries", ""+queryIdx, "densePE_top100_shortlist.mat");
elseif step == "densePV"
    path = fullfile(outputDir, ""+dsetIdx, "queries", ""+queryIdx, "densePV_top10_shortlist.mat");
else
    path = fullfile(outputDir, ""+dsetIdx, "queries", ""+queryIdx, "densePV_top10_shortlist.mat");
end

load(path);


fig = figure;
t = tiledlayout(3,4);
nexttile;
imshow(imread(ImgList.queryname));
title("Query image");

if step == "densePE" ||step == "densePV"
    for dbimgIdx=1:10
        nexttile;
        imshow(imread(ImgList.topNname{dbimgIdx}));
        [fold, fname, suff] = fileparts(ImgList.topNname{dbimgIdx});
        %title("" + fname + suff);
        title({"" + fname + suff, "sc: "+ImgList.topNscore(dbimgIdx)});
    end
    
    title(t, "" + outputDir + ", dset :"+dsetIdx + ", queryIdx: " + queryIdx + ", " + step);
elseif step == "syn"
    for dbimgIdx=1:8
        nexttile;
        [fold, fname, suff] = fileparts(ImgList.topNname{dbimgIdx});
        syn = load(fullfile(outputDir, ""+dsetIdx, "synthesized", ""+queryIdx, fname+".synth.mat"));
        imshow(syn.RGBpersps{1}); 
%         imshow(syn.errmaps{1});
        title({"" + fname + suff, "sc: "+ImgList.topNscore(dbimgIdx)});
        %title("med: "+(1/ImgList.topNscore(dbimgIdx)));
        [K, R, C] = P2KRC(ImgList.Ps{dbimgIdx}{1});
        disp("======== "+dbimgIdx+" (" + fname +")");
           disp(K);
           disp(rotMatrixToAngles(R));
           disp(C);       
    end
    
    title(t, "" + outputDir + ", dset :"+dsetIdx + ", queryIdx: " + queryIdx + ", best synths");
end
end

% Kod pro vykresleni rozdilu odhadu datasetu 4 a 5
%[Cs, Rs ] = eval_all_queries("outputs100__10", 4:5);
%figure; hold on; plot(Cs{1}, 'r'); plot(Cs{2}, 'b'); legend("DS 4", "DS 5");

%s=[1 2];[Cs, Rs ] = eval_all_queries("outputs100__10", s); figure; xlabel("Dotazové snímky"); ylabel("Vzdálenost [m]"); title("Datasety "+s(1)+" a " + s(2)); hold on; plot(Cs{1}, 'r.', 'MarkerSize', 8); plot(Cs{2}, 'g.', 'MarkerSize', 8); legend("DS "+s(1), "DS "+s(2));