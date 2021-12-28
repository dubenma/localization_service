function inloc_demo(topM, topN)
%topM : originally 100. InLoc takes topM most similiar images in the first step (image retrieval) 
%topN : originally 10. InLoc takes topN most similiar images in the second step. It renders topN synthetic images and estimates topN camera poses.

distcomp.feature( 'LocalUseMpiexec', false )
startup;

shortlist_topN = topM; %100;
topN_with_GV = topN; %10;
mCombinations = topN; %10;

SAVE_SUBRESULT_FILES = 1;    % if =1 : Saves outputs for the experiments
USE_CACHE_FILES = 0;         % if =1 : Loads saved subresults (just for testing, this is not allowed in real runtime)
USE_PAR = 1;                 % if =1 : runs parallel code (parfor cycles). It is faster, but code profiling contains much less details
USE_PROFIL = 1;              % if =1 : uses code profilation

% We use 40 query images for experiments and testing
QUERIES = {
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/1.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/2.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/3.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/4.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/5.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/6.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/7.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/8.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/9.jpg' ,
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/10.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/11.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/12.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/13.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/14.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/15.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/16.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/17.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/18.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/19.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/20.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/21.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/22.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/23.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/24.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/25.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/26.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/27.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/28.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/29.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/30.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/31.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/32.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/33.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/34.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/35.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/36.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/37.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/38.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/39.jpg',
    '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/40.jpg'
    };

setenv("INLOC_EXPERIMENT_NAME","SPRING_Demo");
setenv("INLOC_HW","GPU");

for DATASET_SIZE=1:9
    COMPUTED_FEATURES_PATH = "inputs/features/computed_featuresSize"+DATASET_SIZE+".mat";
    load("inputs/cutout_imgnames_all"+DATASET_SIZE+".mat", 'cutout_imgnames_all');
    [ params ] = setupParams('SPRING_Demo', DATASET_SIZE, true, shortlist_topN, topN_with_GV); % NOTE: adjust
    disp(params.output.proj.dir);
    disp(params.output.proj.dir);
    disp(params.output.proj.dir);
    inloc_hw = getenv("INLOC_HW");
    if isempty(inloc_hw) || (~strcmp(inloc_hw, "GPU") && ~strcmp(inloc_hw, "CPU"))
        fprintf('Please specify environment variable INLOC_HW to one of: "GPU", "CPU"\n');
        fprintf('CPU mode will run on many cores (unsuitable for boruvka).\n');
        fprintf('GPU mode will run on maximum of 4 cores, but with a GPU.\n');
        fprintf('NOTE: You should first run InLocCIIRC on GPU, then run it on CPU.\n')
        error("See above");
    end
    fprintf('InLocCIIRC is running in %s mode.\n', inloc_hw);
    
    delete(gcp('nocreate'));
    if strcmp(inloc_hw, "CPU")
        if strcmp(environment(), 'laptop')
            nWorkers = 8;
        else
            nWorkers = 16;
        end
        c = parcluster;
        c.NumWorkers = nWorkers;
        saveProfile(c);
        p = parpool('local', nWorkers);
    end
    
    wks1 = false; 
    if wks1
        nWorkers = 8;
        c = parcluster;
        c.NumWorkers = nWorkers;
        saveProfile(c);
        p = parpool('local', nWorkers);
    end
    
    
    
    if USE_PROFIL
        profile off; profile on;
    end
    
    for CYCPROF=1:numel(QUERIES)
        QUERY_PATH = QUERIES{CYCPROF};
        % step 1: retrieval. It loads topM images and orders them by score
        ht_retrieval;
        
        % step 2: geometric verification. Recalculates score (previous score + inliers num.). Then takes only topN images.
        ht_top100_densePE_localization;
        
        % step 2: pose verification. It orders topN estimated poses by quality score
        ht_top10_densePV_localization;
        
    end
    if USE_PROFIL
        prof_dir_name = "outputs"+topM+"__"+topN+"/PROFILACE/original/"+DATASET_SIZE+"/P" + datestr(now(), 'yy_mm_dd_hh_MM') + "_QUE_ALL";
        profile off;
        saveProfileResult(profile('info'), prof_dir_name);
        disp("PROFILACE datasetu " + DATASET_SIZE + " ULOZENA");
    end
end

disp("Algoritmus skoncil");
end % FUNCTION inloc_demo
