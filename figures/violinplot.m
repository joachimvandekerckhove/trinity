function varargout = violinplot(coda, varargin)
% VIOLINPLOT  Make a violin plot
%   H = VIOLINPLOT(CODA, [TARGET]); where CODA is a coda structure and
%   TARGET is an optional regular expression, produces a violin plot of the
%   parameters matched by TARGET and returns a handle to the axes in H.
%   VIOLINPLOT(CODA, TARGET, ...) allows extra input arguments to be
%   passed along to the plotting functions.
% 
%  See also: TRACEPLOT, CATERPILLAR, AUCOPLOT, SMHIST
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
if nargin < 2
    if nargin < 1
        error_tag('trinity:violinplot:badInput', ...
            'Insufficient input to violinplot.')
    end
    target = '.';
else
    target = varargin{1};
end

colorOrder = get(0, 'DefaultAxesColorOrder');
set(0, 'DefaultAxesColorOrder', trinity_preferences('colororder'))

if isnumeric(coda)  % If user gave chains instead of coda structure
    violinplot_sub(coda, 1, varargin{:});
else  % Select fields by regular expression
    if ~isempty(varargin), varargin(1) = []; end
    [selection, n_sel] = select_fields(coda, target);
    if ~n_sel, return, end
    
%     hs = ishold();  % get hold status

    % Then loop over selected fields
    for parameter = 1:n_sel
        violinplot_sub(coda.(selection{parameter}), parameter, varargin{:});
        hold on
    end
    
    h = gca;
    set(findobj(h, 'Tag', 'violinplot:lines'), 'Ydata', ylim)  % stretch vertical lines
    set(h, 'XTick', 1:n_sel, 'XTickLabel', selection)
    ylabel value

%     if ~hs, hold off, end  % reset hold status
end

if nargout,  varargout = {h};  end
figure(gcf)  % focus figure
set(0, 'DefaultAxesColorOrder', colorOrder);

end

%% --------------------------------------------------------------------- %%
function violinplot_sub(x, number, varargin)

% First get smoothed densities for all chains
[py, px] = ksdensity(x(:));
py(py<.0005) = NaN;

% Scale distributions down
[ma_y, idx] = nanmax(py);
py_a_r =  .25 * py ./ ma_y + number;
py_a_l = -.25 * py ./ ma_y + number;

colors = get(0, 'DefaultAxesColorOrder');

% Draw distribution
line(py_a_r, px, 'color', colors(1,:), 'LineWidth', 2, varargin{:}, ...
    'marker', 'none', 'Tag', 'violinplot:distribution');
line(py_a_l, px, 'color', colors(1,:), 'LineWidth', 2, varargin{:}, ...
    'marker', 'none', 'Tag', 'violinplot:distribution');

% Draw vertical center line
line([1 1] * number, ylim, ...
    'color', 'k', 'linestyle', ':', 'Tag', 'violinplot:lines')

% Mark mean
line(number, mean(x), 'marker', 'o', ...
    varargin{:}, 'LineWidth', 2, ...
    'color', colors(2,:), 'Tag', 'violinplot:mean');

% Line for the mode
line([py_a_l(idx) py_a_r(idx)], [1 1] * px(idx), ...
    varargin{:}, 'color', colors(2,:), ...
    'LineWidth', 2, 'linestyle', '--', ...
    'marker', 'none', 'Tag', 'violinplot:mode');

end
