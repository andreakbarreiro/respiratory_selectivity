% Fig2_Shusterman_etal
%
% Create something similar to Shusterman et al., 2011
% "Precise olfactory responses tile..."
%
% Illustrates that OB cells respond in a phase and odor-dependent manner
%

% If necessary, set paths

set_paths_AKB

% Parameters
whichFile  = '170608';       % dataset
regText    = 'OB_';          % choose 'OB_' or 'CX_'

% Pick cells with a variety of "significance" results.
% i.e. respond to some odorants but not others, etc. 
cellIDs = [1 2 3 4];

% "Clean" is 7
odorIDs = [1 2 4 5 7];

nOdors_to_plot  = length(odorIDs);
nCells_to_plot  =  length(cellIDs);

% Colors to use
colors = [1 0 0; 0.8 0.6 0; ...
    0 1 0.4; 0.5 1 0.3;...
    0.5 0.5 0.5];

if size(colors,1)< nOdor_to_plot
    error('Not enough colors for figure: need one per odor')
end
if size(colors,1)>nOdors_to_plot
    warning('Check that gray is the odor for "clean"');
end

%%% Read in phase file
%% Fill this in

%%% LATER: Read in file that contains significance results

%%% Compute PSPHs for each cell listed above, each odor
%% Fill in 
angle_range = [-4*pi,8*pi]; % Shusterman et al use [-4*pi, 4*pi]


%% Try this for one cell first.
% Then put into a "for" loop to do each cell in a separate figure


figure; 

% PSPH for all
subplot(1,nOdors_to_plot+1,nOdors_to_plot+1);

% Plot each PSPH
for j1=1:nOdors_to_plot
    %% Fill in
end

for j1=1:nOdors_to_plot
    % Raster plot for odor 
    %% Fill in

    %% Find our old code for a raster plot.
    %% Encapsulate it into a function
end
