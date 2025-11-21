
% README for phase files

whichFile = ['170613'];

% Which region?
% regionFlag = 1:   OB
%            = 2:   CX
regionFlag = 1;

% To determine which file we want; 
if (regionFlag == 2)
    regText = 'CX_';    regFlagBF = 'P'; 
else
    regText = 'OB_';    regFlagBF = 'B';
end


%% Stimulus-driven

if (0)
    %% Contents:
    
    dirtoRead = '../Calc_PhaseBF/';
    %dirtoRead = pwd
    infname = [dirtoRead 'phase_BF_' regText whichFile '.mat'];
    
    load(infname);
    %
    %% Breath information
    %  PREXTimesAlign:  (nOdors x nTrials) cell array of inhale times 
    %  POSTXTimesAlign: (nOdors x nTrials) "exhale times" i.e. zero crossings in
    %       the other direction, during the same time period. 
    %  BreathHeight,BreathSlope, BreathWidth:   
    %      (nOdors x nTrials) cell arrays, associated with breaths identified in
    %       PREXTimesAlign
    %  respTimesAlign: (nOdors x nTrials) respiration traces associated with
    %       each trial
    %  zeroTimesAlign: (nOdors x nTrials) time of 1st inhale after each onset
    %       PREXTimesAlign, POSTXTimesAlign have been shifted by this ##
    %
    %% SPIKE INFORMATION
    %   RasterAlign (nOdors x nCells) cell array of spikes that ocl;cur within
    %       [-5, 10] seconds of zeroTimeAlign. They are shifted so "0" =
    %       zeroTimeAlign. Each entry is a {15x1} cell.
    %      ex: RasterAlign{2,3} contains all spikes from cell "3" in response to
    %         all trials of odor 2. RasterAlign{2,3}(4) is the 4th trial. 
    %   
    %   PhaseAlign: as for RasterAlign, but with a phase assigned to each spike
    % 
    %%  STIMULUS and ORDERING
    % Order of stimulus: ('2hex','ea','eb','et','hexa','iso','clean')
    %    (Note this is alphabetical except for 'clean')
    %
else

    %% Spontaneous
    %
    %% Activity was saved in between each pair of trials.
    %  Starting 10 s after one trial ends, 6 sec is saved (so ending 4 s
    %  before the next trial
    %
    %  Only one "odor" (no distinction is made by identity of
    %  preceding/following odor)
    %
    dirtoRead = '../Calc_PhaseBF/';
    %dirtoRead = './';
    infname = [dirtoRead 'phase_BF_Spon_' regText whichFile '.mat'];
    
    load(infname)

    %% Breath information
    %  PREXTimesAlign:  (1 x nTrials) cell array of inhale times 
    %  POSTXTimesAlign: (1 x nTrials) "exhale times" i.e. zero crossings in
    %       the other direction, during the same time period. 
    %  BreathHeight,BreathSlope, BreathWidth:   
    %      (1 x nTrials) cell arrays, associated with breaths identified in
    %       PREXTimesAlign
    %  respTimesAlign: (1 x nTrials) respiration traces associated with
    %       each trial
    %  zeroTimesAlign: (1 x nTrials) time of 1st inhale that occurs >= 1s 
    % %     after we start to save spikes. Arbitrary choice, but allows
    %       all rasters to be visualized on more-or-less the same time axis.
    %       PREXTimesAlign, POSTXTimesAlign have been shifted by this ##.
    %
    %% SPIKE INFORMATION
    %   RasterAlign (1 x nCells) cell array of spikes that occur 
    % %     in between stimulus presentations. 
    % %    They are shifted so "0" zeroTimeAlign.
    % %    Each entry is a {nTrialx1} cell.
    %   ONLY one "odor" for spontaneous activity
    %       ex: RasterAlign{3} contains all spikes from cell "3" in response to
    %         all spontaneous trials. RasterAlign{3}(44) is the 44th trial. 
    %   
    %   PhaseAlign: as for RasterAlign, but with a phase assigned to each spike
    % 
end
%class(PhaseAlign)
%whos PhaseAlign
%isvector(PhaseAlign)
%iscell(PhaseAlign)
%isstruct(PhaseAlign)