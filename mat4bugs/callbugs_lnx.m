function output = callbugs_lnx(varargin)
% CALLBUGS_WIN  Use this function to run WinBUGS on Linux
%   CALLBUGS_WIN will execute a call to WinBUGS. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%   
%    Example usage:
%       [stats, chains, diagnostics, info] = callbugs('model', 'myModel.bugs')
%
%    See also: CALLBUGS
%

% (c) 2013 Joachim Vandekerckhove. See license.txt for licensing information.

error_tag('trinity:callbugs_lnx:nobugsinlinux', ...
    'WinBUGS is not supported on Linux.')
