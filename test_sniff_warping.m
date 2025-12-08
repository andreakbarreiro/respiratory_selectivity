%% Test sniff-warping as in Shusterman, et al 2011
%
% "We defined two intervals: the first is from inhalation onset to inhalation 
% offset and the second is the rest of the sniffing cycle, from the inhalation 
% offset to the next inhalation onset. For the whole session, we estimated an 
% average duration for both intervals. Each interval of the sniffing data, 
% together with correspondent spiking data, was stretched or compressed to 
% make its duration equal to the duration of the average interval."
%
%
% If necessary, set paths

set_paths_AKB

% Parameters
whichFile  = '170608';       % dataset
regText    = 'CX_';          % choose 'OB_' or 'CX_'

%disp(regText)

%% -------- Stimulus dep. data --------
fname_in = sprintf('phase_BF_%s%s.mat', regText, whichFile);

load([dirloc fname_in]);

% We saved 5s before, 10s after odor onset (0=the first inhale after odor
% onset)
allInh = [];
allExh = [];

% Cell array of nOdors x nTrials (per odor)
nTrials = numel(PREXTimesAlign);

% In case we want to look at trial-by-trial variability later
meanInh_byTrial = zeros(size(PREXTimesAlign));
meanExh_byTrial = meanInh_byTrial;
stdInh_byTrial = meanInh_byTrial;
stdExh_byTrial = meanInh_byTrial;

%% (1) Compute mean inhale, mean exhale across all trials
for j1=1:nTrials
    %disp([PREXTimesAlign{j1}(1) POSTXTimesAlign{j1}(1)]) 
    preall  = PREXTimesAlign{j1};
    postall = POSTXTimesAlign{j1};
    if preall(1)>postall(1)
        % first exhale occurs before inhale: discard that time point
        postall = postall(2:end);
    end
    if preall(end)<postall(end)
        % last inhale occurs before last exhale; discard 
        postall = postall(1:end-1);
    end
    if ~(length(preall)== length(postall)+1)
        warning('Problem: preall, postall not expected shape');
    end
    % We should now have N+1 Inhale times; N exhale times; meaning we have N full breaths 
    inhale_temp = postall(1:end)-preall(1:end-1);
    exhale_temp = preall(2:end)- postall(1:end);

    meanInh_byTrial(j1) = mean(inhale_temp);
    stdInh_byTrial(j1) = std(inhale_temp);
    meanExh_byTrial(j1) = mean(exhale_temp);
    stdExh_byTrial(j1) = std(exhale_temp);

    allInh = [allInh;inhale_temp'];
    allExh = [allExh;exhale_temp'];

end
% If we want ms (vs s)
timeUnit = 1;

allInh = allInh*timeUnit; allExh = allExh*timeUnit;
meanInh = mean(allInh); meanExh = mean(allExh);

% Look at histogram of inhale, exhale lengths
if (0)
edges = [0:.05:1]*timeUnit;

figure; subplot(1,2,1); 
histogram(allInh,edges); hold on;
histogram(allExh, edges,'DisplayStyle','stairs','LineWidth',2);
set(gca,'FontSize',16);
title(sprintf('Inhale vs Exhale: mouse %s',whichFile));

subplot(1,2,2);
plot(allInh,allExh,'*'); hold on;
xLim = xlim;
plot(xLim, xLim*(meanExh/meanInh),'k--');
xlabel('Inhale (ms)'); ylabel('Exhale (ms)')
set(gca,'FontSize',16);
end

disp([mean(allInh) mean(allExh)])

%% (2) Warp each trial's spikes so they fit within the mean breath cycle
% Spikes are already identified with phases
% "Stretch" these into a time
SWarpedAlign = cell(size(PhaseAlign));

for j2=1:numel(PhaseAlign)
    myphases = PhaseAlign{j2};
    
    % Multiple trials
    temp_warped = cell(size(myphases));
    
    for j1=1:length(myphases)
        % divide by pi
        temp = myphases{j1}/pi;
    
        % inhale vs exhale
        % If EVEN: inhale
        % If ODD: exhale
        inh_vs_exh = floor(temp);
        time_in_breath_phase = mod(temp,1);
    
        all_warped = nan(size(temp));
        for k1=1:length(temp)
            if (mod(inh_vs_exh(k1),2)==0)
                %disp(temp(k1))
                all_warped(k1) = ...
                    inh_vs_exh(k1)*(meanInh+meanExh)/2 + time_in_breath_phase(k1)*meanInh;
            else
                % Number of full breaths + mean Inhale time + 
                all_warped(k1) = ...
                    (inh_vs_exh(k1)-1)*(meanInh+meanExh)/2 + meanInh ...
                    + time_in_breath_phase(k1)*meanExh;
            end
    
        end
        temp_warped{j1} = all_warped;
    end
    SWarpedAlign{j2}=temp_warped;
end

if (1)
    % Visualize an example
    j2 = 6;  % Choose a stim+cell

    myphases = PhaseAlign{j2};
    temp_warped = SWarpedAlign{j2};

    % Although in general warped time will be within a similar range as for
    % "original" time, on trials with unsually short breaths, "warped time"
    % may extend beyond this range since we are "inflating" the breaths
    figure; subplot(1,2,1);
    for j1=1:10
        plot(myphases{j1},temp_warped{j1},'*'); hold on;
        pause;
    end
    set(gca,'FontSize',16);xlabel('Phase');ylabel('Sniff-warped (s)')

    subplot(1,2,2);
    for j1=1:10
        plot(mod(myphases{j1},2*pi),mod(temp_warped{j1},meanInh+meanExh),'*'); hold on;
    end
    set(gca,'FontSize',16);xlabel('Phase (mod 2\pi)');ylabel('mod mean(breath length)');
end


fname_out = sprintf('sniffwarped_BF_%s%s.mat', regText, whichFile);
save([dirloc fname_out],...
    'SWarpedAlign','meanInh','meanExh', ...
    'meanInh_byTrial','meanExh_byTrial','stdInh_byTrial','stdExh_byTrial', ...
    'fname_in');