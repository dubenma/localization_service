function create_subdatasets(sizes)
% Velikosti pro detailni mereni: [261, 391, 522, 783, 1044, 1305, 1566, 1827, 2088]
    allDbsNames = load("SPRING_Demo/inputs/ALL_RGBDsNames.mat"); allDbsNames = allDbsNames.cutout_imgnames_all;
    allDbsFeats = load("SPRING_Demo/inputs/features/ALL_RGBDsFeats.mat"); allDbsFeats = allDbsFeats.cutoutFeatures;
    sizes = sort(sizes, 'desc');
    siz_idx = numel(sizes);
    
    cutout_imgnames_all = allDbsNames;
    cutoutFeatures = allDbsFeats;
    for siz=sizes
        num = numel(cutout_imgnames_all);
        rand_idxs = randperm(num, siz);
        cutout_imgnames_all = cutout_imgnames_all(rand_idxs);
        cutoutFeatures = cutoutFeatures(:, rand_idxs);
        
        save("SPRING_Demo/inputs/cutout_imgnames_all" + siz_idx + ".mat", 'cutout_imgnames_all');
        save("SPRING_Demo/inputs/features/computed_featuresSize" + siz_idx + ".mat", 'cutoutFeatures');
        siz_idx = siz_idx - 1;
    end
end

