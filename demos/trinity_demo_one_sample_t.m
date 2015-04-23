%% Do a one-sample t test using Trinity and JAGS
% Cleanup first
clear all
close all


%% First, enter the data
x = [0.57 0.87 0.80 1.57 -0.09 0.08 -0.22];
ndata = numel(x);


%% Now, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model {'
    '  for (i in 1:ndata){'
    '    x[i] ~ dnorm(mu,lambda)'
    '  }'
    '  mu <- delta*sigma'
    '  lambda <- pow(sigma,-2)'
    '  # delta and sigma Come From (Half) Cauchy Distributions'
    '  lambdadelta ~ dchisqr(1)'
    '  delta ~ dnorm(0,lambdadelta)'
    ''
    '  lambdasigma ~ dchisqr(1)'
%     '  sigmatmp ~ dt(0,1,1000)'
    '  sigma <- abs(sigmatmp)'
    ''
    '  # Sampling from Prior Distribution for Delta'
    '  deltaprior ~ dnorm(0,lambdadeltaprior)'
    '  lambdadeltaprior ~ dchisqr(1)'
    '}'
    };
model = {
    'model {'
    '  for (i in 1:ndata){'
    '    x[i] ~ dnorm(delta * abs(sigma), pow(sigma,-2))'
    '  }'
    ''
    '  delta ~ dt(0,1,1)'
    '  sigma ~ dt(0,1,1)'
    '  deltaprior ~ dt(0,1,1)'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'delta', 'deltaprior', 'sigma'};

% Write a function that generates a structure with one random value for
% each parameter in a field
generator = @()struct(...
    'delta' , randn );

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model)
data = struct('x', x, 'ndata', ndata);

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'         , model         , ...
    'data'          , data          , ...
    'parallel'      , isunix&~ismac , ...
    'workingdir'    , 'wdir'        , ...
    'monitorparams' , parameters    , ...
    'init'          , generator     );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% First, inspect the mean of each parameter in each chain
disp('Posterior means by chain:')
disp(stats.mean)

% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains)


%% Make some figures
figure('windowstyle', 'docked')
% Trace plots
traceplot(chains, 'delta')
traceplot(chains, 'sigma')

% Smoothed histograms
smhist(chains, 'delta')
smhist(chains, 'sigma')

% Autocorrelation plots
aucoplot(chains, 'delta'  )
aucoplot(chains, 'sigma' )
