function [clustering] = ensembleGen02(features,SOM_size,DM,DR,NTH,HMTH,selection_matrix,mod)

%% adapt data to jackknifing member
sel_idx = selection_matrix(:,mod);
features = features(sel_idx,:);

%% SOM Training
sD = som_data_struct(features);
sData = som_normalize(sD,'var'); %Z-score
sMap = som_make(sData,'mapsize',SOM_size,'lattice','hexa','init','lininit','shape','sheet','tracking',0);
ydim=sMap.topol.msize(1);
xdim=sMap.topol.msize(2);
hits = som_hits(sMap,sData);  % hits

%% SOM DS2L Enrichment
sMap_C=BS2L_mod(sData.data,sMap,DM,NTH);

%change numbering to consecutive numbers
u=unique(sMap_C.denclust);
base_temp=zeros(size(sMap_C.denclust));
if DR == "Yes"
    base_cl = sMap_C.denclust;
elseif DR == "No"
    base_cl = sMap_C.valclust;
end
k = 1;
for i = 1:size(u,1)
    if u(i) < 0
        idx = find(base_cl==u(i));
        for ii=1:length(idx)
            idx2 = idx(ii);base_temp(idx2) = k;k=k+1;
        end
    else
        idx = base_cl == u(i); base_temp(idx) = k;k = k+1;
    end
end
base_cl = base_temp;
no = max(base_cl);

%Merge clusters with few hits (HMTH) and rename the rest
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
base_cl = base_temp;
no = max(base_cl); %number of clusters

%% order samples according to clusters
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

%% create function output
clustering = nan(size(sel_idx));
clustering(sel_idx,1) = clusternumbers_of_samples;
end
