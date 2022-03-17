% input_path = "/home/ciirc/dubenma1/data/Inloc dataset/Maps/SPRING/Broca_dataset2/Broca Living Lab without Curtains/all/cutouts_matlab/poses.csv";
% output_path = "~/dubenma1/data/Inloc dataset/Maps/SPRING/Broca_dataset2";

poses_file_path = fullfile(cutouts_in_path, "poses.csv");
poses_path = fullfile(output_path, "poses");

table = readtable(poses_file_path);

if not(isfolder(poses_path))
        mkdir(poses_path)
end
    
for i = 1 : size(table,1)
    cutout_name = string(table2cell(table(i,1)));
    
    tmp = split(cutout_name, "_");
    pano_id = str2double(tmp(3));
    
    path = fullfile(poses_path, space_name, string(pano_id + 1));
    if not(isfolder(path))
        mkdir(path)
    end
    
    poses = table2array(table(i,2:end));
    position = poses(1:3);
    q = poses(4:end);
    R = q2r(q);
    
    
    save(fullfile(path, cutout_name + ".mat"),'position','R')
end






