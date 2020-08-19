function sM=S2LD_SOM(D, varargin)

warning off all

close all

TF=0;

if isempty(varargin),
  varargin = {'umat','ngi','ng'};
end
  
if ischar(D); sD = som_read_data(D); data = sD.data; else sD = D; data=D; end;  
if isequal(varargin{1} , 'msize')  ;TF=1; mapsize=varargin{2} ;varargin{2}='';end;
if ismember('norm',varargin), sD = som_normalize(sD,'var'); end;

arg = {};

if ismember('long',varargin);
    if ismember('small',varargin); arg =  {'long','small'};
    elseif ismember('big',varargin); arg =  {'long','big'};
    else arg =  {'long'};
    end;
elseif ismember('small',varargin); arg = {'small'};
elseif ismember('big',varargin); arg = {'big'};    
end;
if TF; arg = {arg{:},'msize',mapsize}; end;

%%%%%%%%%%%%% Apprentissage %%%%%%%%%%%%%%%%%

if ismember('rect',varargin); sM=som_make_S2LD(sD,'seq','rect',arg{:});
else sM=som_make_S2LD(sD,'seq',arg{:}); end; 


%%%%%%%%%% Segmentation par la densité %%%%%%%%%%%%%%

Ne1 = som_unit_neighs(sM.topol);
udist = som_neighborhood(Ne1,1);
udist(find(udist==0))=inf;

denclust = sM.density;

%Etape 1, calcul des zones emmergées            

udist(udist==inf)=0;
nclust = 1;                     
for n = 1:max(sM.valclust);
    for un = 1 : size(sM.density,1);
        if sM.valclust(un)==-1; denclust(un)=-1;
        elseif sM.valclust(un)==n;
            tmp_udist = udist(un,:)'.*(sM.valclust==n);
            if sM.valclust(un,:)==n;
              denV = sM.density.*(tmp_udist==1);
              if max(denV) < sM.density(un); 
                  denclust(un)=nclust; nclust = nclust + 1;
              else denclust(un)=-1; 
              end;
            end;
        end;
    end;
end;


sM.denclust = denclust;

%Etape 2, calcul du seuil de regroupement et monté de gradient de densité
co = min(sM.density(:));
%co = mean(sM.density(:));
%co = 0.08;

seuil = zeros(max(denclust));

for clust1 = 1 : max(denclust);
    for clust2 = 1 : max(denclust);
        AB = sM.density(denclust == clust1) - co;
        CD = sM.density(denclust == clust2) - co;
        seuil(clust1,clust2) = 1/(1/AB+1/CD) + co;
    end;
end;

denct = findsommet(sM, sM.density); denct2 = denct;

%Etape 3, regrouper les clusters non séparés par un fossé de densité important (cf seuil de regroupement)
regroup = zeros(max(denclust));

for unit = 1 : size(denct,1); 
    for vois = 1 : size(denct,1); 
        if sM.valclust(unit)==sM.valclust(vois) && denct(unit)>0 && denct(vois)>0 && udist(unit,vois)==1 && ~(denct(unit)==denct(vois)) && sM.density(unit)>seuil(denct(unit),denct(vois)) && sM.density(vois)>seuil(denct(unit),denct(vois));
            regroup(denct(unit),denct(vois)) = 1;
            regroup(denct(vois),denct(unit)) = 1;
        end;
    end;
end; 

for cl1 = 1 : max(denclust); 
        for cl2 = 1 : max(denclust); 
            if regroup(cl1,cl2)==1; 
                denct(denct==min(cl1,cl2))=max(cl1,cl2);
                regroup(min(cl1,cl2),:)=min(regroup(cl1,:)+regroup(cl2,:),1);
                regroup(max(cl1,cl2),:)=min(regroup(cl1,:)+regroup(cl2,:),1);
            end;
        end;
end;

%%% correction des valeurs de cluster      
step = 1;

for ii=1:max(denct)
    denct(denct==ii)=step;
    if ismember(step, denct) ; step=step+1;
    end;
end;

Denmodes = sM.denclust;

sM.denclust = denct;

%Visualisation
sMShow = rmfield(sM,'t');
sMShow = rmfield(sMShow,'ngconnect');
sMShow = rmfield(sMShow,'valclust');
sMShow = rmfield(sMShow,'density');
sMShow = rmfield(sMShow,'denclust');

nbclust = max(sM.valclust);

if ismember('vote',varargin); 
    sMShow = som_autolabel(sMShow, sD, 'vote');

elseif ismember('add',varargin); 
     sMShow = som_autolabel(sMShow, sD, 'add1'); 

elseif ismember('freq',varargin); 
    sMShow = som_autolabel(sMShow, sD, 'freq');

end
                           

for i=1:length(varargin),

    if strcmp(varargin(i),'umat');
        figure(i)
        som_show_S2LD(sM,'Umat','all');
    end;

    if strcmp(varargin(i),'sammon');
           if size(sM.codebook,2) >2; 
                P = sammon(sM,3);
            else P = sammon(sM,2);
            end;
            
            mmoy = mean(sM.ngconnect(:));
            
             
            for unit1 = 1 : size(sM.codebook,1);
                 for unit2 = 1 : size(sM.codebook,1);
                    if udist(unit1,unit2)==1;
                        if sM.valclust(unit1) == sM.valclust(unit2) && sM.valclust(unit1)>0 && sM.ngconnect(unit1,unit2)==0, connect(unit1,unit2) = mmoy;
                        elseif  ~(sM.valclust(unit1) == sM.valclust(unit2)) || sM.valclust(unit1)==-1 || sM.valclust(unit2)==-1,  connect(unit1,unit2) = 0; 
                        else connect(unit1,unit2) = sM.ngconnect(unit1,unit2);
                        end;
                   end;
                end;
            end;
                     
                     
            linesize = connect / max(connect(:));
            
            unitsize = zeros(size(sM.density));
            unitsize(~(sM.denclust==-1)) = 20 * sM.density(~(sM.denclust==-1))/ max(sM.density(~(sM.denclust==-1)));
            
            unitcolor = zeros(size(sM.denclust,1),3);
                            
            for nclust = 1 : max(sM.denclust);
                rnd = rand(1,3);
                for classe = 1 : size(sM.denclust,1);
                    if sM.denclust(classe,:) == nclust; 
                        unitcolor(classe,:) = rnd; 
                    end;
                end;
            end;     
                      
            figure(i)
            
            som_grid(sM,'Coord',P,'MarkerColor',unitcolor,'Linecolor','k','LineWidth',linesize,'MarkerSize',unitsize,'Label',sMShow.labels,'LabelSize',10,'LabelColor','k');
    end;

    if strcmp(varargin(i),'den');

        svc = sign(sM.valclust+1);

        figure(i)
        som_show_S2LD(sM,'color',{sM.valclust,'Cluster par connexion'},'ngpe',1,'ngpei',1,'color',{Denmodes.*svc,'Etape 1'},'color',{denct2,'Etape 2'},'color',{denct,'Etape 3'},'norm','n');

    end;

    if strcmp(varargin(i),'ng');
        figure(i)
        h=som_show_S2LD(sM,'ng',1,'norm','n');
        som_show_add('label',sMShow,'Textsize',8,'TextColor','k','Subplot',1);
        colormap(h.plane(1),jet(nbclust+2)), 
        labelstick = {'Non connecté'};
        posstick = [-0.5] ;
        for k=1:nbclust-1,
            labelstick(k+1)={sprintf('Cluster %d',k)};
            posstick(k+1)=k+0.5;
        end;
        som_recolorbar(1,posstick,'',{labelstick});
    end;

    if strcmp(varargin(i),'comp');
        figure(i)
        som_show_S2LD(sM,'comp','all');
    end;    


    if strcmp(varargin(i),'data') ;
        if size(data,2)==3 ;
            figure
            plot3(data(:,1),data(:,2),data(:,3),'ro')
            hold on
            som_grid(sM,'Coord',sM.codebook)
            figure
            plot3(data(:,1),data(:,2),data(:,3),'ro')
        else
            figure
            [Pd,V,me] = pcaproj(data,2);        % project the data
            Pm        = pcaproj(sM.codebook,V,me); % project the prototypes
            plot(Pd(:,1),Pd(:,2),'ro')
            hold on
            som_grid(sM,'Coord',Pm)
            figure
            plot(Pd(:,1),Pd(:,2),'ro')
        end;
    end;   

     if strcmp(varargin(i),'datacolorden') ;
            Bmus = som_bmus(sM, sD, 'best');
            clust = sM.denclust;
            nbgr = max(clust);
            color=jet(nbgr);
            dataclust = clust(Bmus);
            
            sM.bmu = Bmus;
            
            if size(data,2)==2 ;
                figure
                for ii=1:nbgr
                    dat=data(dataclust==ii,:);
                    plot(dat(:,1),dat(:,2),'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color(ii,:));
                    hold on
                end;
                hold on
            elseif size(data,2)==3 ;
                figure
                for ii=1:nbgr
                    dat=data(dataclust==ii,:);
                    plot3(dat(:,1),dat(:,2),dat(:,3),'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color(ii,:));
                    hold on
                end;
                hold on
            else
                figure
                [Pd,V,me] = pcaproj(Data,3);        % projection des data  
                for ii=1:nbgr
                    dat=Pd(dataclust==ii,:);
                    plot3(dat(:,1),dat(:,2),dat(:,3),'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', color(ii,:));
                    hold on
                end;
                hold on
            end;
      end; 
end;

sM = rmfield(sM,'t');
sM = rmfield(sM,'bmu');
