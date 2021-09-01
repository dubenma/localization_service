startup;

setenv("INLOC_EXPERIMENT_NAME","hospital_1")
setenv("INLOC_HW","GPU")
[ params ] = setupParams('hospital_1', true); % NOTE: adjust

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
wks1=true;
if wks1
    nWorkers = 64;
    c = parcluster;
    c.NumWorkers = nWorkers;
    saveProfile(c);
    p = parpool('local', nWorkers);
end
%1. retrieval
ht_retrieval;

%2. geometric verification
ht_top100_densePE_localization;

%3. pose verification
ht_top10_densePV_localization;

%4. evaluate
evaluate;

if ~strcmp(environment(), "laptop")
    exit(0); % avoid "MATLAB: management.cpp:671: find: Assertion `' failed."
end