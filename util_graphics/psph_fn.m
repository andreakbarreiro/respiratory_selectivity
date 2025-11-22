function [psph,centers] = psph_fn(phaseCell,optPSPH)
% Collect all spike phases for this odor across trials
%
%  phaseCell:  cell array of phases 
%  optPSPH:    optional parameters
%     angle_range [(0,8pi)]:     restrict phases in each trial;
%                                equivalent to setting the number of
%                                 breaths
%     dtPhase [0.1]:            bin length for histogram, in cycles
%                               (multiples of 2*pi)
%     myfilter []:                filter to use for smoothing
%
dtPhase     = 0.1;                      % phase bin width (in cycles)
angle_range = [0,8*pi];
myfilter      = [];

if isfield(optPSPH,'dtPhase'); dtPhase = optPSPH.dtPhase;end
if isfield(optPSPH,'angle_range'); angle_range = optPSPH.angle_range;end
if isfield(optPSPH,'myfilter'); myfilter = optPSPH.myfilter;end

phaseEdges = angle_range(1):(dtPhase*2*pi):angle_range(2);             % 0–8 cycles (phase / 2π)
phaseEdges = phaseEdges/(2*pi);

allPhases = [];
for tr = 1:length(phaseCell)
     ph = phaseCell{tr};
     if ~isempty(ph)
          allPhases = [allPhases; ph(:)];
     end
end

% Keep valid range and convert to cycles
validPhases = allPhases(allPhases >= angle_range(1) & allPhases <= angle_range(2)) / (2*pi);
%if isempty(validPhases), continue; end

% Bin; do not use PDF normalization, which discards information about overall spikecounts.
%  Normalize by dtPhase*nTrials so it becomes "spikes per unit of phase"
[psph, edges] = histcounts(validPhases, phaseEdges);
%
psph = psph/dtPhase/length(phaseCell);

if ~isempty(myfilter)
    psph = conv(psph, myfilter, 'same');
end

centers = (edges(1:end-1) + edges(2:end)) / 2;