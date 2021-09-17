% TODO: Pomuze tohle udelat paralelni cluster?:
clear;
distcomp.feature( 'LocalUseMpiexec', false )

startup;

%TOTO: Tyhle komentare asi uz neplati, tak je odstran
% Nazev souboru určuje vybraný dataset.
% Pro 250 snímků:  computed_featuresSize1.mat
% Pro 500 snímků:  computed_featuresSize2.mat
% Pro 1000 snímků: computed_featuresSize3.mat
% Pro 2000 snímků: computed_featuresSize4.mat
% Matice obahuje extrahovane features pro dany pocet snimku.
% Databazove snimky jsou pak v teto slozce:
% /home/seberma3/InLocCIIRC_NEWdataset/cutouts<250, 500, 1000, 2000>
% MUSITE soucasne s vyberem datasetu prejmenovat prislusnou slozku na
% "cutouts", tj. odstranit z nazvu cislovku.
DATASET_SIZE = 1;
QUERY_PATH = '/home/seberma3/InLocCIIRC_NEWdataset/query-s10e/1.jpg';
COMPUTED_FEATURES_PATH = "/home/seberma3/InLocCIIRC_NEWdataset/inputs-pokus/features/computed_featuresSize"+DATASET_SIZE +".mat";

%setenv("INLOC_EXPERIMENT_NAME","hospital_1")
setenv("INLOC_EXPERIMENT_NAME","SPRING_Demo")
setenv("INLOC_HW","GPU")
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

cutout_imgnames_all = dir("/home/seberma3/InLocCIIRC_NEWdataset/cutouts"+DATASET_SIZE+"/*/*/cut*.jpg");

%1. retrieval
ht_retrieval;

%2. geometric verification
ht_top100_densePE_localization;

%3. pose verification
ht_top10_densePV_localization;

%4. evaluate
evaluate_SPRING;

if ~strcmp(environment(), "laptop")
    exit(0); % avoid "MATLAB: management.cpp:671: find: Assertion `' failed."
end