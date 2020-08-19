% clc
clear
% close all
%%
% load('d_workspace_SOM_featuredata_member','features','data','data_weekly','feature_names','HyraumID');
% load g_finalClustering
load('d_workspace_SOM_featuredata_member','features','data','data_weekly','feature_names','HyraumID');
load g_finalClustering


load SOM_customcolormap
% HyraumID = "ORG";

saving_outputs = "Yes";
% saving_outputs = "No";

%%
clusternumbers_of_samples = finalClustering;
no = max(clusternumbers_of_samples);
sD = som_data_struct(features);
sData = som_normalize(sD,'var'); %Z-score
cl_sample_centroids=nan(no,size(features,2));
sample_centroids=table;
for i=1:no
    cluster_idx=find(clusternumbers_of_samples==i);
    cl_sample_centroids(i,:)=mean(sData.data(cluster_idx,:),1);
end
for i = 1:size(feature_names,2)
    sample_centroids.(i)=round(cl_sample_centroids(:,i),3);
    names{1,i}=char(feature_names(i));
end
names=strrep(names,' ','_');names=strrep(names,'std(d/dx)','F_dif');
sample_centroids.Properties.VariableNames=names;

wcd = struct('sample_centroid_distances',{},'sample_indices',{},'mean_wcd',{},'names',{});
for i=1:no %loop each cluster
    idx=find(clusternumbers_of_samples==i);
    distances=nan(length(idx),1);
    for ii=1:length(idx) %loop each cluster sample
        distances(ii,1)=pdist2(cl_sample_centroids(i,:),sData.data(idx(ii,1),:),'euclidean');
        %         distances(ii,1)=pdist2(cl_sample_centroids(i,:),sD_n.data(idx(ii,1),:),'euclidean');
    end
    wcd(i).sample_centroid_distances=distances;
    wcd(i).sample_indices=idx;
    wcd(i).mean_wcd=mean(distances);
    wcd(i).names=sData.labels(idx);
end

%%overall centroid
overall_centroid = mean(sData.data);
% overall_centroid = mean(sD_n.data);
%mean distance within data
mdwd = struct('sample_centroid_distances',{},'sample_indices',{},'mean_d',{},'names',{});
distances=nan(size(features,1),1);
for i=1:size(features,1) %loop each sample
    distances(i,1)=pdist2(overall_centroid,sData.data(i,:),'euclidean');
    %     distances(i,1)=pdist2(overall_centroid,sD_n.data(i,:),'euclidean');
end
distances_all = pdist2(sData.data,sData.data,'euclidean');
% distances_all = pdist2(sD_n.data,sD_n.data,'euclidean');
mdwd(1).sample_centroid_distances=distances;
mdwd(1).sample_indices=1:size(features,1);
mdwd(1).mean_d=mean(distances);
mdwd(1).median_d=median(distances);
mdwd(1).names=sData.labels;
mdwd(1).maxdist = max(distances);%max(max(distances_all));

%% Stammdaten
opts = spreadsheetImportOptions("NumVariables", 4);
opts.Sheet = "ohne preprocessing";
opts.DataRange = "A2:D13714";
opts.VariableNames = ["Proj_ID", "Name", "XCoordETRS1989UTM32N", "YCoordETRS1989UTM32N"];
opts.VariableTypes = ["string", "string", "double", "double"];
opts = setvaropts(opts, [1, 2], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2], "EmptyFieldRule", "auto");
% StammdatenD = readtable("C:\Users\Andreas Wunsch\Data\01_Daten der staatlichen geologischen Dienste\00_Deutschland\Stammdaten_D.xlsx", opts, "UseExcel", false);
StammdatenD = readtable("C:\Users\Andreas Wunsch\Data\01_Daten der staatlichen geologischen Dienste\00_Deutschland\Ablage\Stammdaten_D(mitFR).xlsx", opts, "UseExcel", false);

clear opts

%%

if str2num(HyraumID) < 11
    dest = 'C:\Users\Andreas Wunsch\Workspace\02_GIS\hyraum_v32\hyraum_GR_split\*.shp';
elseif str2num(HyraumID) < 1000
    dest = 'C:\Users\Andreas Wunsch\Workspace\02_GIS\hyraum_v32\hyraum_R_split\*.shp';
elseif str2num(HyraumID) > 1000
    dest = 'C:\Users\Andreas Wunsch\Workspace\02_GIS\hyraum_v32\hyraum_TR_split\*.shp';
elseif HyraumID == "ORG"
    dest = 'C:\Users\Andreas Wunsch\Workspace\02_GIS\hyraum_v32\hyraum_GR_split\*.shp';
end
if HyraumID == "ORG" || HyraumID =="ORG32"
else
    info = dir(dest);
    names = extractfield(info,'name');names = names';
    tr = contains(names,strcat(HyraumID," "));
end
if HyraumID == "ORG"
    S = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\ORG_coarse.shp');
%     SF = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\Rhine_ORG.shp');
elseif HyraumID == "ORG32"
    S = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\ORG_coarse.shp');
%     S = shaperead('31 Oberrheingraben mit Mainzer Becken');
    S1 = shaperead('32 Untermainsenke.shp');
elseif HyraumID == "D"
    S = shaperead('C:\Users\Andreas Wunsch\Data\02_GIS\vg2500_bld_UTM.shp');
%     SF = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\DEU_water_linesUTM32N.shp');
else
    S = shaperead(names{tr});
%     SF = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\DEU_water_linesUTM32N.shp');
end
SF1 = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\ne_10m_rivers_europe_clipped.shp');
SF2 = shaperead('C:\Users\Andreas Wunsch\Workspace\02_GIS\Basemap\ne_10m_rivers_lake_centerlines_clipped.shp');

%%
% S1 = shaperead('66 Thueringisch Fraenkisches Bruchschollenland.shp');
% S2 = shaperead('65 Noerdlinger Ries.shp');
% S3 = shaperead('64 Schwaebische und Fraenkische Alb.shp');
% S4 = shaperead('63 Sueddeutscher Keuper und Albvorland.shp');
% S5 = shaperead('62 Sueddeutscher Buntsandstein und Muschelkalk.shp');
% S6 = shaperead('61 Suedwestdeutsche Trias.shp');

% S1 = shaperead('21 Sandmuensterland.shp');
% S2 = shaperead('22 Muensterlaender Kreidebecken.shp');
% S3 = shaperead('23 Niederrheinische Tieflandsbucht.shp');

% S1 = shaperead('51 Nordwestdeutsches Bergland.shp');
% S2 = shaperead('52 Mitteldeutscher Buntsandstein.shp');
% S3 = shaperead('53 Subherzyne Senke.shp');
% S4 = shaperead('54 Thueringische Senke.shp');

% S1 = shaperead('11 Nordseeinseln und Watten.shp');
% S2 = shaperead('12 Nordseemarschen.shp');
% S3 = shaperead('13 Niederungen im nord und mitteldeutschen Lockergesteinsgebiet.shp');
% S4 = shaperead('14 Norddeutsches Jungpleistozaen.shp');
% S5 = shaperead('15 Nord und mitteldeutsches Mittelpleistozaen.shp');
% S6 = shaperead('16 Altmoraenengeest.shp');
% S7 = shaperead('17 Lausitzer Kaenozoikum.shp');

% S1 = shaperead('91 Elbtalgraben.shp');
% S2 = shaperead('92 Fichtelgebirge Erzgebirge.shp');
% S3 = shaperead('93 Lausitzer Granodioritkomplex.shp');
% S4 = shaperead('94 Nordwestsaechsische Senke.shp');
% S5 = shaperead('95 Oberpfaelzer Bayerischer Wald.shp');
% S6 = shaperead('96 Suedostdeutsches Schiefergebirge.shp');
% S7 = shaperead('97 Thueringer Wald.shp');

% S1 = shaperead('82 Saar Nahe Becken.shp');

% S1 = shaperead('4101 Sueddeutsches Moraenenland.shp');
% S2 = shaperead('4102 Sueddeutsches Tertiaerhuegelland.shp');
% S3 = shaperead('4103 Iller Lech Schotterplatten.shp');
% S4 = shaperead('4104 Fluvioglaziale Schotter des Hochrheins und der Donau mit Nebenfluessen.shp');

%%
dat = data_weekly{:,2:end};
IDs = extractfield(data,'ProjID');
IDs = string(IDs)';
for i = 1:no
    Rmcount = 1;
%     figure
%     figure('Position', [100, 50, 750, 930]) % GR4
    figure('Position', [100, 50, 531, 930]) % R31, GR10
%     subplot(10,1,[1:9])
%     figure('Position', [100, 50, 980, 930]) %GR6
%     figure('Position', [100,50,1434,930]) %GR1
%     subplot(6,1,[1:5])
%     figure('Position', [100, 50, 700, 930]) %D
%     subplot(10,1,[1:9])
% %###################
%     mapshow(S1,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
%     mapshow(S2,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
%     mapshow(S3,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
%     mapshow(S4,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
%     mapshow(S5,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
%     mapshow(S6,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
%     mapshow(S7,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.5);
% %###################
    mapshow(S,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.75,'FaceAlpha',0);
    if HyraumID == "ORG32"
        mapshow(S1,'FaceColor', 'w', 'EdgeColor', 'k','LineWidth',0.75,'FaceAlpha',0);
    end

    limitx  = xlim-5000; limity = ylim; %R31+32
% %     limitx  = [325930 960580]; limity = [5665200 6107500]; %GR1
%     limitx  = xlim; limity = ylim;
    mapshow(SF1,'Color', 'blue','LineWidth',0.3)
    mapshow(SF2,'Color', 'blue','LineWidth',0.8)
    xlim(limitx),ylim(limity)
%     ylim([5550000 5820000]) %GR5 ohne Helgoland

    box on, %axis tight
    set(gca,'YTick',[],'XTick',[],'Fontsize',14);
    title(sprintf('Cluster %d (#%d)',i,size(wcd(i).sample_indices,1)))
    hold on
    %%
    %%%%%%%%%%%%%
    idx = find(finalClustering == i);
    c = dat(:,idx);
    k_ID = IDs(idx);
    [R,P,RL,RU] = corrcoef(c,'Rows','pairwise'); %Omit any rows containing NaN only on a pairwise basis for each two-column correlation coefficient calculation. This option can return a matrix that is not positive semi-definite.
    % extract significant values
    sig = P > 0.05;
    R_sig = R;
    R_sig(sig) = NaN;
    R_sig = R.*(1-P);
    %mean R values
    R_mean = nanmean(R_sig);
    R_mean = R_mean';
    [si,sort_idx]=sort(R_mean,'descend');%nach Distanz sortieren
    %%%%%%%%%
    
%     [si,sort_idx] = sort(wcd(i).sample_centroid_distances);
    samples=wcd(i).sample_indices(sort_idx);
%     cm = viridis(length(samples)); 
    cm = viridis(length(samples)*1.1); cm = cm(1:length(samples),:);
    for ii = 1:length(samples)
        s = find(StammdatenD.Proj_ID == data(samples(ii)).ProjID);
        plot(StammdatenD.XCoordETRS1989UTM32N(s),StammdatenD.YCoordETRS1989UTM32N(s),'ko','Color',cm(ii,:),'LineWidth',2)      
    end
    hold off
    colormap(cm); 
%     c=colorbar('Ticks',[0,1],'TickLabels',{'smallest','largest'}); 
c=colorbar('Ticks',[0,1],'TickLabels',{'highest','smallest'},'Direction','reverse'); 
%     title(c,{'Distance to','Cluster Centroid'});
    title(c,{'Intra-Cluster','Correlation'});
%     c.Location='manual';c.Position=[0.754,0.21,0.034,0.079];%ORG Position
%     c.Location='manual';c.Position=[0.754,0.21,0.034,0.079];%ORG Position
% 
    
     if HyraumID == 'ORG'
%          xlim([350000,490000]);
         xlim([330000,485000]);
         ylim([5250000 5570000])
     end
    
set(gca,'FontSize',14)

    %% saving
    p_max = ceil(length(samples)/50); %multiple saving for multiple stacked graphics
    if rem(length(samples),50)<5 && rem(length(samples),50)>0 && p_max > 1%Anzahl Speichervorgänge reduzieren, weil auch bereits weniger stacked Grafiken erstellt wurden
        p_max=p_max-1;
    end
    
    if saving_outputs == "Yes"
        for p = 1:p_max
            if p <= p_max
%                 if i == merge_cl
%                     print('-dpng','-r300',sprintf('Cluster_%dX_%d_map_importance.png',i,p));
%                 else
                    print('-dpng','-r300',sprintf('Cluster_%d_%d_map.png',i,p));
%                 end
            end
        end
    end
end
if saving_outputs == "Yes"
    close all
end
