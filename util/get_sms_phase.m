function phase_mod = get_sms_phase(para)
% For SMS creates the phases for 3 slices
    
    kspace_info     = para.kSpace_info;
    Narms_per_frame = para.Recon.Narms_per_frame;
    Nframes         = para.Recon.Nframes;
    Narms_total     = Narms_per_frame * Nframes;

    if isfield(kspace_info, 'RFIndex')
        phase_index = kspace_info.RFIndex - 1;
        phase_mod = [- 2*pi/3, 0, 2*pi/3];
        phase_mod = phase_index' .* phase_mod;
        phase_mod = exp(1i * phase_mod);
        phase_mod(Narms_total + 1 : end, :) = [];
        phase_mod = reshape(phase_mod, [Narms_per_frame, Nframes, 3]);
        phase_mod = permute(phase_mod, [4, 1, 2, 5, 3]);
    else
        phase_mod = ones(1, Narms_per_frame, Nframes);
    end

end