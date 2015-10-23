function varargout = caterpillar(coda, varargin)
% CATERPILLAR  Make a caterpillar plot
%   H = CATERPILLAR(CODA, [TARGET]); where CODA is a coda structure and
%   TARGET is an optional regular expression, produces a caterpillar plot of the
%   parameters matched by TARGET and returns a handle to the axes in H.
%   CATERPILLAR(CODA, TARGET, ...) allows extra input arguments to be
%   passed along to the plotting functions.
% 
%  See also: VIOLINPLOT, TRACEPLOT, AUCOPLOT, SMHIST
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
sorted = false;
if nargin < 2
    if nargin < 1
        trinity.error_tag('trinity:caterpillar:badInput', ...
            'Insufficient input to caterpillar.')
    end
    target = '.';
else
    target = varargin{1};
    if nargin >= 3 && strcmp(varargin{2}, 'sort')
        sorted = true;
        varargin(2) = [];
    end        
end

colorOrder = get(0, 'DefaultAxesColorOrder');
set(0, 'DefaultAxesColorOrder', trinity.preferences('colororder'))

if isnumeric(coda)  % If user gave chains instead of coda structure
    caterpillar_sub(coda, 1, varargin{:});
else  % Select fields by regular expression
    if ~isempty(varargin), varargin(1) = []; end
    [selection, n_sel] = trinity.select_fields(coda, target);
    if ~n_sel, return, end
    
    hs = ishold();  % get hold status

    % Then loop over selected fields
    if ~sorted
        parlist = 1:n_sel;
    else
        [~, parlist] = sort(codatable(coda, target, @mean));
        parlist = reshape(parlist, 1, []);
    end
    for parameter = 1:numel(parlist)
        caterpillar_sub(coda.(selection{parlist(parameter)}), ...
            n_sel + 1 - (parameter), varargin{:});
        hold on
    end
    
    h = gca;
    
    set(h, 'YTick', 1:n_sel, 'YTickLabel', selection(parlist(end:-1:1)))
    ylim([0.5 n_sel + 0.5])
    if prod(xlim)<0
        line([0 0], ylim, 'color', 'k', 'linestyle', ':', ...
            'linewidth', 2)
    end
    xlabel value
    
    if ~hs, hold off, end  % reset hold status
end

if nargout,  varargout = {h};  end
figure(gcf)  % focus figure
set(0, 'DefaultAxesColorOrder', colorOrder);

end

%% --------------------------------------------------------------------- %%
function caterpillar_sub(x, number, varargin)

x = x(:);

colors = get(0, 'DefaultAxesColorOrder');

% Draw short line
line(trinity.prctile(x, [ 2.5 97.5]), [1 1] * number, ...
    'color', 'k', 'LineWidth', 3, varargin{:}, ...
    'Tag', 'caterpillar:shortlines')

% Draw long line
line(trinity.prctile(x, [ 0.5 99.5]), [1 1] * number, ...
    'color', colors(1,:), 'LineWidth', 1, varargin{:}, ...
    'linestyle', '-', ...
    'Tag', 'caterpillar:longlines')

% Mark mean
line(mean(x), number, ...
    'color',  colors(1,:), 'LineWidth', 2, ...
    'marker', 'x', 'markersize', 8, ...
    varargin{:}, ...
    'Tag', 'caterpillar:mean');

end
