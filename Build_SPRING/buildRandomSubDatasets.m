function buildRandomSubDatasets()
subdatasets_number = 3;
reduction_const = 2;
source_dataset_imgnames = load('/home/seberma3/_InLoc_PROD/SPRING_Demo/inputs/cutout_imgnames_all4.mat');
source_dataset_imgnames = source_dataset_imgnames.cutout_imgnames_all;
source_dataset_feature_matrix = load('/home/seberma3/_InLoc_PROD/SPRING_Demo/inputs/features/computed_featuresSize4.mat');
source_dataset_feature_matrix = source_dataset_feature_matrix.cutoutFeatures;
num_imgs_in_orig_dataset = numel(source_dataset_imgnames);
num_imgs_in_this_dataset = num_imgs_in_orig_dataset;
subdataset_index = 3;
for i=1:subdatasets_number
    reduction_const = 1; %%%
    num_imgs_in_this_dataset = 2000; %%%%round(num_imgs_in_this_dataset / reduction_const);
    selected_indices = randperm(num_imgs_in_this_dataset, num_imgs_in_this_dataset);
    
    smaller_features_matrix = source_dataset_feature_matrix(:, selected_indices);
    smaller_imgnames_subset = source_dataset_imgnames(selected_indices);
    
    cutout_imgnames_all = smaller_imgnames_subset;
    cutoutFeatures = smaller_features_matrix;
    
    subdataset_index = "4";
    save("/home/seberma3/_InLoc_PROD_Speedup/SPRING_Demo/inputs/cutout_imgnames_all"+subdataset_index+".mat", 'cutout_imgnames_all');
    save("/home/seberma3/_InLoc_PROD_Speedup/SPRING_Demo/inputs/features/computed_featuresSize"+subdataset_index+".mat", 'cutoutFeatures');
    break; %%%
    
    subdataset_index = subdataset_index -1;
end