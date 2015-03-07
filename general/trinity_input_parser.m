function options = trinity_input_parser(engine, varargin)
% TRINITY_INPUT_PARSER  Parses label-value input pairs into an options structure

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Decide on allowed options, specific to engine
switch lower(engine)
    case 'bugs'
        defaults = defaults_bugs();
    case 'jags'
        defaults = defaults_jags();
    case 'stan'
        defaults = defaults_stan();
    otherwise
        error_tag('trinity:trinity_input_parser:unknownEngine', ...
            'Unknown engine "%s".', engine)
end
defaults = updatestruct(defaults_all(), defaults, false);

if nargin==1
    options = defaults;
elseif nargin==2 && isstruct(varargin{1})
    % User supplied a structure.
    options = varargin{1};
else % So it has to be label-value pairs
    labels = varargin(1:2:end);
    values = varargin(2:2:end);
    if numel(labels)~=numel(values)
        error_tag('trinity:trinity_input_parser:oddInput', ...
            'To list options, make label-value pairs.')
    end
    for l = 1:numel(labels)
        options.(labels{l}) = values{l};
    end
end

options.engine = lower(engine);

% Update defaults structure with input and we're done. 
options = updatestruct(defaults, options, true);


%% --------------------------------------------------------------------- %%
function d = defaults_all()

d = struct( ...
    'model'            ,   'model' , ...
    'data'             ,    'data' , ...
    'outputname'       , 'samples' , ...
    'init'             ,       []  , ...
    'modelfilename'    ,       []  , ...
    'datafilename'     ,       []  , ...
    'initfilename'     ,       []  , ...
    'scriptfilename'   ,       []  , ...
    'logfilename'      ,       []  , ...
    'engine'           ,    'jags' , ...
    'nchains'          ,        4  , ...
    'nburnin'          ,     1000  , ...
    'nsamples'         ,     5000  , ...
    'monitorparams'    ,       []  , ...
    'thin'             ,        1  , ...
    'refresh'          ,     1000  , ...
    'workingdir'       ,   'wdir'  , ...
    'cleanup'          ,    false  , ...
    'verbosity'        ,        0  , ... % prints output to screen
    'saveoutput'       ,     true  , ... % saves engine log
    'readonly'         ,    false  , ...
    'parallel'         ,  isunix() , ... % attempts to run in parallel
    'allowunderscores' ,    false  );    % allows underscores in model
 

%% --------------------------------------------------------------------- %%
function d = defaults_bugs()

d = struct( ...
    'showwarnings'   ,     true  );


%% --------------------------------------------------------------------- %%
function d = defaults_jags()

d = struct( ...
    'showwarnings'   ,           true  , ...
    'modules'        ,            {''} , ...    
    'seed'           ,  ceil(rand*1e4) , ...
    'maxcores'       ,              0  );


%% --------------------------------------------------------------------- %%
function d = defaults_stan()

d = struct(...                            Stan internal defaults:
    'remake'           ,  0 , ...         -----------------------
    'seed'             , [] , ...                      from clock
    'leapfrog_steps'   , [] , ...        -1: No-U-Turn Adaptation
    'max_treedepth'    , [] , ...                             10
    'epsilon'          , [] , ...           -1: Set automatically
    'epsilon_pm'       , [] , ...                           0.00
    'delta'            , [] , ...                           0.50
    'gamma'            , [] , ...                           0.05
    'append_samples'   ,  0 , ...
    'equal_step_sizes' ,  0 , ...
    'nondiag_mass'     ,  0 , ...
    'save_warmup'      ,  0 , ...
    'test_grad'        ,  0 , ...
    'maxcores'         ,  0 );


%% --------------------------------------------------------------------- %%
function target = updatestruct(target, source, check)

if isempty(source)
    return
end

oldfields = fieldnames(target);
newfields = fieldnames(source);

unknown = setdiff(newfields, oldfields);
if check && ~isempty(unknown)
    fprintf('Unknown field(s): %s\n', sprintf('\n- %s', unknown{:}));
    error_tag('trinity:trinity_input_parser:updatestruct:unknownFields', ...
        'Unknown fields are not permitted.')
end

for f = 1:numel(newfields)
    target.(newfields{f}) = source.(newfields{f});
end


%% --------------------------------------------------------------------- %%
%{
% Check the number of input arguments

n = length(varargin);
if (mod(n, 2))
    error_tag('Each option must be a string/value pair.');
end

% Check the number of supplied output arguments
if (nargout < (n / 2))
    error_tag('Insufficient number of output arguments given');
elseif (nargout == (n / 2))
    warn = 1;
    nout = n / 2;
else
    warn = 0;
    nout = n / 2 + 1;
end

% Set outputs to be defaults
varargout = cell(1, nout);
for i=2:2:n
    varargout{i/2} = varargin{i};
end

% Now process all arguments
nunused = 0;
for i=1:2:length(args)
    found = 0;
    for j=1:2:n
        if strcmpi(args{i}, varargin{j})
            varargout{(j + 1)/2} = args{i + 1};
            found = 1;
            break;
        end
    end
    if (~found)
        if (warn)
            warning(sprintf('Option ''%s'' not used.', args{i}));
            args{i}
        else
            nunused = nunused + 1;
            unused{2 * nunused - 1} = args{i};
            unused{2 * nunused} = args{i + 1};
        end
    end
end

% Assign the unused arguments
if (~warn)
    if (nunused)
        varargout{nout} = unused;
    else
        varargout{nout} = cell(0);
    end
end
end
%}
