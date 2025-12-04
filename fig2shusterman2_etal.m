% ======================================================
%      Shusterman Figure 2 – Full Composite per Cell
% ======================================================

set_paths_AKB

if (0)
addpath('util_graphics');   % raster_plot.m and psph_polar.m

dirloc = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';
end

whichFile = '170608';
cellIDs   = [3];
odorIDs   = [1 2 4 5 7];   % include clean = 7
plotWindow = [-1 1];
angle_range = [-4*pi 4*pi];
nBins = 36;

% ----------- Do we want spike TIMES? Or spike phases?
%   0 = traditional time (no warping)
%   1 = phases
%   2 = sniff-warping
raster_defin_flag = 1;

% Color for raster plot?
rasArg = [];

% ----------- Load stimulus & spontaneous ----------
stimData  = load([dirloc 'phase_BF_OB_' whichFile '.mat']);
PhaseAlign  = stimData.PhaseAlign;      % 7 x Ncells
RasterAlign = stimData.RasterAlign;     % 7 x Ncells

% ======================================================
%            MAKE COMPOSITE FIGURE FOR EACH CELL
% ======================================================
for ic = 1:numel(cellIDs)
    c = cellIDs(ic);

    nOd = numel(odorIDs);
    figure('Name',sprintf('Composite Cell %d',c), ...
           'Position',[50 100 180*nOd 600], ...
           'Color','w');

    tiledlayout(2, nOd, 'TileSpacing','compact','Padding','compact');

    % ======================================================
    %                   TOP ROW — RASTER PLOTS
    % ======================================================
    for io = 1:nOd
        od = odorIDs(io);
        nexttile(io);

        if raster_defin_flag == 0
            rasEntry = RasterAlign{od, c};
        else
            rasEntry = PhaseAlign{od, c};
        end


        spikeTrials = {};

        if iscell(rasEntry)
            for tr = 1:numel(rasEntry)
                spks = rasEntry{tr};
                if isempty(spks), continue; end

                spks = spks(:)'; 
                if raster_defin_flag == 0
                    spks = spks(spks >= plotWindow(1) & spks <= plotWindow(2));
                else
                    spks = spks(spks >= angle_range(1) & spks <= angle_range(2));
                end
                spks = spks(~isnan(spks));

                if ~isempty(spks)
                    spikeTrials{end+1} = spks; %#ok<AGROW>
                else
                    spikeTrials{end+1} = [];
                end
            end
        end

        if isempty(spikeTrials)
            title(sprintf('Odor %d: No spikes', od));
        else
            if raster_defin_flag == 0
                raster_plot(spikeTrials, plotWindow, rasArg);
            else
                raster_plot(spikeTrials, angle_range, rasArg);
            end
            title(sprintf('Odor %d', od));
        end
    end

    % ======================================================
    %                BOTTOM ROW — PSPH PER ODOR
    % ======================================================
    for io = 1:nOd
        od = odorIDs(io);
        nexttile(nOd + io);

        phEntry = PhaseAlign{od, c};
        allPhases = [];

        if iscell(phEntry)
            for tr = 1:numel(phEntry)
                ph = phEntry{tr};
                if isempty(ph), continue; end

                ph = ph(:)';
                ph = ph(~isnan(ph));
                ph = ph(ph >= angle_range(1) & ph <= angle_range(2));

                allPhases = [allPhases, ph]; %#ok<AGROW>
            end
        end

        if isempty(allPhases)
            polaraxes;
            title(sprintf('Odor %d: No phase data', od));
        else
            %polarhistogram(allPhases, nBins, 'FaceColor',[0.2 0.4 1],
            %'EdgeColor','none');%blue color
            polarhistogram(allPhases, nBins, 'FaceColor',[1 0 0], 'EdgeColor','none');%red color

            title(sprintf('PSPH Odor %d', od));
        end
    end

end
