%% Meta-analysis using Trinity and JAGS
% Data come from the
% <http://www.columbia.edu/~cjd11/charles_dimaggio/DIRE/styled-4/styled-11/code-9/
% Bristol Pediatric Cardiac Mortality Study>.


%% Preamble
% Cleanup first
clear all
p = @sprintf;


%% Prepare data
bristolDat = struct('N', 12, ...
    'r', [ 25,  24,  23,  25,  42,  24,  53,  26,  25,  58,  31,  41], ...
    'n', [187, 323, 122, 164, 405, 239, 482, 195, 177, 581, 301, 143]);


%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
bristolModel = {
    'model{'
    '  for(i in 1:N) {'
    '    r[i] ~ dbin(p[i] ,n[i])  # Likelihood'
    '    logit(p[i]) <- b[i]      # Log-odds of mortality'
    '    b[i] ~ dnorm(mu, prec)   # Random effects model for log-odds mortality'
    '  }'
    ''
    '  mu ~ dnorm(0.0, 1.0E-6)    # Priors'
    '  sd <- 1 / sqrt(prec)'
    '  prec ~ dgamma(1.0E-3, 1.0E-3)'
    '}'
    };

%% 
% List all the parameters of interest (cell variable)
bristolParams = {'p', 'mu', 'sd'};

%% 
% Write a function that generates a structure with one random value for
% each _random_ parameter
bristolInits = @()struct('b', randn(1, bristolDat.N), ...
    'prec', 2 * rand, 'mu', randn);


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes('jags', ...
    'model'         ,  bristolModel , ...
    'data'          ,    bristolDat , ...
    'nchains'       ,            4  , ...
    'nsamples'      ,          1e3  , ...
    'nburnin'       ,          5e2  , ...
    'monitorparams' , bristolParams , ...
    'init'          ,  bristolInits );
toc


%% Inspect the results
% First, inspect convergence
grtable(chains, 1.01)

%%
% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains, 'mu|sd')
h = caterpillar(chains, 'p');
set(h, 'xgrid', 'on')