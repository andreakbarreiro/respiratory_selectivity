% If necessary, set paths

set_paths_AKB

% Parameters
whichFile  = '170608';       % dataset
regText    = 'OB_';          % choose 'OB_' or 'CX_'

disp(regText)

%% -------- Spontaneous data --------
fname1 = sprintf('phase_BF_Spon_%s%s.mat', regText, whichFile);

load([dirloc fname1]);

% optArg may contain arguments
% However the routine also has defaults
% Since I want to archive the results, duplicate the arguments anyway
optArg = [];
optArg.alpha = 0.05;
optArg.threshold = 0.8;
optArg.nShuffles = 1000;
optArg.angle_range = [0, 8*pi];

% Shuffle-based
[allPPC_spon, pval_ppc_spon, sigCells_ppc_spon] = process_phase_data(PhaseAlign, optArg);

% Rayleigh r-test
[allMu_spon, pval_rtest_spon, sigCells_rtest_spon] = process_phase_data_circ_rtest(PhaseAlign, optArg);

%% -------- Stimulus-driven data --------
fname2 = sprintf('phase_BF_%s%s.mat', regText, whichFile);
load([dirloc fname2]);


% Shuffle-based
[allPPC_stim, pval_ppc_stim, sigCells_ppc_stim] = process_stimulus_phase_data(PhaseAlign, optArg);

% Rayleigh r-test
[allMu_stim, pval_rtest_stim, sigCells_rtest_stim] = process_stimulus_phase_data_rtest(PhaseAlign, optArg);


%% -------- Save Results --------
saveName = sprintf('phase_resp_results_%s%s.mat', regText, whichFile);
save(saveName, ...
    'optArg','dirloc',...
    'allPPC_spon','pval_ppc_spon','sigCells_ppc_spon', ...
    'allMu_spon','pval_rtest_spon','sigCells_rtest_spon', ...
    'allPPC_stim','pval_ppc_stim','sigCells_ppc_stim', ...
    'allMu_stim','pval_rtest_stim','sigCells_rtest_stim');
    %'sigCells_shuff_stim', 'sigCells_rtest_stim',

fprintf('\n Results saved to %s\n', saveName);


%% Now collapse trials together
optArg.collapse_trial_flag = true;
load([dirloc fname1]);

% Shuffle-based
[allPPC_spon_coll, pval_ppc_spon_coll, sigCells_ppc_spon_coll] = ...
    process_phase_data(PhaseAlign, optArg);

% Rayleigh r-test
[allMu_spon_coll, pval_rtest_spon_coll, sigCells_rtest_spon_coll] = ...
    process_phase_data_circ_rtest(PhaseAlign, optArg);

%% -------- Stimulus-driven data --------
fname2 = sprintf('phase_BF_%s%s.mat', regText, whichFile);
load([dirloc fname2]);

%% Need to come back and look at this
if (0)
% Shuffle-based
[allPPC_stim_coll, pval_ppc_stim_coll, sigCells_ppc_stim_coll] = ...
    process_stimulus_phase_data(PhaseAlign, optArg);

% Rayleigh r-test
[allMu_stim_coll, pval_rtest_stim_coll, sigCells_rtest_stim_coll] = ...
    process_stimulus_phase_data_rtest(PhaseAlign, optArg);
end

