function [DIST] = my_dist(features, codebook)
% each columns of 'features' is a data vector
d = disteu(features, codebook);
DIST = sum(min(d,[],2)) / size(d,1);
end