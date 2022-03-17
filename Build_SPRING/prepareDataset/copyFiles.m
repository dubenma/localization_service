% output_path = "~/dubenma1/data/Inloc dataset/Maps/SPRING/Broca_dataset2";
% input_path = "~/dubenma1/data/Inloc dataset/Maps/SPRING/Broca_dataset2/Broca Living Lab without Curtains/all";
% space_name = "livinglab_2";

%% cutouts
cutouts_out_path = fullfile(output_path, "cutouts");

if not(isfolder(cutouts_out_path))
    mkdir(cutouts_out_path)
end

for i = 0 : 35
    path = fullfile(cutouts_out_path, space_name, string(i+1));
    if not(isfolder(path))
        mkdir(path)
    end
    
    copyfile(fullfile(cutouts_in_path, "cutout_pano_" + string(i) + "_*.jpg"), path)
end
    


%% matfiles
matfiles_out_path = fullfile(output_path, "matfiles");
matfiles_in_path = fullfile(input_path, "semantic_l", "depth");

if not(isfolder(matfiles_out_path))
    mkdir(matfiles_out_path)
end

for i = 0 : 35
    path = fullfile(matfiles_out_path, space_name, string(i+1));
    if not(isfolder(path))
        mkdir(path)
    end
    
    copyfile(fullfile(matfiles_in_path, "cutout_pano_" + string(i) + "_*.jpg.mat"), path)
end

%% meshes
meshes_out_path = fullfile(output_path, "meshes");
meshes_in_path = fullfile(input_path, "semantic_l", "rgbs");

if not(isfolder(meshes_out_path))
    mkdir(meshes_out_path)
end

for i = 0 : 35
    path = fullfile(meshes_out_path, space_name, string(i+1));
    if not(isfolder(path))
        mkdir(path)
    end
    
    copyfile(fullfile(meshes_in_path, "cutout_pano_" + string(i) + "_*.jpg"), path)
end

