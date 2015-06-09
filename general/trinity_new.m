function trinity_new(fn)
% TRINITY_NEW  Start a new Trinity project
%   TRINITY_NEW(PROJECT_NAME) makes a new script file to use Trinity.

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if ~nargin
    fn = 'main';
end

newname = sprintf('%s_trinity.m', fn);
if exist(newname, 'file')
    warning('trinity:trinity_new:existingFile', ...
        'A file with that name already exists!')
else
    copyfile(which('trinity_generic_script'), newname)
end
edit(newname)