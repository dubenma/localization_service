function parfor_denseGV( cnnq, qname, dbnames, params )
coarselayerlevel = 5;
finelayerlevel = 3;

%%%this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, buildCutoutName(dbname, params.output.gv_dense.matformat));
%%this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, "GVtop100.mat");

% disp("PGV step1");
if 1==1
    %disp("OVERIT TOTO");
    %disp(this_densegv_matname);
    %if exist(this_densegv_matname, 'file') ~= 2
    num_dbimgs = numel(dbnames);
    cnndbs = cell(1, num_dbimgs);
%     disp("PGV step2");
    %load input feature
    for i=1:num_dbimgs
        disp("PARTS");
%         disp(params.input.feature.dir);
%         disp(params.dataset.db.cutout.dirname);
%         disp(dbnames{i});
%         disp(params.input.feature.db_matformat);
%         dbfname = fullfile(params.input.feature.dir, params.dataset.db.cutout.dirname, [dbnames{i}, params.input.feature.db_matformat]);
        dbfname = "" + dbnames{i} + params.input.feature.db_matformat;
        disp(dbfname);
        cnndb = load(dbfname, 'cnn');cnndb = cnndb.cnn;
        cnndbs{i} = cnndb;
    end
%     disp("PGV step3");
    %coarse-to-fine matching
    cnnfeat1size = size(cnnq{finelayerlevel}.x);
    [match12,f1,f2,cnnfeat1,cnnfeat2] = at_coarse2fine_matching(cnnq,cnndbs,coarselayerlevel,finelayerlevel);
%     disp("PGV step4");
    for i=1:numel(f2)
        cnnfeat2size = size(cnndbs{i}{finelayerlevel}.x);
        this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, buildCutoutName(dbnames{i}, params.output.gv_dense.matformat));
        [inls12] = at_denseransac(f1,f2{i},match12{i},2);
%         disp("PGV step5");
        % TODO: possible race condition?
        % this function is executed in parfor in ht_top100_densePE_localization and all the workers are working on the same query
        % if that happens, though, mkdir is noop but it shows an error.
        if exist(fullfile(params.output.gv_dense.dir, qname), 'dir') ~= 7
            mkdir(fullfile(params.output.gv_dense.dir, qname));
        end
        save_dense_gv_results(this_densegv_matname, cnnfeat1size, cnnfeat2size, f1, f2{i}, inls12, match12{i})
        %save('-v6', this_densegv_matname, 'cnnfeat1size', 'cnnfeat2size', 'f1', 'f2', 'inls12', 'match12');
    end
    
    %     %debug
    %     im1 = imresize(imread(fullfile(params.dataset.query.dir, qname)), cnnfeat1size(1:2));
    %     im2 = imresize(imread(fullfile(params.dataset.db.cutouts.dir, dbname)), cnnfeat2size(1:2));
    %     figure();
    %     ultimateSubplot ( 2, 1, 1, 1, 0.01, 0.05 );
    %     imshow(rgb2gray(im1));hold on;
    %     plot(f1(1,match12(1,:)),f1(2,match12(1,:)),'b.');
    %     plot(f1(1,inls12(1,:)),f1(2,inls12(1,:)),'g.');
    %     ultimateSubplot ( 2, 1, 2, 1, 0.01, 0.05 );
    %     imshow(rgb2gray(im2));hold on;
    %     plot(f2(1,match12(2,:)),f2(2,match12(2,:)),'b.');
    %     plot(f2(1,inls12(2,:)),f2(2,inls12(2,:)),'g.');
    %     keyboard;
end

end

