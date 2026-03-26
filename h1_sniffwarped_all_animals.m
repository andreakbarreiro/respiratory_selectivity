set_paths_AKB
%dirloc = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';

load(fullfile(dirloc,'phase_selectivity_survey.mat'));

nAnimals = length(Survey);

percentRetro_per_animal = nan(nAnimals,1);
nCoupled_per_animal     = zeros(nAnimals,1);
nRetro_per_animal       = zeros(nAnimals,1);
nMissing_per_animal     = zeros(nAnimals,1);

% What is the "null hypothesis" for cells are more likely 
% to be selective during retronasal phase (i.e. is it possible the
% preferred phases are uniformly distributed thoroughout breath cycle?)
%
nullSignificantPhasePerc = zeros(nAnimals,1);

% For "phase-coupled" cells, get preferred phase
phiCoupled = cell(nAnimals,1);
ItoEConst = zeros(nAnimals,1);

for animalID = 1:nAnimals

    myresult = Survey(animalID).result;

    nOdor = size(myresult,1);
    nCell = size(myresult,2);

    coupled_array  = false(nOdor,nCell);
    phi_pref_array = nan(nOdor,nCell);
    ItoE_array     = nan(nOdor,nCell);
    valid_entry    = false(nOdor,nCell);

    for j1 = 1:nOdor
        for j2 = 1:nCell

            entry = myresult(j1,j2);

            if isempty(entry)
                nMissing_per_animal(animalID) = nMissing_per_animal(animalID) + 1;
                continue;
            end

            hasCoupled = isfield(entry,'coupled')  && ~isempty(entry.coupled);
            hasPhi     = isfield(entry,'phi_pref') && ~isempty(entry.phi_pref);
            hasItoE    = isfield(entry,'ItoE')     && ~isempty(entry.ItoE);

            if ~(hasCoupled && hasPhi && hasItoE)
                nMissing_per_animal(animalID) = nMissing_per_animal(animalID) + 1;
                fprintf('Animal %d, odor %d, cell %d has missing data\n', animalID, j1, j2);
                continue;
            end

            coupled_array(j1,j2)  = logical(entry.coupled);
            phi_pref_array(j1,j2) = entry.phi_pref;
            ItoE_array(j1,j2)     = entry.ItoE;
            valid_entry(j1,j2)    = true;
        end
    end

    % Constant for the animal, only need to evaluate once
    ItoEConst(animalID) = entry.ItoE;
    nullSignificantPhasePerc(animalID) = 1- (entry.ItoE)/(2*pi);

    % sniff-warped retro definition
    isRetroPref = phi_pref_array > ItoE_array;

    % only valid + coupled entries count
    validCoupled = valid_entry & coupled_array;
    retroPref_and_coupled = validCoupled & isRetroPref;

    nCoupledOverall = sum(validCoupled(:));
    nRetroOverall   = sum(retroPref_and_coupled(:));

    nCoupled_per_animal(animalID) = nCoupledOverall;
    nRetro_per_animal(animalID)   = nRetroOverall;

    phiCoupled{animalID} = phi_pref_array(validCoupled);
    
    if nCoupledOverall > 0
        percentRetro_per_animal(animalID) = nRetroOverall / nCoupledOverall;
    end

    fprintf('Animal %d: coupled=%d, retro=%d, percent=%.1f%%, missing=%d\n', ...
        animalID, nCoupledOverall, nRetroOverall, ...
        100*percentRetro_per_animal(animalID), nMissing_per_animal(animalID));
end

%% overall summary across animals
totalCoupled = sum(nCoupled_per_animal);
totalRetro   = sum(nRetro_per_animal);
totalMissing = sum(nMissing_per_animal);

overallPercentRetro = totalRetro / totalCoupled;

fprintf('\n=====================================\n');
fprintf('Total animals = %d\n', nAnimals);
fprintf('Total coupled = %d\n', totalCoupled);
fprintf('Total retro   = %d\n', totalRetro);
fprintf('Total missing = %d\n', totalMissing);
fprintf('Overall percent retro = %.1f%%\n', 100*overallPercentRetro);

if totalCoupled == 0
    disp('❌ Hypothesis #1 NOT supported (no coupled cells)');
elseif overallPercentRetro == 0.80
    disp('✅ Hypothesis #1 fully supported');
elseif overallPercentRetro >= 0.70
    disp('⚠️ Hypothesis #1 partially supported');
else
    disp('❌ Hypothesis #1 NOT supported');
end

%% plot
figure('Color','w');
bar(1:nAnimals, 100*percentRetro_per_animal, 'FaceColor', [0.2 0.5 0.85]);
hold on;
yline(90, 'r--', 'LineWidth', 1.5);
xlabel('Animal ID');
ylabel('% retro among coupled cells');
title('Hypothesis 1 across animals (sniff-warped)');
ylim([0 100]);
grid on;
hold off;


figure;
for j1=1:nAnimals
    subplot(2,4,j1);
%polar plot
% preferred phases of only coupled cells
    if (0)
    phi_coupled = phi_pref_array(coupled_array);
    % remove NaN just in case
    phi_coupled = phi_coupled(~isnan(phi_coupled));
    else
        phi_coupled = phiCoupled{j1};
    end
    %figure('Color','w');
    polarhistogram(phi_coupled, 24, ...
        'FaceColor', [0.2 0.5 0.85], ...
        'FaceAlpha', 0.8);
    title(sprintf('Animal %d',j1));
    
    hold on;
    
    % mark retro range boundaries: pi and 2*pi
    rl = rlim;
    polarplot([ItoEConst(j1) ItoEConst(j1)], [0 rl(2)], 'r--', 'LineWidth', 2);
    
    % 2*pi is same as 0, so draw at angle 0
    polarplot([0 0], [0 rl(2)], 'r--', 'LineWidth', 2);
    
    hold off;
end


phi_coupled = phi_pref_array(coupled_array);
phi_coupled = phi_coupled(~isnan(phi_coupled));

isRetro = (phi_coupled >= pi) & (phi_coupled <= 2*pi);

figure('Color','w');

% non-retro (gray)
polarhistogram(phi_coupled(~isRetro), 24, ...
    'FaceColor', [0.75 0.75 0.75], ...
    'FaceAlpha', 0.8);
hold on;

% retro (RED)
polarhistogram(phi_coupled(isRetro), 24, ...
    'FaceColor', [0.85 0.2 0.2], ...
    'FaceAlpha', 0.9);

rl = rlim;
polarplot([pi pi], [0 rl(2)], 'k--', 'LineWidth', 2);
polarplot([0 0], [0 rl(2)], 'k--', 'LineWidth', 2);

title('Coupled cells (RED = retro, GRAY = non-retro)');
legend({'Non-retro (0–\pi)','Retro (\pi–2\pi)'}, 'Location','bestoutside');

hold off;