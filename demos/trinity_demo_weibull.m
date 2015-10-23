%% Fit a Weibull model using Trinity and JAGS

%%
% It is important to note that the Weibull distribution follows a different
% parameter convention in MATLAB and JAGS, and we will have to transform
% parameters in order to compare.
%% JAGS convention (scale $\lambda$ and shape $k$):
% $v \lambda x^{v-1} \exp\left(-\lambda x^v \right)$
%% MATLAB convention (scale $a$ and shape $b$):
% $\frac{b}{a} \left( \frac{x}{a} \right)^{b-1} \exp\left(-(x/a)^b\right)$

%% Preamble
% Cleanup first
clear all
close all

proj_id = 'wbl';

%% Generate data and make structure
rng(0)
I = 400;  % trials per person per condition

scale = 2.0;
shape = 2.5;
l = scale^-shape
v = shape

y = wblrnd(scale, shape, I, 1);  % MATLAB uses (scale a, shape b)
                                 % JAGS uses (scale l, shape v)
                                 %   v = b, l = a^-b
                                 %   b = v, a = l^v
data = struct('N', I, 'y', y(:));
hist(y)

%% Define some priors
% Use JAGS parameter conventions
prscale = [.10 .10];  % gamma distribution (shape, rate)
prshape = [.10 .10];  % gamma distribution (shape, rate)


%% Plot the priors
% Make sure to transform to MATLAB parameter conventions
%%
% Scale $\alpha$
figure('windowstyle', 'docked')
xax = linspace( 0.0, 10.0, 200);
plot(xax, gampdf(xax, prscale(1), prscale(2)^-1), 'linewidth', 2)
xlabel alpha
%%
% Shape $\beta$
xax = linspace( 0.0, 10.0, 200);
plot(xax, gampdf(xax, prshape(1), prshape(2)^-1), 'linewidth', 2)
xlabel beta


%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model {'
    '  # Priors'
    '  v ~ dgamma(.01, .01)'
    '  l ~ dgamma(.01, .01)'
    ''
    '  # Likelihood'
    '  for (n in 1:N) {'
    '     y[n] ~ dweib(v, l)'
    '  }'
    '}'
    };

%% 
% List all the parameters of interest (cell variable)
parameters = {'v', 'l'};

%% 
% Write a function that generates a structure with one random value for
% each _random_ parameter
generator = @()struct(...
        'v', rand(1, 1) + 0.1  , ...
        'l', rand(1, 1) + 0.1  );

%%    
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
    'nchains'        ,        4  , ...
    'nburnin'        ,      1e3  , ...
    'nsamples'       ,      1e3  , ...
    'monitorparams'  ,   parameters  , ...
    'thin'           ,        5  , ...
    'refresh'        ,     1  , ...
    'workingdir'     ,    ['/tmp/' proj_id]  , ...
    'verbosity'      ,        0  , ...
    'saveoutput'     ,     true  , ...
    'parallel'       ,  isunix() );

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
% disp('Descriptive statistics for all chains:')

%%
% Boundary separation $\alpha$
% codatable(chains, '^mushape')

%%
% A-priori bias $\beta$
% codatable(chains, '^muscale')


%% Make some figures
% Smoothed histograms
% figure('windowstyle', 'docked')
codatable(chains, '.')