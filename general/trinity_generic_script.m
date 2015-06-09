%% Fit a model using Trinity
% Cleanup first
clear all
close all

proj_id = 'id';  %$ PROJECT ID GOES HERE $%

%% First, enter the data

%$ DATA PROCESSING GOES HERE $%


%% Now, make all inputs that Trinity needs
% Write the model into a variable (cell variable)
model = {
    %$ MODEL GOES HERE $%
    };

% List all the parameters of interest (cell variable)
parameters = {
    %$ PARAMETERS GO HERE $%
    };

% Write a function that generates a structure with one random value for
% each parameter in a field
generator = @()struct(...  %$ PARAMETERS AND SAMPLERS GO HERE $%
    );

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model)
data = struct(...  %$ DATA GO HERE $%
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
    'monitorparams'  ,   parameters  , ...
    'thin'           ,        1  , ...
    'refresh'        ,     1000  , ...
    'workingdir'     ,    ['/tmp/' proj_id]  , ...
    'cleanup'        ,    false  , ...
    'verbosity'      ,        0  , ...
    'saveoutput'     ,     true  , ...
    'parallel'       ,  isunix() , ...
    'modules'        ,  {'wiener', 'dic'}  );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% First, inspect the convergence of each parameter
disp('Convergence statistics:')
grtable(chains, 1.05)

% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains)


%% Make some figures
% ...
