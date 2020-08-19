function [F_range_ratio,F_rng] = range_ratio(X,X1,date1)
F_rng=range(X); % total range
    
    Jahreszahlen=year(date1);
    Jahre=unique(Jahreszahlen);
    rng_tmp(1,1)=NaN;
    for ii=2:1:length(Jahre)-1 %skip first and last year, if not complete
        %extract single years
        idx=Jahreszahlen==Jahre(ii,1);
        J=X1(idx,1); %based on original data
        if sum(isnan(J))< 17 %not more than 16 nan values per year allowed
%             D=date1(idx,1);
            rng_tmp(ii,1)=range(J);
        else
            rng_tmp(ii,1)=NaN;
        end
        clear J D J2
    end
    F_range_ratio=nanmean(rng_tmp)/F_rng;
    
end

