%Note: It loads localization score and output top100 database list for each query.
[~,QFname,~] = fileparts(QUERY_PATH);

%% Load query and database list
load(COMPUTED_FEATURES_PATH);
load(params.input.dblist.path);

%% top100 retrieval
dirname = fullfile(params.output.dir, string(DATASET_SIZE), 'queries', QFname);
top100_matname = fullfile(dirname, 'original_top100_shortlist.mat');

if exist(dirname, 'dir') ~= 7
    mkdir(dirname);
end

if ~USE_CACHE_FILES || exist(top100_matname, 'file') ~= 2
    disp("# Starting retrieval");
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'primary', {});
    
    score = getScores1Query(params, COMPUTED_FEATURES_PATH, QUERY_PATH);
    ImgList(1).queryname = QUERY_PATH;
    ii = find(strcmp({score.queryname}, QUERY_PATH));
    [~, score_idx] = sort(score(ii).scores, 'descend');
    ImgList(1).topNname = cutout_imgnames_all(score_idx(1:shortlist_topN));
    ImgList(1).topNscore = score(ii).scores(score_idx(1:shortlist_topN));
    ImgList(1).primary = true;
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    
    if SAVE_SUBRESULT_FILES
        save('-v6', top100_matname, 'ImgList');
    end
else
    load(top100_matname, 'ImgList');
end
ImgList_original = ImgList;
