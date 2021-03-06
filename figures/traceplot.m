function varargout = traceplot(coda, varargin)
% TRACEPLOT  Make a trace plot
%   H = TRACEPLOT(CODA, [TARGET]); where CODA is a coda structure and 
%   TARGET is an optional regular expression, produces a trace plot of the
%   parameters matched by TARGET and returns a handle to the axes in H.
%   TRACEPLOT(CODA, TARGET, ...) allows extra input arguments to be
%   passed along to the containing axes.
% 
%  See also: VIOLINPLOT, CATERPILLAR, AUCOPLOT, SMHIST
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
if nargin < 2
    if nargin < 1
        trinity.error_tag('trinity:traceplot:badInput', ...
            'Insufficient input to traceplot.')
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
    traceplot_sub(coda, 'parameter', varargin{:})
else  % Select fields by regular expression
    varargin(1) = [];
    [selection, n_sel] = trinity.select_fields(coda, target);
    % Then loop over selected fields
    h = zeros(n_sel, 1);
    for parameter = 1:n_sel
        if n_sel>1, figure(), end
        traceplot_sub(coda.(selection{parameter}), ...
            selection{parameter}, varargin{:})
        h(parameter) = gca;
    end
end

if nargout,  varargout = {h};  end
figure(gcf)  % focus figure
set(0, 'DefaultAxesColorOrder', colorOrder);

end

%% --------------------------------------------------------------------- %%
function traceplot_sub(x, name, varargin)

plot(x, varargin{:}, 'Tag', 'traceplot:lines')

ylabel(name,'interpreter','none')
xlabel('sample','interpreter','none')

end
