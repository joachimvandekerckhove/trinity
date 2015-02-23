%% Fit a Rasch model using Trinity and JAGS
% This Trinity script will load data from a file and estimate the
% parameters of the two-parameter Rasch model. 

%% Preamble
% Cleanup first
clear all
close all


%% First, load data
load('trinity_rasch1')
data = struct('x', x, 'I', I, 'P', P);


%% First, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    % to be completed
    };


% List all the parameters of interest (cell variable)
parameters = {'meanBeta', 'precBeta', 'precTheta', 'theta', 'beta'};

% Write a function that generates a structure with one random value for
% each random parameter in a field
generator = @()struct('beta' , randn(I, 1), ...
                      'theta', randn(P, 1));

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'         ,      model , ...
    'data'          ,       data , ...
    'parallel'      ,   isunix() , ...
    'workingdir'    ,     'wdir' , ...
    'monitorparams' , parameters , ...
    'nburnin'       ,       5e2  , ...
    'nsamples'      ,       5e2  , ...
    'init'          , generator  );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% First, inspect convergence
if any(codatable(chains, @gelmanrubin) > 1.1)
    grtable(chains, 1.1)
    warning('Some chains were not converged!')
else
    disp('Convergence looks good.')
end

% Now check some basic descriptive statistics averaged over all chains
codatable(chains, 'mean|prec');
