load("TEST_get_tcs_params_light.mat");
result = get_tcs_cublas(desc1, desc2);
disp(size(result));