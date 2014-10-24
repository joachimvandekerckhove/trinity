%% Fit a less trivial model using Trinity and JAGS
% This Trinity script is given as an exercise. The assignment is to
% load data from a file and estimate the parameters of the two-parameter
% Rasch model.

%% Preamble
% Cleanup first
clearvars -except chains
close all


%% First, load data
load('trinity_rasch1')


%% First, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    '    for (p in 1:P) {'
    '        for (i in 1:I) {'
    '            pi[p,i] <- ilogit(theta[p] - beta[i])'
    '            x[p,i] ~ dbern(pi[p,i])'
    '        }'
    '    }'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'x'};

% Write a function that generates a structure with one random value for
% each random parameter in a field
generator = @()struct('x', rand(P,I)>1  );

% Make a structure with the data (we have the chains from a previous run)
beta = codatable(chains, '^beta', @mean);
theta = codatable(chains, '^theta', @mean);
data = struct('theta', theta, ...
    'beta', beta, 'P', P, 'I', I);

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, ppc, diagnostics, info] = callbayes(engine, ...
    'model'         , model         , ...
    'data'          , data          , ...
    'parallel'      , isunix&~ismac , ...
    'workingdir'    , 'wdir'        , ...
    'monitorparams' , parameters    , ...
    'nburnin'       ,    1          , ...
    'nsamples'      ,  100          , ...
    'init'          , generator     );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% Now check some basic descriptive statistics averaged over all chains
x_pred = getMatrixFromCoda(ppc, 'x');


%% Make some figures
scatter(mean(x, 2), mean(x_pred, 2), 'r')
line([0 1], [0 1], 'linestyle', '--', 'color', 'k')
grid on
xlabel 'observed score'
ylabel 'predicted score'
title 'model recovery'