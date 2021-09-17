function save_dense_gv_results(this_densegv_matname,cnnfeat1size, cnnfeat2size, f1, f2, inls12, match12)

save('-v6', this_densegv_matname, 'cnnfeat1size', 'cnnfeat2size', 'f1', 'f2', 'inls12', 'match12');

end

