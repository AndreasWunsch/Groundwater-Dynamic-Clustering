function [F_longest_recession] = recession_length(X)
Ableitungen=diff(X);
Steigung=sign(Ableitungen);
%längste Sequenz negativer Steigungswerte
zero_idx=Steigung==0;
Steigung_mod=Steigung;
Steigung_mod(zero_idx,1)=-1;
[b, n, ~] = RunLength(Steigung_mod);
neg_idx=b==-1;
neg_sequences=n(neg_idx,1);
F_longest_recession=max(neg_sequences);
if isempty(F_longest_recession)==1
    F_longest_recession = 0;
end
end

