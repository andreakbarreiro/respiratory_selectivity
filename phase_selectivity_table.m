clear; clc;

dirloc = '/Users/sharanaparvin/Fall 25 Research/Respiratory phase selectivity/';
load(fullfile(dirloc,'phase_selectivity_survey.mat'),'Results');

Results = sortrows(Results, {'animal','cell','odor'});

texFile = fullfile(dirloc, 'phase_selectivity_results_table_short.tex');
fid = fopen(texFile, 'w');

fprintf(fid, '%% Auto-generated LaTeX table from MATLAB\n');
fprintf(fid, '\\begin{longtable}{llrrrrr}\n');
fprintf(fid, '\\caption{Sniff phase selectivity results across all animals, cells, and odors.}\\\\\n');
fprintf(fid, '\\hline\n');
fprintf(fid, 'Animal & Cell & Odor & $R_{\\mathrm{obs}}$ & $\\mathrm{thr}_{90}$ & $p$-value & Coupled \\\\\n');
fprintf(fid, '\\hline\n');
fprintf(fid, '\\endfirsthead\n');

fprintf(fid, '\\hline\n');
fprintf(fid, 'Animal & Cell & Odor & $R_{\\mathrm{obs}}$ & $\\mathrm{thr}_{90}$ & $p$-value & Coupled \\\\\n');
fprintf(fid, '\\hline\n');
fprintf(fid, '\\endhead\n');

fprintf(fid, '\\hline\n');
fprintf(fid, '\\endfoot\n');

fprintf(fid, '\\hline\n');
fprintf(fid, '\\endlastfoot\n');

for i = 1:height(Results)
    fprintf(fid, '%s & %d & %d & %.4f & %.4f & %.4g & %d \\\\\n', ...
        Results.animal{i}, ...
        Results.cell(i), ...
        Results.odor(i), ...
        Results.Robs(i), ...
        Results.thr90(i), ...
        Results.pval(i), ...
        Results.coupled(i));
end

fprintf(fid, '\\end{longtable}\n');
fclose(fid);

fprintf('Short LaTeX table saved to:\n%s\n', texFile);