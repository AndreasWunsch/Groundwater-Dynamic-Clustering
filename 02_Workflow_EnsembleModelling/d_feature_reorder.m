clear
% clc
close all
tic

%% load previous results and data

load('a_workspace_SOM_featuredata_pool.mat','data_weekly','features','feature_names')
load c_bestConfig

%% create new feature data set according to best member
idx = bestconfiguration == 0;
bestconfiguration(idx) = [];
features = features(:,bestconfiguration);
feature_names = feature_names(:,bestconfiguration);

%% feature correlations graphics
figure('Position', [1,41,1920,960],'Units','pixels')
corrplot(features,'varNames',feature_names,'testR','on')
print('-dpng','-r600','0_3_Feature_Correlations.png')

%%
clear idx bestconfiguration
save d_workspace_SOM_featuredata_member
toc
