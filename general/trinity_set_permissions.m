function status = trinity_set_permissions(flag, fn)
% TRINITY_SET_PERMISSIONS  Set permissions for executable scripts

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

switch computer
    case {'PCWIN', 'PCWIN64'}
        status = false;
    case {'GLNX86', 'GLNXA64'}
        status = system(sprintf('chmod %s %s', flag, fn));
    case {'MACI64'}
        status = system(sprintf('chmod %s %s', flag, fn));
    otherwise
        error_tag('trinity:set_permissions:unknownArch', ...
            'Unknown architecture "%s".', computer)
end


