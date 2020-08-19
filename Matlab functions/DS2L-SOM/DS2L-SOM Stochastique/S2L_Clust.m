function valclust = S2L_Clust(sMap,connect)

nb_clust = 0;
[munits dim] = size(sMap.codebook);

ngconnect_log = logical(connect);

testes = zeros(munits,1);
valclust = zeros(munits,1);

clustind = 1;

while ~isequal(testes, ones(munits,1));
    for i = 1:munits,
        if testes(i,:)==0;
            valclust(i) = clustind;
            testes(i)=1;
            testconnect=[];
            for j=1:munits,
                siz = size(testconnect);
                if testes(j,:)==0 && ngconnect_log(i,j)==1; testconnect(siz(2)+1) = j; testes(j,:)=1; end;
            end;
            clustindtmp = clustind;
            if ~isequal(testconnect,[]); clustind = clustind + 1; end;
            while size(testconnect)~[1 0];
                test=testconnect(1); testconnect(1)=[];
                for j=1:munits,
                    siz = size(testconnect);
                    if testes(j,:)==0 && ngconnect_log(test,j)==1; testconnect(siz(2)+1) = j; testes(j,:)=1; end;
                end;
                valclust(test)=clustindtmp;
            end;
        end;
    end;
end;

for j=1:munits,
    if isequal(ngconnect_log(j,:),zeros(1,munits)); valclust(j)=-1; end;
end;

nb_clust_tmp = max(valclust);


if ~(nb_clust_tmp==nb_clust); 

    codeb = sMap.codebook;
    clust = valclust ;
    x = 1; arret = 0;

    while arret == 0 ;
         if clust(x,:)==-1; 
                clust(x,:)=[];
                codeb(x,:)=[];
         else x=x+1; 
         end;
         if x>size(clust,1); arret = 1; end;
    end;
end;    