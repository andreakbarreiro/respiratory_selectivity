function ax = raster_plot(spikeTrials, plotWindow, optArg)
% spikeTrials should be a 1×N cell, but may contain inner cells
% plotWindow = [t_start, t_end] in seconds
%
% optArg.color ['b']: color for spikes  

t0 = plotWindow(1);
tf = plotWindow(2);

raster_color = 'k';
if isfield(optArg, 'raster_color'); raster_color = optArg.raster_color; end

% ===== FIX: Convert nested cells to numeric =====
for i = 1:numel(spikeTrials)
    if iscell(spikeTrials{i})
        spikeTrials{i} = cell2mat(spikeTrials{i}(:)); % force numeric
    end
end

hold on;
for tr = 1:numel(spikeTrials)
    spks = spikeTrials{tr};  % now numeric
    if isempty(spks), continue; end

    % filter numeric safely
    spks = spks(spks >= t0 & spks <= tf);
    for k = 1:numel(spks)
        plot([spks(k) spks(k)], [tr-0.3 tr+0.3], 'LineWidth', 1,...
            'Color',raster_color);
    end
end

xlabel('Time (s)');
ylabel('Trial #');
title('Sniff-aligned Raster');
ylim([0 numel(spikeTrials)+1]);
xlim([t0 tf]);
hold off;

ax = gca;
end
