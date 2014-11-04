function output = callbugs_lnx(varargin)
% CALLBUGS_LNX  [Not yet implemented] Executes a call to WinBUGS on Linux
%   CALLBUGS_LNX will execute a call to WinBUGS. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%
%    See also: CALLBAYES
%

% (c) 2013- Joachim Vandekerckhove. See license.txt for licensing information.

error_tag('trinity:callbugs_lnx:nobugsinlinux', ...
    'WinBUGS is not supported on Linux.')
