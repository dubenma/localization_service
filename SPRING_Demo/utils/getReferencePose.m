function [P,spaceName,fullName] = getReferencePose(qid,imgList,params)
%GETQUERYPOSE Summary of this function goes here
%   Detailed explanation goes here
    qname = imgList(qid).queryname;
    spaceName = strsplit(qname,'/'); spaceName = spaceName{1};
    [~,space_id,~] = fileparts(qname); space_id = str2num(space_id); % space_id is the query id
    params.dataset.db.space_names;
    trueName = '';
    for i = 1:numel(params.dataset.db.space_names)
        run(fullfile(params.dataset.dir,'metadata',params.dataset.db.space_names{i},'query_mapping.m'));
        if ~strcmp(spaceName, params.dataset.db.space_names{i})    
%             qid = qid - numel(q2name);
        else
            
            trueName = q2name(space_id);
            break
        end
    end
    panoId = strsplit(trueName,'_'); 
    panoDirId = str2double(panoId{3})+1;
    P_gt = load(fullfile(params.dataset.query.mainDir,spaceName,'poses',string(panoDirId),sprintf('%s.%s',trueName,'mat')));
    P_gt.C = P_gt.position';
    rFix = [0., 180., 180.];
    Rfix = rotationMatrix(deg2rad(rFix), 'XYZ');
    % Rfix = [1 0 0; 0 -1 0; 0 0 -1]
    P_gt.R =Rfix*P_gt.R';
    P = [P_gt.R, -P_gt.R*P_gt.C];
    fullName = sprintf('%s/%s',string(panoDirId),trueName);
end
