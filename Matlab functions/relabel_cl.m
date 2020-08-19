function [clustering] = relabel_cl(cl)
cl = checkcl(cl');
cl = cl';
no = max(cl);
for i = 1:no
    idx = cl == i;
    hit_counts(i) = sum(idx);
end

clustering = nan(size(cl));
for i = 1:no
    c_idx = find(hit_counts == max(hit_counts));
    c_idx = c_idx(1);
    hit_counts(c_idx) = NaN;
    idx = find(cl == c_idx);
    clustering(idx) = i;    
end

end