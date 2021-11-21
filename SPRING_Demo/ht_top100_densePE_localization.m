%Note: It first rerank top100 original shortlist (ImgList_original) in accordance
%with the number of dense matching inliers. TODO: and then?

% shortlist_topN = 100;
% topN_with_GV = 10;
% mCombinations = 10;

%% densePE (top100 reranking -> top10 pose candidate)

% dirname = fullfile(params.output.dir, 'queries', QFname);
dirname = fullfile(params.output.dir, string(DATASET_SIZE), 'queries', QFname);

if exist(dirname, 'dir') ~= 7
   mkdir(dirname); 
end

% Tohle je v ht_retireival
% dirname = fullfile(params.output.dir, string(DATASET_SIZE), 'queries', QFname);
% top100_matname = fullfile(dirname, 'original_top100_shortlist.mat');
    
densePE_matname = fullfile(dirname, 'densePE_top100_shortlist.mat');
denseGV_matname = fullfile(dirname, 'denseGV_top100_shortlist.mat');

if ~USE_CACHE_FILES || exist(densePE_matname, 'file') ~= 2 %1 == 1
    disp("# Starting top100 because " + densePE_matname + " does not exist");
    if ~USE_CACHE_FILES || exist(denseGV_matname, 'file') ~= 2 %1 == 1 
        disp("# Starting top100 No2 because " + denseGV_matname + " does not exist");
        %dense feature extraction
        
        net = load(params.netvlad.dataset.pretrained);
        net = net.net;
        net= relja_simplenn_tidy(net);
        net= relja_cropToLayer(net, 'postL2');
        %for ii = 1:1:length(ImgList_original)
        %q_densefeat_matname = fullfile(params.input.feature.dir, params.dataset.query.dirname, [ImgList_original(ii).queryname, params.input.feature.q_matformat]);
        % Extrahuje to lokální deskriptory na 3. a 5. vrstve cnn
        q_densefeat_matname = "" + ImgList_original(1).queryname + params.input.feature.q_matformat;
        fprintf("Existuje-li feature file %s ? %d", q_densefeat_matname, exist(q_densefeat_matname));
        %if exist(q_densefeat_matname, 'file') ~= 2 % TODO: Tohle tady nebude, protoze query je predem neznamy
        % this is necessary because of denseGV:
       
        queryImage = load_query_image_compatible_with_cutouts(ImgList_original(1).queryname, ...
            params.dataset.db.cutout.size);
      
        cnn = at_serialAllFeats_convfeat(net, queryImage, 'useGPU', false);
        %cnn = at_serialAllFeats_convfeat(net, queryImage, 'useGPU', true);
        cnn{1} = [];
        cnn{2} = [];
        cnn{4} = [];
        cnn{6} = [];
       
        
        [feat_path, ~, ~] = fileparts(q_densefeat_matname);
        if exist(feat_path, 'dir')~=7; mkdir(feat_path); end
        save('-v6', q_densefeat_matname, 'cnn');
        fprintf('Dense feature extraction: %s done. \n', ImgList_original(1).queryname);
        %end
        
        % Extrahuje to lokální deskriptory databazovych snimku na 3. a 5. vrstve cnn
        for jj = 1:1:shortlist_topN            
            %db_densefeat_matname = fullfile(params.input.feature.dir, params.dataset.db.cutout.dirname, ...
            %    [ImgList_original(ii).topNname{jj}, params.input.feature.db_matformat]);
            %db_densefeat_matname = ImgList_original(1).topNname{jj} + params.input.feature.db_matformat;
            db_densefeat_matname = getFeaturesPath(ImgList_original(1).topNname{jj}, params);
            if exist(db_densefeat_matname, 'file') ~= 2
                   assert(false);
%                 Zakomentovano, protozue nechci dovolit buildovat features
%                 pri lokalizuaci! Uz ma bejt vse hotovo!
%                 %cutoutImage = imread(fullfile(params.dataset.db.cutout.dir, ImgList_original(ii).topNname{jj}));
%                 cutoutImage = imread(ImgList_original(1).topNname{jj});
%                 cnn = at_serialAllFeats_convfeat(net, cutoutImage, 'useGPU', true);
%                 cnn{1} = [];
%                 cnn{2} = [];
%                 cnn{4} = [];
%                 cnn{6} = [];
%                 [feat_path, ~, ~] = fileparts(db_densefeat_matname);
%                 if exist(feat_path, 'dir')~=7; mkdir(feat_path); end
%                 save('-v6', db_densefeat_matname, 'cnn');
%                 fprintf('Dense feature extraction: %s done. \n', ImgList_original(1).topNname{jj});
            end
        end
        %end
        
        inloc_hw = getenv("INLOC_HW");
        if strcmp(inloc_hw, "GPU")
            %exit(0);
        end
        
        %shortlist reranking
        ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'primary', {}, 'Ps', {});
        %for ii = 1:1:length(ImgList_original)
        ImgList(1).queryname = ImgList_original(1).queryname;
        ImgList(1).topNname = ImgList_original(1).topNname(1:shortlist_topN);
        ImgList(1).primary = ImgList_original(1).primary;
        
        %preload query feature
        %qfname = fullfile(params.input.feature.dir, params.dataset.query.dirname, [ImgList(ii).queryname, params.input.feature.q_matformat]);
        qfname = "" + ImgList(1).queryname + params.input.feature.q_matformat;
        cnnq = load(qfname, 'cnn');cnnq = cnnq.cnn;
        f = dir(fullfile(params.output.gv_dense.dir, ImgList(1).queryname)); %skip-recomputation
        if numel(f) ~= (shortlist_topN+2)
            parfor_denseGV( cnnq, ImgList(1).queryname, ImgList(1).topNname, params ); % New version of GV accepts all db data for batch processing (20 GB RAM)
        end
        for jj = 1:1:shortlist_topN
            cutoutPath = ImgList(1).topNname{jj};
            %                 %this_gvresults = load(fullfile(params.output.gv_dense.dir, ImgList(1).queryname, buildCutoutName(cutoutPath, params.output.gv_dense.matformat)));
            %                 fprintf("ImgList(1).queryname : %s", ImgList(1).queryname);
            %                 fprintf("built : %s", buildCutoutName(cutoutPath, params.output.gv_dense.matformat));
            %                 fprintf("FULL : %s", fullfile(ImgList(1).queryname, buildCutoutName(cutoutPath, params.output.gv_dense.matformat)));
            %                 fprintf("exist : %d", exist(fullfile(ImgList(1).queryname, buildCutoutName(cutoutPath, params.output.gv_dense.matformat)) ));
            %                 this_gvresults = load(fullfile(ImgList(1).queryname,
            %                 buildCutoutName(cutoutPath, params.output.gv_dense.matformat)));
            [~,QFname,~] = fileparts(ImgList(1).queryname);
            [~,DBFname,~] = fileparts(cutoutPath);
            %mkdirIfNonExistent(fullfile(params.output.gv_dense.dir, QFname));
            this_densegv_matname = fullfile(params.output.gv_dense.dir, QFname, ""+DBFname+params.output.gv_dense.matformat);
            this_gvresults = load(this_densegv_matname);
            ImgList(1).topNscore(jj) = ImgList_original(1).topNscore(jj) + size(this_gvresults.inls12, 2);
        end
        
        [sorted_score, idx] = sort(ImgList(1).topNscore, 'descend');
        ImgList(1).topNname = ImgList(1).topNname(idx);
        ImgList(1).topNscore = ImgList(1).topNscore(idx);
        
        fprintf('%s done. \n', ImgList(1).queryname);
        %end
        %     save('DenseGV.mat');
        if SAVE_SUBRESULT_FILES
            save('-v6', denseGV_matname, 'ImgList');
        end
        
    else
        load(denseGV_matname, 'ImgList');
    end
    
    
    ImgList_denseGV = ImgList;
    
    %% for each query, find top-mCombinations sequences of lengths params.sequence.length
    treatQueriesSequentially = isfield(params, 'sequence') && isfield(params.sequence, 'length');
%     if treatQueriesSequentially && params.sequence.length == 1
%         treatQueriesSequentially = false; % to avoid NaN pose estimates for queries that don't have HoloLens data
%     end
%     if treatQueriesSequentially && strcmp(params.sequence.processing.mode, 'sequentialPV')
%         treatQueriesSequentially = false;
%     end
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
    
    
    for i=1:length(ImgListSequential)
        parentQueryName = ImgListSequential(i).queryname;
        parentQueryId = i;%queryNameToQueryId(parentQueryName);
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
        lastQueryId = ii;%queryNameToQueryId(ImgListSequential(ii).queryname); % the one for which we try to estimate pose
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
        %for ii = 1:length(qlist)
        parfor_densePE(qlist{ii}, dblist{ii}, dbind{ii}, posesFromHoloLensList{ii}, firstQueryInd{ii}, lastQueryInd{ii}, params);
        fprintf('densePE: %s vs a cutout sequence DONE. \n', qlist{ii});
        fprintf('%d/%d done.\n', ii, length(qlist));
    end
    
    %load top-mCombinations poses
    for ii = 1:1:length(ImgListSequential)
        ImgListSequential(ii).Ps = cell(1, mCombinations);
        for jj = 1:1:mCombinations
            [~,QFname,~] = fileparts(ImgListSequential(ii).queryname);
            [~,DBFname,DBFsuffix] = fileparts(ImgListSequential(ii).topNname{jj});
            this_densepe_matname = fullfile(params.output.pnp_dense_inlier.dir, QFname, sprintf('%s%s', DBFname, params.output.pnp_dense.matformat));
%             this_densepe_matname = fullfile(params.output.pnp_dense_inlier.dir, ImgListSequential(ii).queryname, ...
%                 sprintf('%d%s', jj, params.output.pnp_dense.matformat));
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
