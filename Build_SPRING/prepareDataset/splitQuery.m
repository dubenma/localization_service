input_dir = "/local1/homes/dubenma1/data/inloc_dataset/before_splitting_queries/hospital_1";
new_dataset_dir = "/local1/homes/dubenma1/data/inloc_dataset/Broca_dataset";

space_name = "hospital_1";
query_ids = [8,10,14,27,40,43,46,51,56,91,101,103];

% query_all - 1-?.jpg
%% copy all database and query data
copyfile(input_dir, new_dataset_dir);

%% separate query data
queries_path = fullfile(new_dataset_dir, "queries");

if not(isfolder(queries_path))
    mkdir(queries_path)
end

for i = 1 : length(query_ids)
    % cutouts
    dir_name = "cutouts";
    inpath = fullfile(new_dataset_dir, dir_name, space_name, string(query_ids(i)));
    outpath = fullfile(new_dataset_dir, "queries", space_name, dir_name, string(query_ids(i)));
    if not(isfolder(outpath))
        mkdir(outpath)
    end
    movefile(inpath, outpath);
    
    % matfiles
    dir_name = "matfiles";
    inpath = fullfile(new_dataset_dir, dir_name, space_name, string(query_ids(i)));
    outpath = fullfile(new_dataset_dir, "queries", space_name, dir_name, string(query_ids(i)));
    if not(isfolder(outpath))
        mkdir(outpath)
    end
    movefile(inpath, outpath);
    
    % meshes
    dir_name = "meshes";
    inpath = fullfile(new_dataset_dir, dir_name, space_name, string(query_ids(i)));
    outpath = fullfile(new_dataset_dir, "queries", space_name, dir_name, string(query_ids(i)));
    if not(isfolder(outpath))
        mkdir(outpath)
    end
    movefile(inpath, outpath);
    
    % poses
    dir_name = "poses";
    inpath = fullfile(new_dataset_dir, dir_name, space_name, string(query_ids(i)));
    outpath = fullfile(new_dataset_dir, "queries", space_name, dir_name, string(query_ids(i)));
    if not(isfolder(outpath))
        mkdir(outpath)
    end
    movefile(inpath, outpath);
    
    % semantic
    dir_name = "semantic";
    inpath = fullfile(new_dataset_dir, dir_name, space_name, string(query_ids(i)));
    outpath = fullfile(new_dataset_dir, "queries", space_name, dir_name, string(query_ids(i)));
    if not(isfolder(outpath))
        mkdir(outpath)
    end
    movefile(inpath, outpath);
    
end

%% delete excessive query data




%% generate query_all

query_all_path = fullfile(new_dataset_dir, "queries", space_name, "query_all");
if not(isfolder(query_all_path))
        mkdir(query_all_path)
end
    
query_name = 1;
for i = 1 : length(query_ids)
   files = dir(fullfile(new_dataset_dir, "queries", space_name, "cutouts", string(query_ids(i))));
   for j = 3 : length(files)
       copyfile( fullfile(files(j).folder, files(j).name), fullfile(query_all_path, string(query_name) + ".jpg"));
       query_name = query_name + 1;
   end
end
