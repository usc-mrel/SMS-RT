function res = mtimes(E, x)

% E = Phi * F * C
%
% Phi   -> CAIPI Phase Term
% F     -> NUFFT 
% C     -> Coil Sens

if E.adjoint % ----------------------------> E'*d   
    d = x;
    Fhd = NUFFT.NUFFT_adj(d .* conj(E.phase_mod), E.N);
    Ehd = sum(Fhd .* conj(E.C), 4); 
    res = Ehd;
else % ------------------------------------> E*m
    m  = x;
    Em = single(zeros(E.data_size, class(m))); 
    for ii = 1:E.Ncoil
        Cm  = bsxfun(@times, m, E.C(:,:,:,ii,:));         % Cm
        Em_ = NUFFT.NUFFT(Cm,  E.N);                      % Em
        Em_ = sum(Em_ .* E.phase_mod, 5);
        Em(:,:,:,ii) = Em_;  
    end
    res = Em;
end


end