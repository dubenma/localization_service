clear

addpath('utils/')
addpath('tools/')
addpath('visual_inspection/')

startup;

setenv("INLOC_EXPERIMENT_NAME","SPRING_Demo")
setenv("INLOC_HW","GPU")
[ params ] = setupParams('SPRING_Demo', true); % NOTE: adjust

load(params.input.qlist.path); % loads query_imgnames_all.mat
densePV_matname = fullfile(params.output.dir, 'densePV_top10_shortlist.mat');
load(densePV_matname, 'ImgList');

nn_dir = fullfile(params.output.dir, "nn_dataset", params.dynamicMode);


for id_q = 1 : numel(ImgList)
    query_name = ImgList(id_q).queryname;
    spaceName = strsplit(query_name,'/'); spaceName = spaceName{1};
    errors = struct();
    for id_db = 1 : 10
        this_densePV_matname = fullfile(params.output.synth.dir, query_name, sprintf('%d%s', id_db, params.output.synth.matformat));
        load(this_densePV_matname)
        
        output_dir = fullfile(nn_dir, query_name);
        
        if not(isfolder(output_dir))
            mkdir(output_dir)
        end
        output_file = fullfile(output_dir, sprintf('%d%s', id_db, params.output.synth.matformat));
        
        % query_img
        query_img = Iqs{1};
        save(output_file, 'query_img');
        
        % query_name
        save(output_file,'query_name','-append');
        
        % synth_img
        synth_img = RGBpersps{1};
        save(output_file,'synth_img','-append');
        
        % mask
        if ~strcmp(params.dynamicMode, 'original')
            [filepath,name,ext] = fileparts(query_name);
            mask_name = fullfile(params.input.dir, "queries_masks", name + ".png");
            [h, w, ~] = size(query_img);
            mask = imresize(imread(mask_name), [h, w], 'nearest');
            mask = logical(mask);
            save(output_file,'mask','-append');
        end
        
        % ref poses
        [P,ref_spaceName,fullName] = getReferencePose(id_q,ImgList,params);
        P_ref = {};
        P_ref.R = P(:,1:3);
        P_ref.t = P(:,4);
        P_ref.P = P;
        P_ref.C = -P_ref.R'*P_ref.t;
        
        C_ref = P_ref.C;
        R_ref = P_ref.R;
        
        save(output_file,'C_ref', 'R_ref','-append');
        
        % query_true_name
        query_true_name = fullfile(ref_spaceName,fullName);
        save(output_file,'query_true_name','-append');
        
        % est poses
        P_est = {};
        P_est.P = ImgList(id_q).Ps{id_db}{1};
        [P_est.K,P_est.R,P_est.C] = P2KRC(P_est.P);
        P_est.t = -P_est.R*P_est.C;
             
        C_est = P_est.C;
        R_est = P_est.R;
        
        save(output_file,'C_est', 'R_est','-append');
        
        % space names
        est_spaceName = strsplit(ImgList(id_q).topNname{id_db},'/'); est_spaceName = est_spaceName{1};
        est_mapName = strsplit(est_spaceName,'_'); est_mapName = est_mapName{1};
        ref_mapName = strsplit(ref_spaceName,'_'); ref_mapName = ref_mapName{1};
        
        save(output_file,'est_mapName', 'ref_mapName','-append');
               
        % error
        error.translation = norm(C_ref - P_est.C); 
        error.orientation = rotationDistance(R_ref, P_est.R);
        error.inMap = strcmp(est_mapName,ref_mapName);
        
        save(output_file, 'error','-append');
        
        % score 
        score = scores{1};
        save(output_file, 'score','-append');

        % save(filename,variables,'-append')
    end    
end




