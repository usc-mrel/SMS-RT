function I = window_prctile(I, percentile)
% do a windowing to the image based on the given percentile.
% Takes only real valued images.
% Ecrin Yagiz

    if ~isreal(I)
        disp('Image is not real. It is converted to real \n');
        I = abs(I);
    end
    
    if percentile < 50
        percentile = 100 - percentile;
    end
    
    % based on the percentile find cmin and cmax
    cmax = prctile(I(:), percentile);
    cmin = prctile(I(:), 100-percentile);
    
    I(I < cmin) = cmin;
    I(I > cmax) = cmax;
    I = (I - cmin) / (cmax - cmin);
end