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

% Smooth using simple moving average (heartbeat style)
win = 3; kernel = ones(win,1)/win;
myopt=[];
myopt.myfilter = kernel;

allPSPH_smoothed = cell(size(myphase.PhaseAlign));
for j1=1:nOdors
    for k1=1:nCells
        [mypsph,centers]=psph_fn(myphase.PhaseAlign{j1,k1},myopt);
        allPSPH_smoothed{j1,k1}=mypsph;
    end
end


% Cells that are significant for at least one stim (including "clean")
anySig = unique(cell2mat(mystats.sigCells_ppc_stim));
odorNames  = {'2hex','ea','eb','et','hexa','iso','clean'};
colors     = lines(length(odorNames));

for k1 = 1:length(anySig)
    whichCell = anySig(k1);
    figure; hold on;
    for j1 = 1:nOdors
        if ismember(whichCell,mystats.sigCells_ppc_stim{j1})
            plot(centers,allPSPH{j1,whichCell},'.-',...
                  'LineWidth', 2, 'Color', colors(j1,:));
            plot(centers,allPSPH_smoothed{j1,whichCell},'-',...
                  'LineWidth', 2, 'Color', colors(j1,:));
        else
            plot(centers,allPSPH{j1,whichCell},'.-',...
                  'LineWidth', 1, 'Color', colors(j1,:));
            plot(centers,allPSPH_smoothed{j1,whichCell},'-',...
                  'LineWidth', 1, 'Color', colors(j1,:));
        end
    end
     % Formatting
    %title(sprintf('Cell %d – PSPH (High-PPC, Non-Sig)', c), 'FontWeight','bold');
    xlabel('Respiration Phase (cycles of 2\pi)');
    ylabel('Spike Probability (PSPH)');
    %xlim([0 8]);
    set(gca, 'FontSize', 13, 'Box', 'off', 'LineWidth', 1.2);
    legend(odorNames, 'Location', 'northeastoutside');
    sgtitle(sprintf('PSPH Visualization – Cell %d (%s%s)', whichCell, regText, whichFile), ...
            'FontWeight','bold','FontSize',14);
   
end