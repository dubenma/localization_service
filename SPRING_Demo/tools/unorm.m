% n = unorm(x) - columnwise vector 2 normalization
% 
% n = x ./ repmat(sqrt(sum(x.^2)),size(x,1),1)

% (c) T. Pajdla, pajdla@gmail.com, 2006-05-02
function n = unorm(x) 
    % n = bsxfun(@times,x,d);
    % n = x.*d(ones(size(x,1),1),:);    
    d = 1./sqrt(sum(x.^2));
    n = x.*repmat(d,size(x,1),1);
    %n = x./repmat(vnorm(x),size(x,1),1);
return
