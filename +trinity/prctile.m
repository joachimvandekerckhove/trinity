function o = prctile(d, p)
% PRCTILE Compute percentiles of a vector
%   O = PRCTILE(D, P), where D is a vector of data and P a vector of
%   percentiles, returns O, a vector of associated quantiles.
%
%   See also: PRCTILE (Statistics Toolbox).

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

n   = length(d);
d   = sort(d);
spc = [0 (0.5:(n-0.5))./n 1]';
vec = [d(1,:); d(1:n,:); d(n,:)];
o   = interp1q(spc, vec, p'/100)';
