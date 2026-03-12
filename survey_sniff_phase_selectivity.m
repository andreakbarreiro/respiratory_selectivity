% ===============================================================
% Survey sniff phase selectivity across ALL animals / cells / odors
% ===============================================================

clear; clc
addpath('util_graphics')

%% ================= USER SETTINGS =================
dirloc = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';

fileList = {'170622','170621','170619','170618','170614','170613','170609','170608'};

Nshuf = 100;
alpha = 0.10;
nCyclesToUse = 2;

shuffleMode = "trial_phase_shift";

%% ================= STORAGE =================

row = 0;

Results = table();

Survey = struct();

%% ================= MAIN LOOP =================

for fi = 1:numel(fileList)

    animalID = fileList{fi};

    dataFile = sprintf('sniffwarped_BF_OB_%s.mat', animalID);
    fullpath = fullfile(dirloc,dataFile);

    fprintf('\n=================================\n')
    fprintf('Processing animal %s\n',animalID)
    fprintf('=================================\n')

    D = load(fullpath);

    SWarpedAlign = D.SWarpedAlign;

    [nOdors,nCells] = size(SWarpedAlign);

    cycleLen = D.meanInh + D.meanExh;

    scale_to_phase = (2*pi)/cycleLen;

    Survey(fi).animal = animalID;

    %% ----- LOOP CELLS -----

    for c = 1:nCells

        for od = 1:nOdors

            trialCell = SWarpedAlign{od,c};

            if isempty(trialCell) || ~iscell(trialCell)
                continue
            end

            %% -------- BUILD PHASES BY TRIAL --------

            phases_by_trial = cell(size(trialCell));

            for tr = 1:numel(trialCell)

                spk = trialCell{tr};

                if isempty(spk)
                    phases_by_trial{tr} = [];
                    continue
                end

                phi = spk(:)*scale_to_phase;

                keep = phi>=0 & phi<=2*pi*nCyclesToUse;

                phi = phi(keep);

                phases_by_trial{tr} = mod(phi,2*pi);

            end

            %% -------- FLATTEN SPIKES --------

            tmp = cellfun(@(x)x(:),phases_by_trial,'UniformOutput',false);
            tmp = tmp(~cellfun(@isempty,tmp));

            if isempty(tmp)
                continue
            end

            phases_obs = vertcat(tmp{:});
            phases_obs = mod(phases_obs,2*pi);

            %% -------- COMPUTE METRICS --------

            M = phase_selectivity_metrics(phases_by_trial,Nshuf,alpha,shuffleMode);

            phi_pref = M.phi_pref;
            Robs = M.Robs;
            thr90 = M.thr90;
            pval = M.pval;
            coupled = M.coupled;

            %% -------- STORE STRUCT --------

            Survey(fi).result(od,c).phi_pref = phi_pref;
            Survey(fi).result(od,c).Robs = Robs;
            Survey(fi).result(od,c).thr90 = thr90;
            Survey(fi).result(od,c).pval = pval;
            Survey(fi).result(od,c).coupled = coupled;

            %% -------- STORE TABLE --------

            row = row + 1;

            Results.animal{row,1} = animalID;
            Results.cell(row,1) = c;
            Results.odor(row,1) = od;

            Results.phi_pref(row,1) = phi_pref;
            Results.Robs(row,1) = Robs;
            Results.thr90(row,1) = thr90;
            Results.pval(row,1) = pval;
            Results.coupled(row,1) = coupled;

            Results.nSpikes(row,1) = length(phases_obs);

            fprintf('Cell %d Odor %d | R=%.3f | thr=%.3f | p=%.4f | coupled=%d\n',...
                c,od,Robs,thr90,pval,coupled);

        end
    end
end

%% ================= SAVE =================

save(fullfile(dirloc,'phase_selectivity_survey.mat'),...
    'Survey','Results','Nshuf','alpha','nCyclesToUse')

disp('Survey saved.')