% process_phase_data
function [allMu, allPvalues, sigCells] = process_phase_data_circ_rtest(PhaseAlign, optArg)
    % INPUTS:
    %  PhaseAlign:          structure containing spike phases (1 x nCells)
    %  optArg: may contain
    %     alpha [0.05]:                significance threshold
    %     threshold [0.8]:            fraction of trials that must be significant
    %     (NA) nShuffles [1000]:           for shuffle method (PPC), number of times we
    %                                 shuffle spikes before assessing significance
    %     angle_range [(0,8pi)]:     restrict phases in each trial;
    %                                equivalent to setting the number of breaths                            
    %     collapse_trial_flag [false]: Collapse trials? 
    %
    % OUTPUTS:
    %   allMu:       (size: nCells x nTrials) Mu (mean phase) for each trial
    %   allPvalues:   (size: nCells x nTrials) p-value of Rayleigh test for each trial
    %   sigCells: (size: variable) indices of cells that are significant:
    %                  i.e. "% trials with pvalue < alpha, is >= threshold"
    %
    
    % Default arguments
    alpha = 0.05;
    threshold = 0.8;
    %nShuffles = 1000;
    angle_range = [0, 8*pi];
    collapse_trial_flag = false;

    % Process optional arguments
    if isfield(optArg,'alpha'); alpha = optArg.alpha; end
    if isfield(optArg,'threshold'); threshold = optArg.threshold; end
    %if isfield(optArg,nShuffles); nShuffles = optArg.nShuffles; end
    if isfield(optArg,'angle_range'); angle_range = optArg.angle_range; end
    if isfield(optArg,'collapse_trial_flag'); collapse_trial_flag = optArg.collapse_trial_flag; end

    if collapse_trial_flag
        % We will combine all trials for one calculation
        nTrials = 1;
    else
        nTrials = length(PhaseAlign{1});
    end
    nCells = length(PhaseAlign);
    allMu = zeros(nCells, nTrials);
    allPvalues = zeros(nCells, nTrials);
    %allShuffles = cell(nCells, nTrials);
    

    for j1 = 1:nCells
        muVals = zeros(1, nTrials);
        if collapse_trial_flag
            % Turn into single vector: replace first entry of
            % "phaseAlign"
            % Turn into single vector: replace first entry of
            % "phaseAlign"
            try
                PhaseAlign{j1}{1} = cell2mat(PhaseAlign{j1});
            catch
            % Phases per trial might be saved as a row or column vector; if
            % row vectors, "try" clause will fail and you should use the transpose
                PhaseAlign{j1}{1} = cell2mat(PhaseAlign{j1}')';
            end
         
        end
        for t = 1:nTrials
            phaseData = PhaseAlign{j1}{t};
            validPhases = phaseData(phaseData >= angle_range(1) & phaseData <= angle_range(2));

            % Compute PPC for the trial
            if ~isempty(validPhases)
                muVals(t) = circ_mean(validPhases);
                [pval,~] =  circ_rtest(validPhases);
                allPvalues(j1, t) = pval;
            else
                muVals(t)=NaN;
                allPvalues(j1, t) = NaN;
            end
        end
        allMu(j1, :) = muVals;
    end
   
    % Significant cells
    sigCells = find(mean(allPvalues < alpha, 2, 'omitnan') > threshold);

end