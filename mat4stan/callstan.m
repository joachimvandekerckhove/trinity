function [stats, chains, diagnostics, info] = callstan(varargin)
% CALLSTAN  Use this function to run Stan
%   CALLSTAN will execute a call to Stan. Supply a set of options 
%   through label-value pairs or as a structure. See the Trinity
%   manual for a list of options.
%   
%    Example usage:
%       [stats, chains, diagnostics, info] = callstan('model', 'myModel.stan')
%
%    See also: STAN2CODA, CALLJAGS, CALLBUGS
%

% (c)2013 Joachim Vandekerckhove. See license.txt for licensing information.

options = trinity_input_parser('stan', varargin{:});

options = trinity_prechecks(options);

switch computer
    case {'PCWIN', 'PCWIN64'}
        options = callstan_win(options);
    case {'GLNX86', 'GLNXA64'}
        options = callstan_lnx(options);
    case {'MACI64'}
        options = callstan_mac(options);
    otherwise
        error('Unknown architecture "%s".', computer)
end

coda = stan2coda(options);

output = summary_stats(coda.samples);

stats        = output.stats;
chains       = output.chains;
diagnostics  = output.diagnostics;
info         = coda.info;
info.tuning  = coda.tuning;
info.options = options;
