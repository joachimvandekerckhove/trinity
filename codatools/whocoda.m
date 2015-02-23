function whocoda(chains)
% WHOCODA    List nodes in a coda structure
%
%    WHOCODA(CHAINS) shows the nodes available in a CODA stucture, with size
%    and type information.

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

fns = fieldnames(chains);

nfns = numel(fns);

stripped = strtok(fns, '_');
list = unique(stripped);
fnln = max([10; cellfun(@length, list)]) + 2;
btln = max(6, ceil(log10(max(structfun(@numel, chains)) * 8))) + 4;

nlst = numel(list);
niter = numel(chains.(fns{1}));

fstr1 = sprintf('  %%-%is%%-12s%%%is    %%-18s\\n\\n', fnln, btln);
fstr2 = sprintf('  %%-%is%%-12s%%%ii    %%-18s\\n', fnln, btln);
fstr3 = sprintf('  %%-%is%%-12s%%%ii    %%-18s\\n', fnln, btln);

fprintf(fstr1, 'Name', 'Size', 'Bytes', 'Type');

for ctr = 1:nlst
    match = ismember(stripped, list{ctr});
    nmatch = sum(match);
    if nmatch==1
        fprintf(fstr2, list{ctr}, '1x1', 8*niter, 'scalar')
    else
        mark = find(match, 1, 'last');
        remainder = fns{mark};
        sz = {};
        while true
            [sz{end+1}, remainder] = strtok(remainder, '_');
            if isempty(remainder), break, end
        end
        sz = cellfun(@str2double, sz);
        if numel(sz)==2
            sz(1) = 1;
        else
            sz(1) = [];
        end
        szstr = sprintf('%s%i', sprintf('%ix', sz(1:end-1)), sz(end));
        fprintf(fstr3, list{ctr}, szstr, ...
            8*prod(sz)*niter, sprintf('%i-D matrix', numel(sz)))
    end
end

fprintf('\n')
