function name = trinity_untitled(options, style, idx)
% TRINITY_UNTITLED  Makes unique if unimaginative names for temporary files
%   TRINITY_UNTITLED(options, style, idx)

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

engine          = options.engine;
modelfilename   = options.modelfilename;
datafilename    = options.datafilename;
initfilename    = options.initfilename;
scriptfilename  = options.scriptfilename;
logfilename     = options.logfilename;

ext.script = 'script';
ext.log    = 'log';
ext.data   = 'data';
ext.init   = 'init';
switch engine
    case 'bugs'
        ext.model = 'txt';
    otherwise
        ext.model  = engine;
end

switch style
    case 'model'
        if ~isempty(modelfilename)
            name = modelfilename;
        else
            ctr = 0;
            name = sprintf('untitled.%s', ext.model);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i.%s', ctr, ext.model);
            end
        end
    case 'script'
        if ~isempty(scriptfilename)
            if ischar(initfilename)  % if root given
                name = sprintf('%s_%i.%s', scriptfilename, idx, ext.script);
            else
                name = scriptfilename{idx};
            end
        else
            ctr = 0;
            name = sprintf('untitled_%i.%s', idx, ext.script);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.%s', ctr, idx, ext.script);
            end
        end
    case 'log'
        if ~isempty(logfilename)
            name = logfilename;
        else
            ctr = 0;
            name = sprintf('untitled_%i.%s', idx, ext.log);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.%s', ctr, idx, ext.log);
            end
        end
    case 'data'
        if ~isempty(datafilename)
            name = datafilename;
        else
            ctr = 0;
            name = sprintf('untitled.%s', ext.data);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i.%s', ctr, ext.data);
            end
        end
    case 'init'
        if ~isempty(initfilename)
            if ischar(initfilename)  % if root given
                name = sprintf('%s_%i', initfilename, idx);
            else
                name = initfilename{idx};
            end
        else
            ctr = 0;
            name = sprintf('untitled_%i.%s', idx, ext.init);
            while exist(name, 'file')
                ctr = ctr + 1;
                name = sprintf('untitled%i_%i.%s', ctr, idx, ext.init);
            end
        end
    otherwise
        error_tag('trinity:trinity_untitled:unknownstyle', ...
            'Unknown filename style "%s".', style)
end

name = force_path_and_extension(name, style, options, ext);

end


%% --------------------------------------------------------------------- %%
function name = force_path_and_extension(name, style, options, ext)

workingdir = options.workingdir;

[~, file, ~] = fileparts(name);

name = fullfile(workingdir, [file '.' ext.(style)]);

end
