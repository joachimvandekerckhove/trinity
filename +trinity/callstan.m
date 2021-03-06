function [stats, chains, diagnostics, info] = callstan(varargin)
% CALLSTAN  Executes a call to Stan
%   CALLSTAN will execute a call to Stan. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%   
%    See also: CALLBAYES
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

options = trinity.input_parser('stan', varargin{:});

options = trinity.prechecks(options);

switch computer
    case {'PCWIN', 'PCWIN64'}
        options = trinity.callstan_win(options);
    case {'GLNX86', 'GLNXA64'}
        options = trinity.callstan_lnx(options);
    case {'MACI64'}
        options = trinity.callstan_mac(options);
    otherwise
        trinity.error_tag('trinity:callstan:unknownArch', ...
            'Unknown architecture "%s".', computer)
end

coda = trinity.stan2coda(options);

output = trinity.summary_stats(coda.samples);

stats        = output.stats;
chains       = output.chains;
diagnostics  = output.diagnostics;
info         = coda.info;
info.tuning  = coda.tuning;
info.options = options;
