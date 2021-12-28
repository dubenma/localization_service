[~,QFname,~] = fileparts(QUERY_PATH);

PV_topN = params.PV.topN;
dirname = fullfile(params.output.dir, string(DATASET_SIZE), 'queries', QFname);
if exist(dirname, 'dir') ~= 7
    mkdir(dirname);
end
densePV_matname = fullfile(dirname, 'densePV_top10_shortlist.mat');

if 1==1 || ~USE_CACHE_FILES || exist(densePV_matname, 'file') ~= 2
    disp("# Starting top10");
    %synthesis list
    qlist = cell(1, PV_topN*length(ImgList_densePE));
    dblist = cell(1, PV_topN*length(ImgList_densePE));
    PsList = cell(1, PV_topN*length(ImgList_densePE));
    dbind = cell(1, PV_topN*length(ImgList_densePE));
    for jj = 1:1:PV_topN
        qlist{jj} = ImgList_densePE(1).queryname;
        dblist{jj} = ImgList_densePE(1).topNname(:,jj);
        PsList{jj} = ImgList_densePE(1).Ps{jj};
        dbind{jj} = jj;
    end
    
    %find unique scans
    dbscanlist = cell(size(dblist));
    for ii = 1:1:length(dblist)
        for j=1:size(dblist{ii},1)
            dbpath = dblist{ii}{j};
            this_floorid = strsplit(dbpath, '/');this_floorid = this_floorid{1};
            info = parse_WUSTL_cutoutname(dbpath);
            dbscanlist{ii} = strcat(this_floorid, params.dataset.db.scan.matformat);
        end
    end
    [dbscanlist_uniq, sort_idx, uniq_idx] = unique(dbscanlist);
    qlist_uniq = cell(size(dbscanlist_uniq));
    dblist_uniq = cell(size(dbscanlist_uniq));
    PsList_uniq = cell(size(dbscanlist_uniq));
    dbind_uniq = cell(size(dbscanlist_uniq));
    for ii = 1:1:length(dbscanlist_uniq)
        idx = uniq_idx == ii;
        qlist_uniq{ii} = qlist(idx);
        dblist_uniq{ii} = dblist(idx);
        PsList_uniq{ii} = PsList(idx);
        dbind_uniq{ii} = dbind(idx);
    end
    
    %compute synthesized views and similarity
    
    poolobj = gcp('nocreate');
    delete(poolobj); % terminate any previous pool
    if strcmp(environment(), 'laptop')
        nWorkers = 1;
    else
        nWorkers = 8;
    end
    c = parcluster;
    c.NumWorkers = nWorkers;
    saveProfile(c);
    
    if USE_PAR
        p = parpool('local', nWorkers);
    end
    
    
    for ii = 1:1:length(dbscanlist_uniq)
        this_dbscan = dbscanlist_uniq{ii};
        this_qlist = qlist_uniq{ii};
        this_dblist = dblist_uniq{ii};
        this_PsList = PsList_uniq{ii};
        this_dbind = dbind_uniq{ii};
        
        %compute synthesized images and similarity scores
        if USE_PAR % Parallel code is faster, but code profilation contains much less information
            parfor jj = 1:length(this_qlist)
                parfor_densePV( this_qlist{jj}, this_dblist{jj}, this_dbind{jj}, this_PsList{jj}, params );
                fprintf('densePV: %d / %d done. \n', jj, length(this_qlist));
            end
        else
            for jj = 1:length(this_qlist)
                parfor_densePV( this_qlist{jj}, this_dblist{jj}, this_dbind{jj}, this_PsList{jj}, params );
                fprintf('densePV: %d / %d done. \n', jj, length(this_qlist));
            end
        end
        
        fprintf('densePV: scan %s (%d / %d) done. \n', this_dbscan, ii, length(dbscanlist_uniq));
    end
    
    %load similarity score and reranking
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'Ps', {}, 'dbnamesId', {});
    ImgList(1).queryname = ImgList_densePE(1).queryname;
    ImgList(1).topNname = ImgList_densePE(1).topNname(:,1:PV_topN);
    ImgList(1).topNscore = zeros(1, PV_topN);
    ImgList(1).Ps = ImgList_densePE(1).Ps(1:PV_topN);
    for jj = 1:1:PV_topN
        [~,DBFname,DBFsuffix] = fileparts(ImgList(1).topNname{jj});
        dbnamesId = jj;
        ImgList(1).dbnamesId(jj) = dbnamesId;
        synthpath = fullfile(params.output.synth.dir, QFname, sprintf('%s%s', DBFname, params.output.synth.matformat));
        load(synthpath, 'scores');
        cumulativeScore = sum(cell2mat(scores)); % TODO: try something else than a sum?
        ImgList(1).topNscore(jj) = cumulativeScore;
    end
    
    %reranking
    [sorted_score, idx] = sort(ImgList(1).topNscore, 'descend');
    ImgList(1).topNname = ImgList(1).topNname(:,idx);
    ImgList(1).topNscore = ImgList(1).topNscore(idx);
    ImgList(1).Ps = ImgList(1).Ps(idx);
    ImgList(1).dbnamesId = ImgList(1).dbnamesId(idx);
    
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    
    if SAVE_SUBRESULT_FILES
        save('-v6', densePV_matname, 'ImgList');
    end
    
else
    load(densePV_matname, 'ImgList');
end
ImgList_densePV = ImgList;
