function valclust = S2L_Clust_mod(sMap,connect,NTH)

% original function (BS2L and DS2L_Clust) by Guénaël Cabanes s.a.: Cabanes, G., Bennani, Y., & Fresneau, D. (2012). Enriched topological learning for cluster detection and visualization. Neural Networks, 32, 186–195. https://doi.org/10/f3z7z8
% modified by Andreas Wunsch (2019) to include some flexibility in terms of
% cluster number with variables/thresholds: DM and NTH

% function is called by BS2L_mod.m

nb_clust = 0;
[munits , ~] = size(sMap.codebook);

% ngconnect_log = logical(connect); %mod. für Schwellenwertimplikation(NTH)

testes = zeros(munits,1);
valclust = zeros(munits,1);

clustind = 1;

while ~isequal(testes, ones(munits,1))
    for i = 1:munits
        if testes(i,:)==0
            valclust(i) = clustind;
            testes(i)=1;
            testconnect=[];
            for j=1:munits
                siz = size(testconnect);
%                 if testes(j,:)==0 && ngconnect_log(i,j)==1 %mod. für Schwellenwertimplikation(NTH)
                if testes(j,:)==0 && connect(i,j)> NTH %mod. für Schwellenwertimplikation(NTH)
                    testconnect(siz(2)+1) = j; testes(j,:)=1;
                end
            end
            clustindtmp = clustind;
            if ~isequal(testconnect,[])
                clustind = clustind + 1;
            end
            while size(testconnect)~[1 0];
                test=testconnect(1);
                testconnect(1)=[];
                for j=1:munits
                    siz = size(testconnect);
%                     if testes(j,:)==0 && ngconnect_log(test,j)==1 %mod. für Schwellenwertimplikation(NTH)
                    if testes(j,:)==0 && connect(test,j)> NTH %mod. für Schwellenwertimplikation(NTH)
                        testconnect(siz(2)+1) = j; testes(j,:)=1;
                    end
                end
                valclust(test)=clustindtmp;
            end
        end
    end
end
%%%%%%%%%%
for j=1:munits
    if isequal(connect(j,:),zeros(1,munits))
        valclust(j)=-1;
    end
end

nb_clust_tmp = max(valclust);


if ~(nb_clust_tmp==nb_clust)
    
    codeb = sMap.codebook;
    clust = valclust ;
    x = 1; arret = 0;
    
    while arret == 0
        if clust(x,:)==-1
            clust(x,:)=[];
            codeb(x,:)=[];
        else
            x=x+1;
        end
        if x>size(clust,1)
            arret = 1;
        end
    end
end