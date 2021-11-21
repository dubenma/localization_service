function durations = TEST_MEX_FILES_PERFORMANCE(dim1, dim2, descs)
%TEST_MEX_FILES_PERFORMANCE Summary of this function goes here
%   Detailed explanation goes here

sfilename = "impl_durations"+dim1+"_"+dim2+"_"+descs+".mat"
addpath("/home/seberma3/_InLoc_PROD_Speedup/functions/yael_matlab_linux64_v438");

% dims_for_tasks = [100  200  500  1000  1500  2500  4000  7500
%                    10   20   30    60    90   150   300   500];
%
% descs_num = [1    3    10    20    50    75   100];

dims_for_tasks = [dim1; dim2];

descs_num = [descs];

% Dim 1 = 4, pro 4 ruzne implementace (puvodni matlab, mkl, eigen, cublas)
% Dim 2 ... pro kazdou preddefinovanou velikost matic s deskriptory
% Dim 3 ... pro kazde definovane mnozstvi poctu deskriptoru
rounds = 200;

durations = zeros(4, rounds);


for r=1:rounds
    disp("Zacina round " + r);
    desc_query = single(rand(dims_for_tasks(1), dims_for_tasks(2)));
    desc_dbs = get_random_cell(descs_num, dims_for_tasks(1), dims_for_tasks(2));
    
    tic;
    if descs == 1
        res = at_dense_tc(desc_query, desc_dbs{1});
    else
        res = at_dense_tc_many(desc_query, desc_dbs);
    end
    
    dur_matlab = toc;
    durations(1, r) = durations(1, r) + dur_matlab;
    fprintf("-");
    tic;
    res = get_tcs_mkl(desc_query, desc_dbs);
    dur_mkl = toc;
    durations(2, r) = durations(2, r) + dur_mkl;
    
    fprintf("-");
    tic;
    res = get_tcs_eig(desc_query, desc_dbs);
    dur_eig = toc;
    durations(3, r) = durations(3, r) + dur_eig;
    
    fprintf("-");
    tic;
    res = get_tcs_cublas(desc_query, desc_dbs);
    dur_cublas = toc;
    durations(4, r) = durations(4, r) + dur_cublas;
    
    fprintf("\nTrvani %d*(%dx%d): %d\t%d\t%d\t%d \n", ...
        descs_num, dims_for_tasks(1), dims_for_tasks(2),1000*dur_matlab, 1000*dur_mkl, 1000*dur_eig, 1000*dur_cublas);
end

% for task=1:size(dims_for_tasks, 2)
%     for round=1:rounds
%         for cs =1:numel(descs_num)
%             fprintf(".");
%           desc_query = single(rand(dims_for_tasks(1, task), dims_for_tasks(2, task)));
%           desc_dbs = get_random_cell(descs_num(cs), dims_for_tasks(1, task), dims_for_tasks(2, task));
%
%
%           dur_matlab = 0;
%           tic;
%           res = at_dense_tc_many(desc_query, desc_dbs);
%           dur_matlab = toc;
%           durations(1, task, cs) = durations(1, task, cs) + dur_matlab;
%           fprintf("-");
%           tic;
%           res = get_tcs_mkl(desc_query, desc_dbs);
%           dur_mkl = toc;
%           durations(2, task, cs) = durations(2, task, cs) + dur_mkl;
%
%           fprintf("-");
%           tic;
%           res = get_tcs_eig(desc_query, desc_dbs);
%           dur_eig = toc;
%           durations(3, task, cs) = durations(3, task, cs) + dur_eig;
%
%           fprintf("-");
%           tic;
%           res = get_tcs_cublas(desc_query, desc_dbs);
%           dur_cublas = toc;
%           durations(4, task, cs) = durations(4, task, cs) + dur_cublas;
%
%           fprintf("\nTrvani %d*(%dx%d): %d\t%d\t%d\t%d \n", ...
%             descs_num(cs), dims_for_tasks(1, task), dims_for_tasks(2, task),1000*dur_matlab, 1000*dur_mkl, 1000*dur_eig, 1000*dur_cublas);
%         end
%     end
% end


% durations = durations / rounds;
save(sfilename, 'durations');

end

function rand_cell = get_random_cell(matrices_num, dim1, dim2)
rand_cell = cell(1, matrices_num);

for i=1:matrices_num
    rand_cell{i} = single(rand(dim1, dim2));
end
end