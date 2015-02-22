function options = calljags_win(options)
% CALLJAGS_WIN  Executes a call to JAGS on Windows
%   CALLJAGS_WIN will execute a call to JAGS. Supply a set of options
%   as a structure. See the Trinity manual for a list of options.
%
%    See also: CALLBAYES
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% CALLJAGS to ensure integrity of input

% Move to working directory
cleanupHandle = trinity_move_to_wdir(options);

% Make scripts for each chain
options = make_jags_scripts(options);

% Launch JAGS for Linux
options = launch_jags(options);

% Save the output from JAGS to a text file
save_jags_output(options);

% Error checking from output
options = error_checking_jags(options);

% Force cleanup and return to previous directory
delete(cleanupHandle)

end


%% --------------------------------------------------------------------- %%
function options = make_jags_scripts(options)

model          = options.model          ;
datafile       = options.data           ;
outputname     = options.outputname     ;
modules        = options.modules        ;
nchains        = options.nchains        ;
nburnin        = options.nburnin        ;
nsamples       = options.nsamples       ;
monitorparams  = options.monitorparams  ;
thin           = options.thin           ;
init           = options.init           ;
seed           = options.seed           ;

scriptfile = cell(1, nchains);
coda_files = cell(1, nchains);
seed_files = cell(1, nchains);

for ch = 1:nchains
    scriptfile{ch} = trinity_untitled(options, 'script', ch);
    coda_files{ch} = sprintf('%s_%d_', outputname, ch);
    seed_files{ch} = sprintf('%s_%i.seed', datafile(1:end-5), ch);
    str2data('jags', seed_files{ch}, ...
        'RNG_name__', '"base::Mersenne-Twister"', ...
        'RNG_seed__', seed + ch)
    
    % Create the JAGS script for this chain
    [fid, stream] = robust_fopen(scriptfile{ch}, 'wt');
    
    if ~isempty(modules)
        if iscell(modules)
            fprintf(fid, 'load %s\n', modules{:});
        else
            fprintf(fid, 'load %s\n', modules);
        end
    end
    fprintf(fid, 'model in "%s"\n', model);
    fprintf(fid, 'data in "%s"\n', datafile);
    fprintf(fid, 'compile, nchains(1)\n');
    fprintf(fid, 'parameters in "%s"\n', init{ch});
    fprintf(fid, 'parameters in "%s"\n', seed_files{ch});
    fprintf(fid, 'initialize\n');
    fprintf(fid, 'update %d\n', nburnin) ;
    if ~isempty(monitorparams)
        if iscell(monitorparams)
            fprintf(fid, sprintf('monitor set %%s, thin(%d)\\n', thin), ...
                monitorparams{:});
        else
            fprintf(fid, 'monitor set %s, thin(%d)\n', monitorparams, thin);
        end
    end
    if ismember('dic', modules)
        fprintf(fid, 'monitor deviance\n');
%        fprintf(fid, 'monitor pD, type(mean)\n');
    end
    fprintf(fid, 'update %d\n', nsamples*thin);
    fprintf(fid, 'coda *, stem(''%s'')\n', coda_files{ch});
%    if ismember('dic', modules)
%        fprintf(fid, 'coda pD, stem(PD)\n');
%    end
    delete(stream)
    trinity_set_permissions('+x', scriptfile{ch});
end

options.scriptfile = scriptfile;
options.coda_files = coda_files;

end

%% --------------------------------------------------------------------- %%
function options = launch_jags(options)

% workingdir     = options.workingdir     ;
nchains        = options.nchains        ;
verbosity      = options.verbosity      ;
doparallel     = options.parallel       ;
scriptfile     = options.scriptfile     ;
maxcores       = options.maxcores       ;
if ~maxcores
    maxcores = Inf;
end

% libpath = trinity_preferences('libpath_win');

if doparallel
    % Check that parallel exists
    trinity_assert_parallel()
    
    % Make sure the matlabpool is the right size
    workers = min(maxcores, 2 * feature('numCores'));
    
    % This section needs to deal with various versions of the Parallel
    % Computing Toolbox creating and managing pools of workers differently.
    % If the parallel.Pool exists, use pool objects. Otherwise, if
    % parallel.cluster exists, use parcluster syntax. Otherwise, use
    % deprecating findResource method.
    if exist('parallel.Pool', 'class')
        pool = gcp('nocreate');
        if isempty(pool) || pool.NumWorkers ~= workers
            delete(pool);
            parpool(workers);
        end
    elseif exist('parallel.cluster.Local', 'class')
        %#ok<*DPOOL>
        if matlabpool('size') ~= workers
            fprintf('Opening matlabpool with %i workers.\n', workers)
            parcl = parcluster;
            matlabpool close force
            set(parcl, 'NumWorkers', workers)
            matlabpool(parcl, 'open', workers)
        end
    else
        %#ok<*REMFF1>
        if matlabpool('size') ~= workers
            fprintf('Opening matlabpool with %i workers.\n', workers)
            matlabpool close force
            sched = findResource('scheduler', 'type', 'local');
            set(sched, 'ClusterSize',n)
            matlabpool('open', n)
        end
    end
        
    % Parallel loop over chains
    status = cell(1, nchains);
    result = cell(1, nchains);
    parfor iChain = 1:nchains
        cmd = sprintf('jags %s', scriptfile{iChain});
        if verbosity > 0
            fprintf('Running chain %d of %d (parallel execution)\n', ...
                iChain, nchains);
        end
        [status{iChain}, result{iChain}] = system(cmd);
        
        if status{iChain}
            warning('trinity:calljags_win:errorcallingsinglejags',...
                'System threw error:\n%s', result{iChain})
        end
        
    end
    
    if any([status{:}])
        error_tag('trinity:calljags_win:errorcallingparalleljags',...
            'System threw errors:\n%s\n', result{[status{:}]})
    end
    
else % Run each chain serially
    status = cell(1, nchains);
    result = cell(1, nchains);
    for iChain = 1:nchains
        cmd = sprintf('jags %s', scriptfile{iChain});
        if verbosity > 0
            fprintf('Running chain %d of %d (serial execution)\n', ...
                iChain, nchains);
        end
        [status{iChain}, result{iChain}] = system(cmd);
        
        if status{iChain}
            warning('trinity:calljags_win:errorcallingjags',...
                'System threw error:\n%s', result{iChain})
        end
        
    end
    
    if any([status{:}])
        error_tag('trinity:calljags_win:errorcallingjags',...
            'System threw errors:\n%s\n', result{[status{:}]})
    end
end

options.status = status;
options.result = result;

end

%% --------------------------------------------------------------------- %%
function save_jags_output(options)

nchains        = options.nchains        ;
% doparallel     = options.parallel       ;
saveoutput     = options.saveoutput     ;
result         = options.result         ;

if ~saveoutput
    return
end

for iChain = 1:nchains
    filenm = sprintf('jags_output_%d.txt', iChain);
    resultnow = result{iChain};
    [fid, stream] = robust_fopen(filenm, 'wt');
    fprintf(fid, '%s', resultnow);
    delete(stream);
end

end

%% --------------------------------------------------------------------- %%
function options = error_checking_jags(options)
% For each chain, check if the output contains some error or warning message.

nchains        = options.nchains        ;
verbosity      = options.verbosity      ;
doparallel     = options.parallel       ;
showwarnings   = options.showwarnings   ;
result         = options.result         ;
erroronerror   = true                   ;  % TODO?: options.erroronerror   ;

if doparallel
    for iChain = 1:nchains
        error_parser(result{iChain});
    end
else
    error_parser(result);
end

    %% ----------------------------------------------------------------- %%
    function error_parser(resultnow)
        
        if iscell(resultnow)
            resultnow = resultnow{1};
        end
        
        % Rethrow all error messages from JAGS
        pattern = 'can''t|RUNTIME ERROR|syntax error|failure';
        errstr = regexpi(resultnow, pattern, 'match');
        if ~isempty(errstr)
            if doparallel
                msg = sprintf(...
                    'Error encountered in JAGS (chain %d):\n%s\n', ...
                    iChain, resultnow);
            else
                msg = sprintf(...
                    'Error encountered in JAGS!\nJAGS output (all chains):\n%s\n', ...
                    resultnow);
            end
            if erroronerror
                error_tag('trinity:calljags_win:error_checking:jagsError', ...
                    'Stopping execution because of JAGS error:\n%s', msg);
            else
                warning('trinity:calljags_win:error_checking:jagsErrorWarn', ...
                    'JAGS error encountered:\n%s', msg);
            end
        end
        
        % Rethrow all warning messages from JAGS
        if showwarnings ~= 0
            pattern = 'WARNING';
            errstr = regexpi(resultnow, pattern, 'match');
            if ~isempty(errstr)
                warning('trinity:calljags_win:error_checking:jagsWarning', ...
                    'JAGS produced a warning message:');
                if doparallel
                    fprintf('JAGS output (chain %d):\n%s\n', iChain, resultnow);
                else
                    fprintf('JAGS output (all chains):\n%s\n', resultnow);
                end
            end
        end
        
        if verbosity >= 2
            if doparallel
                fprintf( 'JAGS output (chain %d):\n%s\n', iChain, resultnow);
            else
                fprintf( 'JAGS output (all chains):\n%s\n', resultnow);
            end
        end
    end
    %% ----------------------------------------------------------------- %%

end

%% --------------------------------------------------------------------- %%
