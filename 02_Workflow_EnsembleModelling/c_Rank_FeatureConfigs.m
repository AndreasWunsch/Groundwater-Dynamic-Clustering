% load chirp, sound(y,Fs)

clear
close all
tic
%% import R data
filename = 'C:\Users\Andreas Wunsch\Workspace\01_Matlab\R_ClusterVal_stats_FeatureConfig.txt';
eva = importR_ClusterVal_stats2(filename);

%% load previous matlab data
load b_workspaceEnsemble_FeatureConfig

%% perform ensemble member ranking
for i = 1:5
   eva.(i) = round(eva{:,i},4); 
end

ranking = table;
%CH (maximise) - Cali?ski-Harabasz criterion (CH)  (Cali?ski & Harabasz, 1974)
R = tiedrank(eva{:,1}); 
ranking{:,1} = size(eva,1)+1-R;

%MR (minimise) - McClain-Rao criterion (MR) (McClain & Rao, 1975)
ranking{:,2}=tiedrank(eva{:,2});

%PBM (maximise) - PBM-Index (Pakhira et al., 2004)
R = tiedrank(eva{:,3}); 
ranking{:,3} = size(eva,1)+1-R;

%RL (maximise) - Ratkowsky-Lance criterion (RL) (Ratkowsky & Lance, 1978)
R = tiedrank(eva{:,4}); 
ranking{:,4} = size(eva,1)+1-R;

%C(minimise) - C-Index (Hubert & Schultz, 1976)
ranking{:,5}=tiedrank(eva{:,5});

%overall ranking(minimise sum of rankings)
ranking.sum = sum(ranking{:,:},2);
ranking{:,end+1}=tiedrank(ranking{:,6});
ranking.Properties.VariableNames = {'CH','MR','PBM','RL','C','Sum','Overall_Ranking'};


%% Select best member
bestranking = find(ranking.Overall_Ranking == min(ranking.Overall_Ranking)); %alternativle use a specific rank: e.g. rank 2 -> bestranking = find(ranking.Overall_Ranking == 2);
bestranking = bestranking(1);
bestconfiguration = Feature_selection_and_order(bestranking,:);
save('c_bestConfig','bestconfiguration')

%% write stuff to files
bestconfig_stats = eva(1,:);
bestconfiguration = table;
ranks = ranking(1,:);

[~,I] = sort(ranking.Overall_Ranking);
ranks{1:size(I,1),1:7} = ranking{I,:};
bestconfiguration{:,1:size(Feature_selection_and_order,2)} = Feature_selection_and_order(I,:);
bestconfig_stats{1:size(I,1),1:5} = eva{I,:};
ranks.order = I;

writetable(bestconfig_stats,'01_FeatureConfig_stats_ordered.txt');
writetable(bestconfiguration,'01_FeatureConfigs_ordered.txt');
writetable(ranks,'01_ranks_Feature_Configs_ordered.txt');

save c_workspaceEnsemble_FeatureConfig_ranks

toc






