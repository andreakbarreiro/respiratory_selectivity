function [allPPC, allPvalues, sigCells] = process_stimulus_phase_data(PhaseAlign, optArg)
    % INPUTS:
    %  PhaseAlign:          structure containing spike phases (nOdors x nCells)
    %  optArg: may contain
    %     alpha [0.05]:                significance threshold
    %     threshold [0.8]:            fraction of trials that must be significant
    %     nShuffles [1000]:           for shuffle method (PPC), number of times we
    %                                 shuffle spikes before assessing significance
    %     angle_range [(0,8pi)]:     restrict phases in each trial;
    %                               equivalent to setting the number of
    %                               breaths
    % OUTPUTS:
    %   allPPC:       (struct: 1 x nOdors)
    %       allPPC{k} = (array: nCells x nTrials) PPC for each trial
    %   allPvalues:   (struct: 1 x nOdors)
    %       allPvalues{k} = (array: nCells x nTrials) pvalue of PPC for each trial
    %   sigCells:     (struct: 1 x nOdors)
    %       sigCells{k} = (array: variable size) indices of cells that are significant:
    %                  i.e. "is [% trials with pvalue < alpha] >= threshold?"
    %

    [nOdors, ~] = size(PhaseAlign);
    allPPC      = cell(nOdors, 1);
    allPvalues  = cell(nOdors, 1);
    sigCells    = cell(nOdors, 1);

    % Put this in the "rtest" function
    %mu = cell(nOdors, 1);

    for odor = 1:nOdors
    
        %% ISSUE: This does not function properly if collapse_trial_flag=true
        [PPC, Pvalues, sCells] = process_phase_data(PhaseAlign(odor,:), optArg);
        allPPC{odor} = PPC; allPvalues{odor} = Pvalues; sigCells{odor} = sCells;
        %mu{odor} = compute_mu(PhaseAlign(odor,:), SigCells);
    end
end