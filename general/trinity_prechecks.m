function options = trinity_prechecks(options)
% TRINITY_PRECHECKS  Checks preconditions before launching engine

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.


% Check that working dir exists and is writable
options = check_wdir(options);

% Clean working directory
options = clean_wdir(options);

% Check that model file exists
options = check_model(options);

% Check that data file exists
options = check_data(options);

% Check that init files exist
options = check_inits(options);

% Check that log files exist
options = check_log(options);

% Repopulate working directory
options = populate_wdir(options);

end

%% --------------------------------------------------------------------- %%
function options = check_wdir(options)

workingdir = options.workingdir;

if ~exist(workingdir, 'dir')
    [status, message]  = mkdir(workingdir);
    if status ~= 1
        error_tag('trinity:trinity_prechecks:wdirError', message);
    end
end

assertunlocked(workingdir, 'dir');

options.workingdir = get_full_path(workingdir);

end

%% --------------------------------------------------------------------- %%
function options = check_model(options)

model         = options.model;
modelfilename = options.modelfilename;
% workingdir    = options.workingdir;

switch class(model)
    case 'char'  % it can be a filename...
        if ~isempty(modelfilename)
            error_tag('trinity:trinity_prechecks:check_model:conflictinginputmodel', ...
                'If the model is defined as a file name, "modelfilename" must be empty.');
        end
        modelfilename = model;
    case 'cell'  % ... or we need to write the model to a temp file
        modelfilename = trinity_untitled(options, 'model');
        cell2model(model, modelfilename)
end

assertunlocked(modelfilename, 'file');

trinity_set_permissions('+x', modelfilename);

options.model         = get_full_path(modelfilename);
options.modelfilename = modelfilename;

grammar_check(options);

end

%% --------------------------------------------------------------------- %%
function options = check_data(options)

engine       = options.engine;
data         = options.data;
datafilename = options.datafilename;

switch class(data)
    case 'char'    % it can be a filename...
        if ~isempty(datafilename)
            error_tag('trinity:trinity_prechecks:check_data:conflictinginputdata', ...
                'If the data is defined as a file name, "datafilename" must be empty.');
        end
        datafilename = data;
    case 'struct'  % ... or we need to write the model to a temp file
        datafilename = trinity_untitled(options, 'data');
        str2data(engine, datafilename, data)
end

assertunlocked(datafilename, 'file');

trinity_set_permissions('+x', datafilename);

options.data  = get_full_path(datafilename);

end

%% --------------------------------------------------------------------- %%
function options = check_inits(options)

engine       = options.engine;
init         = options.init;
nchains      = options.nchains;
initfilename = options.initfilename;

initfilename_upd = cell(1, nchains);

if isa(init, 'function_handle')
    generating_function = init;
    init = cell(1, nchains);
    for c = 1:nchains
        init{c} = generating_function();
    end
end

for c = 1:nchains
    switch class(init{c})
        case 'char'    % it can be a filename...
            if ~isempty(initfilename)
                error_tag('trinity:check_inits:trinity_prechecks:conflictinginputinit', ...
                    'If the initial values is defined as a file name, "initfilename" must be empty.');
            end
            initfilename_upd{c} = init{c};
        case 'struct'  % ... or we need to write the inits to a temp file
            initfilename_upd{c} = trinity_untitled(options, 'init', c);
            str2data(engine, initfilename_upd{c}, init{c})
    end
    
    assertunlocked(initfilename_upd{c}, 'file');
    
    trinity_set_permissions('+x', initfilename_upd{c});
end

options.init = cellfun(@get_full_path, initfilename_upd, 'uni', 0);

end


%% --------------------------------------------------------------------- %%
function options = check_log(options)

nchains      = options.nchains;
logfilename  = options.logfilename;

logfilename_upd = cell(1, nchains);

for c = 1:nchains
    switch class(logfilename)
        case 'double'
            if isempty(logfilename)
                logfilename_upd{c} = trinity_untitled(options, 'log', c);
            else
                error_tag('trinity:check_log:trinity_prechecks:invalidinput', ...
                    'Invalid log file name.');
            end
        case 'char'    % it can be a root...
            logfilename_upd{c} = sprintf('%s_%i.log', logfilename, c);
        case 'cell'  % ... or all log file names were given
            logfilename_upd{c} = trinity_untitled(options, 'log', c);
    end
end

options.logfilename = cellfun(@get_full_path, logfilename_upd, 'uni', 0);

end


%% --------------------------------------------------------------------- %%
function options = clean_wdir(options)

workingdir     = options.workingdir     ;
cleanup        = options.cleanup        ;

if cleanup
    delete(fullfile(workingdir, '*'));
end

end


%% --------------------------------------------------------------------- %%
function options = populate_wdir(options)

workingdir     = options.workingdir     ;
model          = options.model          ;
data           = options.data           ;
init           = options.init           ;
nchains        = options.nchains        ;
engine         = options.engine         ;

[~, model] = fileparts(model);
model = fullfile(workingdir, [model, '.', engine]);
if ~strcmp(options.model, model)
    copyfile(options.model, model)
    options.model = model;
end

[~, data] = fileparts(data);
data = fullfile(workingdir, [data, '.data']);
if ~strcmp(options.data, data)
    copyfile(options.data, data)
    options.data = data;
end

for ch = 1:nchains
    [~, init{ch}] = fileparts(init{ch});
    init{ch} = fullfile(workingdir, [init{ch}, '.init']);
    if ~strcmp(options.init{ch}, init{ch})
        copyfile(options.init{ch}, init{ch})
        options.init{ch} = init{ch};
    end
end

end

%% --------------------------------------------------------------------- %%
function assertunlocked(filename, qtype)

switch qtype
    case 'file'
        if ~exist(filename, 'file')
            error_tag('trinity:trinity_prechecks:assertunlocked:filemissing', ...
                'Unable to access "%s" (file missing).', filename);
        end
    case 'dir'
        if ~iswritable(filename)
            error_tag('trinity:trinity_prechecks:assertunlocked:unwritablewdir', ...
                ['Could not write to directory "%s" ', ...
                '(not a local permissions issue).'], filename);
        end
end

[~, f] = fileattrib(filename);
if ~f.UserRead
    error_tag('trinity:trinity_prechecks:assertunlocked:readprotected', ...
        'Unable to access "%s" (read-protected).', filename);
end
if ~f.UserWrite
    error_tag('trinity:trinity_prechecks:assertunlocked:writeprotected', ...
        'Unable to access "%s" (write-protected).', filename);
end

end

%% --------------------------------------------------------------------- %%
function s = iswritable(varargin)
%ISWRITABLE Tests if a folder is writable.
%   ISWRITABLE (FOLDERNAME) returns 1 if the folder indicated by FOLDERNAME is
%   writable and 0 otherwise.
%
%   ISWRITABLE  tests whether the directory, FOLDERNAME, is writable by
%   attempting to create a subdirectory within FOLDERNAME.  If the
%   subdirectory can be created then FOLDERNAME is writable and the
%   subdirectory is deleted.  ISWRITE differs from FILEATTRIB in that
%   ISWRITE captures network and share level permissions where FILEATTRIB
%   does not.
%
%   Example:
%
%   x = iswritable('C:\WINDOWS');   returns whether or not the Windows
%                                   directory is writable
%
%   x = iswritable('\\VT1\public'); returns whether or not the network
%                                   share, 'public' is writable
%
%   x = iswritable                  returns whether or not the present
%                                   working directory is writable
%
%
%   See also FILEATTRIB

%   Original written by Chris J Cannell
%   Contact ccannell@mindspring.com for questions or comments.
%   12/08/2005

if nargin > 1
    error_tag('trinity:trinity_prechecks:iswritable:badInput', ...
        'Too many input arguments');
elseif nargin == 1
    folderName = varargin{1};
else
    folderName = pwd;
end

% create a random folder name so no existing folders are affected
testDir = ['deleteMe_', num2str(floor(rand*1e12))];

% check if folderName exists
if exist(folderName, 'dir') == 7
    % test for write permissions by creating a folder and then deleting it
    s = mkdir(folderName, testDir);
    % check if directory creation was successful
    if s == 1
        % we have permission to write so delete the created test directory
        status = rmdir(fullfile(folderName, testDir));
        if status ~= 1
            warning('trinity:trinity_prechecks:iswritable:undeletable', ...
                'Test folder "%s" could be written but not be deleted', ...
                fullfile(folderName, testDir));
        end
    end
else
    error_tag('trinity:trinity_prechecks:iswrite:wdirmissing', ...
        'Folder "%s" does not exist', folderName);
end
end

%% --------------------------------------------------------------------- %%
function grammar_check(options)
% GRAMMAR_CHECK  Does limited robustness check of model

modelfilename    = options.modelfilename;
allowunderscores = options.allowunderscores;

model = model2cell(modelfilename);

if ~allowunderscores
    underscores = cellfun(@(x)any(x=='_'), model);
    
    if any(underscores)
        error_tag('trinity:trinity_prechecks:grammar_check:illegal_character', ...
            ['The _ character is reserved for internal use in Trinity, '...
             'but was found in your model specification. To force Trinity ' ...
             'to ignore this restriction, set the "allowunderscores" option ' ...
             'to 1. However, this may cause unexpected behavior, and it is ' ...
             'recommended to remove underscores from the model specification instead.'])
    end
end

end