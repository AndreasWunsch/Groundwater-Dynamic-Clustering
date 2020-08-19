function [TS_detrend,trend] = TREND(TS,TS_nogaps)
%original length of TS

smpls1=length(TS);
x1=[1:smpls1]';

%% detrend
smpls=length(TS_nogaps);
x=[1:smpls]';
y=detrend(TS_nogaps);

trend = TS_nogaps-y;
% subtract trend elementwise from original time series
idx = isnan(TS) == 0;
TS_detrend = nan(size(TS));
TS_detrend(idx) = TS(idx) - trend;

end

