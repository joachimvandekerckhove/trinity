function [f, nf] = print_partially_specified_matrix(L, prior, ...
    mat_name, temp_name, exploratory)
% Define loadings matrix in JAGS code

if nargin < 5
    exploratory = 'confirmatory';
    if nargin < 4
        temp_name = 'aux';
        if nargin < 3
            mat_name = 'L';
            if nargin < 2
                prior = 'dnorm(0.00, 1.00)';
            end
        end
    end
end

[T, F] = size(L);

free  = find(isnan(L));
nfree = find(~isnan(L));
nf  = numel(free);
nnf = numel(nfree);
[xf, yf] = ind2sub([T, F], free);
[xn, yn] = ind2sub([T, F], nfree);

f = { sprintf('for (c in 1:%i) {\n', nf)
      sprintf('     %s[c] ~ %s\n', temp_name, prior)
      sprintf('}\n\n') };

switch exploratory
    case 'confirmatory'
        for c = 1:nnf
            f{end+1} = sprintf('%s[%2i,%2i] <- %g\n', ...
                mat_name, xn(c), yn(c), L(xn(c), yn(c)));
        end
    case 'exploratory'
        for c = 1:nnf
            f{end+1} = sprintf('%s[%2i,%2i] ~ dnorm(%g, 100)\n', ...
                mat_name, xn(c), yn(c), L(xn(c), yn(c)));
        end
end
for c = 1:nf
    f{end+1} = sprintf('%s[%2i,%2i] <- %s[%i]\n', ...
        mat_name, xf(c), yf(c), temp_name, c);
end

end

%#ok<*AGROW>