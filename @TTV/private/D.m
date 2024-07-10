function res = D(m, is_circular)
% 
if ndims(m) < 3
    error('Image does not have a time dimension \n');
end

if is_circular
    Dtm = m(:,:,[2:end,1],:,:) - m;
else
    Dtm = m(:,:,[2:end,end],:,:) - m;
end
res = Dtm;
end