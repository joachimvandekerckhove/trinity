function options = calljags_mac(options)
% CALLJAGS_MAC  Executes a call to JAGS on Linux
%   CALLJAGS_MAC will execute a call to JAGS. Supply a set of options
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
    set_permissions('+x', scriptfile{ch});
end

options.scriptfile = scriptfile;
options.coda_files = coda_files;

end

%% --------------------------------------------------------------------- %%
function options = launch_jags(options)

workingdir     = options.workingdir     ;
nchains        = options.nchains        ;
verbosity      = options.verbosity      ;
doparallel     = options.parallel       ;
scriptfile     = options.scriptfile     ;
maxcores       = options.maxcores       ;

libpath = trinity_preferences('libpath_mac');

if doparallel
    % Check that parallel exists
    trinity_assert_parallel()
    
    % Make a temporary file name
    [~, tfn] = fileparts(tempname);
    tfn = fullfile(workingdir, tfn);
    
    % Write batch of commands to file
    scrf = [repmat({libpath}, 1 ,numel(scriptfile))
        reshape(scriptfile, 1, [])];
    [fid, stream] = robust_fopen(tfn, 'w');
    fprintf(fid, 'export LD_LIBRARY_PATH=%s; jags %s\n', scrf{:});
    delete(stream);
    
    % Prepare system call
    cmd = sprintf('cat %s | parallel --max-procs %i', tfn, maxcores);
    if verbosity > 0
        fprintf( 'Running %d chains (parallel execution):  ', nchains);
        disp(['$ ' cmd]);
        if verbosity <= 2
            dbtype(tfn)
        end
    end
    
    % Call system
    [status, result] = system(cmd);
    
    if status
        error_tag('trinity:calljags_mac:errorcallingparallel',...
            'System threw error:\n%s', result)
    end
    
else % Run each chain serially
    status = cell(1, nchains);
    result = cell(1, nchains);
    for iChain = 1:nchains
        cmd = sprintf('%sjags %s', ...
            libpath, scriptfile{iChain});
        if verbosity > 0
            fprintf('Running chain %d of %d (serial execution)\n', ...
                iChain, nchains);
        end
        [status{iChain}, result{iChain}] = system(cmd);
        
        if status{iChain}
            warning('trinity:calljags_mac:errorcallingjags',...
                'System threw error:\n%s', result{iChain})
        end
        
    end
    
    if any([status{:}])
        error_tag('trinity:calljags_mac:errorcallingjags',...
            'System threw errors:\n%s\n', result{[status{:}]})
    end
end

options.status = status;
options.result = result;

end

%% --------------------------------------------------------------------- %%
function save_jags_output(options)

nchains        = options.nchains        ;
doparallel     = options.parallel       ;
saveoutput     = options.saveoutput     ;
result         = options.result         ;

if ~saveoutput
    return
end

if doparallel
    filenm = sprintf('jags_output.txt');
    [fid, stream] = robust_fopen(filenm, 'wt');
    fprintf(fid, '%s', result);
    delete(stream);
else
    for iChain = 1:nchains
        filenm = sprintf('jags_output_%d.txt', iChain);
        resultnow = result{iChain};
        [fid, stream] = robust_fopen(filenm, 'wt');
        fprintf(fid, '%s', resultnow);
        delete(stream);
    end
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

if doparallel
    error_parser(result);
else
    for iChain = 1:nchains
        error_parser(result{iChain});
    end
end

    %% ----------------------------------------------------------------- %%
    function error_parser(resultnow)
        
        % Rethrow all error messages from JAGS
        pattern = 'can''t|RUNTIME ERROR|syntax error|failure';
        errstr = regexpi(resultnow, pattern, 'match');
        if ~isempty(errstr)
            if doparallel
                msg = sprintf(...
                    'Error encountered in JAGS!\nJAGS output (all chains):\n%s\n', ...
                    resultnow);
            else
                msg = sprintf(...
                    'Error encountered in JAGS (chain %d):\n%s\n', ...
                    iChain, resultnow);
            end
            error_tag('trinity:calljags_mac:error_checking:jagsError', ...
                'Stopping execution because of JAGS error:\n%s', msg);
        end
        
        % Rethrow all warning messages from JAGS
        if showwarnings ~= 0
            pattern = 'WARNING';
            errstr = regexpi(resultnow, pattern, 'match');
            if ~isempty(errstr)
                warning('trinity:calljags_mac:error_checking:jagsWarning', ...
                    'JAGS produced a warning message:');
                if doparallel
                    fprintf('JAGS output (all chains):\n%s\n', resultnow);
                else
                    fprintf('JAGS output (chain %d):\n%s\n', iChain, resultnow);
                end
            end
        end
        
        if verbosity >= 2
            if doparallel
                fprintf( 'JAGS output (all chains):\n%s\n', resultnow);
            else
                fprintf( 'JAGS output (chain %d):\n%s\n', iChain, resultnow);
            end
        end
    end
    %% ----------------------------------------------------------------- %%

end

%% --------------------------------------------------------------------- %%
