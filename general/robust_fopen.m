function [fid, cleanupFlag] = robust_fopen(fn, flag)

if nargin < 2
    flag = 'r';
end

[fid, message] = fopen(fn, flag);
if fid == -1
    error('trinity:robust_fopen:errorOpeningFile', ...
        'Error opening %s: %s', fn, message);
end

cleanupFlag = onCleanup(@()fclose(fid));