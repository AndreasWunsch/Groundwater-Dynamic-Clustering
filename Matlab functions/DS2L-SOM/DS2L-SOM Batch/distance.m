function d = distance(a,b)

a2=sum(a.*a,1); b2=sum(b.*b,1); ab=a'*b; 
d = sqrt(abs(repmat(a2',[1 size(b2,2)]) + repmat(b2,[size(a2,2) 1]) - 2*ab));
