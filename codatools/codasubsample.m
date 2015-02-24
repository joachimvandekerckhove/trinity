function [sample, fnms] = codasubsample(coda, target, n)
% CODASUBSAMPLE  Draw posterior subsample coda structure
%  CODASUBSAMPLE returns a structure with subsamples from the posterior of
%  one or more given parameters.
% 
%  SAMPLE = CODASUBSAMPLE(CODA, TARGET, N), where CODA is a coda structure,
%  TARGET is a regular expression, and N is a positive integer, will return
%  a structure SAMPLE, in which each field is a set of N samples from the
%  posterior distribution of each of the parameters matched by TARGET.
% 
%  [SAMPLE, FNMS] = CODASUBSAMPLE(CODA, TARGET, N), additionally returns
%  FNMS, a cell string with the matched parameter names.
% 
%  See also: CODATABLE
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if nargin ~= 3
    error_tag('trinity:codasubsample:insufficientInput', ...
        'CODASUBSAMPLE requires exactly three input parameters.')
end

% Select fields
[fnms, n_sel] = select_fields(coda, target);

% Check that there are enough samples
nsamp = numel(coda.(fnms{1}));
if nsamp < n
    error_tag('trinity:codasubsample:youAskTooMuch', ...
        'You requested %i samples, but only %i are available.', n, nsamp)
end

% Pick a random set of numbers
[~, idx] = sort(rand(nsamp, 1));
idx = idx(1:n);

% Loop over matches
for parameter = 1:n_sel
     sample.(fnms{parameter}) = coda.(fnms{parameter})(idx);
end