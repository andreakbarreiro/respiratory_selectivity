% ===============================================================
% Fukunaga 2012 Fig S7-style significance test via sniff shuffling
% (CDF of null R + observed Robs + thr90) as SUBPLOTS (one figure per cell)
%
% - Coupling metric: resultant vector length R
% - Null: Nshuf shuffles (trial-wise random phase shift)
% - "Sniff-coupled" if Robs > 90% of null (thr90)
% ===============================================================

set_paths_AKB
% clear; clc;
% 
% % ---------------- USER SETTINGS ----------------
dataFile = 'sniffwarped_BF_OB_170608.mat';
% dirloc   = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';

fullpath = fullfile(dirloc, dataFile);

cellIDs  = [1];                % cells to analyze (columns)
odorIDs  = [1 2 4 5 7];         % odors to analyze (rows)

nBins    = 36;                 % bins used for R computation (binned resultant)
Nshuf    = 100;                % Fig S7 uses 100 sets
alpha    = 0.10;               % 90% threshold
nCyclesToUse = 4;              % keep 0..(2*pi*nCyclesToUse) before wrapping

shuffleMode = "trial_phase_shift";  % per-trial random offset in [0,2pi)

% ---------------- LOAD ----------------
D = load(fullpath);

if ~isfield(D,'SWarpedAlign')
    error('SWarpedAlign not found in %s', fullpath);
end
SWarpedAlign = D.SWarpedAlign;      % size: odors x cells

% Per-trial cycle length (optional)
hasPerTrial = isfield(D,'meanInh_byTrial') && isfield(D,'meanExh_byTrial');
if hasPerTrial
    meanInh_byTrial = D.meanInh_byTrial;   % odors x trials
    meanExh_byTrial = D.meanExh_byTrial;   % odors x trials
end

% Global cycle length fallback
if isfield(D,'meanInh') && isfield(D,'meanExh')
    cycleLen_global =D.meanInh + D.meanExh;
else
    error('meanInh/meanExh not found. Need cycle length to map time -> phase.');
end

fprintf('Loaded: %s\n', fullpath);
fprintf('SWarpedAlign size: %dx%d (odors x cells)\n', size(SWarpedAlign,1), size(SWarpedAlign,2));
fprintf('Global cycleLen = %.4f sec\n\n', cycleLen_global);

% ---------------- MAIN LOOP ----------------
results = []; % columns: [cell od phi_pref Robs thr90 pval coupled]

for ic = 1:numel(cellIDs)
    c = cellIDs(ic);

    % === ONE FIGURE PER CELL ===
    nOd = numel(odorIDs);
    figW = max(1200, 260*nOd);
    figure('Color','w', ...
        'Name', sprintf('Cell %d | sniff-shuffle significance (all odors)', c), ...
        'Position', [100 200 figW 360]);

    for io = 1:nOd
        od = odorIDs(io);

        trialCell = SWarpedAlign{od,c};
        if isempty(trialCell) || ~iscell(trialCell)
            % empty subplot placeholder
            subplot(1,nOd,io);
            axis off;
            title(sprintf('Odor %d\n(empty)', od), 'Interpreter','none');
            continue;
        end

        % --- convert each trial: time -> phase -> keep first cycles -> wrap
        phases_by_trial = cell(size(trialCell));
        for tr = 1:numel(trialCell)
            spk = trialCell{tr};
            if isempty(spk)
                phases_by_trial{tr} = [];
                continue;
            end

            spk = spk(:);
            spk = spk(isfinite(spk));

            % choose cycle length
            cycleLen = cycleLen_global;
            if hasPerTrial
                if od <= size(meanInh_byTrial,1) && tr <= size(meanInh_byTrial,2)
                    tmp = meanInh_byTrial(od,tr) + meanExh_byTrial(od,tr);
                    if isfinite(tmp) && tmp > 0
                        cycleLen = tmp;
                    end
                end
            end

            % unwrapped phase (radians)
            phi_unwrapped = (2*pi) * (spk / cycleLen);

            % keep only first nCycles To Use cycles (0..2*pi*nCycles)
            keep = (phi_unwrapped >= 0) & (phi_unwrapped <= (2*pi*nCyclesToUse));
            phi_unwrapped = phi_unwrapped(keep);

            % wrap to [0,2pi)
            phases_by_trial{tr} = mod(phi_unwrapped, 2*pi);
        end

        phases_obs = vertcat(phases_by_trial{:});
        phases_obs = phases_obs(isfinite(phases_obs));

        if isempty(phases_obs)
            subplot(1,nOd,io);
            axis off;
            title(sprintf('Odor %d\n(no spikes)', od), 'Interpreter','none');
            continue;
        end

        % observed
        [phi_pref, Robs] = preferred_phase_and_R(phases_obs, nBins);

        % shuffled null
        Rnull = sniff_shuffle_Rnull(phases_by_trial, nBins, Nshuf, shuffleMode);

        if isempty(Rnull)
            subplot(1,nOd,io);
            axis off;
            title(sprintf('Odor %d\n(null empty)', od), 'Interpreter','none');
            continue;
        end

        thr90 = prctile(Rnull, 100*(1-alpha));
        coupled = (Robs > thr90);

        pval = (1 + sum(Rnull >= Robs)) / (numel(Rnull) + 1);

        % store
        results = [results; c, od, phi_pref, Robs, thr90, pval, coupled]; 

        % -------- subplot: CDF --------
        subplot(1, nOd, io);

        Rsort = sort(Rnull(:));
        y = (1:numel(Rsort))/numel(Rsort);

        plot(Rsort, y, 'k-', 'LineWidth', 1.5); hold on;
        xline(thr90, 'b--', 'LineWidth', 2);
        xline(Robs,  'r-',  'LineWidth', 2);
        ylim([0 1]);
        grid on;

        %xlabel('Resultant vector length R');
        xlabel('Resultant vector length $R$', 'Interpreter','latex');

        if io == 1
            %ylabel('CDF (P(R_{null} \le r))'); % plain text avoids interpreter warnings
            ylabel('CDF ($P(R_{\mathrm{null}} \le r)$)', 'Interpreter','latex');

        end

        title(sprintf('Odor %d | thr90=%.3f\np=%.3g | coupled=%d', ...
            od, thr90, pval, coupled), 'Interpreter','none');

        hold off;

        fprintf('Cell %d Odor %d: phi_pref=%.4f, Robs=%.4f, thr90=%.4f, p=%.4g, coupled=%d\n', ...
            c, od, phi_pref, Robs, thr90, pval, coupled);
    end

    % optional: overall title line
    sgtitle(sprintf('Cell %d | Sniff-shuffle significance (Nshuf=%d, cycles=%d)', ...
        c, Nshuf, nCyclesToUse), 'Interpreter','none');

    fprintf('\n');
end

% Optional: print results table
%if ~isempty(results)
   % T = array2table(results, 'VariableNames', ...
     %   {'cell','odor','phi_pref_rad','Robs','thr90','pval','isCoupled'});
   % disp(T);
%else
   % disp('No results (no spikes after filtering).');
%end

%% =================== LOCAL FUNCTIONS ===================

function [phi_pref, Rlen, Rvec, counts, thetaCenters, edges] = preferred_phase_and_R(phases, nBins)
    % phases should be in [0, 2*pi)
    phases = phases(:);
    phases = phases(isfinite(phases));
    phases = mod(phases, 2*pi);

    edges = linspace(0, 2*pi, nBins+1);
    counts = histcounts(phases, edges);
    thetaCenters = (edges(1:end-1) + edges(2:end))/2;

    if sum(counts) == 0
        phi_pref = NaN; Rlen = NaN; Rvec = NaN;
        return;
    end

    Rvec = sum(counts(:) .* exp(1i*thetaCenters(:))) / sum(counts);
    phi_pref = angle(Rvec);
    if phi_pref < 0, phi_pref = phi_pref + 2*pi; end
    Rlen = abs(Rvec);
end

function Rnull = sniff_shuffle_Rnull(phases_by_trial, nBins, Nshuf, shuffleMode)
    Rnull = NaN(Nshuf,1);

    for k = 1:Nshuf
        phases_sh = [];

        for tr = 1:numel(phases_by_trial)
            phi = phases_by_trial{tr};
            if isempty(phi), continue; end
            phi = phi(:);
            phi = phi(isfinite(phi));
            if isempty(phi), continue; end

            switch shuffleMode
                case "trial_phase_shift"
                    delta = 2*pi*rand(1);
                    phi = mod(phi + delta, 2*pi);
                otherwise
                    error('Unknown shuffleMode: %s', shuffleMode);
            end

            phases_sh = [phases_sh; phi]; %#ok<AGROW>
        end

        if isempty(phases_sh)
            Rnull(k) = NaN;
            continue;
        end

        [~, Rlen_sh] = preferred_phase_and_R(phases_sh, nBins);
        Rnull(k) = Rlen_sh;
    end

    Rnull = Rnull(isfinite(Rnull));
end
