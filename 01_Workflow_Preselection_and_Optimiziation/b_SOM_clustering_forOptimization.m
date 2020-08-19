clear
clc
close all
tic

%% load Data
load('a_workspace_SOM_featuredata','data_weekly','features','feature_names');

%%
saveminimum = "Yes"; %save workspace, validation indices and SOM parameter
% saveminimum = "No"; %save nothing, just run the script
saving = "Yes"; % generate file output (graphics, files and stuff)
% saving = "No"; %save nothing, just run the script

SOM_size = 'big';
% SOM_size = 'normal';
% SOM_size = 'small';

% DR = "No"; DM = "No";     %DR: Density refinement, DM: Density merging
DR = "Yes"; DM = "No";    %DR: Density refinement, DM: Density merging
% DR = "Yes"; DM = "Yes";   %DR: Density refinement, DM: Density merging

NTH = 0; %neighborhood_threshold: higher values produce more clusters (as a general approximation...notalways the case)

HMTH = 0; %hits merging threshold, %all clusters below and equal this threshold are merged together into one cluster -> usefull to reduce cluster number

% subplotlayout1 x subplotlayout2 must be > feature number
subplotlayout1 = 3; %vertical number
subplotlayout2 = 4; %horizontal number

%write litte summary table to text file with info about parameter
%configuration used
info = table; info.SOM_size = SOM_size; info.Dens_refinement = DR; info.Dens_merging = DM;
info.neighborhood_threshold = NTH; info.hits_merging_threshold = HMTH;
if saveminimum == "Yes"
    writetable(info, 'SOM_Parameter.txt');
end



%% Data set build up

%remove NaN Samples (feature calculation errors)
for i = 1:size(features,2)
    idx = find(isnan(features(:,i)) == 1);
    if isempty(idx) == 0
        for ii = length(idx):-1:1
            features(idx(ii),:) = [];
            data(idx(ii)) = [];
            data_weekly.(idx(ii)+1) = [];
        end
    end
end

% create struct according to SOM-Toolbox needs
sD = som_data_struct(features);

% Standardization
sData = som_normalize(sD,'var'); %Z-score

%% Initialization + Training

sMap = som_make(sData,'mapsize',SOM_size,'lattice','hexa','init','lininit','shape','sheet');

% make map dimensions easier acccesible in workspace
ydim=sMap.topol.msize(1);
xdim=sMap.topol.msize(2);
hits = som_hits(sMap,sData);  % hits

%% Enrichment

sMap_C=BS2L_mod(sData.data,sMap,DM,NTH,'den');

if saving == "Yes"
    print('-dpng','-r300','002_Clustering_steps.png')
end

if DR == "Yes"
    base_cl = sMap_C.denclust;
elseif DR == "No"
    base_cl = sMap_C.valclust;
end

base_cl = relabel_cl(base_cl);
no = max(base_cl);
D = sMap_C.density;
D_reshape = reshape(D,ydim,xdim);


%Merge clusters with few hits and rename the rest
k=1;merge_cl = NaN;
for i=1:no
    if sum(hits(base_cl==i))<=HMTH && k == 1
        merge_cl=i;k=2;
    elseif sum(hits(base_cl==i))<=HMTH && k == 2
        base_cl(base_cl==i)=merge_cl;
    end
end
u = unique(base_cl);base_temp=zeros(size(base_cl)); %change numbering to consecutive numbers
for i = 1:length(u)
    u1 = base_cl == u(i);%disp(sum(u1));
    base_temp(u1) = i;
end
mcl = find(base_cl == merge_cl);
if isempty(mcl) == 0
    mcl=mcl(1);
end
base_cl = relabel_cl(base_cl);
merge_cl = base_cl(mcl);
no = max(base_cl);


%Visualize Clusters
randomclusternumber=rand(no,1);
part_vis=base_cl;
for i=1:no
    for ii=1:length(base_cl)
        if part_vis(ii,1)==i
            part_vis(ii,1)=randomclusternumber(i,1);
        end
    end
end
clear randomclusternumber
cluster_numbers = cellstr(int2str(base_cl));
if HMTH > 0
    cluster_numbers(base_cl == merge_cl) = {sprintf("%dX",merge_cl)};
end
figure('Position', [250 200 1100 700])
subplot(1,2,1), som_cplane(sMap,part_vis), hold on; som_grid(sMap,'Label',cluster_numbers,'Labelsize',8,...
    'Line','none','Marker','none','Labelcolor','k'); hold off
custom=colorcube;
custom(39:end,:) = [];
for i=1:no
    if i<=38
        custom(i,:)=custom(i,:);
    else
        custom(i,:)=custom(i-38,:);
    end
end
custom(end+1:end+length(custom),:)=custom;

colormap(custom)
title('cluster numbers')

subplot(1,2,2),
som_cplane(sMap,part_vis), hold on; som_grid(sMap,'Label',cellstr(int2str(hits)),'Labelsize',8,...
    'Line','none','Marker','none','Labelcolor','k'); hold off
colormap(custom)
title('hits'); suptitle('enriched SOM cluster');
if saving == "Yes"
    print('-dpng','-r300','003_Clustering.png')
end

%possibility to pause: often the first iteration already ends here:
% toc,disp('PAUSED - press any key to proceed or [CTRL]+C to abort'),pause

%%
%Density Surface Cluster
for i=1:ydim*xdim
    idx = base_cl(i);
    C(i,1:3)=custom(idx,:);
end

fig = figure('Position', [250 100 1100 700]);
Surface=zeros(ydim*xdim,3);
for i = 1:ydim*xdim
    Surface(i,1)=ceil(i/ydim);
    if rem(i,ydim)>0
        Surface(i,2)=(i-floor(i/ydim)*ydim);
    else
        Surface(i,2)=ydim;
    end
end
Surface(:,3) = D;
surf(D_reshape,'FaceColor',[0.95 0.95 0.95]);hold on;
for i = 1: ydim*xdim
    plot3(Surface(i,1),Surface(i,2),Surface(i,3)+0.02*max(D),'o','MarkerSize',10,...
        'MarkerEdgeColor','k','MarkerFaceColor',C(i,:));hold on;
end
hold off
suptitle('Density Surface (colors: cluster)');
set(gca,'Ydir','reverse')
if saving == "Yes"
    print('-dpng','-r300','004_Density.png')
    savefig(fig,'004_Density_Surface','compact')
end

clear xline yline base_clr k idx  fig base_temp base_reshape connection_strength ...
    cl_idx i ii iii iiii ix iy iz m merge n  neighs S seed u u1 C

%% Calculate U Matrix and Neuron hits
U_matrix = som_umat(sMap); % U-matrix
D_matrix = U_matrix(1:2:size(U_matrix,1),1:2:size(U_matrix,2)); %Distance Matrix


% Visualization Component Planes
figure('Position', [250 100 1000 700]);
% som_show(sMap,'comp','all','footnote', '','norm','d'); %denormalized component planes
som_show(sMap,'comp','all','footnote','','norm','n'); %normalized component planes
suptitle('Component Planes');
if saving == "Yes"
    print('-dpng','-r300','001_ComponentPlanes.png')
end

%% variable importance 
% we try to derive the feature importance for each cluster from the trained SOM
% Idea: Deviation of the mean weight of a cluster from the mean weight of a feature for the whole SOM
load SOM_customcolormap
importance=nan(no,size(features,2));
for i=1:size(features,2) %loop each variable
    weights=zscore(sMap.codebook(:,i));
    for ii=1:no %loop each cluster
        idx=base_cl==ii;
        weights_cl=weights(idx,1);
        importance(ii,i)=(mean(weights_cl)-median(weights))^2;
        if ii == merge_cl
            yvalues{1,ii}=sprintf('Cluster %dX',ii);
        else
            yvalues{1,ii}=sprintf('Cluster %d',ii);
        end
    end
    %     xvalues{1,i}=sprintf('Feature %d',i);
    xvalues{1,i}=char(feature_names(i));
    
end

%overall comparison
fig = figure('Position', [400 50 700 940]);
subplot(3,1,1);heatmap(xvalues,yvalues,importance,'CellLabelFormat','%.2f','MissingDataColor',[0.8 0.8 0.8]);
colormap(colormap_variable_importance)
title('Variable Importance');

%clusterwise comparison
subplot(3,1,2);
heatmap(xvalues,yvalues,normalize(importance,2,'range'),'ColorScaling',...
    'scaledrows','CellLabelFormat','%.2f','MissingDataColor',[0.8 0.8 0.8]);
colormap(colormap_variable_importance)
title('scaled rows - importance per cluster');

%variablewise comparison
subplot(3,1,3);heatmap(xvalues,yvalues,normalize(importance,'range'),'ColorScaling',...
    'scaledcolumns','CellLabelFormat','%.2f','MissingDataColor',[0.8 0.8 0.8]);
colormap(colormap_variable_importance)
title('scaled columns - importance per feature');
if saving == "Yes"
    print('-dpng','-r500','006_Variable_importance.png')
    savefig(fig,'006_Variable_importance','compact')
end
clear fig

%% specify clusternumber of each input sample
clusternumbers_of_samples=nan(size(features,1),1);
[~,I]=som_divide(sMap, sData); %Divides a dataset according to a given map
hit_counts=nan(1,no);
for ii=1:no
    idx=base_cl==ii;
    cluster_hits=I(idx);
    cluster_hits=cell2mat(cluster_hits);
    hit_counts(1,ii)=numel(cluster_hits);
    clusternumbers_of_samples(cluster_hits)=ii;
end
clear cluster_hits
%% Bar Plot: hits per Cluster
figure,
b=bar(hit_counts);
b.FaceColor = 'flat';
if isnan(merge_cl) == 0
    b.CData(merge_cl,:) = [1 1 1];
end
grid on, title('Cluster hit counts'); xlabel('Cluster Number'), ylabel('Cluster Hits');
barvalues;
set(gca,'FontSize',14);
if saving == "Yes"
    print('-dpng','-r500','005_Cluster_hits.png')
end

%% boxplots
fig = figure('Position', [10 10 1900 980]);
for i=1:size(features,2) %loop each feature
    
    M=nan(max(hit_counts),no);
    for ii=1:no %loop each cluster
        idx= base_cl==ii;
        cluster_boxdata=features(cell2mat(I(idx)),i);
        M(1:length(cluster_boxdata),ii)=cluster_boxdata;
    end
    
    subplot(subplotlayout1,subplotlayout2,i)
    %-----------------
    bp=boxplot(M);
    %-----------------
    set(bp,'Linewidth',1);
    
    xlabels = get(gca,'xticklabel');
    if no>15
        for iii = 2:2:no
            xlabels{iii}='';
        end
        set(gca,'xticklabels',xlabels);
        grid on
    end
    if no>15 || subplotlayout2 > 3
        for iii = 2:1:no
            xlabels{iii}='';
        end
        for iii = 5:5:no
            xlabels{iii}=num2str(iii);
        end
        set(gca,'xticklabels',xlabels);
        grid on
    end
    xlabel('Cluster')
    %     ylabel(boxplotylabels(i))
    title(feature_names(i))
    axis tight
end
if saving == "Yes"
    print('-dpng','-r300','007_Feature box plots') %save boxplot graphics
    savefig(fig,'007_Feature box plots','compact')
end
clear boxplotylabels bp M idx i ii text

%% store indices per cluster - ipc
ipc = struct('sample_indices',{});
for i=1:no %loop each cluster
    idx=find(clusternumbers_of_samples==i);
    ipc(i).sample_indices=idx;
end

%% End
clear f fig
if saveminimum == "Yes"
    save workspace_SOM_results
end
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%end of script