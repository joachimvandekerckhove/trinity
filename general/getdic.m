function [dic, ha, qt] = getdic(chains)
% GETDIC  Compute Plummer's DIC from chains
%  GETDIC computes an estimate of the Deviance Information Criterion using
%  only samples from the Monte Carlo chains. Plummer's approximation to
%  DIC is mean(-2 ln L) + 0.5 * var(-2 ln L). Note that long, converged
%  chains are required for stable estimates of DIC.
%
%  DIC = GETDIC(CODA) will return Plummer's DIC.
%
%  [DIC, HALF, QTR] = GETDIC(CODA) additionally returns HALF, a two-element
%  vector containing DIC estimates computed on the first and second half of
%  the chains, and QTR, a four-element vector containing DIC estimates
%  computed on each quarter of the chains. HALF and QTR can be used to
%  assess the stability of DIC estimates.
% 
%  FCN = GETDIC('function') returns FCN, a function handle to compute DIC
%  from a coda structure.
%
%  See also: CODATABLE
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

%% Setup
% Create DIC function
dicfn = @(y)codatable(y, 'deviance', @(x)mean(x)+0.5*var(x));

%% Handle flag behavior
% If function flag given, return handle and exit
if ischar(chains) 
    if strcmp(chains, 'function')
        dic = dicfn;
        return
    else
        error_tag('trinity:getdic:unknownflag', ...
            'Input to GETDIC must be a coda structure or a string.')
    end
end

%% Error checking
if ~isstruct(chains)
    error_tag('trinity:getdic:notastruct', ...
        'Input to GETDIC must be a coda structure or a string.')
end
if ~isfield(chains, 'deviance')
    error_tag('trinity:getdic:missingdeviance', ...
        'The coda structure is missing a "deviance" field.')
end


%% Compute DICs
% Strip unused fields for speed
chains = struct('deviance', chains.deviance);

% Compute DIC over all samples
dic = dicfn(chains);

% Compute robustness DICs
if nargout > 1
    % Define halves and compute DIC
    nsamples = size(chains.deviance, 1);
    h1 = 1:(nsamples/2);
    h2 = (nsamples/2+1):nsamples;
    ha = [ ...
        dicfn(structfun(@(x)x(h1,:), chains, 'uni', 0))
        dicfn(structfun(@(x)x(h2,:), chains, 'uni', 0)) ];
    if nargout > 2
        % Define quarters and compute DIC
        q1 = 1:(nsamples/4);
        q2 = (1/4*nsamples+1):(nsamples/2);
        q3 = (nsamples/2+1):(3/4*nsamples);
        q4 = (3/4*nsamples+1):nsamples;
        qt = [ ...
            dicfn(structfun(@(x)x(q1,:), chains, 'uni', 0))
            dicfn(structfun(@(x)x(q2,:), chains, 'uni', 0))
            dicfn(structfun(@(x)x(q3,:), chains, 'uni', 0))
            dicfn(structfun(@(x)x(q4,:), chains, 'uni', 0)) ]';
    end
end