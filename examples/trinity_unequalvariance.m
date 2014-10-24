%% Fit a less trivial model using Trinity and JAGS
% This Trinity script is given as an exercise. The assignment is to
% generate data from two normal distributions with similar means but
% unequal standard deviations, and to estimate the difference between the
% means as well as between the standard deviations. Most of the code is
% given, only the JAGS code (in the _model_ variable) needs to be
% completed.

%% Preamble
% Cleanup first
clear all
close all


%% First, generate some data
m1 = 1;   m2 = 1;
s1 = 1;   s2 = 3;
n1 = 30;  n2 = 30;

rng(0)
x1 = randn(n1, 1) * s1 + m1;
x2 = randn(n2, 1) * s2 + m2;


%% Now, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    '    for (c in 1:2) {'
    '        mu[c] ~ dnorm(0, 0.1)      # prior for mu'
    '        tau[c] ~ dgamma(0.01, 0.01) # prior for si'
    '        si[c] <- pow(tau[c], -0.5)  # tau = si^(-2)'
    '    }'
    '    for (n in 1:n1) {'
    '        x1[n] ~ dnorm(mu[1], tau[1]) # likelihood for x1'
    '    }'
    '    for (n in 1:n2) {'
    '        x2[n] ~ dnorm(mu[2], tau[2]) # likelihood for x2'
    '    }'
    '    d <- mu[2] - mu[1] # difference scores d'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'mu', 'si', 'd'};

% Write a function that generates a structure with one random value for
% each _random_ parameter in a field
generator = @()struct(...
    'mu' , randn(1,2) , ...
    'tau', rand(1,2)  );

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model)
data = struct('n1', n1, 'n2', n2, 'x1', x1, 'x2', x2);

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
% Trace plots
% traceplot(chains, '.')  % will plot each in its own figure

% Smoothed histograms
figure('windowstyle', 'docked')
subplot(1,3,1), smhist(chains, 'mu');  % will plot both in one figure
subplot(1,3,2), smhist(chains, 'si');  % will plot both in one figure
subplot(1,3,3), smhist(chains, 'd');
