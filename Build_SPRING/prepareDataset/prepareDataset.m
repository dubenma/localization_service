%% select space
space_name = "livinglab"; % hospital, livinglab
%% set paths
if space_name == "hospital"
    input_path = "/local1/homes/dubenma1/data/inloc_dataset/habitat + matlab dataset/hospital_1";
    output_path = "/local1/homes/dubenma1/data/inloc_dataset/before_splitting_queries";
    n_cutouts = 115;
    habitat_dir_name = "semantic_h";
elseif space_name == "livinglab"
    input_path = "/local1/homes/dubenma1/data/inloc_dataset/habitat + matlab dataset/livinglab_2/-120:30:-60/";
    output_path = "/local1/homes/dubenma1/data/inloc_dataset/before_splitting_queries";
    n_cutouts = 35;
    habitat_dir_name = "semantic_l";
end
% output_path = fullfile(output_path, space_name);

if not(isfolder(output_path))
    mkdir(output_path)
end
%% copy files, move them with correct structure
copyFiles

%% create mat file with poses
buildPosesFiles