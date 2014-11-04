%% Fit a Gaussian distribution using Trinity and JAGS
% Cleanup first
clear all
close all


%% First, enter the data
d = [0.57 0.87 0.80 1.57 -0.09 0.08 -0.22];
J = numel(d);


%% Now, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    '    mu ~ dnorm(0,0.1)'
    '    tau ~ dgamma(4,0.01)'
    '    for (j in 1:J) {'
    '        d[j] ~ dnorm(mu, tau)'
    '    }'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {'mu', 'tau'};

% Write a function that generates a structure with one random value for
% each parameter in a field
generator = @()struct(...
    'mu'  , randn , ...
    'tau' , rand  );

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model)
data = struct('d', d, 'J', J);

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
subplot(2,3,1), traceplot(chains, 'mu')
subplot(2,3,4), traceplot(chains, 'tau')

% Smoothed histograms
subplot(2,3,2), smhist(chains, 'mu'  , 'color', 'b')
subplot(2,3,5), smhist(chains, 'tau' , 'color', 'r')

% Autocorrelation plots
subplot(2,3,3), aucoplot(chains, 'mu'  )
subplot(2,3,6), aucoplot(chains, 'tau' )
