function varargout = test(engine)
% TEST  Test some of the Trinity functionality
rng(0)
if ~nargin
    engine = 'jags';
end

% Make sure that all Trinity files are in the path
trinity silent

% Make some fake data
N = 100;
x = randn(N, 1);  x = (x-mean(x))./std(x) + 2;
data = struct('N', N, 'x', x);

% Make the model variable, depending on the engine
switch engine
    case {'jags' 'bugs'}
        model = {
            'model { '
            '  a ~ dnorm(0, 1)'
            '  b ~ dnorm(0, 1)'
            '  c[1] ~ dnorm(0, 1)'
            '  c[2] <- a + b'
            '  for (n in 1:N) {'
            '     x[n] ~ dnorm(c[2], 1)'
            '  }'
            '}'
            };
    case 'stan'
        model = {
            'data { '
            '  int<lower=0> N;'
            '  real x[N];'
            '}'
            'parameters {'
            '  real a;'
            '  real b;'
            '}'
            'transformed parameters {'
            '  real c;'
            '  c <- a + b;'
            '}'
            'model { '
            '  a ~ normal(0, 1);'
            '  b ~ normal(0, 1);'
            '  for (n in 1:N) {'
            '     x[n] ~ normal(c, 1);'
            '  }'
            '}'
            };
end

% Call the engine
tic
[~, chains, ~, ~] = callbayes(engine, ...
    'model'        ,  model, ...
    'data'         ,   data, ...
    'refresh'      ,   1e5 , ...
    'nsamples'     ,   1e3 , ...
    'nburnin'      ,   1e3 , ...
    'verbosity'    ,     0 , ...
    'workingdir'   ,  '/tmp/test'  , ...
    'monitorparams', {'a', 'b', 'c'}, ...
    'init', @()struct('a', randn, 'b', randn));

fprintf('%s took %f seconds!\n', upper(engine), toc)

% Print the results
codatable(chains)

if nargout
    varargout{1} = chains;
end