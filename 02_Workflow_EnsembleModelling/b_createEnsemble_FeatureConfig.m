clear
close all
tic

%% load Feature-Data
load('a_workspace_SOM_featuredata_pool.mat','features','feature_names');

%% Cluster Parameters
SOM_size = 'big';
DR = "Yes"; DM = "No";    %DR: Density refinement, DM: Density merging
NTH = 0; %neighborhood_threshold
HMTH = 0; %hits merging threshold

%write little summary text file to store cluster algorithm parameters directly to txt file
info = table; info.SOM_size = SOM_size; info.Dens_refinement = DR; info.Dens_merging = DM;
info.neighborhood_threshold = NTH; info.hits_merging_threshold = HMTH;
writetable(info, 'SOM_Parameter.txt');

%% create ensemble members

%%%%%%%%%%%%%%%%%%%%%%%
%use binomial coefficients to get all possible combinations

mods = 0; %just a counter
kstart = 1; %it is possible to start with a higher number, default: 1
kend = size(features,2);
bs = zeros(1,kend);
for k = kstart:kend
    b = nchoosek(size(features,2),k);
    bs(k)=b;
    mods = mods + b;
end
selection_matrix_1 = false(mods,size(features,2));
for k = kstart:kend
    combs = combnk(1:size(features,2),k);
    for i = 1:size(combs,2)
        lidx = sum(bs(1,1:k-1))+1:sum(bs(1,1:k-1))+bs(k);
        for ii = 1:size(combs,1)
            selection_matrix_1(lidx(ii),combs(ii,i)) = true;
        end
    end
end
clear k b bs combs lidx i ii kstart kend

%%%%%%%%%%%%%%%%%%%%%%%
%create random permutations of possible feature combinations

c = 15; %number of permutations which schould be tested; set higher or lower if desired
n = size(selection_matrix_1,1);
selection_matrix = kron(selection_matrix_1,ones(c,1)); %Kronecker tensor product (replicate rows multiple times)
mods = size(selection_matrix,1); 
Feature_selection_and_order = zeros(size(selection_matrix));
for mod = 1:mods
    temp = find(selection_matrix(mod,:) == true);
    p = randperm(size(temp,2));
    Feature_selection_and_order(mod,p) = temp;
end
Feature_selection_and_order = unique(Feature_selection_and_order,'rows'); %remove duplicates
mods = size(Feature_selection_and_order,1);

%%%%%%%%%%%%%%%%%%%%%%%
%print number of members and decide whether to proceed or not (e.g. to many members)

fprintf('Ensemble will have %d members\n',size(Feature_selection_and_order,1))
load chirp; sound(y,Fs); fprintf('press any key to proceed\n'), pause, disp('...proceeding now')

%% Calculate member clustering results

parfor mod = 1:mods
%     fprintf('%d    ',mod), toc, fprintf('\n')
    [clustering,no_s,~] = ensembleGen01(features,SOM_size,DM,DR,NTH,HMTH,Feature_selection_and_order(mod,:));
    ensembleresults(:,mod) = clustering;
    no(mod) = no_s;
end

%% Write data to txt files for transfer to R
sData = som_data_struct(features);
sData = som_normalize(sData,'var'); %Z-score
features_z = sData.data;
toc

f = table;
rows = size(ensembleresults,1);
cols = size(ensembleresults,2);
f{1:rows,1:cols} = ensembleresults;
writetable(f,"Ensemble_FeatureConfigs_forR.txt",'WriteVariableNames',false);

f = table;
rows = size(features_z,1);
cols = size(features_z,2);
f{1:rows,1:cols} = features_z;
writetable(f,"features_z_forR.txt",'WriteVariableNames',false);

%% save workspace
clear b eva_s i ii p list temp c f n mod selection_matrix selection_matrix_1 rows cols features_z
save b_workspaceEnsemble_FeatureConfig

%% Calculate internal cluster indices for the members directly in R
tic
cd('C:\Users\Andreas Wunsch\Workspace\05_R'); %change directory to the path where the R scripts can be found
system('"C:\Program Files\R\R-3.4.2\bin\x64\R.exe" CMD BATCH ClusterStats_FeatureConfig.R'); %call R directly with matlab, please adapt the path and the script-name if necessary
% system('"C:\Program Files\R\R-3.5.1\bin\x64\R.exe" CMD BATCH ClusterStats_FeatureConfig.R');
cd('C:\Users\Andreas Wunsch\Workspace\01_Matlab'); % change directory back to your matlab path
toc
