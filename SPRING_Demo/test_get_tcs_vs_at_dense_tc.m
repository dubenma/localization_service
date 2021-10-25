function [equal, num_errors] = test_get_tcs_vs_at_dense_tc()
    startup;
    descsLoc = "/home/seberma3/_InLoc_PROD_Speedup/get_tcs_tests/";
    imgsDescs = dir(descsLoc+"*.mat");
    equal = true;
    num_errors = 0;
    
    % Jak moc se liší tentativní korespondence funkcí get_tcs a at_dense_tc
    diffs = struct("tcs1_num", 0, "tcs2_num", 0, "errors", 0);
    
    for i=142:numel(imgsDescs)
        load(descsLoc + imgsDescs(i).name, 'desc1', 'descs2');
        tic;
        
        %tcs1 a tcs2 jsou celly - každá obsahuje 100x seznam t. korespondencí
        tcs1 = get_tcs(desc1, descs2);
        tcs2 = at_dense_tc_many(desc1, descs2);
        toc
        [eq, n_err] = test_matches_ok(tcs1, tcs2);
        if ~eq
            equal = false;
        end
        diffs(i).tcs1_num = numel(tcs1);
        diffs(i).tcs2_num = numel(tcs2);
        diffs(i).errors = n_err;
        num_errors = num_errors + n_err;
        fprintf("Chyb: %d, Celkem chyb: %d", n_err, num_errors);
        save("/home/seberma3/_InLoc_PROD_Speedup/get_tcs_vs_at_dense_tc2.mat", "diffs");
    end
end