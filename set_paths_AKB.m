%% Set path and locations
% Ensure CircStat package is added


username = 'andrea'; %HELP:['andrea','sharana']
if ( strcmp(username,'sharana'))

    % Add CircStat path
    addpath('/Users/sharanaparvin/MatLab Code/CircStat/');
    % Directory and file list
    dirloc = '/Users/sharanaparvin/MATH-6310/sep 30/Calc_PhaseBF/';
else
    addpath('~/Dropbox/MyProjects_Current/Sharana/CircStat_Info/CircStat');
    % Directory to read data
    dirloc = '~/Dropbox/MyProjects_Current/Sharana/Calc_PhaseBF/';
end