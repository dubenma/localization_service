function parfor_denseGV( cnnq, qname, dbnames, params )
coarselayerlevel = 5;
finelayerlevel = 3;

num_dbimgs = numel(dbnames);
cnndbs = cell(1, num_dbimgs);

for i=1:num_dbimgs
    %dbfname = "" + dbnames{i} + params.input.feature.db_matformat;
    %dbfname = fullfile(params.output.gv_dense.dir, qname, buildCutoutName(dbname, params.output.gv_dense.matformat));
    dbfname = getFeaturesPath(dbnames{i}, params);
    cnndb = load(dbfname, 'cnn');
    cnndb = cnndb.cnn;
    cnndbs{i} = cnndb;
end

cnnfeat1size = size(cnnq{finelayerlevel}.x);
[match12,f1,f2,cnnfeat1,cnnfeat2] = at_coarse2fine_matching(cnnq,cnndbs,coarselayerlevel,finelayerlevel);

% Zde by mohl byt parfor asi
parfor i=1:numel(f2)
    cnnfeat2size = size(cnndbs{i}{finelayerlevel}.x);
    %this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, buildCutoutName(dbnames{i}, params.output.gv_dense.matformat));
    [~,QFname,~] = fileparts(qname);
    [~,DBFname,~] = fileparts(dbnames{i});
    mkdirIfNonExistent(fullfile(params.output.gv_dense.dir, QFname));
    this_densegv_matname = fullfile(params.output.gv_dense.dir, QFname, ""+DBFname+params.output.gv_dense.matformat);
    
    [inls12] = at_denseransac(f1,f2{i},match12{i},2);
    %         disp("PGV step5");
    % TODO: possible race condition?
    % this function is executed in parfor in ht_top100_densePE_localization and all the workers are working on the same query
    % if that happens, though, mkdir is noop but it shows an error.
    if exist(fullfile(params.output.gv_dense.dir, qname), 'dir') ~= 7
        mkdir(fullfile(params.output.gv_dense.dir, qname));
    end
%     disp("SAVgv: " + this_densegv_matname);
    save_dense_gv_results(this_densegv_matname, cnnfeat1size, cnnfeat2size, f1, f2{i}, inls12, match12{i})
    %save('-v6', this_densegv_matname, 'cnnfeat1size', 'cnnfeat2size', 'f1', 'f2', 'inls12', 'match12');
end
end
