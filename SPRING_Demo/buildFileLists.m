function [ status ] = buildFileLists(params)
%% query
if numel(params.dataset.query.dir) == 1
    paths{1} = params.dataset.query.dir{1};
else
    paths = params.dataset.query.dir;
end
query_imgnames_all = {};
for p = 1:numel(paths)
    files = dir(fullfile(paths{p}, '*.jpg'));
    nFiles = size(files,1);
    
    for i=1:nFiles
        query_imgnames_all{end+1} = sprintf('%s/%s/%s',params.dataset.query.space_names{p},'query_all',files(i).name);
    end 
end
if ~exist(fileparts(params.input.qlist.path), 'dir')
    mkdir(fileparts(params.input.qlist.path))
end
save(params.input.qlist.path, 'query_imgnames_all');

%% query masks

for i = 1 : length(params.dataset.query.space_names)
    masks_dir = fullfile(params.input.dir, "queries_masks", params.dataset.query.space_names{i});
    if not(isfolder(masks_dir))
        mkdir(masks_dir)
    end
end

for i = 1 : length(query_imgnames_all)
    qname = query_imgnames_all{i};
    spaceName = strsplit(qname,'/'); spaceName = spaceName{1};
    [~,space_id,~] = fileparts(qname); space_id = str2num(space_id); % space_id is the query id
    run(fullfile(params.dataset.dir,'metadata', spaceName,'query_mapping.m'));
    trueName = q2name(space_id);
    [~, name, ~] = fileparts(trueName);
    trueName = name + ".png";
    
    panoId = strsplit(trueName,'_'); 
    panoDirId = str2double(panoId{3})+1;
    mask_path = fullfile(params.dataset.query.mainDir, spaceName, "masks_dynamic", string(panoDirId), trueName);
    
    copyfile(mask_path, fullfile(params.input.dir, "queries_masks", spaceName, string(i) + ".png"));
    
end

%% cutouts
if numel(params.dataset.db.cutouts.dir) == 1
    paths{1} = params.dataset.db.cutouts.dir;
else
    paths = params.dataset.db.cutouts.dir;
end
cutout_imgnames_all = {};
for p = 1:numel(paths)
    files = dir(string(fullfile(paths{p}, '**/cutout*.jpg')));
    nFiles = size(files,1);
    for i=1:nFiles
        relativePath = extractAfter(files(i).folder, strlength(string(paths{p}))+1);
        cutout_imgnames_all{end+1} = sprintf('%s/%s/%s',params.dataset.db.space_names{p},relativePath,files(i).name);
%         cutout_imgnames_all{end+1} = fullfile(relativePath, files(i).name);
    end
end

save(params.input.dblist.path, 'cutout_imgnames_all');


end