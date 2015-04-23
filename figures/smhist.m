function varargout = smhist(coda, varargin)
% SMHIST  Plot a smoothed histogram
%   H = SMHIST(CODA, [TARGET]); where CODA is a coda structure and TARGET
%   is an optional regular expression, produces a smoothed histogram of the 
%   parameters matched by TARGET and returns a handle to the axes in H. The
%   second element of H is a handle to an invisible Legend object.
%   SMHIST(CODA, TARGET, ...) allows extra input arguments to be passed
%   along to the containing axes.
% 
%  See also: VIOLINPLOT, TRACEPLOT, CATERPILLAR, AUCOPLOT
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
if nargin < 2
    if nargin < 1
        error_tag('trinity:smhist:badInput', ...
            'Insufficient input to smhist.')
    end
    target = '.';
else
    target = varargin{1};
end

colorOrder = get(0, 'DefaultAxesColorOrder');
set(0, 'DefaultAxesColorOrder', trinity_preferences('colororder'))

if isnumeric(coda)  % If user gave chains instead of coda structure
    [h, y, x] = smhist_sub(coda, 1, varargin{:});
else  % Select fields by regular expression
    if ~isempty(varargin), varargin(1) = []; end
    [selection, n_sel] = select_fields(coda, target);
    if ~n_sel, return, end
    
    hs = ishold();  % get hold status

    % Then loop over selected fields
    y = cell(1, n_sel);
    x = cell(1, n_sel);
    for parameter = 1:n_sel
        [~, y{parameter}, x{parameter}] = smhist_sub(coda.(selection{parameter}), parameter, varargin{:});
        hold on
        ylim([0 max(ylim * 1.4)])
    end
    h = [gca legend(selection{:})];
%     set(h(2), 'Visible', 'off', 'Tag', 'smhist:legend')
    ylabel value
    xlabel(target)

    if ~hs, hold off, end  % reset hold status
end

if nargout,  varargout = {h, y, x};  end
figure(gcf)  % focus figure
set(0, 'DefaultAxesColorOrder', colorOrder);

end

%% --------------------------------------------------------------------- %%
function [h, y, x] = smhist_sub(v, number, varargin)

% First get smoothed densities for all chains
v = v(:);
if all(v==fix(v))
    % parameter is discrete
    t = tabulate(v);
    x = t(:,1);
    y = t(:,3);
    h = bar(x, y, varargin{:});
    return
elseif all(v > 0) && all(v < 1)
    % assume parameter is bounded between 0 and 1
    [y, x] = ksdensity(v, 'support', [0 1]);
elseif all(v > 0)
    % assume parameter is bounded to be positive
    [y, x] = ksdensity(v, 'support', 'positive');
else
    [y, x] = ksdensity(v, 'npoints', 250);
end
% y(y < .0005) = nan;  % TODO: This line

% Figure out color
colororder = get(gca, 'ColorOrder');
color = colororder(mod(number - 1,size(colororder, 1)) + 1,:);

% Then plot
h = plot(x, y, 'color', color, 'LineWidth', 2, varargin{:}, ...
    'Tag', 'smhist:histogram');

end
