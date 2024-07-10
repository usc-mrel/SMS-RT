function res = mtimes(Dxy, m)

if Dxy.adjoint % ----------------------------> D'*m   
    Dxyhm = adjD(m, Dxy.is_circular);
    res = Dxyhm;
else % ------- ----------------------------> D*m
    Dxym = D(m, Dxy.is_circular);
    res = Dxym;
end

end