function name = trinity_untitled(options, style, idx)
% TRINITY_UNTITLED  Makes unique if unimaginative names for temporary files

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

engine          = options.engine;
modelfilename   = options.modelfilename;
datafilename    = options.datafilename;
initfilename    = options.initfilename;
scriptfilename  = options.scriptfilename;

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
            name = force_path_and_extension(name, style, options);
        end
    case 'script'
        if ~isempty(scriptfilename)
            name = scriptfilename;
        else
            ctr = 0;
            name = sprintf('untitled_%i.cmd', idx);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.cmd', ctr, idx);
            end
            name = force_path_and_extension(name, style, options);
        end
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
            name = force_path_and_extension(name, style, options);
        end
    case 'init'
        if numel(initfilename) >= idx
            name = initfilename{idx};
        else
            ctr = 0;
            name = sprintf('untitled_%i.init', idx);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.init', ctr, idx);
            end
            name = force_path_and_extension(name, style, options);
        end
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
end

name = fullfile(workingdir, [file '.' ext]);

end