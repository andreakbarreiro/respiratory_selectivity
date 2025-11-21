% If necessary, set paths

set_paths_AKB

% Parameters
whichFile  = '170608';       % dataset
regText    = 'OB_';          % choose 'OB_' or 'CX_'

disp(regText)

%% -------- Spontaneous data --------
load([dirloc 'phase_BF_Spon_' regText whichFile '.mat']);

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


%% -------- Save Results --------
saveName = sprintf('phase_resp_results_%s%s.mat', regText, whichFile);
save(saveName, ...
    'optArg','allPPC_spon','pval_ppc_spon','sigCells_ppc_spon',...
    'allMu_spon','pval_rtest_spon','sigCells_rtest_spon', 'dirloc');
    %'allPPC_stim','mu_stim', ...
    %'sigCells_shuff_stim', 'sigCells_rtest_stim',

fprintf('\n Results saved to %s\n', saveName);

