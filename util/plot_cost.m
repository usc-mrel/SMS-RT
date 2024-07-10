function plot_cost(Cost)
% plots the individual and overall cost terms for the STCR reconstruction.
% Ecrin Yagiz

ms = 5;
lw = 2;
fs = 10;

% Colors
color_total_cost = 'k';  
color_fidelity = "#0072BD";
color_temporal = "#7E2F8E";
color_spatial =  "#77AC30";

figure(100); 
hold on;

loglog(Cost.totalCost,      'LineWidth', lw, 'Marker', 'x', 'MarkerSize', ms, 'Color', color_total_cost);
loglog(Cost.fidelityNorm,   'LineWidth', lw, 'Marker', 'x', 'MarkerSize', ms, 'Color', color_fidelity);
legend('Total Cost','Fidelity Norm')

if Cost.temporalNorm(end)
    loglog(Cost.temporalNorm, 'LineWidth', lw, 'Marker', 'x', 'MarkerSize', ms, 'Color', color_temporal);
    lgd = get(gca,'Legend');
    lgd = lgd.String;
    legend([lgd(1:end-1),'Temporal Norm'])
end

if isfield(Cost, 'spatialNorm')
    if ~isempty(Cost.spatialNorm)
        if Cost.spatialNorm(end)
            loglog(Cost.spatialNorm, 'Marker', 'x', 'LineWidth', lw, 'MarkerSize', ms, 'Color', color_spatial);
            lgd = get(gca,'Legend');
            lgd = lgd.String;
            legend([lgd(1:end-1),'Smoothed Temporal Norm'])
        end
    end
end

if isfield(Cost, 'l2Norm')
    if ~isempty(Cost.l2Norm)
        if Cost.l2Norm(end)
            plot(Cost.l2Norm,'.-','LineWidth',2,'MarkerSize',15);
            lgd = get(gca,'Legend');
            lgd = lgd.String;
            legend([lgd(1:end-1),'L2 Norm'])
        end
    end
end

grid on;
xlabel 'Iteration Number'
ylabel 'Norm'
set(gca,'FontSize', fs)
hold off

end