function [f] = Summary_Cluster_Ensemble(prefix)
load(strcat(prefix,'a_workspace_SOM_featuredata_pool'),'feature_names','features')
k = size(feature_names,2);
f=table;
f.samples = string(size(features,1));
f.F_Nr(1:k) = string([1:k]');
f.Feature_Pool = feature_names';
clearvars -except f prefix
%%
load(strcat(prefix,'b_workspaceEnsemble_FeatureConfig'),'SOM_size','DR','NTH','HMTH','DM')
f.SOM_Parameter1(1:5) = ["SOM_size"; "DR"; "DM"; "NTH"; "HMTH"];
f.SOM_Parameter(1:5) = string([SOM_size; DR; DM; NTH; HMTH]);
clearvars -except f prefix 

%%
load(strcat(prefix,'c_bestConfig'),'bestconfiguration')
load(strcat(prefix,'d_workspace_SOM_featuredata_member.mat'),'feature_names')
k = size(feature_names,2);
f.bestconfig(1:k) = string(bestconfiguration(1:k));
f.Feature_Member(1:k) = feature_names';
clearvars -except f prefix 

%%
load(strcat(prefix,'g_workspaceEnsemble_votings_ranks'),'bestvoting_stats');
f.ind_finCl(1:5) = ["CH";"MR";"PBM";"RL";"C"];
f.stats_finCl(1:5) = string(bestvoting_stats{1,:}');
clearvars -except f prefix
%%
load(strcat(prefix,'g_finalClustering'),'finalClustering')
f.Cluster_Number(1) = string(max(finalClustering));
clearvars -except f prefix

%%
load(strcat(prefix,'b_workspaceEnsemble_FeatureConfig'),'mods')
f.Ensemble(1) = "FeatureConfigs";
f.member_no(1) = string(mods);

%%
load(strcat(prefix,'e_workspaceEnsemble_Jackknife_bestFeatureConfig'),'mods')
f.Ensemble(2) = "Jackknife";
f.member_no(2) = string(mods);

%%
load(strcat(prefix,'f_voting_bestFeatureConfig_resampled'),'mx')
f.Ensemble(3) = "Voting";
f.member_no(3) = string(mx);
end

