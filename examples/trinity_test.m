clear all

trinity_install();
rng(0)

N = 100;
x = randn(N, 1);  x = (x-mean(x))./std(x) + 2;
data = struct('N', N, 'x', x);
engine = 'jags';
% engine = 'stan';

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

tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'         ,           model , ...
    'data'          ,            data , ...
    'cleanup'       ,            true , ...
    'nsamples'      ,            1e4  , ...
    'nburnin'       ,            1e3  , ...    
    'parallel'      ,   isunix|~ismac , ...
    'verbosity'     ,              0  , ...
    'workingdir'    ,          'wdir' , ...
    'monitorparams' , {'a', 'b', 'c'} , ...
    'init'          , @()struct('a', normrnd(0, 1) , ...
                                'b', normrnd(0, 1) ));

fprintf('%s took %f seconds!\n', upper(engine), toc)

% dg = diagnostics.Rhat
mn = stats.mean

