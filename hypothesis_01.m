% Check hypothesis 01:
% 
% Neurons exhibiting statistically significant pairwise phase consistency (PPC) in response
% to odor stimulation will preferentially phase lock during retronasal stimulation. 
% % In other words, these
% neurons will have peak phases in the range 180◦ <θ <360◦, 
% %corresponding to the retronasal portion of the respiration cycle.

%% To assess this:
% 1) Read in file where we have precomputed significance
% 2) compute average Mu
% 3) Restrict to cells (or cell-odor pairs) which are significant.


% If necessary, set paths
set_paths_AKB

% Parameters
whichFile  = '170622';       % dataset
regText    = 'OB_';          % choose 'OB_' or 'CX_'


% 1) Read in file where we have precomputed significance
fname1 = sprintf('phase_resp_results_%s%s.mat', regText, whichFile);
load([outdir_data fname1]);

nCells = size(allMu_spon,1);

% 2) compute average Mu
%% Spontanous, PPC 
keepMu_spon_ppc_avg = mean(allMu_spon,2,'omitnan');

%% Spontanous, Rtest
keepMu_spon_rtest_avg = mean(allMu_spon,2,'omitnan');

%% Stimulus-dep
nOdors = length(allMu_stim);

keepMu_stim_ppc_avg = cell(1,nOdors);
for j1=1:nOdors
    keepMu_stim_ppc_avg{j1} = mean(allMu_stim{j1},2,'omitnan');
end

% 3) Restrict to cells (or cell-odor pairs) which are significant.

%% Make a table 
retroSelTable = zeros(nOdors+1,4);
for j1=1:nOdors
    % Significance by PPC
    retroSelTable(j1,1) = length(sigCells_ppc_stim{j1});
    retroSelTable(j1,2) = sum(keepMu_stim_ppc_avg{j1}(sigCells_ppc_stim{j1})<0);
    % Significance by rtest
    retroSelTable(j1,3) = length(sigCells_rtest_stim{j1});
    retroSelTable(j1,4) = sum(keepMu_stim_ppc_avg{j1}(sigCells_rtest_stim{j1})<0);
end
retroSelTable(nOdors+1,1) = length(sigCells_ppc_spon);
retroSelTable(nOdors+1,2) = sum(keepMu_spon_ppc_avg(sigCells_ppc_spon)<0);
retroSelTable(nOdors+1,3) = length(sigCells_rtest_spon);
retroSelTable(nOdors+1,4) = sum(keepMu_spon_ppc_avg(sigCells_rtest_spon)<0);

odors_to_keep = 1:6;
fprintf('\n\nStimulus-driven activity\n\n')
fprintf('Of %d significant cell-odor pairs (by PPC), %d are retro preferring\n', ...
    sum(retroSelTable(odors_to_keep,1)),sum(retroSelTable(odors_to_keep,2)) );
fprintf('Of %d significant cell-odor pairs (by Rtest), %d are retro preferring\n', ...
    sum(retroSelTable(odors_to_keep,3)),sum(retroSelTable(odors_to_keep,4)) );

fprintf('\n\nSpontanous activity\n\n')
fprintf('Of %d significant cells (by PPC), %d are retro preferring\n', ...
    retroSelTable(end,1),retroSelTable(end,2) );
fprintf('Of %d significant cells (by Rtest), %d are retro preferring\n', ...
    retroSelTable(end,3),retroSelTable(end,4) );


%% Optional:  To visualize histograms of mu
if (1)
    edges = [-1:.1:1]*pi;

    % Visualize mean Mu; for significant vs non-significant
    figure; 
    for j1=1:nOdors
        subplot(3,3,j1); 
        mu_sig = keepMu_stim_ppc_avg{j1}(sigCells_ppc_stim{j1});
        mu_nonsig = keepMu_stim_ppc_avg{j1}(setdiff(1:nCells,sigCells_ppc_stim{j1}));
    
        % Nonsignificant
        histogram(mu_nonsig,edges); hold on;
        histogram(mu_sig,edges,'DisplayStyle','stairs','linewidth',2);
        title(sprintf('Odor %d', j1));
        xlim([-pi,pi]);
    end
    % Spontaneous; with PPC
    subplot(3,3,8); 
    mu_sig = keepMu_spon_ppc_avg(sigCells_ppc_spon);
    mu_nonsig = keepMu_spon_ppc_avg(setdiff(1:nCells,sigCells_ppc_spon));
    % Nonsignificant
    histogram(mu_nonsig,edges); hold on;
    histogram(mu_sig,edges,'DisplayStyle','stairs','linewidth',2);
    title(sprintf('Spontaneous; using PPC'));
    xlim([-pi,pi]);
    
    % Spontaneous; with Rtest
    subplot(3,3,9); 
    mu_sig = keepMu_spon_ppc_avg(sigCells_rtest_spon);
    mu_nonsig = keepMu_spon_ppc_avg(setdiff(1:nCells,sigCells_rtest_spon));
    % Nonsignificant
    histogram(mu_nonsig,edges); hold on;
    histogram(mu_sig,edges,'DisplayStyle','stairs','linewidth',2);
    title(sprintf('Spontaneous; using Rtest'));
    xlim([-pi,pi]);
end