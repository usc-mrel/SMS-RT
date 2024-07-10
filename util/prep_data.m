function [Data, para] = prep_data(para)

%% some hard params, can be changed
temporal_resolution = 45;                         % [ms]
FOV_recon           = [500, 500];                 % [mm]
recon_arms          = 'all'; 
nSMS                = 3;                          % SMS Factor = 3
Nframescut          = 1;                               

%% set recon parameters

para.Recon.epsilon     = eps('single');           % small vale to avoid singularity in TV constraint
para.Recon.step_size   = 2;                       % initial step size
para.Recon.break       = 1;                       % stop iteration if creteria met. Otherwise will run to noi
para.Recon.nSMS        = nSMS;

%% Load raw data             
load(para.fn)                                     % Loads kspace and kspace_info 
para.kSpace_info = kspace_info;
%% Reshape data

TR = kspace_info.user_TR / 1000;
para.Recon.narm = max(floor(temporal_resolution / TR), 1);
Narms_per_frame = para.Recon.narm;

res = [kspace_info.user_ResolutionX, kspace_info.user_ResolutionY];

kspace = permute(kspace, [1, 2, 4, 3])*1e3;

matrix_size = round(FOV_recon ./ res / 2) * 2;

matrix_size_keep = ceil([kspace_info.user_FieldOfViewX, kspace_info.user_FieldOfViewX] ./ res);

para.Recon.matrix_size      = matrix_size;
para.Recon.matrix_size_keep = round(matrix_size_keep);


if isfield(kspace_info, 'ResolutionIndex')
    if isempty(kspace_info.ResolutionIndex)
        res_index = 1;
    else
        res_index = kspace_info.ResolutionIndex(1);
    end
    kx = kspace_info.kx_GIRF(:, :, res_index) * matrix_size(1);
    ky = kspace_info.ky_GIRF(:, :, res_index) * matrix_size(2);
else
    res_index = 1;
    kx = kspace_info.kx_GIRF * matrix_size(1);
    ky = kspace_info.ky_GIRF * matrix_size(2);
end
para.Recon.res_index = res_index;
%%
viewOrder = kspace_info.viewOrder;  % GA ordering

if exist('recon_arms', 'var')
    if isnumeric(recon_arms)
        kspace = kspace(:, recon_arms, :, :);
        viewOrder = viewOrder(recon_arms);
    else
        arms_drop = ceil(1000 / TR);
        arms_drop = 0;
        kspace = kspace(:, arms_drop + 1:end, :, :);
        viewOrder = viewOrder(arms_drop + 1:end);
    end
end

GA_steps = size(kx, 2);
Narms_total = size(kspace, 2);
Nframes = floor(Narms_total / Narms_per_frame);
Narms_total = Nframes * Narms_per_frame;
Ncoil = size(kspace, 4);
Nsample = size(kspace, 1);

kx = repmat(kx, [1, ceil(Narms_total / GA_steps)]);
ky = repmat(ky, [1, ceil(Narms_total / GA_steps)]);

kspace(:, Narms_total + 1 : end, :, :) = [];
viewOrder(Narms_total + 1 : end) = [];

viewOrder = mod(viewOrder, GA_steps);
viewOrder(viewOrder == 0) = GA_steps;
para.Recon.viewOrder = viewOrder;

kx = kx(:, viewOrder);
ky = ky(:, viewOrder);


kspace = reshape(kspace, [Nsample, Narms_per_frame, Nframes, Ncoil]);
kx = reshape(kx, [Nsample, Narms_per_frame, Nframes]);
ky = reshape(ky, [Nsample, Narms_per_frame, Nframes]);

%% 
para.Recon.Nsample = Nsample;
para.Recon.Narms_per_frame = Narms_per_frame;
para.Recon.Nframes = Nframes;
para.Recon.Ncoil = Ncoil;


%%  Correction

%
q0 = kspace_info.user_QuaternionW;
q1 = kspace_info.user_QuaternionX;
q2 = kspace_info.user_QuaternionY;
q3 = kspace_info.user_QuaternionZ;

rot = [2 * (q0^2  + q1^2 ) - 1,     2 * (q1*q2 - q0*q3),        2 * (q1*q3 + q0*q2);
    2 * (q1*q2 + q0*q3),         2 * (q0^2  + q2^2 ) - 1,    2 * (q2*q3 - q0*q1);
    2 * (q1*q3 - q0*q2),         2 * (q2*q3 + q0*q1),        2 * (q0^2  + q3^2) - 1];

dx = kspace_info.user_TranslationX;
dy = kspace_info.user_TranslationY;
dz = kspace_info.user_TranslationZ;

kx0 = kspace_info.kx(:, :, res_index);
ky0 = kspace_info.ky(:, :, res_index);

kx0 = kx0 / kspace_info.user_ResolutionX;
ky0 = ky0 / kspace_info.user_ResolutionY;

kx_girf = kspace_info.kx_GIRF(:, :, res_index);
ky_girf = kspace_info.ky_GIRF(:, :, res_index);

kx_girf = kx_girf / kspace_info.user_ResolutionX;
ky_girf = ky_girf / kspace_info.user_ResolutionY;

%rotate trajectory to physical coordinate
[nsample, narm] = size(kx0);
k0 = cat(1, kx0(:)', ky0(:)', zeros(size(kx0(:)))');
k0 = rot * k0;

kx0 = reshape(k0(1, :), [nsample, narm]);
ky0 = reshape(k0(2, :), [nsample, narm]);
kz0 = reshape(k0(3, :), [nsample, narm]);

k_girf = cat(1, kx_girf(:)', ky_girf(:)', zeros(size(kx_girf(:)))');
k_girf = rot * k_girf;

kx_girf = reshape(k_girf(1, :), [nsample, narm]);
ky_girf = reshape(k_girf(2, :), [nsample, narm]);
kz_girf = reshape(k_girf(3, :), [nsample, narm]);


phase_x_0 = 2 * pi * dx * kx0;
phase_y_0 = 2 * pi * dy * ky0;
phase_z_0 = 2 * pi * dz * kz0;

phase_x_girf = 2 * pi * dx * kx_girf;
phase_y_girf = 2 * pi * dy * ky_girf;
phase_z_girf = 2 * pi * dz * kz_girf;

demod_phase_x = circshift(phase_x_0, [-2, 0]) - phase_x_girf;
demod_phase_y = circshift(phase_y_0, [-2, 0]) - phase_y_girf;
demod_phase_z = circshift(phase_z_0, [-2, 0]) - phase_z_girf;

demod_phase = demod_phase_x + demod_phase_y + demod_phase_z;
delay_corr = reshape(demod_phase(:, viewOrder), [nsample, Narms_per_frame, Nframes]);
delay_corr = exp(-1i * delay_corr);
kspace = kspace .* delay_corr;

%% Phase Mod for SMS = 3. 
% Returns all 1s for SB case
phase_mod = get_sms_phase(para);

%% Trim the data
phase_mod   = phase_mod(:,:,Nframescut:end,:,:);
kspace      = kspace(:,:,Nframescut:end,:);
kx          = kx(:,:,Nframescut:end);
ky          = ky(:,:,Nframescut:end);

para.Recon.Nframes = size(phase_mod, 3);
para.Recon.viewOrder = para.Recon.viewOrder(1:para.Recon.Nframes * para.Recon.Narms_per_frame);
%% Assign things to Data struct
Data.kSpace     = kspace; clear kspace
Data.phase_mod  = phase_mod;
Data.kx         = kx;
Data.ky         = ky;
end