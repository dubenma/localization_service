function [newmatch_all, feat1fine, feat2fines, cnnfeat1fine, cnnfeat2fine] = ...
    at_coarse2fine_matching(cnn1,cnn2,coarselayerlevel,finelayerlevel)

num_imgdbs = numel(cnn2);
% disp("num_imgdbs:")
% disp(num_imgdbs);

cnnfeat1 = cnn1{coarselayerlevel}.x;
cnnfeat2 = cell(1, num_imgdbs);
for i=1:num_imgdbs
%     disp(cnn2);
%     disp(cnn2{i});
%     disp(cnn2{i}{coarselayerlevel});
    cnnfeat2{i} = cnn2{i}{coarselayerlevel}.x;
end

cnnfeat1fine = cnn1{finelayerlevel}.x;
cnnfeat2fine = cell(1, num_imgdbs);
for i=1:num_imgdbs
    cnnfeat2fine{i} = cnn2{i}{finelayerlevel}.x;
end
%cnnfeat2fine = cnn2{finelayerlevel}.x;

cnnfinesize1 = size(cnnfeat1fine(:,:,1));
%cnnfinesize2 = size(cnnfeat2fine(:,:,1));
cnnfinesize2 = cell(1, num_imgdbs);
for i=1:num_imgdbs
    cnnfinesize2{i} = size(cnnfeat2fine{i}(:,:,1));
end

[desc1, feat1] = at_cnnfeat2vlfeat(cnnfeat1);
descs2 = cell(1, num_imgdbs);
feats2 = cell(1, num_imgdbs);
for i=1:num_imgdbs
    [xdesc2, xfeat2] = at_cnnfeat2vlfeat(cnnfeat2{i});
    descs2{i} = xdesc2;
    feats2{i} = xfeat2;
end

[desc1fine, feat1fine] = at_cnnfeat2vlfeat(cnnfeat1fine);
desc2fines = cell(1, num_imgdbs);
feat2fines = cell(1, num_imgdbs);
for i=1:num_imgdbs
    [xdesc2fine, xfeat2fine] = at_cnnfeat2vlfeat(cnnfeat2fine{i});
    desc2fines{i} = xdesc2fine;
    feat2fines{i} = xfeat2fine;
end

% desc1 = single(rand(AA, AB));
% desc2 = single(rand(AA, AB));

% tic;
% match12OBS = cell(1,num_imgdbs);
% for i=1:num_imgdbs
%     match12OBS{i} = at_dense_tc(desc1,descs2{i});
% end
% toc

% savepath = "../get_tcs_tests/GTCS_VS_ADT"+datestr(now(), 'yy_mm_dd_hh_MM')+".mat";
% save(savepath, 'desc1', 'descs2');
match12 = get_tcs_mkl(desc1,descs2);
% newmatch_all = []; feat1fine = []; feat2fines = []; cnnfeat1fine = []; cnnfeat2fine = [];
% return;

% for i=1:num_imgdbs
%    if size(match12OBS{i}, 2) ~= size(match12{i}, 2)
%       disp("Odchykla v kodu!"); 
%    end
% end

% fine level position is
%save("TESTUSKA.mat", "match12", "match12NEW");


newmatch_all = cell(1, num_imgdbs);
for i=1:num_imgdbs
    [hash_table1, hash_coarse1] = at_dense_hashtable(cnnfeat1,cnnfeat1fine);
    [hash_table2, hash_coarse2] = at_dense_hashtable(cnnfeat2{i},cnnfeat2fine{i});
    
    newmatch = cell(1,size(match12{i},2));
    for ii=1:size(match12{i},2)
        [d1,f1,ind1] = at_retrieve_fineposition(hash_coarse1,hash_table1,feat1(:,match12{i}(1,ii)),desc1fine,feat1fine,cnnfinesize1);
        [d2,f2,ind2] = at_retrieve_fineposition(hash_coarse2,hash_table2,feats2{i}(:,match12{i}(2,ii)),desc2fines{i},feat2fines{i},cnnfinesize2{i});
%         tic;
%           thismatch12OBS = at_dense_tc(d1,d2);
%         toc        
        thismatch12 = get_tcs_mkl(d1,{d2});
%         disp("DEBUG msg 2");
%         save("KontrolaNavratu.mat", 'thismatch12');
%         disp("DEBUG msg 3");
%         disp(thismatch12);
%         if size(thismatch12OBS, 2) ~= size(thismatch12{1}, 2)
%             disp("Odchykla v kodu!"); 
%         end        
        newmatch{ii} = [ind1(thismatch12{1}(1,:)); ind2(thismatch12{1}(2,:))];        
    end
    %disp("SM2");
    %disp(size(match12,2));
    newmatch = [newmatch{:}];
    newmatch_all{i} = newmatch;
end

% %--- compute similarity (matching NN score)
% % [match12,inls12] = at_denseransac(desc1,f1,desc2,f2);
%

function [d1,f1,ind1] = at_retrieve_fineposition(hash_coarse1,hash_table1,feat1,desc1fine,feat1fine,sizeF)

x = feat1(2,:);
y = feat1(1,:);

xmin = max(1,x-1);
%xmin = max(1,x);
xmax = min(size(hash_coarse1,1),x+1);
ymin = max(1,y-1);
%ymin = max(1,y);
ymax = min(size(hash_coarse1,2),y+1);

[x_nb,y_nb] = meshgrid(xmin:xmax,ymin:ymax);
x_nb = x_nb(:); y_nb = y_nb(:);

pos1 = hash_coarse1(x_nb,y_nb);
sub1 = [hash_table1{pos1}];
ind1 = sub2ind(sizeF,sub1(2,:),sub1(1,:));

d1 = desc1fine(:,ind1);
f1 = feat1fine(:,ind1);
