%% Fit a model using Trinity
% Cleanup first
clear all
close all

proj_id = 'linreg';

%% First, enter the data

% create vector containing the the predicted number of attendees
x = [51, 44, 57, 41, 53, 56, 49, 58, 50, 32,...
     24, 21, 23, 28, 22, 30, 29, 35, 18, 25,...
     32, 42, 27, 38, 32, 21, 21, 12, 29, 14];

% create vector containing the the observed number of attendees
y = [33, 55, 49, 56, 58, 61, 46, 82, 53, 33,...
     35, 18, 14, 31, 13, 23, 15, 20, 20, 33,...
     32, 31, 37, 17, 11, 24, 17,  5, 16,  7];

% create a scalar that corresponds to the number of sessions
N = numel(x);

% create a list that contains the data and will be passed on to WinBUGS
datastruct = struct('y', y, 'x', x, 'N', N);



%% Now, make all inputs that Trinity needs
% Write the model into a variable (cell variable)
model = {
   'model {'
   '   # linear regression'
   '   for (i in 1:N) {'
   '      y[i] ~ dnorm(mu[i], tau)'
   '      mu[i] <- beta[1] + beta[2] * x[i]'
   '   }'
   '   # prior definitions'
   '   beta[1] ~ dnorm(0, .001)'
   '   beta[2] ~ dnorm(0, .001)'
   '   tau ~ dgamma(.001, .001)'
   '}'
    };

% List all the parameters of interest (cell variable)
params = {
    'beta' 'tau'
    };

% Write a function that generates a structure with one random value for
% each parameter in a field
generator = @()struct(...
    'beta' , randn(2, 1) * 10,...
    'tau'  , rand * 5);

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model)
data = struct(...
    'x', x, ...
    'y', y, ...
    'N', numel(x) ...
    );

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'          ,     model , ...
    'data'           ,      data , ...
    'outputname'     , 'samples' , ...
    'init'           , generator , ...
    'modelfilename'  ,   proj_id , ...
    'datafilename'   ,   proj_id , ...
    'initfilename'   ,   proj_id , ...
    'scriptfilename' ,   proj_id , ...
    'logfilename'    ,   proj_id , ...
    'nchains'        ,        3  , ...
    'nburnin'        ,      500  , ...
    'nsamples'       ,      500  , ...
    'monitorparams'  ,    params , ...
    'thin'           ,        2  , ...
    'workingdir'     ,    ['/tmp/' proj_id]  , ...
    'verbosity'      ,        0  , ...
    'saveoutput'     ,     true  , ...
    'parallel'       ,  isunix() );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% First, inspect the convergence of each parameter
disp('Convergence statistics:')
grtable(chains, 1.05)

% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains)


%% Make some figures
% Basic scatter plot
scatter(x, y)
line(xlim, stats.mean.beta_1 + stats.mean.beta_2 * xlim)

% Prettier scatter plot
scatter(x, y, 'o', 'markeredgecolor', 'k', 'markerfacecol', [1 4/5 2/5])
box on, grid on
axis([0 100 0 100])
axis square 
xax = [0 100];
yax = stats.mean.beta_1 + stats.mean.beta_2 * xax;
line(xax, yax, 'color', [1/5 1/10 0], 'linewidth', 2)
% line(xax, xax, 'color', 'k', 'linestyle', ':', 'zdata', [-10 -10])
xlabel 'predicted (x)'
ylabel 'observed (y)'
set(gca, 'XTick', 0:20:100,'YTick', 0:20:100)

set(gcf, 'pos', [417   411   280   251])
% savepic linreg