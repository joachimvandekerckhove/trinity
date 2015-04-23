function varargout = aucoplot(coda, varargin)
% AUCOPLOT  Make an autocorrelation plot
%   H = AUCOPLOT(CODA, [TARGET]); where CODA is a coda structure and
%   TARGET is an optional regular expression, produces an autocorrelation
%   plot of the parameters matched by TARGET and returns a handle to the
%   axes in H.
%   AUCOPLOT(CODA, TARGET, ...) allows extra input arguments to be
%   passed along to the containing axes.
% 
%  See also: VIOLINPLOT, TRACEPLOT, CATERPILLAR, SMHIST
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
if nargin < 2
    if nargin < 1
        error_tag('trinity:aucoplot:badInput', ...
            'Insufficient input to aucoplot.')
    end
    target = '.';
else
    target = varargin{1};
end

colorOrder = get(0, 'DefaultAxesColorOrder');
set(0, 'DefaultAxesColorOrder', trinity_preferences('colororder'))

maxlag = 40; % number of lags to display

if isnumeric(coda) % If user gave chains instead of coda structure
    figure()
    h = axes();
    aucoplot_sub(coda, 'parameter', maxlag, varargin{:})
else  % Select fields by regular expression
    varargin(1) = [];
    [selection, n_sel] = select_fields(coda, target);
    % Then loop over selected fields
    h = zeros(n_sel, 1);
    for parameter = 1:n_sel
        if n_sel>1, figure(), end
        h(parameter) = aucoplot_sub(coda.(selection{parameter}), ...
            selection{parameter}, maxlag, varargin{:});
    end
end

if nargout,  varargout = {h};  end
figure(gcf)  % focus figure
set(0, 'DefaultAxesColorOrder', colorOrder);

end

%% --------------------------------------------------------------------- %%
function h = aucoplot_sub(x, name, maxlag, varargin)

nc = size(x, 2);
X = zeros(maxlag + 1, nc);
for c = 1:nc
    X(:,c) = auco(x(:,c), maxlag);
end

% Make plot as bar chart
bar(X, varargin{:}, 'Tag', 'aucoplot:bar');

xlabel('lag')
ylabel('autocorrelation')
title(name, 'interpreter', 'none')
axis([1 maxlag -1 1])

h = gca;

end

%% --------------------------------------------------------------------- %%
function r = auco(x, maxlag)

n = 2^(nextpow2(length(x)) + 1);    % length of vector
F = fft(x - mean(x), n);            % detrend, pad, and fft
r = ifft(F .* conj(F));             % conjugate, multiply, and ifft
r = real(r(1:maxlag + 1) ./ r(1));  % trim, scale, remove imaginary

end