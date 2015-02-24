%% Fit an explanatory IRT model using Trinity and JAGS
% This Trinity script is given as an exercise. The assignment is to fit an
% explanatory IRT model to the provided data.  The variable IQ must be
% normalized, then used as a predictor for the person-specific ability
% parameter \theta of the Rasch model.

%% Preamble
% Cleanup first
clear all
close all


%% First, load data
load('trinity_rasch3')
data = struct(...
    'x', x, 'I', I, 'P', P, ...
    'IQ', (IQ-mean(IQ))/std(IQ));


%% First, make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    % to be completed
    };

% List all the parameters of interest (cell variable)
parameters = {
    % to be completed
    };

% Write a function that generates a structure with one random value for
% each random parameter in a field
generator = @()struct( ... 
    ... % to be completed
    );

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
options = {
     % to be completed
     };
[stats, chains, diagnostics, info] = callbayes(engine, options);

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
% to be completed


%% Some figures
ability = getMatrixFromCoda(chains, 'theta');
scatterhist(IQ, ability)
