function [fid, cleanupFlag] = robust_fopen(fn, flag)
% ROBUST_FOPEN  Opens stream and returns file ID and close handle
%   [FID, CLEANUPFLAG] = ROBUST_FOPEN(FILENAME, [FLAG]) where FILENAME is
%   an existing file and FLAG is an optional read/write flag for FOPEN,
%   returns FID, the file ID used for reading and writing, and CLEANUPFLAG,
%   an onCleanup object that causes the file stream to be closed if it is
%   deleted.
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if nargin < 2
    flag = 'r';
end

[fid, message] = fopen(fn, flag);
if fid == -1
    error_tag('trinity:robust_fopen:errorOpeningFile', ...
        'Error opening %s: %s', fn, message);
end

cleanupFlag = onCleanup(@()fclose(fid));