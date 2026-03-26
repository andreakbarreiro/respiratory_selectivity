% ===============================================================
% Hypothesis 3:
% Mean phase-locking strength R is higher during stimulus
% than during spontaneous activity.
%
% Here:
%   odors 1:6 = stimulus
%   odor 7    = spontaneous / mineral oil
% ===============================================================

clear; clc
dirloc = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';
load(fullfile(dirloc,'phase_selectivity_survey.mat'));

nAnimals = length(Survey);

meanR_stim_per_animal = nan(nAnimals,1);
meanR_spont_per_animal = nan(nAnimals,1);
pval_per_animal = nan(nAnimals,1);

allR_stim = [];
allR_spont = [];

for a = 1:nAnimals
    myresult = Survey(a).result;

    nOdor = size(myresult,1);
    nCell = size(myresult,2);

    if nOdor < 7
        error('Animal %d does not have 7 odors.', a);
    end

    Robs_array = nan(nOdor,nCell);
    valid_entry = false(nOdor,nCell);

    for od = 1:nOdor
        for c = 1:nCell
            entry = myresult(od,c);

            if isempty(entry), continue; end

            hasRobs = isfield(entry,'Robs') && ~isempty(entry.Robs);

            if hasRobs
                Robs_array(od,c) = entry.Robs;
                valid_entry(od,c) = true;
            end
        end
    end

    Rstim_cell = nan(1,nCell);
    Rspont_cell = nan(1,nCell);

    for c = 1:nCell
        stimVals = Robs_array(1:6,c);
        stimVals = stimVals(~isnan(stimVals));

        if ~isempty(stimVals) && valid_entry(7,c)
            Rstim_cell(c) = mean(stimVals);
            Rspont_cell(c) = Robs_array(7,c);
        end
    end

    validCell = ~isnan(Rstim_cell) & ~isnan(Rspont_cell);

    Rstim_valid = Rstim_cell(validCell);
    Rspont_valid = Rspont_cell(validCell);

    meanR_stim_per_animal(a) = mean(Rstim_valid);
    meanR_spont_per_animal(a) = mean(Rspont_valid);

    allR_stim = [allR_stim; Rstim_valid(:)];
    allR_spont = [allR_spont; Rspont_valid(:)];

    if ~isempty(Rstim_valid)
        pval_per_animal(a) = signrank(Rstim_valid, Rspont_valid);
    end

    fprintf('Animal %s: mean R stim = %.4f, mean R spont = %.4f, p = %.4g\n', ...
        Survey(a).animal, meanR_stim_per_animal(a), meanR_spont_per_animal(a), pval_per_animal(a));
end

%% overall summary
overallMeanStim = mean(allR_stim);
overallMeanSpont = mean(allR_spont);
pOverall = signrank(allR_stim, allR_spont);

fprintf('\n=====================================\n');
fprintf('Overall mean R stim  = %.4f\n', overallMeanStim);
fprintf('Overall mean R spont = %.4f\n', overallMeanSpont);
fprintf('Overall signrank p   = %.4g\n', pOverall);

if overallMeanStim > overallMeanSpont
    disp('✅ Hypothesis 3 supported');
else
    disp('❌ Hypothesis 3 NOT supported');
end

%% plot
figure('Color','w');
b = bar([meanR_stim_per_animal, meanR_spont_per_animal]);
xlabel('Animal ID');
ylabel('Mean phase-locking strength R');
title('Hypothesis 3 across animals');
legend({'Stimulus (mean odors 1-6)','Spontaneous (odor 7)'}, 'Location','best');
grid on;