%% Evaluate diffusion model parameter recovery using Trinity and JAGS
% Note: this requires the 
% <http://sourceforge.net/projects/jags-wiener/ jags-wiener plugin>.


%% Preamble
% Cleanup first
clear all
p = @sprintf;


%% Define parameter sets and sample sizes
true_param = [ 1.0  0.2  0.3  0.0  0.5  1.5
               1.5  0.2  0.3  0.0  0.5  1.5
               1.0  0.2  0.5  0.0  0.5  1.5
               1.5  0.2  0.5  0.0  0.5  1.5];
           true_param(:, 5:6) = [];
N = 20;
C = size(true_param, 2) - 3;  % number of conditions


%% Define some priors
% Use JAGS parameter conventions
alpha = [2 2];  % gamma distribution (shape, rate)
beta  = [5 5];  % beta distribution (successes, failures)
tau   = [3 8];  % gamma distribution (shape, rate)
delta = [0 2];  % Gaussian distribution (mean, precision)


%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
model = {
    'model { '
  p('   a ~ dgamma(%g, %g)', alpha)
  p('   b ~ dbeta(%g, %g)', beta)
  p('   t ~ dgamma(%g, %g)', tau)
  p('   for (i in 1:%g) { ', C)
  p('      d[i] ~ dnorm(%g, %g)', delta)
    '      for (n in 1:N) {'
    '         y[n,i] ~ dwiener(a, t, b, d[i])'
    '      }'
    '   }'
    '}'
    };

%% 
% List all the parameters of interest (cell variable)
parameters = {'a', 'b', 't', 'd'};

%% 
% Write a function that generates a structure with one random value for
% each _random_ parameter
generator = @()struct(...
        'a', 3 * rand(1, 1) + 0.1 , ...
        'b', rand(1, 1)           , ...
        't', rand(1, 1) * .19     , ...
        'AS_VECTOR_d', randn(1, C)          );

%%    
% Tell Trinity which engine to use
engine = 'jags';

ops = { 'model'         ,         model , ...
        'nchains'       ,            4  , ...
        'verbosity'     ,            0  , ...
        'nsamples'      ,          4e2  , ...
        'nburnin'       ,          4e2  , ...
        'parallel'      ,      isunix() , ...
        'modules'       ,    {'wiener'} ,...
        'workingdir'    ,        'wdir' , ...
        'monitorparams' ,    parameters , ...
        'init'          ,     generator };

%% Run Trinity with the CALLBAYES() function
this_pset = zeros(1, 7);
t = zeros(N, C);
x = false(N, C);
fprintf('[%s] Starting... ', datestr(now))
for idx = 1:100
    rng(idx)
    for pset = 1:1%size(true_param, 1)
        tic
        for cond = 1:C
            this_pset([1 2 4 7]) = true_param(1, [1:3 3+cond]);
            [t(:,cond), x(:,cond)] = wdmrand(this_pset, N);
        end
        
        t(~x) = -t(~x);
        
        [stats(pset, idx), chains(pset, idx)] = callbayes(engine, ...
            ops{:}, 'data', struct('N', N, 'AS_MATRIX_y', t));
        
%         fprintf('%s took %f seconds!\n', upper(engine), toc)
    end
    fprintf('[%s]  d: %8.4f\n', datestr(now), stats(pset, idx).mean.d)
end


%% Inspect the results

