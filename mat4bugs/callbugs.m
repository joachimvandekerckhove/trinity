function [stats, chains, diagnostics, info] = callbugs(varargin)
% CALLBUGS  [Not yet implemented] Executes a call to WinBUGS
%   CALLBUGS will execute a call to WinBUGS. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%   
%    See also: CALLBAYES
%

% (c) 2013- Joachim Vandekerckhove. See license.txt for licensing information.

options = trinity_input_parser('bugs', varargin{:});

switch computer
    case {'PCWIN', 'PCWIN64'}
        output = calljags_win(options);
    case {'GLNX86', 'GLNXA64'}
        output = calljags_lnx(options);
    case {'MACI64'}
        output = calljags_mac(options);
    otherwise
        error_tag('trinity:callbugs:unknownArch', ...
            'Unknown architecture "%s".', computer)
end

stats        = output.stats;
chains       = output.chains;
diagnostics  = output.diagnostics;
info         = output.info;
info.options = options;
