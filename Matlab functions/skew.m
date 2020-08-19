function [F_skewness] = skew(X1,F_mean,F_std)
m3=X1;
    for ii=1:length(X1)
        m3(ii,1)=(X1(ii,1)-F_mean)^3;
    end
    F_skewness=nanmean(m3)/F_std^3;
end

