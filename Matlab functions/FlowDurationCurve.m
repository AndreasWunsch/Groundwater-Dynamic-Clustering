function [P,Xs] = FlowDurationCurve(X)
% Flow Duration Curve
%remove NaN
X(isnan(X)) = [];

% Rank (order) for each value
Xs = sort(X,'descend');
ranks(:,1) = 1:length(Xs);

% Exceedance Probability:
P = ranks./(length(Xs)+1);

% Flow Duration Curve Plot
% scatter(P,Xs);
end

