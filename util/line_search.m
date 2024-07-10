function step = line_search(x, update, Data, para)
%--------------------------------------------------------------------------
%   [step] = line_search(old, update, Data, para)
%--------------------------------------------------------------------------
%   Line search called in a conjugate gradient algorithm
%--------------------------------------------------------------------------
%   Inputs:      
%       - old       [sx, sy, nof, ...]
%       - update    [sx, sy, nof, ...]
%       - Data      [structure]
%       - para      [structure]
%               
%       - old       image from previous iteration
%       - update    update term
%       - Data      see 'help STCR_conjugate_gradient.m'
%       - para      see 'help STCR_conjugate_gradient.m'
%--------------------------------------------------------------------------
%   Output:
%       - step      [scalar]
%
%       - step      step size for CG update
%--------------------------------------------------------------------------
%   This function trys to find a suitable step size to perform a CG update.
%   The function starts with a step size adopted from last iteration, and
%   multiply it by 1.3 (magic number). If the step size yeilds a cost that
%   is larger than the previous cost, it shrinks the step size by 0.8
%   (magic number again). If it yeilds a cost that is smaller than the
%   previous cost, it will increase the step size by 1.3 until it no longer
%   yeild a smaller cost. The maximum number of trys is 15.
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%--------------------------------------------------------------------------

step_start = 2*1.3; % magic number

tau = 0.8; % magic number again
tau_2 = 1.3;
max_try = 20;
step = step_start;

cost_old = para.Cost.totalCost(end);
flag = 0;

d  = Data.kSpace;
Nx = size(x,1);
N  = numel(x);

weight_tTV = para.Recon.weight_tTV;
weight_sTV = para.Recon.weight_sTV;

for i=1:max_try
    
    xu = x + step * update;
    
    %%% Calculate Cost,
    % Data Fidelity
    fNorm = (para.E * xu - d) .* (para.kSpace_info.DCF(:,1).^0.5);
    fNorm = 1/2*sqrt(abs(fNorm(:)' * fNorm(:)))/(Nx);
    fNorm = fNorm^2/N;
    % TTV
    tNorm = mean(weight_tTV(:)) .* abs(diff(xu,1,3));
    tNorm = sum(tNorm(:))/N;
    % sTV
    sx_norm = abs(diff(xu,1,2));     sx_norm(:,end+1,:,:,:) = 0;
    sy_norm = abs(diff(xu,1,1));     sy_norm(end+1,:,:,:,:) = 0;
    sNorm = weight_sTV .* sqrt(abs(sx_norm).^2+abs(sy_norm).^2);
    sNorm = sum(sNorm(:))/N;
    

    cost_new = fNorm + tNorm + sNorm;
   
    if cost_new > cost_old && flag == 0
        step = step * tau;
    elseif cost_new < cost_old 
        step = step * tau_2;
        cost_old = cost_new;
        flag = 1;
    elseif cost_new > cost_old && flag == 1
        step = step / tau_2;

        return
    end
end