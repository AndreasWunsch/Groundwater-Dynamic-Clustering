clear
% clc
close all
tic

%% load Data
load('d_workspace_SOM_featuredata_member');
load('b_workspaceEnsemble_FeatureConfig','SOM_size','DR','NTH','HMTH','DM')

%% resampling
%delete d(random with range) Jackknife
mods = 10000; %number of ensemble members
n = size(features,1);
selection_matrix = true(n,mods);
for i = 1:mods
    if ceil(sqrt(n)) <= round(0.1*n)
        selection_matrix(randi(n,randi([ceil(sqrt(n)) round(0.1*n)]),1),i)=false;
    else
        selection_matrix(randi(n,randi([1 ceil(sqrt(n))]),1),i)=false;
    end
end

%% Calculate member clustering results
tic
parfor mod = 1:mods
    [clustering] = ensembleGen02(features,SOM_size,DM,DR,NTH,HMTH,selection_matrix,mod);
    ensembleresults(:,mod) = clustering;
end
toc

%% end script
clear b eva_s
save e_workspaceEnsemble_Jackknife_bestFeatureConfig