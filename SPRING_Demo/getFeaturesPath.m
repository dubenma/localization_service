function [absFeatPath] = getFeaturesPath(absCutoutPath, params)

dbfname_parts = strsplit(absCutoutPath, "/");
cutout_name = dbfname_parts{numel(dbfname_parts)};
cutout_dirname = dbfname_parts{numel(dbfname_parts)-2};
cutout_subdirname = dbfname_parts{numel(dbfname_parts)-1};

absFeatPath = fullfile(params.input.feature.dir, cutout_dirname, cutout_subdirname, ""+ cutout_name + params.input.feature.db_matformat);
% fprintf("QNAME: %s \n", cutout_name);
% fprintf("ABS: %s \n", absCutoutPath);
% fprintf("TESTFIL: exist: %d, path: %s \n", exist(absFeatPath), absFeatPath);

end

