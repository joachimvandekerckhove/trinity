% TRINITY_TEST  Test some of the Trinity functionality
clear all
rng(0)

% Make sure that all Trinity files are in the path
trinity_install();

% Make some fake data
N = 100;
x = randn(N, 1);  x = (x-mean(x))./std(x) + 2;
data = struct('N', N, 'x', x);

% Make the model variable, depending on the engine
engine = 'stan';
switch engine
    case 'jags'
        model = {
            'model { '
            '  a ~ dnorm(0, 1)'
            '  b ~ dnorm(0, 1)'
            '  c <- a + b'
            '  for (n in 1:N) {'
            '     x[n] ~ dnorm(c, 1)'
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
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'        ,  model, ...
    'data'         ,   data, ...
    'nsamples'     ,   1e5 , ...
    'nburnin'      ,   1e4 , ...
    'verbosity'    ,     3 , ...
    'workingdir'   , 'wdir', ...
    'monitorparams', {'a', 'b', 'c'}, ...
    'init', @()struct('a', normrnd(0, 1), 'b', normrnd(0, 1)));

fprintf('%s took %f seconds!\n', upper(engine), toc)

% Print the results
codatable(chains)

