function res = mtimes(Dt, m)

if Dt.adjoint % ----------------------------> D'*m   
    Dthm = adjD(m, Dt.is_circular);
    res = Dthm;
else % ------- ----------------------------> D*m
    Dtm = D(m, Dt.is_circular);
    res = Dtm;
end

end