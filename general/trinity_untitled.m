function name = trinity_untitled(options, style, idx)
% TRINITY_UNTITLED  Makes unique if unimaginative names for temporary files

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

engine          = options.engine;
modelfilename   = options.modelfilename;
datafilename    = options.datafilename;
initfilename    = options.initfilename;
scriptfilename  = options.scriptfilename;
logfilename     = options.logfilename;

switch style
    case 'model'
        if ~isempty(modelfilename)
            name = modelfilename;
        else
            ctr = 0;
            name = sprintf('untitled.%s', engine);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i.%s', ctr, engine);
            end
        end
        name = force_path_and_extension(name, style, options);
    case 'script'
        if ~isempty(scriptfilename)
            if ischar(initfilename)  % if root given
                name = sprintf('%s_%i.cmd', scriptfilename, idx);
            else
                name = scriptfilename{idx};
            end
        else
            ctr = 0;
            name = sprintf('untitled_%i.cmd', idx);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.cmd', ctr, idx);
            end
        end
        name = force_path_and_extension(name, style, options);
    case 'log'
        if ~isempty(logfilename)
            name = logfilename;
        else
            ctr = 0;
            name = sprintf('untitled_%i.log', idx);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.log', ctr, idx);
            end
        end
        name = force_path_and_extension(name, style, options);
    case 'data'
        if ~isempty(datafilename)
            name = datafilename;
        else
            ctr = 0;
            name = 'untitled.data';
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i.data', ctr);
            end
        end
        name = force_path_and_extension(name, style, options);
    case 'init'
        if ~isempty(initfilename)
            if ischar(initfilename)  % if root given
                name = sprintf('%s_%i', initfilename, idx);
            else
                name = initfilename{idx};
            end
        else
            ctr = 0;
            name = sprintf('untitled_%i.init', idx);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.init', ctr, idx);
            end
        end
        name = force_path_and_extension(name, style, options);
    otherwise
        error_tag('trinity:trinity_untitled:unknownstyle', ...
            'Unknown filename style "%s".', style)
end

end


%% --------------------------------------------------------------------- %%
function name = force_path_and_extension(name, style, options)

engine     = options.engine;
workingdir = options.workingdir;

[~, file, ~] = fileparts(name);
switch style
    case 'model'
        ext = engine;
    case 'script'
        ext = 'cmd';
    case 'data'
        ext = 'data';
    case 'init'
        ext = 'init';
    case 'log'
        ext = 'log';
end

name = fullfile(workingdir, [file '.' ext]);

end