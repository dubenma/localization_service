function save_imglist_as_images(imgs, directory)
mkdirIfNonExistent(directory);
disp(imgs);
for i=1:numel(imgs.topNname)
    imgPath = imgs.topNname{i}(1);
    imgData = imread(imgPath);
    [xdir, xfname, xext] = fileparts(imgPath);
    savepath = fullfile(directory, "sel_"+i+"_"+xfname+xext);
    imwrite(imgData, savepath);
    %imsave(fullfile(directory, "sel"+i+imgs.topNname(i)) );
end







end

