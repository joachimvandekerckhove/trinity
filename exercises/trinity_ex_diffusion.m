%% Fit a diffusion model using Trinity and JAGS
% This Trinity script is given as an exercise. The assignment is to
% use the provided data set (in trinity_wiener.mat) and perform an
% exploratory analysis with an appropriately designed diffusion model.
% The data file contains the following variables:
% 
% * y: A vector of choice response times, in seconds, with lower-boudary
% hits indicated by negative numbers.
% * c: A vector of integer condition indicators, ranging from 1 to 4.
% 
% Estimate the parameters of a diffusion model in which all parameters are
% allowed to differ between conditions.
% Note: this requires the 
% <http://sourceforge.net/projects/jags-wiener/ jags-wiener plugin>.


%% Preamble
% Cleanup first
clear all
p = @sprintf;


%% Load data and make structure
load trinity_wiener
data = struct('N', numel(y), 'c', c, 'y', y);


%% Define some priors
% Use JAGS parameter conventions
alpha = [2 2];  % gamma distribution (shape, rate)
beta  = [5 5];  % beta distribution (successes, failures)
tau   = [3 8];  % gamma distribution (shape, rate)
delta = [0 2];  % Gaussian distribution (mean, precision)


%% Plot the priors
% Make sure to transform to MATLAB parameter conventions
%%
% Boundary separation $\alpha$
figure('windowstyle', 'docked')
xax = linspace( 0.0, 6.0, 200);
plot(xax, gampdf (xax, alpha(1), alpha(2)^-1), 'linewidth', 2)
xlabel alpha
%%
% A-priori bias $\beta$
xax = linspace( 0.0, 1.0, 200);
plot(xax, betapdf(xax, beta(1), beta(2)), 'linewidth', 2)
xlabel beta
%%
% Nondecision time $\tau$
xax = linspace( 0.0, 1.0, 200);
plot(xax, gampdf (xax, tau(1), tau(2)^-1), 'linewidth', 2)
xlabel tau
%%
% Drift rate $\delta$
xax = linspace(-3.0, 3.0, 200);
plot(xax, normpdf(xax, delta(1), delta(2)^-0.5), 'linewidth', 2)
xlabel delta


%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
    '  for (i in 1:4) { '
  p('    a[i] ~ dgamma(%g, %g)', alpha)
  p('    b[i] ~ dbeta(%g, %g)', beta)
  p('    t[i] ~ dgamma(%g, %g)', tau)
  p('    d[i] ~ dnorm(%g, %g)', delta)
    '  }'
    ''
    % to be completed
    '}'
    };

%% 
% List all the parameters of interest (cell variable)
parameters = {'a', 'b', 't', 'd'};

%% 
% Write a function that generates a structure with one random value for
% each _random_ parameter
generator = @()struct(...
        'a', 3 * rand(1, 4) + 0.1          , ...
        'b', rand(1, 4)                    , ...
        't', rand(1, 4) * .9 * min(abs(y)) , ...
        'd', randn(1, 4)                   );

%%    
% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = ...
    callbayes(... % to be completed
    );

fprintf('%s took %f seconds!\n', upper(engine), toc)



%% Inspect the results
% First, inspect convergence
if any(codatable(chains, @gelmanrubin) > 1.1)
    grtable(chains, 1.1)
    warning('Some chains were not converged!')
else
    disp('Convergence looks good.')
end

%%
% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')

%%
% Boundary separation $\alpha$
codatable(chains, 'a')

%%
% A-priori bias $\beta$
codatable(chains, 'b')

%%
% Nondecision time $\tau$
codatable(chains, 't')

%%
% Drift rate $\delta$
codatable(chains, 'd')


%% Make some figures
% Smoothed histograms
figure('windowstyle', 'docked')
smhist(chains, 'd');
