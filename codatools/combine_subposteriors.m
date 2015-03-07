function stats = combine_subposteriors(chains, method, varargin)
% TRINITY_COMBINE_SUBPOSTERIORS  Combines subposteriors per Neiswanger, Wang, and Xing
%    STATS = trinity_combine_subposteriors(CHAINS, METHOD), where CHAINS
%    is a struct array with chains that all result from runs of an
%    identical model on different data sets, and METHOD is 'nwx1', 'nwx2',
%    or 'nwx3', computes statistics of the full-data posterior using any
%    one of the three methods descibed in Neiswanger, Wang, and Xing (2014)
%    and returns them in STATS. Note that the model used to obtain CHAINS
%    must be appropriate for use of these methods. Specifically, the model
%    must be built with subpriors.

fieldns = fieldnames(chains);

% Put all chains in a 3D matrix [iteration, node, batch]:
samples = collapse_chains(chains);  

switch method
    case {1 'nwx1'}
        stats = combine_subposteriors_method1(samples, fieldns);
    case {2 'nwx2'}
        stats = combine_subposteriors_method2(samples, fieldns, varargin{:});
    case {3 'nwx3'}
        stats = combine_subposteriors_method3(samples, fieldns, varargin{:});
end

end


%% --------------------------------------------------------------------- %%
function stats = combine_subposteriors_method1(samples, fieldn)
% Implements Method 1, based on asymptotic multivariate normality of the
% full posterior per the Bernstein - von Mises theorem. Only a preferred
% method if each batch is large and the model is generally well-behaved,
% with a continuous prior space, concave likelihood, etc.

[~, K, M] = size(samples);
Si_m = zeros(K, K, M);  % covariance matrices
Pr_m = zeros(K, K, M);  % precision matrices
Mu_m = zeros(K, M);     % mean vectors
We_m = zeros(K, M);     % weighted mean (normalized difference) vectors

for m = 1:M  % compute normal parameters for each batch
    Si_m(:,:,m) = cov(samples(:,:,m));
    Pr_m(:,:,m) = inv(Si_m(:,:,m));
    Mu_m(:,m) = mean(samples(:,:,m));
    We_m(:,m) = Si_m(:,:,m) \ Mu_m(:,m);
end

Pr_M = sum(Pr_m, 3);         % sum in precision space
Mu_M = Pr_M \ sum(We_m, 2);  % rescale means

Si_M = inv(Pr_M);            % recover covariance matrix
stds = sqrt(diag(Si_M));     % assume independence, reduce to standard deviations

for k = 1:K  % make typical structure with fields for all parameters
    stats.mean.(fieldn{k}) = Mu_M(k);
    stats.std.(fieldn{k})  = stds(k);
    stats.plt0.(fieldn{k}) = normcdf(0, Mu_M(k), stds(k));
end
stats.covmtx = Si_M;  % for completeness, add full-posterior covariance matrix

end


%% --------------------------------------------------------------------- %%
function stats = combine_subposteriors_method2(samples, fieldn, h2)

error('trinity:trinity_combine_subposteriors:notYetImplemented:combine_subposteriors_method2', ...
    'Function combine_subposteriors_method2 is not yet implemented.')

[T, K, M] = size(samples);

S = eye(K) * h2;

p{m} = @(t) 1 * sum(mvnpdf(samples(:,:,m), t, S)) ./ T;


end


%% --------------------------------------------------------------------- %%
function stats = combine_subposteriors_method3(samples, fieldn)
stats = chains;

error('trinity:trinity_combine_subposteriors:notYetImplemented:combine_subposteriors_method3', ...
    'Function combine_subposteriors_method3 is not yet implemented.')
end


%% --------------------------------------------------------------------- %%
function samples = collapse_chains(chains)

chains = arrayfun(@(y)structfun(@(x)x(:), y, 'uni', 0), chains(:));
chaincell = struct2cell(chains);

samples = [];
for m = 1:size(chaincell, 3)  % there has to be a better way... TODO
    samples(:,:,m) = horzcat(chaincell{:,m});
end

end