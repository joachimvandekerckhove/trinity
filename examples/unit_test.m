%% Fit a diffusion model using Trinity and JAGS

%% Preamble
% Cleanup first
clear all

%% Load data and make structure
P = 200;
data = struct('x', betarnd(0.1,0.1,P,1), 'P', P);


%% Now, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    '    for (p in 1:P) {'
    '        x[p] ~ dnorm(es[p], 1)'
    '        es[p] <- dnorm(mu, tau)'
    '    }'
    '    tau <- pow(sigma, -2)'
    '    sigma ~ dnorm(0.1, 0.1)'
    '    mu ~ dnorm(0, 0.1)'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'e', 'mu', 'tau', 'es'};

% Write a function that generates a structure with one random value for
% each _random_ parameter in a field
generator = @()struct(...
        'mu', 0, ...
        'sigma', 1, ...
        'es', randn(2, P));

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'         ,         model , ...
    'data'          ,          data , ...
    'nchains'       ,            2  , ...
    'nsamples'      ,          1e2  , ...
    'nburnin'       ,          4e2  , ...
    'parallel'      , isunix|~ismac , ...
    'verbosity'     ,            5  , ...
    'modules'       ,    {'wiener'} ,...
    'workingdir'    ,        'wdir' , ...
    'monitorparams' ,    parameters , ...
    'init'          ,     generator );

fprintf('%s took %f seconds!\n', upper(engine), toc)



%% Inspect the results
% First, inspect the mean of each parameter in each chain
disp('Posterior means by chain:')
disp(stats.mean)

% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains)
