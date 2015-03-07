function [stats, chains, diagnostics, info] = callbayes(engine, varargin)
% CALLBAYES  Use this function to run a Bayesian model
%   CALLBAYES will execute a call to <engine>. Supply a set of options 
%   through label-value pairs or as a structure. The available options
%   depend on the engine, with some being general.
% 
%     GENERAL OPTIONS WITH DEFAULTS
%     -----------------------------
% 
%        'model'          ,   'model' 
%        'data'           ,    'data' 
%        'outputname'     , 'samples' 
%        'init'           ,       []  
%        'modelfilename'  ,       []  
%        'datafilename'   ,       []  
%        'initfilename'   ,       []  
%        'scriptfilename' ,       []  
%        'logfilename'    ,       []  
%        'engine'         ,    'jags' 
%        'nchains'        ,        4  
%        'nburnin'        ,     1000  
%        'nsamples'       ,     5000  
%        'monitorparams'  ,       []  
%        'thin'           ,        1  
%        'refresh'        ,     1000  
%        'workingdir'     ,    'wdir'  
%        'cleanup'        ,    false  
%        'verbosity'      ,        0  
%        'saveoutput'     ,     true  
%        'readonly'       ,    false  
%        'parallel'       ,  isunix()
% 
% 
%    JAGS OPTIONS WITH DEFAULTS
%    --------------------------
%
%        'showwarnings'   ,           true  
%        'modules'        ,            {''}     
%        'seed'           ,  ceil(rand*1e4) 
%        'maxcores'       ,              0
%  
%
%    WINBUGS OPTIONS WITH DEFAULTS
%    -----------------------------
%
%        'showwarnings'   ,     true
% 
% 
%    STAN OPTIONS WITH DEFAULTS
%    --------------------------
%                                       Stan internal defaults:
%        'remake'           ,  0        -----------------------
%        'seed'             , []                     from clock
%        'leapfrog_steps'   , []     -1: "No-U-Turn Adaptation"
%        'max_treedepth'    , []                            10
%        'epsilon'          , []        -1: "Set automatically"
%        'epsilon_pm'       , []                          0.00
%        'delta'            , []                          0.50
%        'gamma'            , []                          0.05
%        'append_samples'   ,  0 
%        'equal_step_sizes' ,  0 
%        'nondiag_mass'     ,  0 
%        'save_warmup'      ,  0 
%        'test_grad'        ,  0 
%        'maxcores'         ,  0
% 
%   
%    Example usage:
%       [stats, chains, diagnostics, info] = callbayes('jags', 'model', 'myModel.jags')
%
%       [stats, chains] = callbayes('jags', ...
%                                   'model'         ,         model , ...
%                                   'data'          ,          data , ...
%                                   'nchains'       ,            4  , ...
%                                   'nsamples'      ,          1e3  , ...
%                                   'nburnin'       ,          5e2  , ...
%                                   'monitorparams' ,        params , ...
%                                   'init'          ,         inits );
% 
%    See also: CALLBUGS, CALLJAGS, CALLSTAN
%

% (c) 2013- Joachim Vandekerckhove. See license.txt for licensing information.

if ~nargin
    help(mfilename);
    return
end

options = trinity_input_parser(engine, varargin{:});

switch lower(engine)
    case 'bugs'
        [stats, chains, diagnostics, info] = callbugs(options);
    case 'jags'
        [stats, chains, diagnostics, info] = calljags(options);
    case 'stan'
        [stats, chains, diagnostics, info] = callstan(options);
end
