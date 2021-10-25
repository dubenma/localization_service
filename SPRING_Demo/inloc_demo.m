% TODO: Pomuze tohle udelat paralelni cluster?:
clear;
distcomp.feature( 'LocalUseMpiexec', false )

startup;

SAVE_SUBRESULT_FILES = 1;
USE_CACHE_FILES = 0;
USE_PAR = 1;
USE_PROFIL = 1;
%DATASET_SIZE = 1;
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

%QUERY_PATH = '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/1.jpg';
%COMPUTED_FEATURES_PATH = "/home/seberma3/InLocCIIRC_NEWdataset/inputs-pokus/features/computed_featuresSize"+DATASET_SIZE +".mat";

%setenv("INLOC_EXPERIMENT_NAME","hospital_1")
setenv("INLOC_EXPERIMENT_NAME","SPRING_Demo");
setenv("INLOC_HW","GPU");


for DATASET_SIZE=1:4
    %COMPUTED_FEATURES_PATH = "/home/seberma3/InLocCIIRC_NEWdataset/inputs-pokus/features/computed_featuresSize"+DATASET_SIZE +".mat";
    %cutout_imgnames_all = dir("/home/seberma3/InLocCIIRC_NEWdataset/cutouts"+DATASET_SIZE+"/*/*/cut*.jpg");
    COMPUTED_FEATURES_PATH = "/home/seberma3/_InLoc_PROD_Speedup/SPRING_Demo/inputs/features/computed_featuresSize"+DATASET_SIZE+".mat";
    load("inputs/cutout_imgnames_all"+DATASET_SIZE+".mat", 'cutout_imgnames_all');
    %setenv("INLOC_HW","CPU")
    %[ params ] = setupParams('hospital_1', true); % NOTE: adjust
    [ params ] = setupParams('SPRING_Demo', DATASET_SIZE, true); % NOTE: adjust
    
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
    %wks1=true;
    wks1 = false; % Co to kurva je? Kde je vysvetlujici komentar?
    if wks1
        %nWorkers = 64;
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
        %1. retrieval
        ht_retrieval;
        
        %2. geometric verification
        ht_top100_densePE_localization;
        
        %3. pose verification
        ht_top10_densePV_localization;
        
%         if USE_PROFIL
%             prof_dir_name = "outputs/PROFILACE/original/"+DATASET_SIZE+"/P" + datestr(now(), 'yy_mm_dd_hh_MM') + "_QUE_"+CYCPROF;
%             %profile off;
%             % profsave(profile('info'), prof_dir_name);
%             saveProfileResult(profile('info'), prof_dir_name);
%         end
    end
    if USE_PROFIL
        prof_dir_name = "outputs/PROFILACE/original/"+DATASET_SIZE+"/P" + datestr(now(), 'yy_mm_dd_hh_MM') + "_QUE_ALL";
        profile off;
        % profsave(profile('info'), prof_dir_name);
        saveProfileResult(profile('info'), prof_dir_name);
    end
end

%4. evaluate
% cutout_imgnames_all = dir("/home/seberma3/InLocCIIRC_NEWdataset/cutouts"+DATASET_SIZE+"/*/*/cut*.jpg");
% evaluate_SPRING;
% 
% if ~strcmp(environment(), "laptop")
%     exit(0); % avoid "MATLAB: management.cpp:671: find: Assertion `' failed."
% end



% % % % %setenv("INLOC_HW","CPU")
% % % % %[ params ] = setupParams('hospital_1', true); % NOTE: adjust
% % % % [ params ] = setupParams('SPRING_Demo', DATASET_SIZE, true); % NOTE: adjust
% % % % 
% % % % inloc_hw = getenv("INLOC_HW");
% % % % if isempty(inloc_hw) || (~strcmp(inloc_hw, "GPU") && ~strcmp(inloc_hw, "CPU"))
% % % %     fprintf('Please specify environment variable INLOC_HW to one of: "GPU", "CPU"\n');
% % % %     fprintf('CPU mode will run on many cores (unsuitable for boruvka).\n');
% % % %     fprintf('GPU mode will run on maximum of 4 cores, but with a GPU.\n');
% % % %     fprintf('NOTE: You should first run InLocCIIRC on GPU, then run it on CPU.\n')
% % % %     error("See above");
% % % % end
% % % % fprintf('InLocCIIRC is running in %s mode.\n', inloc_hw);
% % % % 
% % % % delete(gcp('nocreate'));
% % % % if strcmp(inloc_hw, "CPU")
% % % %     if strcmp(environment(), 'laptop')
% % % %         nWorkers = 8;
% % % %     else
% % % %         nWorkers = 16;
% % % %     end
% % % %     c = parcluster;
% % % %     c.NumWorkers = nWorkers;
% % % %     saveProfile(c);
% % % %     p = parpool('local', nWorkers);
% % % % end
% % % % %wks1=true;
% % % % wks1 = false; % Co to kurva je? Kde je vysvetlujici komentar?
% % % % if wks1
% % % %     %nWorkers = 64;
% % % %     nWorkers = 8;
% % % %     c = parcluster;
% % % %     c.NumWorkers = nWorkers;
% % % %     saveProfile(c);
% % % %     p = parpool('local', nWorkers);
% % % % end
% % % % 
% % % % cutout_imgnames_all = dir("/home/seberma3/InLocCIIRC_NEWdataset/cutouts"+DATASET_SIZE+"/*/*/cut*.jpg");
% % % % 
% % % % if USE_PROFIL
% % % %    profile off; profile on;  
% % % % end
% % % % 
% % % % for CYCPROF=1:numel(QUERIES)
% % % % QUERY_PATH = QUERIES{CYCPROF};
% % % % %1. retrieval
% % % % ht_retrieval;
% % % % 
% % % % %2. geometric verification
% % % % ht_top100_densePE_localization;
% % % % 
% % % % %3. pose verification
% % % % ht_top10_densePV_localization;
% % % % 
% % % % if USE_PROFIL
% % % %     prof_dir_name = "outputs/PROFILACE/"+DATASET_SIZE+"/P" + datestr(now(), 'yy_mm_dd_hh_MM') + "_QUE_"+CYCPROF;
% % % %     profile off; 
% % % %     % profsave(profile('info'), prof_dir_name);
% % % %     saveProfileResult(profile('info'), prof_dir_name);
% % % % end
% % % % 
% % % % end
% % % % %4. evaluate
% % % % evaluate_SPRING;
% % % % 
% % % % if ~strcmp(environment(), "laptop")
% % % %     exit(0); % avoid "MATLAB: management.cpp:671: find: Assertion `' failed."
% % % % end