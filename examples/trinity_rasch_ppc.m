%% Generate posterior predictives using Trinity and JAGS
% This Trinity script is intended to be run after TRINITY_RASCH has
% completed. Posterior predictive values are generated.

%% Preamble
% Cleanup first
clearvars -except chains  % keep the chains variable from TRINITY_RASCH
close all
p = @sprintf;  % A shortcut to @sprintf for tidier model construction


%% First, load data
load('trinity_rasch1')

%% Determine number of posterior predictives to generate (per chain!)
n_pp = 25;

%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    '    for (p in 1:P) {'
    '        for (i in 1:I) {'
    '            pi[p,i] <- ilogit(theta[p] - beta[i])'
  p('            for (n in 1:%i) {', n_pp)
    '                x[p,i,n] ~ dbern(pi[p,i])'
    '            }'
    '        }'
    '    }'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'x'};

% Write a function that generates a structure with one random value for
% each random parameter in a field
generator = @()struct('x', rand(P, I, n_pp)>1  );

% Make a structure with the parameter estimates (we have chains from a
% previous run)
beta = codatable(chains, '^beta', @mean);
theta = codatable(chains, '^theta', @mean);
data = struct('theta', theta, ...
    'beta', beta, 'P', P, 'I', I);

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, ppc, diagnostics, info] = callbayes(engine, ...
    'model'         ,      model , ...
    'data'          ,       data , ...
    'parallel'      ,   isunix() , ...
    'workingdir'    ,     'wdir' , ...
    'monitorparams' , parameters , ...
    'nburnin'       ,         1  , ...
    'nsamples'      ,         1  , ...
    'init'          , generator  );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% Now check some basic descriptive statistics averaged over all chains
x_pred = getMatrixFromCoda(ppc, 'x');
x_pred_mn = mean(x_pred, 3);


%% Make some figures
scatter(mean(x, 2), mean(x_pred_mn, 2), 'r')
line([0 1], [0 1], 'linestyle', '--', 'color', 'k')
grid on
xlabel 'observed score'
ylabel 'predicted score'
title 'model recovery'