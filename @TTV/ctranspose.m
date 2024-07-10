function res = ctranspose(Dt)

    Dt.adjoint = xor(Dt.adjoint, 1);
    res = Dt;

end