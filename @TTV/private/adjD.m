function res = adjD(m, is_circular)

if ndims(m) < 3
    error('Image does not have a time dimension \n');
end

if is_circular
    Dhm = m(:,:,[end,1:end-1],:,:) - m;
else
    Dhm = m(:,:,[1,1:end-1],:,:) - m;
    Dhm(:,:,1,:,:)   = -m(:,:,1,:,:);
    Dhm(:,:,end,:,:) = m(:,:,end-1,:,:);
end
res = Dhm;

end