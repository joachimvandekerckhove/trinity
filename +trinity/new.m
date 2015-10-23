function new(fn)
% NEW  Start a new Trinity project
%   NEW(PROJECT_NAME) makes a new script file to use Trinity.

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if ~nargin
    fn = 'main';
end

newname = sprintf('%s_trinity.m', fn);
if exist(newname, 'file')
    warning('trinity:new:existingFile', ...
        'A file with that name already exists!')
else
    copyfile(which('trinity.generic_script'), newname)
end
edit(newname)
