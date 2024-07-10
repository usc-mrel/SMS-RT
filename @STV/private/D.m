function res = D(m, is_circular)
% 

if is_circular
    % x
    Dxym = m([2:end,1],:,:,:,:) - m;
    % y
    Dxym = Dxym + (m(:,[2:end,1],:,:,:) - m);
else
    % x
    Dxym = m([2:end,end],:,:,:,:) - m;
    % y
    Dxym = Dxym + (m(:,[2:end,end],:,:,:) - m);
end
res = Dxym;
end