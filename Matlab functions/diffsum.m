function [DS] = diffsum(date1,X1z)
%Median aller Summen der Beträge aller Steigungen pro Einzeljahr
% -> sowas wie eine mittlere Steigung
Jahre = year(date1);
k=1;
for i = min(Jahre)+1:max(Jahre)
    idx = Jahre == i;
    DS_all(k,1)= nansum(abs(diff(X1z(idx))));k=k+1;
%     plot(date1(idx),X1z(idx));
end

DS=median(DS_all);
% plot(DS_all)
end

