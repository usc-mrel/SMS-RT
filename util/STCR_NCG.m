function [Image_recon, para] = STCR_NCG(Data, para)

fprintf([repmat('-', [1, 75]), '\n'])
disp('begin iterative STCR nonlinear conjugate gradient reconstruction...');
fprintf([repmat('-', [1, 75]), '\n'])

%%
disp_freq               = 5;
ifplot                  = para.setting.ifplot;
verbose                 = para.setting.verbose;
ifGPU                   = para.setting.ifGPU;

beta_sqrd               = para.Recon.epsilon;
para.Recon.step_size    = para.Recon.step_size(1);

%%

if ifGPU
    d = gpuArray(Data.kSpace);
    beta_sqrd = gpuArray(beta_sqrd);
    para.kSpace_info.DCF = gpuArray(para.kSpace_info.DCF);
end

%% Scale Regularization parameters

x = para.E'* d;
t = gather(x(:,:,20:end,:,:));
scale = max(abs(t(:)));     nSMS = para.Recon.nSMS; clear t

para.Recon.epsilon = scale * 1e-6;
para.Recon.no_comp = para.Recon.Ncoil;
para.Recon.weight_tTV = scale * para.Recon.weight_tTV / nSMS; % temporal regularization weight
para.Recon.weight_sTV = scale * para.Recon.weight_sTV / nSMS; % spatial regularization weight

%%

% initialize Cost
para.Cost = struct('fidelityNorm',[],'temporalNorm',[],'spatialNorm',[],'totalCost',[]);

%% NCG
fprintf(' Iteration       Cost       Step    Time(s) \n')

s_old       = 0;

for iter_no = 1:para.Recon.Nmaxiter
    
    % ---------------------------------------------------------------------
    %%% Gradient, 
    delta_x = -1 * gradient_STCR(para, x, d);
    
    % ---------------------------------------------------------------------
    %%% Calculate Beta
    if iter_no == 1
        beta = 0;
    else
        beta = abs(delta_x(:)' * delta_x(:)) / abs(s_old(:)' * s_old(:) + beta_sqrd);
    end
    
    % ---------------------------------------------------------------------
    % Update direction, s
    s = delta_x + beta * s_old;
    
    % ---------------------------------------------------------------------
    % Calculate & Record cost
    [fNorm, tNorm, sNorm]   = get_STCR_cost(para, x, d); 
    para.Cost.fidelityNorm  = [para.Cost.fidelityNorm, fNorm];
    para.Cost.temporalNorm  = [para.Cost.temporalNorm, tNorm];
    para.Cost.spatialNorm   = [para.Cost.spatialNorm,  sNorm];
    para.Cost.totalCost     = [para.Cost.totalCost,    fNorm + tNorm + sNorm];
    
    % ---------------------------------------------------------------------
    % Step Size
    alpha = line_search(x, s, Data, para);
    para.Recon.step_size(iter_no) = alpha;
    
    % ---------------------------------------------------------------------
    % Update
    x = x + alpha * s;
    
    % 
    s_old = s;
    clear s; 
    clear delta_x;
    
    if iter_no > 1
        if alpha < 1e-5 
            break;
        end
    end

    if ifplot && mod(iter_no, disp_freq) == 0 || iter_no == para.Recon.Nmaxiter
        plot_cost(para.Cost)
        grid on;
    end

    if verbose && mod(iter_no, disp_freq) == 0 || iter_no == para.Recon.Nmaxiter
        fprintf(sprintf('%10.0f %10.2f %10.4f %10.4f %10.2f \n',iter_no, para.Cost.totalCost(end), alpha, beta, 0));
    end

end

Image_recon = gather(x);
Image_recon = fliplr(rot90(Image_recon, -1));
Image_recon = crop_half_FOV( abs(Image_recon));

% fprintf(['Iterative STCR running time is ' num2str(para.CPUtime.interative_recon) 's' '\n'])
fprintf([repmat('-', [1, 75]), '\n'])

%%
function [fNorm, tNorm, sNorm]   = get_STCR_cost(para, x, d)
    Nx = size(x,1);
    N  = numel(x);
    weight_tTV = para.Recon.weight_tTV;
    weight_sTV = para.Recon.weight_sTV;
    %%% Calculate Cost,
    % Data Fidelity
    fNorm = (para.E * x - d) .* (para.kSpace_info.DCF(:,1).^0.5);
    fNorm = 1/2*sqrt(abs(fNorm(:)' * fNorm(:)))/(Nx);
    fNorm = fNorm^2/N;
    % TTV
    tNorm = mean(weight_tTV(:)) .* abs(diff(x,1,3));
    tNorm = sum(tNorm(:))/N;
    % sTV
    sx_norm = abs(diff(x,1,2));     sx_norm(:,end+1,:,:,:) = 0;
    sy_norm = abs(diff(x,1,1));     sy_norm(end+1,:,:,:,:) = 0;
    sNorm = weight_sTV .* sqrt(abs(sx_norm).^2+abs(sy_norm).^2);
    sNorm = sum(sNorm(:))/N;
end

%%%
function delta_x = gradient_STCR(para, x, d)
    % Data Fidelity
    delta_x = para.E' * (para.E*x - d);

    % TTV
    Dm = para.Dt * x;
    G  = para.Dt' * (Dm .* (Dm .* conj(Dm) + para.Recon.epsilon).^(-1/2));
    delta_x = delta_x + para.Recon.weight_tTV * G;

    % STV
    Dm = para.Dxy * x;
    G  = para.Dxy' * (Dm .* (Dm .* conj(Dm) + para.Recon.epsilon).^(-1/2));
    delta_x = delta_x + para.Recon.weight_sTV * G;

end

end