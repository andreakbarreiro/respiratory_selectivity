% test_graphics.m : test visualization functions

% If necessary, set paths
set_paths_AKB

% Parameters
whichFile  = '170608';       % dataset
regText    = 'OB_';          % choose 'OB_' or 'CX_'

%% Name of phase data file
phase_dfile = sprintf('phase_BF_%s%s.mat', regText, whichFile);
myphase=load([dirloc phase_dfile]);

%% Name of statistics file
stats_dir   = './';   % where I saved the files
stats_dfile = sprintf('phase_resp_results_%s%s.mat', regText, whichFile);

mystats = load([stats_dir stats_dfile]);

%% Venn diagram
A = length(mystats.sigCells_ppc_spon);
B = length(mystats.sigCells_rtest_spon);
AB = length(intersect(mystats.sigCells_ppc_spon, mystats.sigCells_rtest_spon));
figure; venn_custom(A,B,AB,'Spontaneous','P-test','R-test');

%% PSPH
allPSPH = cell(size(myphase.PhaseAlign));
[nOdors,nCells]=size(myphase.PhaseAlign);
for j1=1:nOdors
    for k1=1:nCells
        [mypsph,centers]=psph_fn(myphase.PhaseAlign{j1,k1},[]);
        allPSPH{j1,k1}=mypsph;
    end
end