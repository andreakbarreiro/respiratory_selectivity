% If necessary, set paths

set_paths_AKB

% Parameters
whichFile  = '170608';       % dataset
regText    = 'OB_';          % choose 'OB_' or 'CX_'

%% -------- Spontaneous data --------
load([dirloc 'phase_BF_Spon_' regText whichFile '.mat']);

% optArg may contain arguments
% However the routine also has defaults
optArg = [];

% Shuffle-based
[allPPC_spon, pval_ppc_spon, sigCells_shuff_spon] = process_phase_data(PhaseAlign, optArg);

% Rayleigh r-test
[allMu_spon, pval_rtest_spon, sigCells_rtest_spon] = process_phase_data_circ_rtest(PhaseAlign, optArg);
