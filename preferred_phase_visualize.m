% ========================================================================
% CHECKS PERFORMED IN preferred_phase_fu:
% • Visual comparison of two phase representations derived from the same
%   sniff-aligned spike times (SWarpedAlign):
%     (1) NOT-warped view: time-in-sniff linearly mapped to phase
%         (inhale = 0→π, exhale = π→2π)
%     (2) Warped view: spike phases restricted to [0, 8π] (4 sniffs) and
%         wrapped to [0, 2π] for visualization
% • Polar histograms computed from wrapped phases with explicit
%   inhale/exhale markers and resultant-vector preferred phase


% REQUIREMENTS:
%   - util_graphics/raster_plot.m must exist 
%
% ========================================================================

clear; clc;

% If necessary, set paths
set_paths_AKB


%addpath('util_graphics');
 
% % --------- paths / file ----------
%dirloc   = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';


whichFile = '170622';
matfile  = fullfile(dirloc, ['sniffwarped_BF_OB_' whichFile '.mat']);
%stimData    = load([dirloc 'sniffwarped_BF_OB_' whichFile '.mat']);

% --------- pick cells/odors ----------
cellIDs = [1 2 3];
odorIDs = [1 2 5 7];

% --------- load "sniff-warped" data----------
D = load(matfile) ;
SWarpedAlign = D.SWarpedAlign;

cycleLen = D.meanInh + D.meanExh;  % seconds per mean sniff cycle
scale_to_phase = (2*pi) / cycleLen;

fprintf('Loaded: %s\n', matfile);
fprintf('SWarpedAlign size: %dx%d (odors x cells)\n', size(SWarpedAlign,1), size(SWarpedAlign,2));
fprintf('meanInh=%.4f s, meanExh=%.4f s, cycleLen=%.4f s\n', D.meanInh, D.meanExh, cycleLen);
region = 'OB';   % or 'CX'

% --------- load "equal-length inhale/exhale" data
%          AND un-modified rasters

matfile_EL  = fullfile(dirloc, ['phase_BF_OB_' whichFile '.mat']);
D2 = load(matfile_EL);

PhaseAlign = D2.PhaseAlign;
RasterAlign = D2.RasterAlign;


% --------- params ----------
nBins            = 36;
angle_range      = [0 8*pi];     % use 0..8pi worth of data (4 sniffs)
angle_range_plot = [0 2*pi];     % for wrapped plots

time_range       = [0 round(4*cycleLen,1)];  % for raster plots (in time)
time_range_plot = time_range;
raster_color     = 'k';



% --------- what to show in each row -----
% Possible flags: 
% data_type =  
%   raster_time: raster plots of spikes, in time, no modification
%   raster_phase_IEequal: phase [0,2pi] with inhale=[0,pi], exhale = [pi,2pi]
%   raster_phase_SW: phase [0,2pi], with inhale, exhale determined by average breath
%   polar_phase_SW: polar histogram w/ SW
%  
% wrapped = 1/0 (True/False)
% 
% data_range = range for data 
%
% wrap_range = range for wrapping/plotting 
%
title_dict = dictionary('raster_time','Raster (time)',...
    'raster_phase_IEequal','Inhale=Exhale',...
    'raster_phase_SW','Sniff-warped',...
    'polar_phase_SW','Polar histogram');
xlabel_dict = dictionary('raster_time','time (s)',...
    'raster_phase_IEequal','phase (rad)',...
    'raster_phase_SW','phase (rad)', 'polar_phase_SW','');
scale_dict = dictionary('raster_time',1,'raster_phase_IEequal',1,...
    'raster_phase_SW',scale_to_phase,'polar_phase_SW',scale_to_phase);

nRows = 5;
all_rows_info = cell(nRows,1);

all_rows_info{1}=struct('data_type','raster_time',...
    'wrapped',0,'data_range',time_range,'wrap_range',time_range_plot);
all_rows_info{2}=struct('data_type','raster_phase_SW',...
    'wrapped',0,'data_range',angle_range,'wrap_range',angle_range);
all_rows_info{3}=struct('data_type','raster_phase_SW',...
    'wrapped',1,'data_range',angle_range,'wrap_range',angle_range_plot);
all_rows_info{4}=struct('data_type','polar_phase_SW',...
    'wrapped',1,'data_range',angle_range,'wrap_range',angle_range_plot);
all_rows_info{5}=struct('data_type','polar_phase_SW',...
    'wrapped',1,'data_range',angle_range/2,'wrap_range',angle_range_plot);


for ic = 1:numel(cellIDs)
    c = cellIDs(ic);
    nOd = numel(odorIDs);

    % Figure layout: 4 rows x nOd columns
    figure('Name', sprintf('OB Cell %d:Raster, phase NOT warped vs sniff-warped', c), ...
           'Color','w', 'Position',[50 100 180*nOd 650]);
    tiledlayout(nRows, nOd, 'TileSpacing','compact', 'Padding','compact');

    % For each row
    for ir = 1:nRows
        row_info = all_rows_info{ir};

        % Which data? 
        switch row_info.data_type
            case 'raster_time'
                mydata = RasterAlign;
            case 'raster_phase_IEequal'
                mydata = PhaseAlign;
            case {'raster_phase_SW','polar_phase_SW'}
                mydata = SWarpedAlign;
            otherwise 
                error('Unknown data type specified');
        end

        for io = 1:nOd
            od = odorIDs(io);
            nexttile((ir-1)*nOd+io);  % row 1 col io

            % Collect trials
            rasEntry = mydata{od,c};   % cell array of trials
            spikeTrials = {};

            if isempty(rasEntry) || ~iscell(rasEntry)
                title(sprintf('Odor %d (%s): empty', od,row_info.data_type));
                continue;
            end
            for tr = 1:numel(rasEntry)
                t = rasEntry{tr};
                if isempty(t)
                    spikeTrials{end+1} = []; 
                    continue;
                end
                t = t(:)'; 
                t = t(isfinite(t));

                % Convert time -> phase axis (radians)
                % Or some other scaling
                t = t * scale_dict(row_info.data_type);

                % Use only prescribed range of data
                t = t(t >= row_info.data_range(1) & t <= row_info.data_range(2));
            
                % Do we wrap?
                if (row_info.wrapped == 1)
                    t = mod(t, row_info.wrap_range(2));
                end
                spikeTrials{end+1} = t;
            end

            switch row_info.data_type
                case 'polar_phase_SW'
                    % Need to reshape this as a list; do not care about
                    % trials
                    t = [];
                    for j1=1:length(spikeTrials)
                        t = [t;spikeTrials{j1}'];
                    end
                    if isempty(t)
                        polaraxes;
                        title(sprintf('Odor %d: No spikes', od));
                        continue;
                    end
                    % ---- histogram bins ----
                    edges = linspace(0, 2*pi, nBins+1);
                    counts = histcounts(t, edges);
                    thetaCenters = (edges(1:end-1) + edges(2:end)) / 2;

                    % ---- resultant vector preferred phase ----
                    [phi_pref, Rlen, Rvec] = preferred_phase_from_psph(thetaCenters, counts);
                    % ---- polar plot ----
                    polarhistogram(t, edges, ...
                        'FaceColor','r', 'EdgeColor','none', 'FaceAlpha',0.6);
                    hold on;

                    ax = gca;
                    ax.ThetaZeroLocation = 'top';
                    ax.ThetaDir = 'clockwise';

                    rmax = max(counts); 
                    if rmax == 0, rmax = 1; end

                    % Inhale start (0) — solid blue
                    polarplot([0 0], [0 rmax], 'b-', 'LineWidth', 1.5);

                    % Inhale end / Exhale start (pi) — dashed blue
                    %polarplot([pi pi], [0 rmax], 'b--', 'LineWidth', 1.5);
                    exhStartPhase = scale_to_phase*D.meanInh;
                    polarplot([exhStartPhase exhStartPhase], [0 rmax], 'b--', 'LineWidth', 1.5);

                    % Preferred phase arrow — black
                    polarplot([phi_pref phi_pref], [0 0.9*rmax], 'k-', 'LineWidth', 2);
                    title(sprintf('Odor %d | \\phi_{pref}=%.3f | R=%.2f', od, phi_pref, Rlen));
                
                    hold off;

                otherwise
                    % Raster plot
                    if isempty(spikeTrials)
                        title(sprintf(' Odor %d (%s)',od,row_info.data_type));
        
                    else
                        raster_plot(spikeTrials, row_info.wrap_range, struct('raster_color', raster_color));
                        if strcmp(row_info.data_type,'raster_phase_SW')
                            % Inhale starts
                            vertInh = [0:10]*cycleLen*scale_to_phase; vertInh = vertInh(vertInh < row_info.wrap_range(2));
                            % Exhale starts
                            vertExh = (D.meanInh+[0:10]*cycleLen)*scale_to_phase; vertExh = vertExh(vertExh < row_info.wrap_range(2));

                            yLim = ylim; 
                            for j1=1:length(vertInh)
                                plot([vertInh(j1) vertInh(j1)], yLim,'g-');
                            end
                            for j1=1:length(vertExh)
                                plot([vertExh(j1) vertExh(j1)], yLim,'b-');
                            end
                        end
                        xlabel(xlabel_dict(row_info.data_type));
                        title(sprintf('Odor %d (%s)',od,title_dict(row_info.data_type)));
        
                    end
            end
        end
    end
end



% ========================================================================
% FUNCTIONS
% ========================================================================

function [phi_pref, Rlen, Rvec] = preferred_phase_from_psph(thetaCenters, counts)
    thetaCenters = thetaCenters(:);
    counts = counts(:);

    counts(~isfinite(counts)) = 0;
    counts(counts < 0) = 0;

    if sum(counts) == 0
        phi_pref = NaN; Rlen = NaN; Rvec = NaN;
        return;
    end

    % Resultant vector (normalized)
    Rvec = sum(counts .* exp(1i*thetaCenters)) / sum(counts);

    % Preferred phase = argument of resultant
    phi_pref = angle(Rvec);
    if phi_pref < 0
        phi_pref = phi_pref + 2*pi;
    end

    % Vector length (0..1): coupling strength / concentration
    Rlen = abs(Rvec);
end
