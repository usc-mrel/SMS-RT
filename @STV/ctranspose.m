function res = ctranspose(Dxy)

    Dxy.adjoint = xor(Dxy.adjoint, 1);
    res = Dxy;

end