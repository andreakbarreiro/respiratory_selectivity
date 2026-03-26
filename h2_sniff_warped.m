% ===============================================================
% Hypothesis 2:
% Cells that are phase-selective during spontaneous activity
% are a subset of those that are phase-selective during stimulus.
%
% Here:
%   odors 1:6 = stimulus
%   odor 7    = spontaneous / mineral oil
% ===============================================================

clear; clc
dirloc = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';
load(fullfile(dirloc,'phase_selectivity_survey.mat'));

nAnimals = length(Survey);

subsetFrac_per_animal = nan(nAnimals,1);
nSpontCoupled_per_animal = zeros(nAnimals,1);
nSubset_per_animal = zeros(nAnimals,1);

for a = 1:nAnimals
    myresult = Survey(a).result;

    nOdor = size(myresult,1);
    nCell = size(myresult,2);

    if nOdor < 7
        error('Animal %d does not have 7 odors.', a);
    end

    coupled_array = false(nOdor,nCell);
    valid_entry   = false(nOdor,nCell);

    for od = 1:nOdor
        for c = 1:nCell
            entry = myresult(od,c);

            if isempty(entry), continue; end

            hasCoupled = isfield(entry,'coupled') && ~isempty(entry.coupled);

            if hasCoupled
                coupled_array(od,c) = logical(entry.coupled);
                valid_entry(od,c) = true;
            end
        end
    end

    stimCoupled = any(coupled_array(1:6,:), 1);     % coupled to at least one stimulus odor
    spontCoupled = coupled_array(7,:);              % coupled to spontaneous/mineral oil

    validStim = any(valid_entry(1:6,:),1);
    validSpont = valid_entry(7,:);
    validCell = validStim & validSpont;

    spontCoupled_valid = spontCoupled & validCell;
    subsetMask = spontCoupled & stimCoupled & validCell;

    nSpont = sum(spontCoupled_valid);
    nSubset = sum(subsetMask);

    nSpontCoupled_per_animal(a) = nSpont;
    nSubset_per_animal(a) = nSubset;

    if nSpont > 0
        subsetFrac_per_animal(a) = nSubset / nSpont;
    end

    fprintf('Animal %s: spont-coupled=%d, also stim-coupled=%d, subset=%.1f%%\n', ...
        Survey(a).animal, nSpont, nSubset, 100*subsetFrac_per_animal(a));
end

%% overall summary
totalSpont = sum(nSpontCoupled_per_animal);
totalSubset = sum(nSubset_per_animal);
overallSubsetFrac = totalSubset / totalSpont;

fprintf('\n=====================================\n');
fprintf('Total spontaneous-coupled cells = %d\n', totalSpont);
fprintf('Subset count = %d\n', totalSubset);
fprintf('Overall subset fraction = %.1f%%\n', 100*overallSubsetFrac);

if totalSpont == 0
    disp('❌ Hypothesis 2 NOT supported (no spontaneous-coupled cells)');
elseif overallSubsetFrac == 0.90
    disp('✅ Hypothesis 2 fully supported');
elseif overallSubsetFrac >= 0.80
    disp('⚠️ Hypothesis 2 partially supported');
else
    disp('❌ Hypothesis 2 NOT supported');
end

%% plot
figure('Color','w');
bar(1:nAnimals, 100*subsetFrac_per_animal, 'FaceColor', [0.3 0.7 0.4]);
hold on;
yline(90, 'r--', 'LineWidth', 1.5);
xlabel('Animal ID');
ylabel('% spont-coupled cells also coupled in stimulus');
title('Hypothesis 2 across animals');
ylim([0 100]);
grid on;
hold off;