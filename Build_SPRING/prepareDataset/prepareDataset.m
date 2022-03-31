%% set paths
space_name = "hospital_1";

input_path = "/local1/homes/dubenma1/data/inloc_dataset/habitat + matlab dataset/hospital_1";
output_path = "/local1/homes/dubenma1/data/inloc_dataset/before_splitting_queries";
output_path = fullfile(output_path, space_name);


cutouts_in_path = fullfile(input_path, "cutouts");

if not(isfolder(output_path))
    mkdir(output_path)
end
%% copy files, move them with correct structure
copyFiles

%% create mat file with poses
buildPosesFiles