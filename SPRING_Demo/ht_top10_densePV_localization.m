%Note: It first synthesize query views according to top10 pose candedates
%and compute similarity between original query and synthesized views. Pose
%candidates are then re-scored by the similarity.
[~,QFname,~] = fileparts(QUERY_PATH);

PV_topN = params.PV.topN; % assuming this is not larger than mCombinations
densePV_matname = fullfile(params.output.dir, 'densePV_top10_shortlist.mat');
if ~USE_CACHE_FILES || exist(densePV_matname, 'file') ~= 2
    disp("# Starting top10");
%     sequentialPV = isfield(params, 'sequence') && strcmp(params.sequence.processing.mode, 'sequentialPV');
%     if sequentialPV
%         % build queryInd (i-th query in ImgList does not mean i-th query in the whole sequence)
%         queryInd = zeros(length(ImgList_densePE),1);
%         for i=1:length(ImgList_densePE)
%             queryIdx = queryNameToQueryId(ImgList_densePE(i).queryname);
%             queryInd(i) = queryIdx;
%         end
% 
%         secondaryIdx = size(ImgList_densePE,2)+1;
%         for i=1:size(ImgList_densePE,2)
%             parentQueryId = queryNameToQueryId(ImgList_densePE(i).queryname);
% 
%             desiredSequenceLength = params.sequence.length;
%             if parentQueryId-desiredSequenceLength+1 < 1
%                 actualSequenceLength = parentQueryId;
%             else
%                 actualSequenceLength = desiredSequenceLength;
%             end
% 
%             for queryId=parentQueryId-actualSequenceLength+1:parentQueryId-1
%                 idx = find(queryInd,queryId);
%                 if ~isempty(idx)
%                     continue;
%                 end 
%                 queryInd(secondaryIdx) = queryId;
%                 secondaryIdx = secondaryIdx + 1;
%             end
%         end
% 
%         posesFromHoloLens = getPosesFromHoloLens(params.HoloLensOrientationDelay, params.HoloLensTranslationDelay, ...
%                                                     queryInd, params);
%         nQueries = length(queryInd);
%         assert(size(posesFromHoloLens,1) == nQueries);
%     end
    
    %synthesis list
    qlist = cell(1, PV_topN*length(ImgList_densePE));
    dblist = cell(1, PV_topN*length(ImgList_densePE));
    PsList = cell(1, PV_topN*length(ImgList_densePE));
    dbind = cell(1, PV_topN*length(ImgList_densePE));
%     for ii = 1:1:length(ImgList_densePE)
        for jj = 1:1:PV_topN
            qlist{jj} = ImgList_densePE(1).queryname;
            dblist{jj} = ImgList_densePE(1).topNname(:,jj);
%             if sequentialPV
% 
%                 desiredSequenceLength = params.sequence.length;
%                 parentQueryId = queryInd(1);
%                 if parentQueryId-desiredSequenceLength+1 < 1
%                     actualSequenceLength = parentQueryId;
%                 else
%                     actualSequenceLength = desiredSequenceLength;
%                 end
% 
%                 % convert Ps such that Ps{end} == ImgList_densePE(ii).Ps{jj}{1}
%                 P_P3P = ImgList_densePE(1).Ps{jj}{1};
% 
%                 if any(isnan(P_P3P(:))) % avoid NaN warnings
%                     PsList{jj} = ImgList_densePE(1).Ps{jj};
%                     dbind{jj} = jj;
%                     continue;
%                 end
% 
%                 R_P3P = P_P3P(1:3,1:3)'; % epsilonBasesToModelBases
%                 T_P3P = -inv(P_P3P(1:3,1:3))*P_P3P(1:3,4); % wrt model
% 
%                 P_HL = squeeze(posesFromHoloLens(queryInd == parentQueryId,:,:));
% 
%                 if any(isnan(P_HL(:))) % avoid NaN warnings
%                     PsList{jj} = ImgList_densePE(1).Ps{jj};
%                     dbind{jj} = jj;
%                     continue;
%                 end
% 
%                 R_HL = P_HL(1:3,1:3); % epsilonBasesTo HL CS Bases
%                 T_HL = P_HL(1:3,4); % wrt HL CS
% 
%                 R_diff = R_P3P * R_HL';
%                 T_diff = T_P3P - T_HL;
%                 P_diff = [R_diff, R_diff*T_diff]; % HL format
%                 P_diff = [P_diff;0,0,0,1];
% 
%                 Ps = cell(1,actualSequenceLength);
%                 for kk=1:actualSequenceLength
%                     thisQueryId = parentQueryId - actualSequenceLength + kk;
%                     tmp = P_diff * squeeze(posesFromHoloLens(queryInd == thisQueryId,:,:));
%                     tmp(1:3,4) = inv(R_diff)*tmp(1:3,4);
%                     tmp = tmp(1:3,1:4); % this is a HL format, we need to use the P3P aka InLoc format:
%                     R_P3P = tmp(1:3,1:3)'; % modelBasesToEpsilonBases
%                     T_P3P = R_P3P * -tmp(1:3,4);
%                     Ps{kk} = [R_P3P,T_P3P];
%                 end
%                 assert(sum( ImgList_densePE(1).Ps{jj}{1} - Ps{end}, 'all') < 1e-6);
%                 PsList{jj} = Ps;
%             else
                PsList{jj} = ImgList_densePE(1).Ps{jj};
%             end
            dbind{jj} = jj;
        end
%     end
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

    % Because projectMesh in densePV requires up to 20 GB of RAM per one instance,
    % we need to limit the number of workers
    % TODO: optimize and leverage more workers
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
        % TODO: Vratit sem parfor
        if USE_PAR
            parfor jj = 1:1:length(this_qlist)
                parfor_densePV( this_qlist{jj}, this_dblist{jj}, this_dbind{jj}, this_PsList{jj}, params );
                fprintf('densePV: %d / %d done. \n', jj, length(this_qlist));
            end
        else
            for jj = 1:1:length(this_qlist)
                parfor_densePV( this_qlist{jj}, this_dblist{jj}, this_dbind{jj}, this_PsList{jj}, params );
                fprintf('densePV: %d / %d done. \n', jj, length(this_qlist));
            end
        end
       
        fprintf('densePV: scan %s (%d / %d) done. \n', this_dbscan, ii, length(dbscanlist_uniq));
    end
    
    %load similarity score and reranking
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'Ps', {}, 'dbnamesId', {});
    %for ii = 1:1:length(ImgList_densePE)
        ImgList(1).queryname = ImgList_densePE(1).queryname;
        ImgList(1).topNname = ImgList_densePE(1).topNname(:,1:PV_topN);
        ImgList(1).topNscore = zeros(1, PV_topN);
        ImgList(1).Ps = ImgList_densePE(1).Ps(1:PV_topN);
        for jj = 1:1:PV_topN
            [~,DBFname,DBFsuffix] = fileparts(ImgList(1).topNname{jj});
            dbnamesId = jj;
            ImgList(1).dbnamesId(jj) = dbnamesId;
            %load(fullfile(params.output.synth.dir, ImgList(1).queryname, sprintf('%d%s', dbnamesId, params.output.synth.matformat)), 'scores');
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
    %end
    
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    
    if USE_CACHE_FILES
        save('-v6', densePV_matname, 'ImgList');
    end
     
else
     load(densePV_matname, 'ImgList');
end
ImgList_densePV = ImgList;
