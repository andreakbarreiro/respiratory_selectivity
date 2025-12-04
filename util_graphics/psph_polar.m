function ax = psph_polar(phases, nBins)
% phases: numeric vector of spike phases (radians) after odor stimulus
% nBins : bins for PSPH (default 36)

if nargin < 2, nBins = 36; end

% ensure numeric & clean
if iscell(phases)
    phases = cell2mat(phases(:));
end
phases = phases(:);
phases = phases(~isnan(phases)); % ✅ remove NaNs safely

%figure('Position',[100 100 500 500],'Name','PSPH','NumberTitle','off');
ax = polaraxes;
polarhistogram(ax, phases, nBins, 'FaceAlpha', 0.6);
title(ax, 'Post-Stimulus Phase Histogram (PSPH)');
%title(['Cell ' num2str(c) ' polar plot odor (1 2 4 5 7)'])
end
