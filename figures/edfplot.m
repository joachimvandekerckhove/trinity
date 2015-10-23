function varargout = edfplot(coda, varargin)
% EDFPLOT  Make an empirical distribution plot
%   EDFPLOT(CODA, [TARGET]); where CODA is a coda structure and
%   TARGET is an optional regular expression, produces an empirical
%   distribution plot of the parameters matched by TARGET.
%   P = EDFPLOT(CODA, TARGET, UPPER), where UPPER is a real scalar, draws a
%   vertical line at UPPER and returns P, the proportion of mass below
%   UPPER.
%   P = EDFPLOT(CODA, TARGET, BOUNDS), where BOUNDS is a two-element real
%   vector, draws vertical lines at BOUNDS(1) and BOUNDS(2) and returns P,
%   the proportion of mass between BOUNDS(1) and BOUNDS(2).
% 
%  See also: VIOLINPLOT, TRACEPLOT, CATERPILLAR, SMHIST
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
if nargin < 2
    if nargin < 1
        trinity.error_tag('trinity:edfplot:badInput', ...
            'Insufficient input to edfplot.')
    end
    target = '.';
else
    target = varargin{1};
end

colorOrder = get(0, 'DefaultAxesColorOrder');
set(0, 'DefaultAxesColorOrder', trinity.preferences('colororder'))

if isnumeric(coda) % If user gave chains instead of coda structure
    figure()
    h = axes();
    edfplot_sub(coda, 'parameter', varargin{:})
else  % Select fields by regular expression
    varargin(1) = [];
    [selection, n_sel] = trinity.select_fields(coda, target);
    % Then loop over selected fields
    h = zeros(n_sel, 1);
    for parameter = 1:n_sel
        if n_sel>1, figure(), end
        h(parameter) = edfplot_sub(coda.(selection{parameter}), ...
            selection{parameter}, varargin{:});
    end
end

if nargout,  varargout = {h};  end
figure(gcf)  % focus figure
set(0, 'DefaultAxesColorOrder', colorOrder);

end

%% --------------------------------------------------------------------- %%
function p = edfplot_sub(x, name, varargin)

if nargin >2 && isnumeric(varargin{1})
    if numel(varargin{1}) == 1
        lowerbnd = -Inf;
        upperbnd = varargin{1};
        varargin(1) = [];
    elseif numel(varargin{1}) == 2
        lowerbnd = min(varargin{1});
        upperbnd = max(varargin{1});
        varargin(1) = [];
    end
else
    lowerbnd = -Inf;
    upperbnd = +Inf;
end

xax = sort(x(:))';
nmp = numel(x);
yax = linspace(1/nmp, 1, nmp);

plot(xax, yax, 'linewidth', 2, 'Tag', 'edfline', varargin{:})

xlabel(name)
ylabel('Prob(X<x)')
title(name, 'interpreter', 'none')

if isfinite(lowerbnd)
    line(lowerbnd([1 1]), [0 1], 'linestyle', '--', 'color', 'k', 'Tag', 'lowerbound')
    [~, y1] = min(abs(xax-lowerbnd));
else
    y1 = 1;
end
if isfinite(upperbnd)
    line(upperbnd([1 1]), [0 1], 'linestyle', '--', 'color', 'k', 'Tag', 'upperbound')
    [~, y2] = min(abs(xax-upperbnd));
else
    y2 = nmp;
end

p = mean(xax>lowerbnd & xax<upperbnd);

text(min(xlim)+diff(xlim)/20, 0.9, sprintf('Pr = %.4f', p))

% Add a patch
% keyboard
if isfinite(lowerbnd) && isfinite(upperbnd)
    if upperbnd > max(xax)
        xp = [lowerbnd xax(y1:y2) upperbnd upperbnd];
        yp = [0 yax(y1:y2) 1 0];
    else
        xp = [lowerbnd xax(y1:y2) upperbnd];
        yp = [0 yax(y1:y2) 0];
    end
elseif isfinite(lowerbnd)
    xp = [lowerbnd xax(y1:y2) max(xlim) max(xlim)];
    yp = [0 yax(y1:y2) 1 0];
else
    xp = [min(xlim) min(xlim) xax(y1:y2) upperbnd];
    yp = [0 0 yax(y1:y2) 0];
end

patch(xp, yp, 'm', 'facealpha', .15, 'edgecolor', 'none')

end

%% --------------------------------------------------------------------- %%