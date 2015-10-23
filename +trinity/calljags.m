function [stats, chains, diagnostics, info] = calljags(varargin)
% CALLJAGS  Use this function to run JAGS
%   CALLJAGS will execute a call to JAGS. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%   
%    See also: CALLBAYES
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

options = trinity.input_parser('jags', varargin{:});

options = trinity.prechecks(options);

switch computer
    case {'PCWIN', 'PCWIN64'}
        options = trinity.calljags_win(options);
    case {'GLNX86', 'GLNXA64'}
        options = trinity.calljags_lnx(options);
    case {'MACI64'}
        options = trinity.calljags_mac(options);
    otherwise
        trinity.error_tag('trinity:calljags:unknownArch', ...
            'Unknown architecture "%s".', computer)
end

coda = trinity.jags2coda(options);

output = trinity.summary_stats(coda);

stats        = output.stats;
chains       = output.chains;
diagnostics  = output.diagnostics;
info         = output.info;
info.options = options;
