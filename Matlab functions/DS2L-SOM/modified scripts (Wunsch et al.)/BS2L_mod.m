function sM = BS2L_mod(Data, sM, DM, NTH, varargin)

% original function (BS2L) by Guénaël Cabanes s.a.: Cabanes, G., Bennani, Y., & Fresneau, D. (2012). Enriched topological learning for cluster detection and visualization. Neural Networks, 32, 186–195. https://doi.org/10/f3z7z8
% modified by Andreas Wunsch (2019) to include some flexibility in terms of
% cluster number with variables/thresholds: DM and NTH

% needs also S2L_Clust_mod.m to run properly



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% INITIALISATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
warning off all

close all

if ismember('norm',varargin)
    Data = som_normalize(Data,'var');
end

M = sM.codebook;

Ne1 = som_unit_neighs(sM.topol);
udist = som_neighborhood(Ne1,1);
udist(udist==0)=inf;

[munits dim] = size(M);
[dlen ddim] = size(Data);
blen = min(munits,dlen);

mask = ones(dim,1);
W1 = (mask*ones(1,dlen));
WD = 2*diag(mask)*Data';

W2 = ones(munits,1)*mask';
D2 = (Data'.^2);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Post Apprentissage (Nach dem Training) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

dis = distance(M',M'); dis(dis==0) = inf;

sigma = mean(min(dis));

density = zeros(munits,1);

i0 = 0;

while i0+1<=dlen,
    
    inds = [(i0+1):min(dlen,i0+blen)]; i0 = i0+blen;
    Dist = (M.^2)*W1(:,inds) - M*WD(:,inds) + W2*D2(:,inds); % Distance euclidienne au carrÃ©e
    Dist = Dist*(2/ddim); % Dist(dim)Â² = dim/2 * dist(2)Â², on pondÃ©re les distances par le rapport entre la dim des donnÃ©es et la dim de la carte
    
    [sorted, index] = sort(Dist);
    bmus(inds) = index(1,:);
    bmus2(inds) = index(2,:);
    
    Dendist = 1/(sigma*sqrt(2*pi)) * exp(-0.5 * Dist / sigma^2);
    
    density = density + sum(Dendist,2);
    
end

ngconnect = zeros(munits,munits);

for ii = 1:size(bmus,2)
    ngconnect(bmus(ii),bmus2(ii)) = (ngconnect(bmus(ii),bmus2(ii))) + 1;
    ngconnect(bmus2(ii),bmus(ii)) = (ngconnect(bmus2(ii),bmus(ii))) + 1;
    
end

sM.ngconnect=ngconnect;

sM.valclust = S2L_Clust_mod(sM, sM.ngconnect,NTH);

%%%%%%%%%%%% À NE PAS UTILISER POUR UTILISER LES CONNEXIONS(NICHT FÜR DIE NUTZUNG DER VERBINDUNGEN ZU VERWENDEN.) %%%%%%%%%%%%%%%

%sM.valclust(sM.valclust>0) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sM.density = density;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Post traitement de la densité %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
denclust = sM.density;

%Etape 1, calcul des zones emmergées(Berechnung der umrandeten Flächen)

udist(udist==inf)=0;
nclust = 1;
for n = 1:max(sM.valclust)
    for un = 1 : size(sM.density,1)
        if sM.valclust(un)==-1
            denclust(un)=-1;
        elseif sM.valclust(un)==n
            tmp_udist = udist(un,:)'.*(sM.valclust==n);
            if sM.valclust(un,:)==n
                denV = sM.density.*(tmp_udist==1);
                if max(denV) < sM.density(un)
                    denclust(un)=nclust; nclust = nclust + 1;
                else
                    denclust(un)=-1;
                end
            end
        end
    end
end


sM.denclust = denclust;

%Etape 2, calcul du seuil de regroupement et monté de gradient de densité
%(Berechnung der Gruppierungsschwelle und des Dichtegradientenanstiegs)

co = min(sM.density(:));
%co = mean(sM.density(:));
%co = 0.08;

seuil = zeros(max(denclust));

for clust1 = 1 : max(denclust)
    for clust2 = 1 : max(denclust)
        AB = sM.density(denclust == clust1) - co;
        CD = sM.density(denclust == clust2) - co;
        seuil(clust1,clust2) = 1/(1/AB+1/CD) + co;
    end
end

denct = findsommet(sM, sM.density); denct2 = denct;

if DM == "Yes"
    % %Etape 3, regrouper les clusters non séparés par un fossé de densité important (cf seuil de regroupement)
    % (Gruppierung der Cluster, die nicht durch einen Spalt hoher Dichte getrennt sind (siehe Clustering-Schwellenwert).)
    regroup = zeros(max(denclust));
    
    for unit = 1 : size(denct,1)
        for vois = 1 : size(denct,1)
            if sM.valclust(unit)==sM.valclust(vois) && denct(unit)>0 && denct(vois)>0 && udist(unit,vois)==1 && ~(denct(unit)==denct(vois)) && sM.density(unit)>seuil(denct(unit),denct(vois)) && sM.density(vois)>seuil(denct(unit),denct(vois));
                regroup(denct(unit),denct(vois)) = 1;
                regroup(denct(vois),denct(unit)) = 1;
            end
        end
    end
    
    for cl1 = 1 : max(denclust)
        for cl2 = 1 : max(denclust)
            if regroup(cl1,cl2)==1
                denct(denct==min(cl1,cl2))=max(cl1,cl2);
                regroup(min(cl1,cl2),:)=min(regroup(cl1,:)+regroup(cl2,:),1);
                regroup(max(cl1,cl2),:)=min(regroup(cl1,:)+regroup(cl2,:),1);
            end
        end
    end
end
%% correction des valeurs de cluster
step = 1;

for ii=1:max(denct)
    denct(denct==ii)=step;
    if ismember(step, denct) ; step=step+1;
    end
end

Denmodes = sM.denclust;

sM.denclust = denct;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Visualisation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%

% sMShow = rmfield(sM,'ngconnect');
% sMShow = rmfield(sMShow,'valclust');
% sMShow = rmfield(sMShow,'density');
% 
% nbclust = max(sM.valclust);

% if ismember('vote',varargin)
%     sMShow = som_autolabel(sMShow, sD, 'vote');
%     
% elseif ismember('add',varargin)
%     sMShow = som_autolabel(sMShow, sD, 'add1');
%     
% elseif ismember('freq',varargin)
%     sMShow = som_autolabel(sMShow, sD, 'freq');
%     
% end



for i=1:length(varargin)
    
%     if strcmp(varargin(i),'data') 
%         if size(Data,2)==3 
%             figure
%             plot3(Data(:,1),Data(:,2),Data(:,3),'ro')
%             hold on
%             som_grid(sM,'Coord',sM.codebook)
%             figure
%             plot3(Data(:,1),Data(:,2),Data(:,3),'ro')
%         else
%             figure
%             [Pd,V,me] = pcaproj(Data,2);        % projection des data
%             Pm        = pcaproj(sM.codebook,V,me); % projection des prototypes
%             plot(Pd(:,1),Pd(:,2),'ro')
%             hold on
%             som_grid(sM,'Coord',Pm)
%             figure
%             plot(Pd(:,1),Pd(:,2),'ro')
%         end
%     end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if strcmp(varargin(i),'den')
        
        svc = sign(sM.valclust+1);
        figure('Position', [250 200 1100 700])
%         figure(i)
        %         som_show_S2L(sM,'color',{sM.valclust,'Cluster par connexion'},'ngpe',1,'ngpei',1,'color',{Denmodes.*svc,'Etape 1'},'color',{denct2,'Etape 2'},'color',{denct,'Etape 3'},'norm','n');
        som_show_S2L(sM,'color',{sM.valclust,'Neighborhod Cluster'},'ngpe',1,'ngpei',1,'color',{Denmodes.*svc,'Step 1'},'color',{denct2,'Step 2'},'color',{denct,'Step 3'},'norm','n');
    end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%     if strcmp(varargin(i),'sammon')
%         if size(sM.codebook,2) >2
%             P = sammon(sM,3);
%         else
%             P = sammon(sM,2);
%         end
%         
%         mmoy = mean(sM.ngconnect(:));
%         
%         
%         for unit1 = 1 : size(sM.codebook,1)
%             for unit2 = 1 : size(sM.codebook,1)
%                 if udist(unit1,unit2)==1
%                     if sM.valclust(unit1) == sM.valclust(unit2) && sM.valclust(unit1)>0 && sM.ngconnect(unit1,unit2)==0
%                         connect(unit1,unit2) = mmoy;
%                     elseif  ~(sM.valclust(unit1) == sM.valclust(unit2)) || sM.valclust(unit1)==-1 || sM.valclust(unit2)==-1
%                         connect(unit1,unit2) = 0;
%                     else
%                         connect(unit1,unit2) = sM.ngconnect(unit1,unit2);
%                     end
%                 end
%             end
%         end
%         
%         
%         linesize = connect / max(connect(:));
%         
%         unitsize = zeros(size(sM.density));
%         unitsize(~(sM.denclust==-1)) = 20 * sM.density(~(sM.denclust==-1))/ max(sM.density(~(sM.denclust==-1)));
%         
%         unitcolor = zeros(size(sM.denclust,1),3);
%         
%         for nclust = 1 : max(sM.denclust)
%             rnd = rand(1,3);
%             for classe = 1 : size(sM.denclust,1)
%                 if sM.denclust(classe,:) == nclust
%                     unitcolor(classe,:) = rnd;
%                 end
%             end
%         end
%         
%         figure(i)
%         
%         som_grid(sM,'Coord',P,'MarkerColor',unitcolor,'Linecolor','k','LineWidth',linesize,'MarkerSize',unitsize,'Label',sMShow.labels,'LabelSize',10,'LabelColor','k');
%         
%     end

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 
%     if strcmp(varargin(i),'datacolorden') 
%         Bmus = som_bmus(sM, Data, 'best');
%         clust = sM.denclust;
%         nbgr = max(clust);
%         color=jet(nbgr);
%         dataclust = clust(Bmus);
%         
%         sM.bmu = Bmus;
%         
%         if size(Data,2)==2 
%             figure
%             for ii=1:nbgr
%                 dat=Data(dataclust==ii,:);
%                 plot(dat(:,1),dat(:,2),'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color(ii,:));
%                 hold on
%             end
%             hold on
%         elseif size(Data,2)==3 
%             figure
%             for ii=1:nbgr
%                 dat=Data(dataclust==ii,:);
%                 plot3(dat(:,1),dat(:,2),dat(:,3),'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color(ii,:));
%                 hold on
%             end
%             hold on
%         else
%             figure
%             [Pd,V,me] = pcaproj(Data,3);        % projection des data
%             for ii=1:nbgr
%                 dat=Pd(dataclust==ii,:);
%                 plot3(dat(:,1),dat(:,2),dat(:,3),'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color(ii,:));
%                 hold on
%             end
%             hold on
%         end
%     end
    
    
end
