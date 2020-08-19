function [F_jumps] = jumps(date1,X1z)
Jahreszahlen=year(date1);
Jahre=unique(Jahreszahlen);
mean_tmp(1,1)=NaN;
for ii=2:1:length(Jahre)-1 %skip first and last year of not complete
    %extract single years
    idx=Jahreszahlen==Jahre(ii,1);
    J=X1z(idx,1); %based on z-scored data
    if sum(isnan(J)) <= 17 %not more than 16 nan values allowed
        %             D=date1(idx,1);
        mean_tmp(ii,1)=nanmean(J);
    else
        mean_tmp(ii,1)=NaN;
    end
    clear J
end
F_jumps= (max(abs(diff(mean_tmp))) / nanmean(abs(diff(mean_tmp)))).^2;


end

