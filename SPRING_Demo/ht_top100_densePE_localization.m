%% densePE (top100 reranking -> top10 pose candidate)

dirname = fullfile(params.output.dir, string(DATASET_SIZE), 'queries', QFname);
disp("#ht100 bude ukladat do slozky: " + dirname);
if exist(dirname, 'dir') ~= 7
   mkdir(dirname); 
end
    
densePE_matname = fullfile(dirname, 'densePE_top100_shortlist.mat');
denseGV_matname = fullfile(dirname, 'denseGV_top100_shortlist.mat');

if ~USE_CACHE_FILES || exist(densePE_matname, 'file') ~= 2
    disp("# Starting top100 because " + densePE_matname + " does not exist");
    if ~USE_CACHE_FILES || exist(denseGV_matname, 'file') ~= 2
        disp("# Starting top100 No2 because " + denseGV_matname + " does not exist");
        %dense feature extraction
        net = load(params.netvlad.dataset.pretrained);
        net = net.net;
        net= relja_simplenn_tidy(net);
        net= relja_cropToLayer(net, 'postL2');
        % Extrahuje to lokální deskriptory na 3. a 5. vrstve cnn
        q_densefeat_matname = "" + ImgList_original(1).queryname + params.input.feature.q_matformat;
        queryImage = load_query_image_compatible_with_cutouts(ImgList_original(1).queryname, ...
            params.dataset.db.cutout.size);
        cnn = at_serialAllFeats_convfeat(net, queryImage);
        cnn{1} = [];
        cnn{2} = [];
        cnn{4} = [];
        cnn{6} = [];
        [feat_path, ~, ~] = fileparts(q_densefeat_matname);
        if exist(feat_path, 'dir')~=7; mkdir(feat_path); end
        save('-v6', q_densefeat_matname, 'cnn');
        fprintf('Dense feature extraction: %s done. \n', ImgList_original(1).queryname);
        
        % Extrahuje to lokální deskriptory databazovych snimku na 3. a 5. vrstve cnn
        for jj = 1:1:shortlist_topN           
            db_densefeat_matname = getFeaturesPath(ImgList_original(1).topNname{jj}, params);
            if exist(db_densefeat_matname, 'file') ~= 2
                disp("Chybi soubor");
                disp(db_densefeat_matname);
                   assert(false);
            end
        end
        
        inloc_hw = getenv("INLOC_HW");
        %shortlist reranking
        ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'primary', {}, 'Ps', {});
        %for ii = 1:1:length(ImgList_original)
        ImgList(1).queryname = ImgList_original(1).queryname;
        ImgList(1).topNname = ImgList_original(1).topNname(1:shortlist_topN);
        ImgList(1).primary = ImgList_original(1).primary;
        
        %preload query feature
        qfname = "" + ImgList(1).queryname + params.input.feature.q_matformat;
        cnnq = load(qfname, 'cnn');cnnq = cnnq.cnn;
        f = dir(fullfile(params.output.gv_dense.dir, ImgList(1).queryname)); %skip-recomputation
        if numel(f) ~= (shortlist_topN+2)
            if USE_PAR
                parfor kk = 1:1:shortlist_topN
                    parfor_denseGV( cnnq, ImgList(1).queryname, ImgList(1).topNname{kk}, params );
                    fprintf('dense matching: %s vs %s DONE. \n', ImgList(1).queryname, ImgList(1).topNname{kk});
                end
            else
                for kk = 1:1:shortlist_topN
                    parfor_denseGV( cnnq, ImgList(1).queryname, ImgList(1).topNname{kk}, params );
                    fprintf('dense matching: %s vs %s DONE. \n', ImgList(1).queryname, ImgList(1).topNname{kk});
                end
            end
        end
        for jj = 1:1:shortlist_topN
            cutoutPath = ImgList(1).topNname{jj};
            [~,QFname,~] = fileparts(ImgList(1).queryname);
            [~,DBFname,~] = fileparts(cutoutPath);
            this_densegv_matname = fullfile(params.output.gv_dense.dir, QFname, ""+DBFname+params.output.gv_dense.matformat);
            fprintf("THSLOAD: %s \n", this_densegv_matname);
            this_gvresults = load(this_densegv_matname);
            ImgList(1).topNscore(jj) = ImgList_original(1).topNscore(jj) + size(this_gvresults.inls12, 2);
        end
        
        [sorted_score, idx] = sort(ImgList(1).topNscore, 'descend');
        ImgList(1).topNname = ImgList(1).topNname(idx);
        ImgList(1).topNscore = ImgList(1).topNscore(idx);
        
        fprintf('%s done. \n', ImgList(1).queryname);
        if SAVE_SUBRESULT_FILES
            save('-v6', denseGV_matname, 'ImgList');
        end
        
    else
        load(denseGV_matname, 'ImgList');
    end
    
    
    ImgList_denseGV = ImgList;
    
    %% for each query, find top-mCombinations sequences of lengths params.sequence.length
    treatQueriesSequentially = isfield(params, 'sequence') && isfield(params.sequence, 'length');
    if ~treatQueriesSequentially
        desiredSequenceLength = 1;
    else
        desiredSequenceLength = params.sequence.length;
    end
    ImgListSequential = ImgList;
    ImgListSequential = ImgList(find([ImgList.primary] == true));
    ImgListSequential = rmfield(ImgListSequential, 'primary');
    
    % build queryInd (i-th query in ImgList does not mean i-th query in the whole sequence)
    queryInd = zeros(length(ImgList),1);
    for i=1:length(ImgList)
        queryIdx = queryNameToQueryId(ImgList(i).queryname);
        queryInd(i) = i;%queryIdx;
    end
    system("nvidia-smi");
    
    for i=1:length(ImgListSequential)
        parentQueryName = ImgListSequential(i).queryname;
        parentQueryId = i;
        % compute cumulative score for each combination
        
        % generate all combination indices
        if parentQueryId-desiredSequenceLength+1 < 1
            actualSequenceLength = parentQueryId;
        else
            actualSequenceLength = desiredSequenceLength;
        end
        permInd = permn([1:topN_with_GV], actualSequenceLength);
        
        permScores = zeros(size(permInd,1),1);
        for j=1:size(permInd)
            score = 0.0;
            permIndCol = 0;
            for queryId=parentQueryId-actualSequenceLength+1:parentQueryId
                permIndCol = permIndCol + 1;
                cutoutIdx = permInd(j,permIndCol);
                ii = queryInd == queryId;
                score = score + ImgList(ii).topNscore(cutoutIdx);
            end
            permScores(j) = score;
        end
        
        % find indices of m sequences with the highest cumulative score
        [sorted_score, idx] = sort(permScores, 'descend');
        ImgListSequential(i).topNscore = sorted_score(1:mCombinations)';
        
        topInd = permInd(idx(1:mCombinations),:);
        ImgListSequential(i).topNname = cell(actualSequenceLength,mCombinations);
        for j=1:size(topInd,1)
            permIndCol = 0;
            for queryId=parentQueryId-actualSequenceLength+1:parentQueryId
                permIndCol = permIndCol + 1;
                ii = queryInd == queryId;
                name = ImgList(ii).topNname{topInd(j,permIndCol)};
                ImgListSequential(i).topNname{permIndCol,j} = name;
            end
        end
    end
    
    if treatQueriesSequentially
        posesFromHoloLens = getPosesFromHoloLens(params.HoloLensOrientationDelay, params.HoloLensTranslationDelay, ...
            queryInd, params);
        nQueries = length(ImgList);
        assert(size(posesFromHoloLens,1) == nQueries);
    end
    
    qlist = cell(1, length(ImgListSequential)*mCombinations);
    dblist = cell(1, length(ImgListSequential)*mCombinations);
    dbind = cell(1, length(ImgListSequential)*mCombinations);
    posesFromHoloLensList = cell(1, length(ImgListSequential)*mCombinations);
    firstQueryInd = cell(1, length(ImgListSequential)*mCombinations);
    lastQueryInd = cell(1, length(ImgListSequential)*mCombinations);
    for ii = 1:length(ImgListSequential)
        lastQueryId = ii;
        for jj = 1:mCombinations
            idx = mCombinations*(ii-1)+jj;
            qlist{idx} = ImgListSequential(ii).queryname;
            dblist{idx} = ImgListSequential(ii).topNname(:,jj);
            dbind{idx} = jj;
            actualSequenceLength = size(ImgListSequential(ii).topNname, 1);
            firstQueryId = lastQueryId - actualSequenceLength + 1;
            if treatQueriesSequentially
                thisPosesFromHoloLens = zeros(actualSequenceLength,4,4);
                k = 1;
                for thisQueryId=firstQueryId:lastQueryId
                    thisPosesFromHoloLens(k,:,:) = posesFromHoloLens(queryInd == thisQueryId,:,:);
                    k = k + 1;
                end
                posesFromHoloLensList{idx} = thisPosesFromHoloLens;
            end
            firstQueryInd{idx} = firstQueryId;
            lastQueryInd{idx} = lastQueryId;
        end
    end
    
    %dense pnp
    for ii = 1:length(qlist)
        parfor_densePE(qlist{ii}, dblist{ii}, dbind{ii}, posesFromHoloLensList{ii}, firstQueryInd{ii}, lastQueryInd{ii}, params);
        fprintf('densePE: %s vs a cutout sequence DONE. \n', qlist{ii});
        fprintf('%d/%d done.\n', ii, length(qlist));
    end
    
    for ii = 1:1:length(ImgListSequential)
        ImgListSequential(ii).Ps = cell(1, mCombinations);
        for jj = 1:1:mCombinations
            [~,QFname,~] = fileparts(ImgListSequential(ii).queryname);
            [~,DBFname,DBFsuffix] = fileparts(ImgListSequential(ii).topNname{jj});
            this_densepe_matname = fullfile(params.output.pnp_dense_inlier.dir, QFname, sprintf('%s%s', DBFname, params.output.pnp_dense.matformat));
            load(this_densepe_matname, 'Ps');
            ImgListSequential(ii).Ps{jj} = Ps;
        end
    end
    
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    ImgList = ImgListSequential;
    
    if SAVE_SUBRESULT_FILES
        save('-v6', densePE_matname, 'ImgList');
    end
else
    load(denseGV_matname, 'ImgList');
    ImgList_denseGV = ImgList;
    
    load(densePE_matname, 'ImgList');
end
ImgList_densePE = ImgList;
