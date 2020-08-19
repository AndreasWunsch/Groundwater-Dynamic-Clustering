clear
% clc

%% load previous data
load e_workspaceEnsemble_Jackknife_bestFeatureConfig

%% perform consensus voting
mx = 12; %number of voting repetitions
parfor i = 1:mx
    disp(i)
    VoteConsensus = vote(ensembleresults(:,randperm(size(ensembleresults,2))));
    VoteConsensus_ensemble(:,i) = relabel_cl(VoteConsensus);
end

%% write results to txt file for R transfer
f=table;
f{1:size(features,1),1:mx}=VoteConsensus_ensemble;
writetable(f,"02_Ensemble_voting_bestFeatureConfig.txt",'WriteVariableNames',false)

%% save workspace
save f_voting_bestFeatureConfig_resampled

%% Calculate internal cluster indices for the votings in R
cd('C:\Users\Andreas Wunsch\Workspace\05_R'); %change directory to the path where the R scripts can be found
system('"C:\Program Files\R\R-3.4.2\bin\x64\R.exe" CMD BATCH ClusterStats_VotingEnsemble.R'); %call R directly with matlab, please adapt the path and the script-name if necessary
% system('"C:\Program Files\R\R-3.5.1\bin\x64\R.exe" CMD BATCH ClusterStats_VotingEnsemble.R');
cd('C:\Users\Andreas Wunsch\Workspace\01_Matlab'); % change directory back to your matlab path
toc



