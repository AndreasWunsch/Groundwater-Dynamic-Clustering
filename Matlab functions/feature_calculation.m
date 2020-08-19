function [F_range_ratio,F_skewness,F_P52corr,F_dif,...
    F_longest_recession,F_jumps,F_SEM,F_seasonalbehaviour,...
    F_var_y,F_HPD,F_LPD,F_median_01scale] = feature_calculation(date1,X1)

%This function calculates time series features using a datetime vector
%date1 and a datavector X1

%% precalculations 
% 'X1' contains NaNs
% 'X1z' is zscored X1
% 'X' contains no NaNs
% 'Xz' is zscored X
% 'Xs' is X normalized to [0 1] range

% X: Remove lines containing NaN Elements

[X,~] = removeNaN(X1,date1);
if  exist('X','var')==10
    X = NaN(1);
end

%Xz (not needed here)
% Xz=zscore(X); %z-scoring

%X1z
F_std=nanstd(X);    %standard deviation
F_mean=nanmean(X);  %mean valuee
X1z=(X1-F_mean)/F_std; %z-scoring

%Xs
Xs = normalize(X,'range');

%% F_range_ratio
[F_range_ratio,~] = range_ratio(X,X1,date1);

%% Skewness
[F_skewness] = skew(X1,F_mean,F_std);

%% F_trend: de-trending
[X_detrend,~] = TREND(X1,X); %[X_detrend,X_trend]

%% periodicity, P52/P52corr
[~,X_periodic,~] = PERIOD(X_detrend,52); %[remainder,X_periodic,periodic]
F_P52corr=corr(X_periodic,X1,'rows','complete');

%% Seasonal behaviour
[~,~,F_seasonalbehaviour] = seasonalbehaviour(date1,X1z);

%% SD_diff
F_dif=nanstd(diff(X));

%% longest recession
[F_longest_recession] = recession_length(X);

%% jumps
[F_jumps] = jumps(date1,X1z);

%% Standar Error of the Mean
F_SEM=F_std/sqrt(length(X));

%% yearly variance Y_var
F_var_y = yearlyvariance(date1,X1z);

%% Med01
F_median_01scale = median(Xs);

%% Pulse durations: HPD,LPD
[F_HPD, F_LPD] = PulseDurations(Xs);


end

