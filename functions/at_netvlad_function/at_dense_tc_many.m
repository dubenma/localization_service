function matches = at_dense_tc_many(desc1,descs2)
matches = cell(1, numel(descs2));
for i=1:numel(descs2)
   matches{i} = at_dense_tc(desc1, descs2{i});
end
% [idx12, dis12] = yael_nn(desc2, desc1, 1);
% [idx21, dis21] = yael_nn(desc1, desc2, 1);
% 
% Ndesc = length(idx12);
% xmatch = NaN(3,Ndesc);
% for ii=1:Ndesc
%   if ~isnan(idx12(1,ii))
%     if idx21(1,idx12(1,ii)) == ii
%       xmatch(:,ii) = [ii; single(idx12(1,ii)); dis12(1,ii)];
%     end
%   end
% end
% match = xmatch(:,~isnan(xmatch(1,:)));