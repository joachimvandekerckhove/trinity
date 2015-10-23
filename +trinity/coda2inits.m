function initstr = coda2inits(chains, odp, banList)
% CODA2INITS Try to make initial values structure from coda structure
% initstr = coda2inits(chains, odp, banList)
%   Usage:       'inits', @coda2inits(chain), ...

if nargin < 3
    banList = {'deviance'};
    if nargin < 2
        odp = 1;
    end
else
    banList = [banList {'deviance'}];
end

list = whocoda(chains);
list(cellfun(@(x)ismember(x, banList), list)) = [];
np = numel(list);

if ismember('deviance', list)
    [~, ml] = min(chains.deviance(:));
    [sm, ch] = ind2sub(size(chains.deviance), ml);
    subset = structfun(@(x)x(sm,ch), chains, 'uni', 0);
end

for p = 1:np
    mn = get_matrix_from_coda(subset, list{p});
    sd = get_matrix_from_coda(chains, list{p}, @std) * odp;
    if isvector(mn)
        mn = mn';
        sd = sd';
    end
    initstr.(list{p}) = rand(size(mn)) .* sd * 4 + mn - 2*sd;
end
