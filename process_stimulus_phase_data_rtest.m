function [allMu, allPvalues, sigCells] = process_stimulus_phase_data_rtest(PhaseAlign, optArg)
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
    %   allMu:       (struct: 1 x nOdors)
    %       allMu{k} = (array: nCells x nTrials) Mu for each trial
    %   allPvalues:   (struct: 1 x nOdors)
    %       allPvalues{k} = (array: nCells x nTrials) p-value of Rayleigh test for each trial
    %   sigCells:     (struct: 1 x nOdors)
    %       sigCells{k} = (array: variable size) indices of cells that are significant:
    %                  i.e. "is [% trials with pvalue < alpha] >= threshold?"
    %

    [nOdors, ~] = size(PhaseAlign);
    allMu      = cell(nOdors, 1);
    allPvalues  = cell(nOdors, 1);
    sigCells    = cell(nOdors, 1);

    % Put this in the "rtest" function
    %mu = cell(nOdors, 1);

    for odor = 1:nOdors
        [mu, Pvalues, sCells] = process_phase_data_circ_rtest(PhaseAlign(odor,:), optArg);
        allMu{odor} = mu; allPvalues{odor} = Pvalues; sigCells{odor} = sCells;
        %mu{odor} = compute_mu(PhaseAlign(odor,:), SigCells);
    end
end