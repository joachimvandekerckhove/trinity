function out = getMatrixFromCoda(coda, target, fcn)
% GETMATRIXFROMCODA  Extract statistics of a matrix of posteriors
%   MTX = GETMATRIXFROMCODA(CODA, TARGET, [FUNCTION]), where CODA is a coda
%   structure, TARGET is a string with the name of a matrix-valued
%   parameter whose posterior samples are contained in the coda structure,
%   and FUNCTION is an optional function handle (default is @mean), returns
%   MTX, a matrix of similar size to the matrix-valued parameter, in which
%   each element is the result of FUNCTION having been applied to the
%   posterior samples of that element.
%   
%   Example:
%     If the BUGS code of a model contains an M-by-N variable MU, then the
%     obtained coda structure will contain fields MU_1_1 through MU_m_n.
%     Given such a coda structure as input:
%     MTX = GETMATRIXFROMCODA(CODA, 'MU', @std) will return an M-by-N
%     matrix MTX, such that MTX(m,n) = std(CODA.MU_m_n).
% 
%  See also CODATABLE, GRTABLE, CSTATS

if nargin < 3
    fcn = @mean;
end

% First look for anything that looks like a matrix named [target_.]
if ~any(cellfun(@(x)~isempty(regexp(x, ['^' target '_'], 'once')), ...
        fieldnames(coda)))
    % if none found, target may still be scalar: hand off to codatable
    out = codatable(coda, ['^' target '$'], fcn);
    return
end

% Grab all fields involved in the matrix
[selection, n_sel] = select_fields(coda, ['^' target '_[0-9]']);


% Count the dimensions
ndim = sum(selection{1} == '_');


% We're going to make a matrix of indices
ix = zeros(n_sel, ndim);
tgt = [target, repmat('_%i', 1, ndim)];
for c = 1:n_sel  % loop over selection to get each field's indices
    ix(c,:) = sscanf(selection{c}, tgt, ndim);
end


% Prepare the output variable
out = nan([max(ix), 1]);


% Compute the requested summary with codatable
l = codatable(coda, ['^' target '_'], fcn);


% Use comma separated list expansion to index into output variable
ix = num2cell(ix);
for c = 1:n_sel
    out(ix{c,:}) = l(c);
end
