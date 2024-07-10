
%   Spatially and temporally constrained reconstruction (STCR):
%   accepts SB (single band) and SMS (Simultanenous multi-slice images)
%   acquired with 2D GA Spiral 
%
%   || Em - d ||_2^2 + lambda_t || TV_t m ||_1 + lambda_s || TV_s m ||_1
%                  
%
%   "E"         encoding matrix includes sensitivity maps, Fourier 
%               transform, and CAIPI phase term (for SMS)
%   "m"         image to be reconstructed
%   "d"         measured k-space data
%   ||.||_2^2   l2 norm
%   ||.||_1     l1 norm
%   "lambda_t"  temporal constraint weight
%   "lambda_s"  sparial constraint weight
%
%   TV_t        temporal total variation (TV) operator (finite difference)
%               sqrt( abs(m_t+1 - m_t)^2 + epsilon )
%   "epsilon"   small term to aviod singularity
%   TV_s        spatial TV operator
%               sqrt( abs(m_x+1 - m_x)^2 + abs(m_y+1 - m_y) + epsilon )
% 
% -------------------------------------------------------------------------
% Author: Ecrin Yagiz
% -------------------------------------------------------------------------
%   Reference:
%       [1]      
% -------------------------------------------------------------------------
%%
clear; clc; close all;

%% Dependencies

addpath util/
addpath thirdparty/

%% User parameters

% Dataset
fn = 'example_SB_sl5.mat';     % Filename of the raw data.
SMS_flag = 0;                  % 1 -> SMS , 0 -> SB

% Regularization
weight_tTV = 5e-2;            % Temporal TV Regularization Coeff
weight_sTV = 5e-3;            % Spatial TV Regularization Coeff

% Solver
Nmaxiter = 100;             % max number of iterations 
ifGPU    = 1;               % for iterative recon
verbose  = 0;               % prints cost
ifplot   = 0;               % plots cost function per iter

% --------------------------------------------------------
para.fn                 = fn;
para.Recon.SMS_flag     = SMS_flag;
para.Recon.weight_tTV   = weight_tTV;
para.Recon.weight_sTV   = weight_sTV;
para.Recon.Nmaxiter     = Nmaxiter;

para.setting.ifGPU      = ifGPU;
para.setting.verbose    = verbose;
para.setting.ifplot     = ifplot;

%% Load and prep data 

[Data, para] = prep_data(para);

%% Operators

para.E   = MCNUFFT(Data, para);
para.Dt  = TTV();
para.Dxy = STV();

%% conjugate gradient reconstruction

[Image_recon, para] = STCR_NCG(Data, para);

%% Display

if SMS_flag
    Nx = size(Image_recon,1); 
    Image_recon = reshape(permute(squeeze(Image_recon), [1,2,4,3]), Nx, 3*Nx, []);
end
sliceViewer(window_prctile(Image_recon,98));
