function grtable(coda, target, cutoff)
% GRTABLE  Print a table with basic convergence statistics
%   GRTABLE(CODA, [TARGET]); where CODA is a coda structure and TARGET is
%   an optional regular expression, prints a table with basic convergence
%   statistics.
% 
%  See also: CODATABLE, CSTATS, GETMATRIXFROMCODA, GELMANRUBIN
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if nargin < 2  % hand off to codatable
    codatable(coda, '.', @mean, @samples, @n_eff, @Rhat);
    return
elseif nargin == 2
    if ischar(target)  % hand off to codatable
        codatable(coda, target, @mean, @samples, @n_eff, @Rhat);
        return
    else  % assume inputs were switched
        cutoff = target;
        target = '.';
    end
elseif nargin == 3
    if ~ischar(target)
        tmp = cutoff;
        cutoff = target;
        target = tmp;
    end
end

% Find which ones to display
[rhat, rows] = codatable(coda, target, @Rhat);
censor = rhat < cutoff;
if all(censor | isnan(rhat))
    fprintf('No GR statistics were over %g', cutoff)
    if any(isnan(rhat))
        fprintf(' (but some nodes returned NaN)')
    end
    fprintf('; highest Rhat was %g.\n', max(rhat(~isnan(rhat))))
    return
end

% Removed censored parameters and move to codatable
codatable(rmfield(coda, rows(censor | isnan(rhat))), target, @mean, ...
    @samples, @n_eff, @Rhat);

end


%% --------------------------------------------------------------------- %%
function v = samples(x)
    v = numel(x);
end


%% --------------------------------------------------------------------- %%
function v = n_eff(x)
    v = gelmanrubin(x, 0, 1, 'neff');
end


%% --------------------------------------------------------------------- %%
function v = Rhat(x)
    v = gelmanrubin(x, 0, 1, 'rhat');
end


