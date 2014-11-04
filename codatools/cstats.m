function cstats(coda, target)
% CSTATS  Print a table with basic posterior statistics
%   CSTATS(CODA, [TARGET]); where CODA is a coda structure and TARGET is an
%   optional regular expression, prints a table with basic posterior
%   statistics.
% 
%  See also: CODATABLE, GRTABLE, GETMATRIXFROMCODA
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if nargin < 2
    target = '.';
end

codatable(coda, target, @mean, @std, @mc_error, ...
    @Rhat, @n_eff, @n_samples, ....
    @pct2_5, @median, @pct97_5)

end


%% --------------------------------------------------------------------- %%
function v = mc_error(x)
    v = std(x)/sqrt(numel(x));
end


%% --------------------------------------------------------------------- %%
function v = pct2_5(x)
    v = prctile(x, 2.5);
end


%% --------------------------------------------------------------------- %%
function v = pct97_5(x)
    v = prctile(x, 97.5);
end


%% --------------------------------------------------------------------- %%
function v = n_eff(x)
    v = gelmanrubin(x, 0, 1, 'neff');
end


%% --------------------------------------------------------------------- %%
function v = n_samples(x)
    v = numel(x);
end


%% --------------------------------------------------------------------- %%
function v = Rhat(x)
    v = gelmanrubin(x, 0, 1, 'rhat');
end


