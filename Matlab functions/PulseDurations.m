function [F_HPD, F_LPD] = PulseDurations(Xs)

[P,X_ranked] = FlowDurationCurve(Xs);

upb = find(P >= 0.8); upb = X_ranked(upb(1));
lwb = find(P <= 0.2); lwb = X_ranked(lwb(end));

idx = Xs >= upb; [~, N, ~] = RunLength(idx);
F_HPD = nanmean(N); 
if isnan(F_HPD)
%     pause;
    F_HPD = 0;
end
idx = Xs <= lwb; [~, N, ~] = RunLength(idx);
F_LPD = nanmean(N); 
if isnan(F_LPD)
%     pause;
    F_LPD = 0;
end
end

