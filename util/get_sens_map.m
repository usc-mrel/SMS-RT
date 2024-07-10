function sens_map = get_sens_map(Image)

if nargin < 2
    smooth = 20;
    niter = 20;
elseif nargin == 2
    niter = 20;
end

[sx,sy,nof,coils,nSMS,ns] = size(Image);

Image = reshape(Image,[sx,sy,nof,coils,nSMS*ns]);
im_for_sens = squeeze(sum(Image,3));
sens_map = zeros(sx,sy,1,coils,nSMS*ns);

for i=1:nSMS*ns
    sens_map(:,:,1,:,i) = ismrm_estimate_csm_walsh_optimized_yt(im_for_sens(:,:,:,i),smooth, niter);
end

sens_map = reshape(sens_map,[sx,sy,1,coils,nSMS,ns]);

% 
sens_map_scale = max(abs(sens_map(:)));
sens_map = sens_map/sens_map_scale;
sens_map_conj = conj(sens_map);

sens_correct_term = 1./sum(sens_map_conj.*sens_map,4);

sens_correct_term = sqrt(sens_correct_term);
sens_map = bsxfun(@times,sens_correct_term,sens_map);

sens_map = single(sens_map);


end