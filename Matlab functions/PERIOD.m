function [remainder,TS_periodic,periodic] = PERIOD(TS,P) 
%data gaps should contain 'NaN'
%NaNs are simply ignored and do not contribute to the periodic fraction of TS
%P=Period length
periodic=zeros(P,1);

for i=1:P
    temp(1,1)=TS(1,1);
for ii=2:length(TS)/P
    temp(ii,1)=TS(ii*P-P+i,1);
end
periodic(i,1)=nanmean(temp(:,1));
end

for i=1:length(TS)/P
TS_periodic(i*P-P+1:i*P,1)=periodic;
end


cnt=length(TS)-length(TS_periodic);
TS_periodic(end+1:end+cnt,1)=periodic(1:cnt,1);
remainder=TS-TS_periodic;


end

