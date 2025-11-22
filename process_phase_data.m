% process_phase_data
function [allPPC, allPvalues, sigCells] = process_phase_data(PhaseAlign, optArg)
    % INPUTS:
    %  PhaseAlign:          structure containing spike phases (1 x nCells)
    %  optArg: may contain
    %     alpha [0.05]:                significance threshold
    %     threshold [0.8]:            fraction of trials that must be significant
    %     nShuffles [1000]:           for shuffle method (PPC), number of times we
    %                                 shuffle spikes before assessing significance
    %     angle_range [(0,8pi)]:     restrict phases in each trial;
    %                                equivalent to setting the number of
    %                                 breaths
    %     collapse_trial_flag [false]: Collapse trials?         
    %     
    % OUTPUTS:
    %   allPPC:       (size: nCells x nTrials) PPC for each trial
    %   allPvalues:   (size: nCells x nTrials) pvalue of PPC for each trial
    %   sigCells: (size: variable) indices of cells that are significant:
    %                  i.e. "% trials with pvalue < alpha, is >= threshold"
    %

    % Default arguments
    alpha = 0.05;
    threshold = 0.8;
    nShuffles = 1000;
    angle_range = [0, 8*pi];
    collapse_trial_flag = false;

    % Process optional arguments
    if isfield(optArg,'alpha'); alpha = optArg.alpha; end
    if isfield(optArg,'threshold'); threshold = optArg.threshold; end
    if isfield(optArg,'nShuffles'); nShuffles = optArg.nShuffles; end
    if isfield(optArg,'angle_range'); angle_range = optArg.angle_range; end
    if isfield(optArg,'collapse_trial_flag'); collapse_trial_flag = optArg.collapse_trial_flag; end

    if collapse_trial_flag
        % We will combine all trials for one calculation
        nTrials = 1;
    else
        nTrials = length(PhaseAlign{1});
    end
    disp(nTrials)

    nCells = length(PhaseAlign);
    allPPC = zeros(nCells, nTrials);
    allPvalues = zeros(nCells, nTrials);
    allShuffles = cell(nCells, nTrials);
    
    for j1 = 1:nCells
        if collapse_trial_flag
            % Turn into single vector: replace first entry of
            % "phaseAlign"
            PhaseAlign{j1}{1} = cell2mat(PhaseAlign{j1});
        end
        ppcVals = zeros(1, nTrials);
        for t = 1:nTrials
            phaseData = PhaseAlign{j1}{t};
            validPhases = phaseData(phaseData >= angle_range(1) & phaseData <= angle_range(2));

            % Compute PPC for the trial
            if ~isempty(validPhases)
                ppcVals(t) = ppc(validPhases);
            else
                ppcVals(t)=NaN;
            end
        end
        allPPC(j1, :) = ppcVals;
    end
    
    % Shuffle PPC
    for j1 = 1:nCells
        for k1 = 1:nTrials
            temp = zeros(nShuffles, 1);
            phaseData = PhaseAlign{j1}{k1};
            oldspikes = phaseData(phaseData >= angle_range(1) & phaseData <= angle_range(2));
            if ~isempty(oldspikes)
                for k2 = 1:nShuffles
                    newspikes = oldspikes + (rand(size(oldspikes)) - 0.5) * (2 * pi);
                    temp(k2) = ppc(newspikes);
                end
                allShuffles{j1, k1} = temp;
                allPvalues(j1, k1) = mean(temp > allPPC(j1, k1));
            else
                allPvalues(j1, k1) = NaN;
            end
        end
    end
    
   
    % Significant cells
    sigCells = find(mean(allPvalues < alpha, 2, 'omitnan') > threshold);

end