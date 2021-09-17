for datasetSize=1:4

cutout_imgnames_all = dir("/home/seberma3/InLocCIIRC_NEWdataset/cutouts"+datasetSize+"/*/*/cut*.jpg");
siz = size(cutout_imgnames_all);
temp = cell(siz);

for i=1:siz 
    fullpath =  cutout_imgnames_all(i).folder + "/" + cutout_imgnames_all(i).name;
    temp{i} = fullpath;
end
cutout_imgnames_all = temp;
savepath = "/home/seberma3/_InLoc_PROD/SPRING_Demo/inputs/cutout_imgnames_all"+datasetSize+".mat";
save(savepath, 'cutout_imgnames_all');

end