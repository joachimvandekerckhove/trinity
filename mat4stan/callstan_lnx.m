function options = callstan_lnx(options)
% CALLSTAN_LNX  Executes a call to Stan on Linux
%   CALLSTAN_LNX will execute a call to Stan. Supply a set of options
%   as a structure. See the Trinity manual for a list of options.
%
%    See also: CALLSTAN
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% CALLSTAN to ensure integrity of input

% Move to working directory
cleanupHandle = trinity_move_to_wdir(options);

% Make scripts for each chain
options = compile_stan_binary(options);

% Launch Stan for Linux
options = launch_stan(options);

% Save the output from Stan to a text file
save_stan_output(options);

% Error checking from output
options = error_checking_stan(options);

% Force cleanup and return to previous directory
delete(cleanupHandle)

end


%% --------------------------------------------------------------------- %%
function options = compile_stan_binary(options)

model          = options.model          ;
verbosity      = options.verbosity      ;
remake         = options.remake         ;

[xdir, xfile] = fileparts(model)      ;
executable    = fullfile(xdir, xfile) ;

if ~remake && exist(executable, 'file')
    dt = dir(model);
    if verbosity > 0
        fprintf('Using existing binary, built %s\n', dt.date);
    end
    return
end

libpath = trinity_preferences('libpath_lnx');
standir = trinity_preferences('stan_main_dir');

if verbosity > 0
    disp('Building Stan binary file...')
end

cmd = [ 'export LD_LIBRARY_PATH=' , libpath    , '; ', ...
        'make ', fullfile(xdir, xfile), ' -C ' standir '; '];

if verbosity > 2
    disp(cmd)
end

[status, output] = system(cmd);

if status || ~isempty(strfind(output, 'FAILURE'))
    error_tag('trinity:callstan_lnx:makeerror', ...
        'System threw make error: %s', output)
end

if verbosity > 0
    if verbosity > 2
        disp(output)
    end
    fprintf('Binary built (%s).\n', datestr(now));
end


end

%% --------------------------------------------------------------------- %%
function options = launch_stan(options)

model          = options.model          ;
datafile       = options.data           ;
% monitorparams  = options.monitorparams  ;
nchains        = options.nchains        ;
thin           = options.thin           ;
init           = options.init           ;
nburnin        = options.nburnin        ;
nsamples       = options.nsamples       ;
verbosity      = options.verbosity      ;
doparallel     = options.parallel       ;
outputname     = options.outputname     ;
save_warmup    = options.save_warmup    ;
seed           = options.seed           ;
maxcores       = options.maxcores       ;
workingdir     = options.workingdir     ;

if doparallel
    trinity_assert_parallel();
end

% standir = trinity_preferences('stan_main_dir');
libpath = trinity_preferences('libpath_lnx');
[xdir, xfile] = fileparts(model);
executable = fullfile(xdir, xfile);

if verbosity > 0
    disp('Calling STAN...')
end

% Make a temporary file name
[~, tfn] = fileparts(tempname);
tfn = fullfile(workingdir, ['.', tfn]);

[fid, stream] = robust_fopen(tfn, 'w');

coda_files = cell(1, nchains);

for ch = 1:nchains
    coda_files{ch} = sprintf('%s_%i.csv', outputname, ch);
    fprintf(fid, '%s'                   , executable);
    fprintf(fid, ' data file=%s'        , datafile);
    fprintf(fid, ' id=%i'               , ch);
    fprintf(fid, ' output file=%s'      , coda_files{ch});
    if ~isempty(nsamples) || ~isempty(nburnin) || ~isempty(thin)
        fprintf(fid, ' sample');
        if ~isempty(nsamples) , fprintf(fid, ' num_samples=%i', nsamples);  end
        if ~isempty(nburnin)  , fprintf(fid, ' num_warmup=%i', nburnin)  ;  end
        if ~isempty(thin)     , fprintf(fid, ' thin=%i', thin)           ;  end
    end
    if save_warmup, fprintf(fid, ' save_warmup=1');  end
    %     if ~isempty(s.refresh)        , fprintf(fid, ' --refresh=%i'        , s.refresh        );  end
    if ~isempty(seed)           , fprintf(fid, ' random seed=%i'      , seed(ch)      );  end
    if ~isempty(init)           , fprintf(fid, ' init=%s'           , init{ch}      );  end
    %     if ~isempty(s.leapfrog_steps) , fprintf(fid, ' --leapfrog_steps=%i' , s.leapfrog_steps );  end
    %     if ~isempty(s.max_treedepth)  , fprintf(fid, ' --max_treedepth=%i'  , s.max_treedepth  );  end
    %     if ~isempty(s.epsilon)        , fprintf(fid, ' --epsilon=%f'        , s.epsilon        );  end
    %     if ~isempty(s.epsilon_pm)     , fprintf(fid, ' --epsilon_pm=%i'     , s.epsilon_pm     );  end
    %     if ~isempty(s.delta)          , fprintf(fid, ' --delta=%f'          , s.delta          );  end
    %     if ~isempty(s.gamma)          , fprintf(fid, ' --gamma=%f'          , s.gamma          );  end
    %     if s.append_samples   , fprintf(fid, ' --append_samples'   );  end
    %     if s.equal_step_sizes , fprintf(fid, ' --equal_step_sizes' );  end
    %     if s.nondiag_mass     , fprintf(fid, ' --nondiag_mass'     );  end
    %     if s.test_grad        , fprintf(fid, ' --test_grad'        );  end
    if ch < nchains, fprintf(fid, '\n'); end
end
delete(stream);
system(sprintf('chmod +x %s', tfn));

if doparallel
    cmd = sprintf('export LD_LIBRARY_PATH=%s; parallel -a %s --max-procs %i --gnu', ...
        libpath, tfn, maxcores);
else
    cmd = sprintf('export LD_LIBRARY_PATH=%s; sh %s', ...
        libpath, tfn);
end

if verbosity > 2
    disp(cmd)
end

if verbosity > 1
    fprintf('Batch file: %s', tfn);
    if verbosity > 2
        type(tfn)
    else
        fprintf('\n');
    end
    fprintf('  (...)\n');
end

[status, output] = system(cmd);
if verbosity > 2
    disp(output)
end

if status
    error_tag('trinity:callstan_lnx:stanerror', ...
        'System threw Stan error: %s', output)
end

options.result = output;
options.coda_files = cellfun(@get_full_path, coda_files, 'uni', 0);

if verbosity > 0
    disp('Stan completed')
end

end

%% --------------------------------------------------------------------- %%
function save_stan_output(options)

nchains        = options.nchains        ;
doparallel     = options.parallel       ;
saveoutput     = options.saveoutput     ;
result         = options.result         ;
logfilename    = options.logfilename    ;

if ~saveoutput
    return
end

if doparallel
    for iChain = 1:nchains
        [fid, message] = fopen(logfilename{iChain}, 'wt');
        if fid == -1
            error_tag('trinity:callstan_lnx:save_stan_output:fileOpenErrorPar', ...
                message);
        end
        fprintf(fid, '%s', result);
        fclose(fid);
    end
else
    for iChain = 1:nchains
        [fid, message] = fopen(logfilename{iChain}, 'wt');
        if fid == -1
            error_tag('trinity:callstan_lnx:save_stan_output:fileOpenError', ...
                message);
        end
%         keyboard
%         resultnow = result{iChain};
%         fprintf(fid, '%s', resultnow);
        fprintf(fid, '%s', result);
        fclose(fid);
    end
end

end

%% --------------------------------------------------------------------- %%
function options = error_checking_stan(options)
% For each chain, check if the output contains some error or warning message.

verbosity      = options.verbosity      ;
doparallel     = options.parallel       ;
result         = options.result         ;

showwarnings   = true ;

error_parser(result);

%% ----------------------------------------------------------------- %%
    function error_parser(resultnow)
        
        % Rethrow all error messages from Stan
        pattern = 'can''t|RUNTIME ERROR|syntax error|failed';
        errstr = regexpi(resultnow, pattern, 'match');
        if ~isempty(errstr)
            if doparallel
                msg = sprintf(...
                    'Error encountered in Stan!\nStan output (all chains):\n%s\n', ...
                    resultnow);
            else
                msg = sprintf(...
                    'Error encountered in Stan (chain %d):\n%s\n', ...
                    iChain, resultnow);
            end
            error_tag('trinity:callstan_lnx:error_checking:stanerror', ...
                'Stopping execution because of Stan error:\n%s', msg);
        end
        
        % Rethrow all warning messages from Stan
        if showwarnings ~= 0
            pattern = 'WARNING';
            errstr = regexpi(resultnow, pattern, 'match');
            if ~isempty(errstr)
                warning('trinity:callstan_lnx:error_checking:stanwarning', ...
                    'Stan produced a warning message:');
                if doparallel
                    if verbosity > 2
                        fprintf('Stan output (all chains):\n%s\n', resultnow);
                    end
                else
                    if verbosity > 2
                        fprintf('Stan output (chain %d):\n%s\n', iChain, resultnow);
                    end
                end
            end
        end
        
        if verbosity >= 2
            if doparallel
                fprintf( 'Stan output (all chains):\n%s\n', resultnow);
            else
                fprintf( 'Stan output (chain %d):\n%s\n', iChain, resultnow);
            end
        end
    end
%% ----------------------------------------------------------------- %%

end

%% --------------------------------------------------------------------- %%


%% --------------------------------------------------------------------- %%


%% --------------------------------------------------------------------- %%
