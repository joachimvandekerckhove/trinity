function status = trinity_set_permissions(flag, fn)

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


