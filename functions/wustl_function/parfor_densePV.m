function parfor_densePV(qname, dbCutoutname, dbnamesId, Ps, params)
if iscell(dbCutoutname) && numel(dbCutoutname) == 1
   dbCutoutname = dbCutoutname{1}; % It should be string. Not cell!
end

[~,QFname,~] = fileparts(qname);
[~,DBFname,~] = fileparts(dbCutoutname);
mkdirIfNonExistent(fullfile(params.output.synth.dir, QFname));
this_densePV_matname = fullfile(params.output.synth.dir, QFname, sprintf('%s%s', DBFname, params.output.synth.matformat));

sequenceLength = length(Ps);
Iqs = cell(1,sequenceLength);
RGBpersps = cell(1,sequenceLength);
RGB_flags = cell(1,sequenceLength);
scores = cell(1,sequenceLength);
errmaps = cell(1,sequenceLength);
firstQueryId = queryNameToQueryId(qname) - sequenceLength + 1;

%if 1==1 %exist(this_densePV_matname, 'file') ~= 2
    sequentialPV = isfield(params, 'sequence') && strcmp(params.sequence.processing.mode, 'sequentialPV');
    firstDbname = dbCutoutname{1};
    for i=1:sequenceLength

        if sequentialPV
            dbname = firstDbname;
        else
            dbname = dbCutoutname{i};
        end

        P = Ps{i};
        if all(~isnan(P(:)))

            %load downsampled images
            %thisQueryName = getFileNameFromPath(qname); %sprintf('%d.jpg', firstQueryId + i - 1);
            %Iq = imresize(imread(fullfile(params.dataset.query.dir, thisQueryName)), params.dataset.query.dslevel);
            %Iq = imresize(imread(fullfile('/home/seberma3/InLocCIIRC_dataset/query', thisQueryName)), params.dataset.query.dslevel);
            Iq = imresize(imread(qname), params.dataset.query.dslevel);
            fl = params.camera.fl * params.dataset.query.dslevel;
            R = P(1:3,1:3);
            t = P(1:3,4);

            spaceName = strsplit(dbname, '/');
            %spaceName = spaceName{1};
            spaceName = spaceName{6};
            % meshPath = fullfile(params.dataset.models.dir, spaceName, 'mesh_rotated.obj');
            meshPath = fullfile(params.dataset.models.dir, spaceName, 'mesh_rotated.obj');
            t = -inv(R)*t;
            rFix = [180.0, 0.0, 0.0];
            Rfix = rotationMatrix(deg2rad(rFix), 'XYZ');
            sensorSize = [size(Iq,2), size(Iq,1)];
            headless = ~strcmp(environment(), 'laptop');
            [RGBpersp, XYZpersp, depth] = projectMesh(meshPath, fl, inv(R)*Rfix, t, sensorSize, false, -1, params.input.projectMesh_py_path, headless);
            RGB_flag = all(~isnan(XYZpersp), 3);

            %compute DSIFT error
            if any(RGB_flag(:))
                %normalization
                Iq_norm = image_normalization( double(rgb2gray(Iq)), RGB_flag );
                I_synth = double(rgb2gray(RGBpersp));
                I_synth(~RGB_flag) = nan;
                I_synth = image_normalization( inpaint_nans(I_synth), RGB_flag );

                %compute DSIFT
                [fq, dq] = vl_phow(im2single(Iq_norm),'sizes',8,'step',4);
                [fsynth, dsynth] = vl_phow(im2single(I_synth),'sizes',8,'step',4);
                f_linind = sub2ind(size(I_synth), fsynth(2, :), fsynth(1, :));
                iseval = RGB_flag(f_linind);
                dq = relja_rootsift(single(dq)); dsynth = relja_rootsift(single(dsynth));

                %error
                err = sqrt(sum((dq(:, iseval) - dsynth(:, iseval)).^2, 1));
                score = quantile(err, 0.5)^-1;
                errmap = nan(size(I_synth));errmap(f_linind(iseval)) = err;
                xuni = sort(unique(fsynth(1, :)), 'ascend');yuni = sort(unique(fsynth(2, :)), 'ascend');
                errmap = errmap(yuni, xuni);

    %             %debug
    %             figure();set(gcf, 'Position', [0 0 1000, 300]);
    %             ultimateSubplot( 3, 1, 1, 1, 0.01, 0.05 );
    %             imshow(Iq);
    %             ultimateSubplot( 3, 1, 2, 1, 0.01, 0.05 );
    %             imshow(RGBpersp);
    %             ultimateSubplot( 3, 1, 3, 1, 0.01, 0.05 );
    %             imagesc(errmap);colormap('jet');axis image off;
    %             keyboard;

            else
                score = single(0);
                errmap = [];
            end
        else
            Iq = [];
            RGBpersp = [];
            RGB_flag = [];
            score = single(0);
            errmap = 0;
            disp("I AM SORRY - projectMesh Skipped");
        end
        Iqs{i} = Iq;
        RGBpersps{i} = RGBpersp;
        RGB_flags{i} = RGB_flag;
        scores{i} = score;
        errmaps{i} = errmap;
    end
    
%     if exist(fullfile(params.output.synth.dir, qname), 'dir') ~= 7
%         mkdir(fullfile(params.output.synth.dir, qname));
%     end
    save(this_densePV_matname, 'Iqs', 'RGBpersps', 'RGB_flags', 'scores', 'errmaps');
%end


end