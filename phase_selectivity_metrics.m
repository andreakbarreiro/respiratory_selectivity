function M = phase_selectivity_metrics(phases_by_trial, Nshuf, alpha, shuffleMode)
%PHASE_SELECTIVITY_METRICS Compute preferred phase and Fukunaga-style shuffle significance.
%
% Inputs
%   phases_by_trial : cell array; each cell contains spike phases in [0, 2*pi)
%phases_by_trial = {
   % [0.2 0.4 0.5], ...
    %[1.0 1.2], ...
    %[5.8 6.0]
     %};
%   Nshuf           : number of shuffles
%   alpha           : significance level (e.g., 0.10 for 90th percentile threshold)
%   shuffleMode     : currently supports "trial_phase_shift"
%
% Outputs (struct M)
%   M.phi_pref  : preferred phase (rad, in [0,2*pi))
%   M.Robs      : observed resultant vector length
%   M.Rvec      : observed resultant vector (complex)



%   M.Rnull     : shuffled null distribution of resultant lengths
%   M.thr90     : (1-alpha) percentile threshold from Rnull
%   M.pval      : empirical one-sided p-value
%   M.coupled   : logical flag (Robs > threshold)

    % ---------- Collect observed phases ----------
   % phases_obs = vertcat(phases_by_trial{:});
%     phases_obs = [];
% for tr = 1:numel(phases_by_trial)
%     phases_obs = [phases_obs; phases_by_trial{tr}(:)];
% end
%     phases_obs = phases_obs(:);
%     phases_obs = phases_obs(isfinite(phases_obs));
%     phases_obs = mod(phases_obs, 2*pi);
% if nargin < 4
%     error('phase_selectivity_metrics requires 4 inputs: phases_by_trial, Nshuf, alpha, shuffleMode');
% end
% ---------- Collect observed phases ----------
tmp = cellfun(@(x) x(:), phases_by_trial(:), 'UniformOutput', false);
tmp = tmp(~cellfun(@isempty, tmp));   % optional: remove empty trials

if isempty(tmp)
    phases_obs = [];
else
    phases_obs = vertcat(tmp{:});
end

phases_obs = phases_obs(isfinite(phases_obs));
phases_obs = mod(phases_obs, 2*pi);
    if isempty(phases_obs)
        M = struct( ...
            'phi_pref', NaN, ...
            'Robs', NaN, ...
            'Rvec', NaN, ...
            'Rnull', [], ...
            'thr90', NaN, ...
            'pval', NaN, ...
            'coupled', false);
        return;
    end

    % ---------- Observed resultant vector (unbinned) ----------
    Rvec = mean(exp(1i * phases_obs));
    Robs = abs(Rvec);
    phi_pref = mod(angle(Rvec), 2*pi);

    % ---------- Shuffled null distribution ----------
    Rnull = NaN(Nshuf, 1);

    for k = 1:Nshuf
        phases_sh = [];

        for tr = 1:numel(phases_by_trial)
            phi = phases_by_trial{tr};
            if isempty(phi), continue; end

            phi = phi(:);
            phi = phi(isfinite(phi));
            if isempty(phi), continue; end

            switch string(shuffleMode)
                case "trial_phase_shift"
                    delta = 2*pi*rand(1);
                    phi = mod(phi + delta, 2*pi);
                otherwise
                    error('Unknown shuffleMode: %s', string(shuffleMode));
            end

            phases_sh = [phases_sh; phi]; %#ok<AGROW>
        end

        if ~isempty(phases_sh)
            Rnull(k) = abs(mean(exp(1i * phases_sh)));
        end
    end

    Rnull = Rnull(isfinite(Rnull));

    if isempty(Rnull)
        thr90 = NaN;
        pval = NaN;
        coupled = false;
    else
        thr90 = prctile(Rnull, 100*(1-alpha));
        pval = (1 + sum(Rnull >= Robs)) / (numel(Rnull) + 1);
        coupled = (Robs > thr90);
    end

    % ---------- Output struct ----------
    M = struct( ...
        'phi_pref', phi_pref, ...
        'Robs', Robs, ...
        'Rvec', Rvec, ...
        'Rnull', Rnull, ...
        'thr90', thr90, ...
        'pval', pval, ...
        'coupled', coupled);
end