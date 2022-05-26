clear
close all
startup;

%% set params 
mode = "SPRING_Demo";
% mode = "B315";
setenv("INLOC_EXPERIMENT_NAME",mode)
setenv("INLOC_HW","GPU")
[ params ] = setupParams(mode, true);

output_path = '/local1/projects/artwin/datasets/B-315_dataset/matterport_data/nn_dataset/';

total_n = 10;
ratio_close = 95; % how many percent should be close, the rest is far
close_n = floor(total_n*ratio_close/100);

% max translations in metres
t_max_close = 0.3;
t_max_far = 3;
% max rotations in degrees
th_max_close = 15; 
th_max_far = 180; 

% should the images be resized?
resized = false;

%% generate data

load(params.input.qlist.path);

for i = 1 : 10 %length(query_imgnames_all)
    output_dir = fullfile(output_path, mode, params.dataset.name, string(i));
    if ~exist(output_dir, 'dir')
        mkdir(output_dir)
    end
    
    output_file = fullfile(output_dir, 'query.mat');
    
    if ~(exist(output_file) == 2)
        qname = query_imgnames_all{i};
        spaceName = strsplit(qname,'/'); spaceName = spaceName{1};
        [~,query_id,~] = fileparts(qname); query_id = str2double(query_id);

        run(fullfile(params.dataset.query.mainDir, spaceName, 'query_all', 'metadata', 'query_mapping.m'));
        trueName = q2name(query_id);
        if strcmp(params.mode,'B315')
            panoDirId = 1;
        else
            panoId = strsplit(trueName,'_'); 
            panoDirId = str2double(panoId{3})+1;
        end

        % query
        Iq = imread(fullfile(params.dataset.query.mainDir , qname));
        if resized
            Iq = imresize(Iq, params.dataset.query.dslevel);
        end
    %     figure();imshow(Iq)
    %     figure();imshow(fullfile(params.dataset.query.mainDir, spaceName, 'cutouts', string(panoDirId), trueName));

        % query mask
        if strcmp(params.dynamicMode, 'original') % staticky, dataset, takze masky neexistuju
            mask = zeros(size(Iq));
        else
            mask_name = fullfile(params.input.dir, "queries_masks", string(i) + ".png");
            mask = imread(mask_name);
        end
        if resized
            imresize(mask, params.dataset.query.dslevel, 'nearest');
        end
    %     figure();imshow(mask)
    %     figure();imshow([rgb2gray(Iq) mask]);

        % query pose
        pose_path = fullfile(params.dataset.query.mainDir,spaceName,'poses',string(panoDirId),sprintf('%s.%s',trueName,'mat'));
        ref_pose = load(pose_path);

        meshPath = fullfile(params.dataset.models.dir, spaceName, 'model.obj');
        if strcmp(mode, 'B315')
            meshPath = fullfile(params.dataset.models.dir, 'b315', 'model.obj');
        end
        fl = params.camera.fl;
        if resized
            fl = fl * params.dataset.query.dslevel;
        end

        sensorSize = [size(Iq,2), size(Iq,1)];

        % fixed 
    %     new_pose.C = ref_pose.position';
        rFix = [0., 180., 180.];
        Rfix = rotationMatrix(deg2rad(rFix), 'XYZ');
        new_pose.R =Rfix*ref_pose.R';

        query = struct();
        query.true_name = trueName;
        query.query_img = Iq;
        query.mask = mask;
        query.qname = qname;
        query.R = new_pose.R';
        query.C = ref_pose.position';

        parfor j = 1 : total_n

            if j == 1
                t_max = 0;
                th_max = 0;
            elseif j <= close_n
                t_max = t_max_close;
                th_max = th_max_close; 
            else
                t_max = t_max_far;
                th_max = th_max_far;
            end

            % random translation
            v2 =  rand(3,1);
            v2 = v2 / norm(v2);
            t = v2 * rand(1) * t_max;

            % random rotation
            v = rand(3,1);
            v = v / norm(v);
            th = rand(1) * th_max / 180 * pi;
            x_ = @(v) [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
            R = (1-cos(th)) * v*v' + cos(th) * eye(3) + sin(th) * x_(v);
            
            if j == 1
                rot = new_pose.R';
                trans = ref_pose.position';              
            else
                rot = R*new_pose.R';
                trans = ref_pose.position' + t;
            end

            error_rotation = rotationDistance(new_pose.R', rot);
            error_translation = norm(ref_pose.position' - trans);

            synth = struct();
            synth.R = rot;
            synth.C = trans;
            synth.error_rotation = error_rotation;
            if j == 1
                synth.error_rotation = 0;
            end
            synth.error_translation = error_translation;
            synth.added_translation = t;
            synth.added_rotation.angle = th;
            synth.added_rotation.axis = v;
            synth.added_rotation.R = R;

            [RGBpersp, XYZpersp, depth] = projectMesh(meshPath, fl, rot, trans, sensorSize, false, -1, params.input.projectMesh_py_path, -1);
            synth.synth_img = RGBpersp;
    %     figure();
    %     imshow(RGBpersp);
    %     figure();
    %     imshow(Iq);
    %     figure();
    %     imshow(mask);
        output_synth_file = fullfile(output_dir, ['synth',num2str(j),'.mat']);
        parsavesynth(output_synth_file, synth)
        end
        save(output_file, 'query');
    end
end

function parsavesynth(path, synth)
  save(path, 'synth')
end