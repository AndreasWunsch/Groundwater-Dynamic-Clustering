function d = findsommet(sMap,density)

Ne1 = som_unit_neighs(sMap.topol);
udist = som_neighborhood(Ne1,1);
udist(udist==inf)=0;

d = sMap.denclust;

for nclust = 1:max(sMap.valclust);          			% Pour chaque cluster initial
    dold = d - 1;						% Initialiser le while
    while ~isequal(dold,d);					% Tant qu'il y a des modifs
        dold = d;    							
        for i=1:size(d);					% Pour chaque neurone i
            tmp_udist = udist(i,:)'.*(sMap.valclust==nclust);	% Parmis les voisins du même cluster (nclust)
            if d(i)==-1 && sMap.valclust(i,:)==nclust;		% Si i n'a pas de denclust et appartient à nclust
                    [dummy mpos] = max(density.*tmp_udist);	% Chercher le voisin de densité maximale
                    if dummy > 0 && d(mpos,:)>-1;		% Si la densité max est non nulle et que le max appartien à denclust
			 d(i,:) = d(mpos,:); 			% i appartient à denclust
		    end;		
            end;
        end;
    end;
end;


%for nclust = 1:max(sMap.valclust);
%    dold = d - 1;
%    while ~isequal(dold,d);
%        dold = d;    
%        for i=1:size(density);
%            tmp_udist = udist(i,:)'.*(sMap.valclust==nclust);
%            if d(i)==-1 && sMap.valclust(i,:)==nclust;
%                    [dummy mpos] = max(density.*tmp_udist.*(d>-1));
%                    if dummy > 0; d(i,:) = d(mpos,:); end;
%            end;
%        end;
%    end;
%end;

% dold = d - 1;
% 
% while ~isequal(dold,d);
%     dold = d;    
%     for i=1:size(density);
%         if d(i)==-1 && ~(sMap.valclust(i,:)==-1) 
%                 du = density.*udist(i,:)';
%                 duc = density.*udist(i,:)'.*(sMap.valclust==sMap.valclust(i));
%                 if max(duc)<density(i);  
%                     [dum mpos] = max((du==(max(du))) .* (d>0));
%                     if dum>0; d(i,:) = d(mpos,:); end;
%                 else
%                     [dum mpos] = max((duc==(max(duc))) .* (d>0));
%                     if dum>0; d(i,:) = d(mpos,:); end; 
%                 end;
%         end;
%     end;
% end;

% dold = d -1;
% 
% while ~isequal(dold,d);
%     dold = d;    
%     for i=1:size(density);
%         if d(i,:)==-1 && ~(sMap.valclust(i,:)==-1) 
%                 [dummy mpos] = max(density.*udist(i,:)'.*(d>-1));
%                 if dummy > 0; d(i,:) = d(mpos,:); end;
%         end;
%     end;
% end;
