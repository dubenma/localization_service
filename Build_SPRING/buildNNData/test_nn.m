
name = 'livinglab/1/cutout_pano_0_-120_60.jpg';
spaceName = 'livinglab';

pose_path = fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Maps/Broca_dataset_dynamic_2/poses',[name '.mat']);
ref_pose = load(pose_path);

iq = imread(fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Maps/Broca_dataset_dynamic_2/cutouts_dynamic', name));
Iq = imresize(iq, params.dataset.query.dslevel);
mask = imread(fullfile('/local1/homes/dubenma1/data/localization_service_dataset/Maps/Broca_dataset_dynamic_2/masks_dynamic/', [name(1:end-4), '.png']));
mask = imresize(mask, params.dataset.query.dslevel, 'nearest');

meshPath = fullfile(params.dataset.models.dir, spaceName, 'model.obj');
fl = params.camera.fl * params.dataset.query.dslevel;

sensorSize = [size(Iq,2), size(Iq,1)];

% pain s rotaciami

rot = ref_pose.R;
trans = ref_pose.position;

new_pose.C = ref_pose.position';
rFix = [0., 180., 180.];
Rfix = rotationMatrix(deg2rad(rFix), 'XYZ');
new_pose.R =Rfix*ref_pose.R';

rot = new_pose.R';
trans = ref_pose.position';

[RGBpersp, XYZpersp, depth] = projectMesh(meshPath, fl, rot, trans, sensorSize, false, -1, params.input.projectMesh_py_path, -1);

figure();
imshow(RGBpersp);
figure();
imshow(Iq);
figure();
imshow(mask);
