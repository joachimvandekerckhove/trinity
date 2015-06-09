function trinity_new(fn)
% TRINITY_NEW  Start new Trinity project

if ~nargin
    fn = 'main';
end

newname = sprintf('%s_trinity.m', fn);
copyfile(which('trinity_generic_script'), newname)
edit(newname)