# respiratory_selectivity
Code to analyze breath-cycle dependence in neural activity


CONTENTS: 
| File name | Description |  
| --------- | ----------- |
| process_phase_data |     Return PPC, pvalues from shuffling, and a list of "significant" cells |
| process_phase_data_circ_rtest |   Return allMu, pvalues from applying Rayleigh test for circular mean, and a list of "significant" cells |
| process_stimulus_phase_data |     Calls "process_phase_data" for each odor |
| process_stimulus_phase_data_rtest |   Calls "process_phase_data_circ_rtest" for each odor |

