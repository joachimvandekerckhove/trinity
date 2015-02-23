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
p = @sprintf;


%% Generate data and make structure
rng(0)
P = 10;  % persons
C =  8;  % conditions
I = 50;  % trials per person per condition

cscale = [4 3 2 1 4 3 2 1];  % scale parameters
cshape = [1 2 3 4 5 6 7 8];  % shape parameters

allscale = repmat(ones(P, 1) * cscale + randn(P, C) / 10, [1, 1, I]);
allshape = repmat(ones(P, 1) * cshape + randn(P, C) / 10, [1, 1, I]);

condition = repmat(1:C, [P, 1, I]);     % condition index
person    = repmat((1:P)', [1, C, I]);  % person index;

y = wblrnd(allscale, allshape);  % MATLAB uses (scale a, shape b)
                                 % JAGS uses (scale l, shape v)
                                 %   v = b, l = a^-b
                                 %   b = v, a = l^v
data = struct('N', P * C * I, 'C', C, 'P', P, ...
    'condition', condition(:), 'person', person(:), 'y', y(:));


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
    '  # Priors on precision'
    '  precshape ~ dgamma(0.1, 0.1)'
    '  precscale ~ dgamma(0.1, 0.1)'
    ''
    '  for (c in 1:C) { '
    '    # Priors on means'
  p('    mushape[c] ~ dgamma(%g, %g)', prshape)
  p('    muscale[c] ~ dgamma(%g, %g)', prscale)
  ''
    '    # Random effects'
    '    for (p in 1:P) { '
    '      shape[c,p] ~ dnorm(mushape[c], precshape)'
    '      scale[c,p] ~ dnorm(muscale[c], precscale)'
    '    }'
    '  }'
    ''
    '  # Likelihood'
    '  for (n in 1:N) {'
    '     y[n] ~ dweib(shape[condition[n],person[n]],'
    '                  scale[condition[n],person[n]])'
    '  }'
    '}'
    };

%% 
% List all the parameters of interest (cell variable)
parameters = { ...
    'scale', 'shape', ...
    'mushape', 'muscale', ...
    'precshape', 'precscale'};

%% 
% Write a function that generates a structure with one random value for
% each _random_ parameter
generator = @()struct(...
        'mushape', rand(1, C) + 0.1  , ...
        'muscale', rand(1, C) + 0.1  );

%%    
% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'         ,         model , ...
    'data'          ,          data , ...
    'nchains'       ,            4  , ...
    'verbosity'     ,            0  , ...
    'nsamples'      ,          15e2  , ...
    'nburnin'       ,          5e2  , ...
    'parallel'      ,      isunix() , ...
    'workingdir'    ,        'wdir' , ...
    'monitorparams' ,    parameters , ...
    'init'          ,     generator );
% load /tmp/wbl

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
% Scale $\lambda$
codatable(chains, '^muscale')

%%
% Shape $v$
codatable(chains, '^mushape')

%% Make some figures
% Plot recovery
l = codatable(chains, '^muscale', @mean);
v = codatable(chains, '^mushape', @mean);

% Transform back to MATLAB parameters
rshape = v;
rscale = l.^(-1./v);

scatter(cshape, rshape, 'bo')
hold on
scatter(cscale, rscale, 'ro')
bisector