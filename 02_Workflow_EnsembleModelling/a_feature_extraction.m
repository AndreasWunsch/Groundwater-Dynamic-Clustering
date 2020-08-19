clear
clc
close all
tic

%% import data

% load your dataset: "data_weekly" = table with time/date as first column, every other column is a (not necessarily weekly) timeseries 
load('workspace_gwdata_Paper.mat','data_weekly');

%% some necessary stuff
feature_extraction_data=data_weekly;
date1=feature_extraction_data.(1);
feature_extraction_data.(1)=[]; 
idx = size(feature_extraction_data,2);

%% Preallocation
F_range_ratio = NaN(idx,1);
F_skewness = NaN(idx,1);
F_P52corr = NaN(idx,1);
F_dif = NaN(idx,1);
F_longest_recession = NaN(idx,1);
F_jumps = NaN(idx,1);
F_SEM = NaN(idx,1);
F_seasonalbehaviour = NaN(idx,1);
F_var_y = NaN(idx,1);
F_median_01scale = NaN(idx,1);
F_HPD = NaN(idx,1);
F_LPD = NaN(idx,1);
%% calculate time series features

parfor i = 1:idx 
    [F_range_ratio(i,1),F_skewness(i,1),F_P52corr(i,1),...
        F_dif(i,1),F_longest_recession(i,1),F_jumps(i,1),...
        F_SEM(i,1),F_seasonalbehaviour(i,1),F_var_y(i,1),...
        F_HPD(i,1),F_LPD(i,1),F_median_01scale(i,1)]   =   feature_calculation(date1,feature_extraction_data.(i));
end

%% R Calculations
%for this feature we use the existing R toolbox: RWRFHYDRO (https://github.com/NCAR/rwrfhydro)
writetable(data_weekly,'gwdata.txt','Delimiter',';') %write groundwater data to text file for transfer to R
cd('C:\Users\Andreas Wunsch\Workspace\05_R'); %directory where the according R scripts can be found

%RBI: Richards Baker Index
% please adapt directory of your R installation:
system('"C:\Program Files\R\R-3.4.2\bin\x64\R.exe" CMD BATCH calculateRBFlashiness.R'); % execute R directly from Matlab: R directory, CMD, batch, "nameofRscript"
% system('"C:\Program Files\R\R-3.5.1\bin\x64\R.exe" CMD BATCH calculateRBFlashiness.R');

% read R results
opts = delimitedTextImportOptions("NumVariables", 1);
opts.DataLines = [1, Inf];opts.Delimiter = ",";opts.VariableNames = "VarName1";opts.VariableTypes = "double";
opts.ExtraColumnsRule = "ignore";opts.EmptyLineRule = "read";
%adapt path where the R script exported the results to!
RBI = readtable("C:\Users\Andreas Wunsch\Workspace\01_Matlab\RBI.txt", opts);RBI = table2array(RBI);
clear opts

%change back to matlab dirctory
cd('C:\Users\Andreas Wunsch\Workspace\01_Matlab');

%% Generate Feature Summary
k = 1;
%from matlab
features(:,k)=F_range_ratio;                feature_names(k)="RR"; k = k+1;
features(:,k)=F_skewness;                   feature_names(k)="Skew"; k = k+1;
features(:,k)=F_P52corr;                    feature_names(k)="P52"; k = k+1;
features(:,k)=F_dif;                        feature_names(k)="SDdiff"; k = k+1;
features(:,k)=F_longest_recession;          feature_names(k)="LRec"; k = k+1;
features(:,k)=F_jumps;                      feature_names(k)="Jumps"; k = k+1;
features(:,k)=F_SEM;                        feature_names(k)="SEM"; k = k+1;
features(:,k)=F_seasonalbehaviour;          feature_names(k)="SB"; k = k+1;
features(:,k)=F_var_y;                      feature_names(k)="Yvar"; k = k+1;
features(:,k)=F_median_01scale(:,1);        feature_names(k)="Med01"; k = k+1;
features(:,k)=F_HPD(:,1);                   feature_names(k)="HPD"; k = k+1;
features(:,k)=F_LPD(:,1);                   feature_names(k)="LPD"; k = k+1;
%from R
features(:,k)=RBI;                          feature_names(k)="RBI"; k=k+1;

%% Visualisation
%check feature correlations
figure('Position', [1,41,1920,960],'Units','pixels')
corrplot(features,'varNames',feature_names,'testR','on')
print('-dpng','-r600','00_Feature_Correlations.png')

%% write feature values to txt file for R
f=table;
f{1:k-1,1} = [1:k-1]';
f{1:k-1,2} = feature_names';
writetable(f,'01_features_pool','WriteVariablenames',false);

%% save results, end script
clear i
save a_workspace_SOM_featuredata_pool
toc
elapsedtime=toc;
