%% set paths
input_path = "/local1/homes/dubenma1/data/inloc_dataset/habitat + matlab dataset/livinglab_2/-120:30:-60";
output_path = "/local1/homes/dubenma1/data/inloc_dataset/before_splitting_queries";

space_name = "livinglab_2";

cutouts_in_path = fullfile(input_path, "cutouts_habitat");
%% copy files, move them with correct structure
copyFiles

%% create mat file with poses
buildPosesFiles