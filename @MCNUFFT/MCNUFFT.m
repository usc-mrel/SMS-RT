function res = MCNUFFT(Data, para)

%
% EXPLANATION
%

%% initialize NUFFT
res.N   = NUFFT.init(Data.kx, Data.ky, 1, [6, 6], para.Recon.matrix_size(1), para.Recon.matrix_size(1));
res.N.W = para.kSpace_info.DCF(:,1);

%% Sensitivity Map
first_est = NUFFT.NUFFT_adj(Data.kSpace .* conj(Data.phase_mod), res.N);

% Low resolution coil sensitivity maps
C = get_sens_map(first_est);

if para.setting.ifGPU
    for i=1:length(res.N)
        res.N(i).S          = gpuArray(res.N(i).S);
        res.N(i).Apodizer   = gpuArray(res.N(i).Apodizer);
        res.N(i).W          = gpuArray(res.N(i).W);
    end
    C = gpuArray(C);
    phase_mod = gpuArray(Data.phase_mod);
end

%
res.C = C;
res.phase_mod = phase_mod;

% dimensions
res.im_size   = size(first_est);
res.data_size = size(Data.kSpace);
res.Ncoil     = para.Recon.Ncoil;
res.Nframes   = para.Recon.Nframes;
res.Nx        = para.Recon.matrix_size(1);


res.adjoint = 0;
res = class(res, 'MCNUFFT');

end