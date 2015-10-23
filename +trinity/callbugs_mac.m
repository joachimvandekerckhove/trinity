function options = callbugs_mac(options)
% CALLBUGS_MAC  [Not yet implemented] Executes a call to WinBUGS on Mac
%   CALLBUGS_MAC will execute a call to WinBUGS. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%
%    See also: CALLBAYES
%

% (c) 2013- Joachim Vandekerckhove. See license.txt for licensing information.

trinity.error_tag('trinity:callbugs_mac:nobugsformac', ...
    'WinBUGS is not supported on Mac.')

% ... but you could try this:
% options = callbugs_win(options);
