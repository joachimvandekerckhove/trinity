function s = summary_stats(coda)


%% Diagnostics
s.diagnostics.Rhat = structfun(...
    @(x)gelmanrubin(x, 0, 1, 'rhat'), coda, 'uni', 0);
s.diagnostics.Neff = structfun(...
    @(x)gelmanrubin(x, 0, 1, 'neff'), coda, 'uni', 0);
% 
% %% Burn
% coda = structfun(@(x)x(:), coda, 'uni', 0);

%% Compute stats

s.stats.mean = structfun( @mean         , coda, 'uni', 0);
s.stats.std  = structfun( @std          , coda, 'uni', 0);
s.stats.plt0 = structfun( @(x)mean(x<0) , coda, 'uni', 0);

%% Info
s.info.samplesize = structfun(@numel, coda, 'uni', 0);

%% Chains
s.chains = coda;