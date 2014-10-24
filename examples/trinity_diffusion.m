%% Fit a diffusion model using Trinity and JAGS

%% Preamble
% Cleanup first
clear all

%% Load data and make structure
load wiener
data = struct('N', numel(y), 'y', y);


%% Now, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    'for (i in 1:4) { '
    '  a[i] ~ dgamma(2, 1)'
    '  b[i] ~ dbeta(5, 5)'
    '  t[i] ~ dgamma(3, 8)'
    '  d[i] ~ dnorm(0, 2)'
    '  for (n in 1:100) {'
    '     y[n+(i-1)*100] ~ dwiener(a[i],t[i],b[i],d[i])'
    '  }'
    '}'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'a', 'b', 't', 'd'};

% Write a function that generates a structure with one random value for
% each _random_ parameter in a field
generator = @()struct(...
        'a', rand(1,4)+0.1, ...
        'b', rand(1,4), ...
        't', rand(1,4)*.9*min(abs(y)), ...
        'd', randn(1,4));

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'         ,         model , ...
    'data'          ,          data , ...
    'nchains'       ,            4  , ...
    'nsamples'      ,          1e3  , ...
    'nburnin'       ,          4e3  , ...
    'parallel'      , isunix|~ismac , ...
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


%% Make some figures
% Smoothed histograms
figure('windowstyle', 'docked')
subplot(2,2,1), smhist(chains, 'a');
subplot(2,2,2), smhist(chains, 't');
subplot(2,2,3), smhist(chains, 'b');
subplot(2,2,4), smhist(chains, 'd');
