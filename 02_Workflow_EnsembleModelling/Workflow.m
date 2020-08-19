% This Workflow corresponds to the workflow figure in the paper. 
% It is only valid if the first iterative steps to preselect the features
% and to optimiize cluster parameters are already done.

% This script is intentionally written to call scripts instead of functions. 
% Experience showed that is more useful to use every step with stand-alone character. 
% This simplifies re-entering the workflow to modify and analyse results

%IMPORTANT: Please open each script before running the workflow and adapt
%it to your preferences (e.g. cluster parameters, program paths,..)

%% timing
format shortg
starting_time = clock;
save('st','starting_time')

%% Step 1
a_feature_extraction, disp('Step 1 done')
%% Step 2
b_createEnsemble_FeatureConfig, disp('Step 2 done')
%% Step 3
c_Rank_FeatureConfigs, disp('Step 3 done')
%% Step 4
d_feature_reorder, disp('Step 4 done')
%% Step 5
e_createEnsemble_bestFeatureConfig_resample, disp('Step 5 done')
%% Step 6
f_Consensus_voting, disp('Step 6 done')
%% Step 7
g_Rank_votings, disp('Step 7 done')
%% Step 8
h_Cluster_stacked_consensus, disp('Step 8 done')
%% Step 9
j_Visualisations, disp('Step 9 done')

%% Summary file
warning('off','all')
% prefix = 'creativeNaming';
prefix = '';
[Summary] = Summary_Cluster_Ensemble(prefix);
writetable(Summary,strcat(prefix,'Summary.txt'))
clear prefix

%% timing
format shortg
ending_time = clock;
load st
fprintf('elapsed time for workflow %.1f min / %.1f h \n',etime(ending_time,starting_time)/60,etime(ending_time,starting_time)/3600);

% %% end sound
% load chirp, sound(y,Fs)
