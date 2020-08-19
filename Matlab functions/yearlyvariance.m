function [var_y] = yearlyvariance(date1,X1z)
Jahreszahlen=year(date1);
Jahre=unique(Jahreszahlen);
var_tmp(1,1)=NaN;
for ii=2:1:length(Jahre)-1 %skip first and last year if not complete
    %extract single years
    idx=Jahreszahlen==Jahre(ii,1);
    J=X1z(idx,1); %based on z-scored data
    if sum(isnan(J)) <= 17 %not mor than 16 nan values allowed
        %             D=date1(idx,1);
        var_tmp(ii,1)=nanvar(J);
    else
        var_tmp(ii,1)=NaN;
    end
    clear J
end
% var_y=nanmean(var_tmp);
var_y=nanmedian(var_tmp);


end

