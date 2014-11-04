function varargout = gelmanrubin(coda,burn,thin,specvar)
% GELMANRUBIN  Computes Gelman-Rubin convergence statistic R-hat
%   RHAT = GELMANRUBIN(PARAM, [BURN], [THIN]), where PARAM is an NxM matrix
%   of N samples from M chains, BURN is the number of iterations to discard
%   (optional; default is 0) and THIN is the downsampling factor (optional;
%   default is 1).
%   [RHAT, VARPLUS, NEFF, B, W] = GELMANRUBIN(...) returns VARPLUS, the
%   marginal posterior variance, NEFF, the effective number of independent
%   draws (actually min(NEFF,M*N), as in Gelman et al.), and B and W, the
%   between- and within-sequence variances.
%   OUT = GELMANRUBIN(..., 'XX') returns only the statistic XX (can be
%   RHAT, VARPLUS, NEFF, B, W).
%
%   Reference: Gelman, A., Carlin, J., Stern, H., & Rubin D., (2004).
%              Bayesian Data Analysis (Second Edition). Chapman & Hall/CRC:
%              Boca Raton, FL. 
% 
%  See also: GRTABLE
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

%% Input sanity
if nargin < 3
    thin = 1;
    if nargin < 2
        burn = 0;
    end
end

% Downsample and burn
coda = coda((burn + 1):thin:end,:);

% Get size
[niter, nchains] = size(coda);
if niter < 50
    if niter < 1
        error_tag('trinity:gelmanrubin:noSamples',...
            'No samples left in chain. Did you burn all your samples?')
    end
%     warning('mat4bugs:gelmanrubin:fewSamples',...
%         'Number of samples left in chain is %i!',niter)
end

%% Get chain stats
chainmeans = sum(coda) / niter;
globalmean = sum(chainmeans) / nchains;

% Compute between- and within-variances and MPV
b = sum((chainmeans - globalmean).^2) * niter / (nchains - 1);
w = sum(var(coda)) / nchains;
varplus = (niter - 1) * w / niter + b / niter;

% Gelma-Rubin statistic
rhat = sqrt(varplus / w);

% Number of effective samples
neff = floor(min(niter * nchains, niter * nchains * varplus / b));


%% Output sanity
argout = {rhat varplus neff b w};
if nargin < 4
    if nargout < 6
        varargout = argout(1:nargout);
    else
        error_tag('trinity:gelmanrubin:tooManyOutputs',...
            'Too many output arguments.')
    end
elseif nargout < 2
    varargout = {eval(lower(specvar))};
else
    error_tag('trinity:gelmanrubin:inconsistentRequest',...
        ['You requested variable ''%s'', but also gave %i output' ...
        ' arguments. Which is it?'], specvar, nargout)
end
    
