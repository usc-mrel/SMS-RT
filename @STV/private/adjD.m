function res = adjD(m, is_circular)


if is_circular
    % x
    Dhm = m([end,1:end-1],:,:,:,:) - m;
    % y
    Dhm = Dhm + m(:,[end,1:end-1],:,:,:) - m;
else
    % x
    Dhmx = m([1,1:end-1],:,:,:,:) - m;
    Dhmx(1,:,:,:,:)   = -m(1,:,:,:,:);
    Dhmx(end,:,:,:,:) = m(end-1,:,:,:,:);

    % y
    Dhmy = m(:,[1,1:end-1],:,:,:) - m;
    Dhmy(:,1,:,:,:)   = -m(:,1,:,:,:);
    Dhmy(:,end,:,:,:) = m(:,end-1,:,:,:);

    Dhm = Dhmx + Dhmy;
end
res = Dhm;

end