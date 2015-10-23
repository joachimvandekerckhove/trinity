%% Fit a model using Trinity
% Cleanup first
clear all
% close all
clf

proj_id = 'correlation';

%% First, enter the data

rho      =   0.707 ;

N        =   1e2 ;

sigma    =  [  1  10 ] ;
MU       =  [  4  10 ] ;

VCV(1,1) =  sigma(1) * sigma(1) ;
VCV(2,2) =  sigma(2) * sigma(2) ;
VCV(1,2) =  sigma(1) * sigma(2) * rho;
VCV(2,1) =  sigma(2) * sigma(1) * rho;

X        =  mvnrnd(MU, VCV, N);

a = X(:,1);
b = X(:,2);

%% Now, make all inputs that Trinity needs
% Write the model into a variable (cell variable)
model = {
    'model {'
    '   MU[1] ~ dnorm(0, .001)'
    '   MU[2] ~ dnorm(0, .001)'
    ''
    '   tau[1] ~ dgamma(1, 1)'
    '   tau[2] ~ dgamma(1, 1)'
    '   sigma[1] <- pow(tau[1], -0.5)'
    '   sigma[2] <- pow(tau[2], -0.5)'
    ''
    '   rho ~ dbeta(1, 1)'
    '   beta <- rho * sigma[2] / sigma[1]'
    ''
    '   for (c in 1:N) {'
    '     a[c] ~ dnorm(MU[1], tau[1])'
    '     Y[c] <- MU[2] + beta * (a[c] - MU[1])'
    '     b[c] ~ dnorm(Y[c], tau[2])'
    '   }'
    '}'
    };

% List all the parameters of interest (cell variable)
params = {
    'MU' 'rho' 'sigma'
    };

% Write a function that generates a structure with one random value for
% each parameter in a field
generator = @()struct(...  %$ PARAMETERS AND SAMPLERS GO HERE $%
    'MU' , randn(1, 2), ...
    'rho', rand ...
    );

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the model)
data = struct(...  %$ DATA GO HERE $%
    'a', a, 'b', b, 'N', N ...
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
    'thin'           ,        1  , ...
    'workingdir'     ,    ['/tmp/' proj_id]  , ...
    'verbosity'      ,        5  , ...
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

corr([a b])

%% Make some figures
scatter(a, b, 'ko', 'markerf', [6/6 5/6 1/6])

xax = xlim;
yax1 = stats.mean.MU_2 ...
    + (xlim - stats.mean.MU_1) / stats.mean.sigma_1 ...
      * stats.mean.sigma_2 * stats.mean.rho;
line(xax, yax1, 'color', [5/6 1/6 1/6], 'linewidth', 3)

yax2 = MU(2) + (xlim - MU(1)) / sigma(1) * sigma(2) * rho;
line(xax, yax2, 'color', [2/6 2/6 6/6], 'linewidth', 3, 'linestyle', '--')

grid on
box on