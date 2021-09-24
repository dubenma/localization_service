function [P,spaceName,fullName] = getReferencePose(qid,imgList,params)
%GETQUERYPOSE Summary of this function goes here
%   Detailed explanation goes here
    qname = imgList(qid).queryname;
    spaceName = strsplit(qname,'/'); spaceName = spaceName{1};
    [~,space_id,~] = fileparts(qname); space_id = str2num(space_id);
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
    panoId = strsplit(trueName,'_'); panoId = panoId{2};
    P_gt = load(fullfile(params.dataset.query.mainDir,spaceName,'poses',panoId,sprintf('%s.%s',trueName,'mat')));
    P_gt.C = P_gt.position';
    rFix = [0., 180., 180.];
    Rfix = rotationMatrix(deg2rad(rFix), 'XYZ');
    P_gt.R =Rfix*P_gt.R';
    P = [P_gt.R, -P_gt.R*P_gt.C];
    fullName = sprintf('%s/%s',panoId,trueName);
end
