set_paths_AKB

load(fullfile(dirloc,'phase_selectivity_survey.mat'));

animalID = 1;

myresult = Survey(animalID).result;

% Store this in array form
coupled_array = zeros(size(myresult));
ItoE_array    = coupled_array;
phi_pref_array = coupled_array;
nOdor     = size(coupled_array,1);
nCell     = size(coupled_array,2);

for j1=1:nOdor
    for j2=1:nCell
        coupled_array(j1,j2) = myresult(j1,j2).coupled;
        phi_pref_array(j1,j2) = myresult(j1,j2).phi_pref;
        ItoE_array(j1,j2) = myresult(j1,j2).ItoE;
    end
end

% This is just one example. Continue to think about 
% %interesting ways to
% explore this data.

% Is preferred in retro phase?
isRetroPref = phi_pref_array > ItoE_array;

% Is retropreferred AND coupled?
retroPref_and_coupled = isRetroPref & coupled_array;

