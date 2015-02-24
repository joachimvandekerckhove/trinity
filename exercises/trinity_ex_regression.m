%% Fit a linear regression model using Trinity and JAGS
% This Trinity script is given as an exercise. The assignment is to
% generate data from a linear regression model, to estimate the parameters
% of the model, and to perform inference on the slope.
% The parameters of the model should be the scalar regression coefficient 
% beta and the scalar residual error sigma.

%% Preamble
% Cleanup first
clear all
close all

% We'll need to normalize vectors occasionally
normalize = @(x) (x - mean(x)) ./ std(x);


%% First, generate some data
intercept = 1.0;
beta      = 4.0;
sigma     = 3.0;
N         = 120;

% rng(0)
x = round(rand(1, N) * 15 + 100);
y = intercept + beta * normalize(x) + randn(size(x)) * sigma;


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
generator = ...
    @()struct('beta', randn(), 'tau', rand());

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model). Regression predictors
% should be normalized for efficiency
data = struct('N', N, 'x', normalize(x), 'y', normalize(y));

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
disp(stats.mean)  % Note that the intercept beta_1 should be zero!

% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains)


%% Make some figures
% Histograms with integer values or smoothed, as appropriate
figure('windowstyle', 'docked')
subplot(1,2,1), smhist(chains, 'beta');
subplot(1,2,2), smhist(chains, 'sigma');


%% Compare prior predictives and posterior predictives
my = mean(y);
sy = std(y);
nx = normalize(x);
zx = size(x);

% Prediction function is a little tricky, with rescaling
pred_fcn = @(b,s) my + (b.*nx + randn(zx).*s) .* sy;

n_pred = 1000;

% Generate prior values and compute
prior.beta  = randn(n_pred, 1) * sqrt(10);   % sample from beta
prior.sigma = gamrnd(1, 4, n_pred, 1).^-0.5; % sample from tau to get sigma

% There is a vectorized solution for this case, but ARRAYFUN is more
% general. It returns a cell array with predictions, which we can reshape
% into a regular array.
prior.predy = arrayfun(pred_fcn, prior.beta, prior.sigma, ...
    'UniformOutput', 0);
prior.predy = vertcat(prior.predy{:});

% Finally, for plotting, jitter the x values
jitter_x = ones(n_pred, 1) * x + randn(n_pred, N) / 12;

figure('windowstyle', 'docked')
plot(jitter_x, prior.predy, '.', 'color', .95 * [1 1 1])

% Generate posterior values and compute, same as for the prior, but use the
% CODASUBSAMPLE function to get samples. Ideally, use only one call to
% CODASUBSAMPLE so that posterior samples will be matched between
% parameters.
posterior = codasubsample(chains, '^beta$|^sigma$', n_pred);

posterior.predy = arrayfun(pred_fcn, posterior.beta, posterior.sigma, ...
    'UniformOutput', 0);
posterior.predy = vertcat(posterior.predy{:});

hold on
plot(jitter_x, posterior.predy, '.', 'color', .70 * [1 1 1])

% Also plot the maximum a posteriori line
xf = [-3, 3];  % how many standard deviations to plot the line
yu = my + (codatable(chains, '^beta$', @mean).*xf) .* sy;  % unnormalized y
xu = xf * std(x) + mean(x);  % unnormalized x

plot(xu, yu, '-', 'color', [0 0 0], 'linewidth', 4)  % plot regression line

% Finally, overlay the data
plot(jitter_x(1,:), y, 'o', 'color', [1 1 1], 'markersize', 4)

axis([min(x) - std(x)/5, max(x) + std(x)/5, my - 5 * sy, my + 5 * sy])
hold off