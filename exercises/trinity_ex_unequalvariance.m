%% Fit an unequal-variance 2-group Gaussian model using Trinity and JAGS
% This Trinity script is given as an exercise. The assignment is to
% generate data from two normal distributions with similar means but
% unequal standard deviations, and to estimate the difference between the
% means as well as the ratio of the standard deviations. Most of the
% code is given, only the JAGS code (in the _model_ variable) needs to be
% completed, together with the list of parameters to be traced (the
% _parameters_ variable) and the generator function (the _generator_
% variable).
% The parameters of the model should be the two-element vector mu[] (for
% the two means), the two-element vector si[] (for the two standard
% deviations), the scalar d (for the difference in means), and the scalar
% r (for the log-ratio of standard deviations).

%% Preamble
% Cleanup first
clear all
close all


%% First, generate some data
m1 = 1.0;   m2 = 1.5;
s1 = 1.0;   s2 = 3.0;
n1 =  30;   n2 =  30;

rng(0)
x1 = randn(n1, 1) * s1 + m1;
x2 = randn(n2, 1) * s2 + m2;


%% Now, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    % to be completed
    };

% List all the parameters of interest (cell variable)
parameters = {
    % to be completed
    };

% Write a function that generates a structure with one random value for
% each _random_ parameter in a field
generator = @()struct(...    % to be completed
    );

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
traceplot(chains, 'd|r')  % will plot each in its own figure

% Smoothed histograms
figure('windowstyle', 'docked')
subplot(2,2,1), smhist(chains, 'mu');  % will plot both in one figure
subplot(2,2,3), smhist(chains, 'si');  % will plot both in one figure
subplot(2,2,2), smhist(chains, 'd');
subplot(2,2,4), smhist(chains, 'r');
