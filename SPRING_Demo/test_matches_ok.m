function [equal, num_errors] = test_matches_ok(cell1, cell2)
num_errors = 0;
equal = true;
if (isequal(numel(cell1), numel(cell2)))
    for i=1:numel(cell1)
        corrs1 = int32(cell1{i}(1:2,:));
        corrs2 = int32(cell2{i}(1:2,:));
        [~, idxs] = sort(corrs2(1,:));
        corrs2 = corrs2(:, idxs);
       if ~isequal(corrs1, corrs2)
          equal = false;          
          num_errors = num_errors + 1;
       end
    end
else
   equal = false; 
end
end
