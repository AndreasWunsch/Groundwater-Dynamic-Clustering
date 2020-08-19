function [Pearson_r,p_val,metrik] = seasonalbehaviour(date1,X1z)

Monate = month(date1);
for i = 1:12
    idx = Monate == i;
   month_means(i,1)= nanmean(X1z(idx));
end

for i=1:12
   representative(i,1)=sin(1/(6/pi())*i); 
end

[Pearson_r,p_val]=corr(representative,month_means);
if Pearson_r >= 0
%     plot(representative),hold on,plot(month_means),hold off
    distance=norm(representative-month_means);
else
    representative = representative*-1;
%     plot(representative),hold on,plot(month_means),hold off
    distance=norm(representative-month_means);
end
metrik = Pearson_r/distance;
% title(sprintf('r=%f, dist=%f, metrik=%f',Pearson_r,distance,metrik))
end

