function s = trinity_summary_stats(coda)
% TRINITY_SUMMARY_STATS  Computes default STATS from CODA as output by CALLBAYES

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

%% Diagnostics
s.diagnostics.Rhat = structfun(...
    @(x)gelmanrubin(x, 0, 1, 'rhat'), coda, 'uni', 0);
s.diagnostics.Neff = structfun(...
    @(x)gelmanrubin(x, 0, 1, 'neff'), coda, 'uni', 0);
% 
% %% Burn
% coda = structfun(@(x)x(:), coda, 'uni', 0);

%% Compute stats

s.stats.mean   = structfun( @(x)mean(x(:))   , coda, 'uni', 0);
s.stats.std    = structfun( @(x)std(x(:))    , coda, 'uni', 0);
s.stats.plt0   = structfun( @(x)mean(x(:)<0) , coda, 'uni', 0);
s.stats.median = structfun( @(x)median(x(:)) , coda, 'uni', 0);

%% Info
s.info.samplesize = structfun(@numel, coda, 'uni', 0);

%% Chains
s.chains = coda;