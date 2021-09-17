function parfor_denseGV( cnnq, qname, dbname, params )
coarselayerlevel = 5;
finelayerlevel = 3;

this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, buildCutoutName(dbname, params.output.gv_dense.matformat));


if 1==1
%disp("OVERIT TOTO");
%disp(this_densegv_matname);
%if exist(this_densegv_matname, 'file') ~= 2
    
    %load input feature
    dbfname = fullfile(params.input.feature.dir, params.dataset.db.cutout.dirname, [dbname, params.input.feature.db_matformat]);
    cnndb = load(dbfname, 'cnn');cnndb = cnndb.cnn;
    disp("Kfas 1")
    %coarse-to-fine matching
    cnnfeat1size = size(cnnq{finelayerlevel}.x);
    cnnfeat2size = size(cnndb{finelayerlevel}.x);
    [match12,f1,f2,cnnfeat1,cnnfeat2] = ZALOHA_at_coarse2fine_matching(cnnq,cnndb,coarselayerlevel,finelayerlevel);
    [inls12] = at_denseransac(f1,f2,match12,2);
    disp("Kfas 2")
    % TODO: possible race condition?
    % this function is executed in parfor in ht_top100_densePE_localization and all the workers are working on the same query
    % if that happens, though, mkdir is noop but it shows an error.
    if exist(fullfile(params.output.gv_dense.dir, qname), 'dir') ~= 7
        mkdir(fullfile(params.output.gv_dense.dir, qname));
    end
    disp("Kfas 3")
    save('-v6', this_densegv_matname, 'cnnfeat1size', 'cnnfeat2size', 'f1', 'f2', 'inls12', 'match12');
    
    
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

