function varargout = codatable(coda, varargin)
% CODATABLE  Print a table with custom posterior statistics
%   MTX = CODATABLE(CODA, [TARGET], [FUNCTIONS...]); where CODA is a coda
%   structure, TARGET is an optional regular expression, and FUNCTIONS...
%   is a list of function handles, produces MTX, a matrix or cell matrix of
%   the result of each function applies to each parameter matched by
%   TARGET.
% 
%  See also: GRTABLE, CSTATS, GETMATRIXFROMCODA
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Check input
[coda, target, func_list] = parseInput(coda, varargin{:});

% Select fields by regular expression
[selection, n_sel] = select_fields(coda, target);

% Then loop over selected fields
mtx = cell(n_sel, numel(func_list));
for parameter = 1:n_sel
    mtx(parameter,:) = codaLine(coda.(selection{parameter}), func_list);
end

% Format output
if nargout  % if output was requested
    if all(cellfun(@isNumber,mtx(:)))  % one matrix
        varargout{1} = cell2mat(mtx);
    else
        varargout{1} = mtx;  % non-numeric input, so cell
    end
    if nargout > 1
        varargout{2} = selection;
        if nargout > 2
            varargout{3} = cellfun(@func2str, func_list, 'uni', 0);
        end
    end
else  % print
    printCell(mtx, selection, func_list);
end

end


%% --------------------------------------------------------------------- %%
function out = codaLine(x, func_list)

evaluatesOnMatrix = {'gelmanrubin', 'Rhat', 'n_eff'};
nfn = numel(func_list);
out = cell(nfn, 1);

for p = 1:nfn
    if ismember(func2str(func_list{p}), evaluatesOnMatrix)
        out{p} = func_list{p}(x);
    else
        out{p} = func_list{p}(x(:));
    end
end

end


%% --------------------------------------------------------------------- %%
function [w, target, func_list] = parseInput(coda, varargin)

switch nargin
    case 0
        error_tag('trinity:codatable:parseInput:insufficientInput', ...
            'Insufficient input to codatable.')
    case 1
        target = '.';
        func_list = {@mean @std @plt0};
    case 2
        if isa(varargin{1}, 'char')
            target = varargin{1};
            func_list = {@mean @std @plt0};
        elseif isa(varargin{1},'function_handle')
            target = '.';
            func_list = varargin;
        else
            error_tag('trinity:codatable:parseInput:badInput1', ...
                'Second argument to codatable was of illegal type "%s".', ...
                class(varargin{1}))
        end
    otherwise
        if isa(varargin{1}, 'char')
            target = varargin{1};
        else
            error_tag('trinity:codatable:parseInput:badInput2', ...
                'Second argument to codatable was of illegal type "%s".', ...
                class(varargin{1}))
        end
        func_list = varargin(2:end);
        if ~all(cellfun(@(x)isa(x,'function_handle'), func_list))
            error_tag('trinity:codatable:parseInput:badInput3', ...
                'Final arguments to codatable must be function handles.')
        end
end

if isNumber(coda) % If user gave chains instead of coda structure
    w.parameter = coda;
    target = 'parameter';
elseif isstruct(coda)
    w = coda;
elseif ischar(coda) % If user tried command syntax
    if length(dbstack)==2
        w = evalin('base', coda);
    else
        error_tag('trinity:codatable:parseInput:noCommandSyntac', ...
            'Command syntax for codatable is only valid from the command line.')
    end
else
    error_tag('trinity:codatable:parseInput:badInput4', ...
        'First argument to codatable must be coda structure or matrix.')
end

end


%% --------------------------------------------------------------------- %%
function v = plt0(x)

v = mean(x(:)<0);

end


%% --------------------------------------------------------------------- %%
function v = isNumber(x)

v = isnumeric(x) | islogical(x);

end


%% --------------------------------------------------------------------- %%
function printCell(mtx, selection, func_list)

% Construct output
fnames = cellfun(@func2str, func_list, 'uni', 0);
mtx = [{'Estimand'} fnames(:)'
       selection(:) mtx];

% Determine data types
i_isstr = cellfun(@ischar, mtx(2,:));
i_isnum = cellfun(@isNumber, mtx(2,:));
i_islgc = cellfun(@islogical, mtx(2,:));

if ~all(i_isstr|i_isnum)
    f = find(~all(i_isstr|i_isnum), 1, 'first');
    error_tag('trinity:codatable:unknownOutputType', ...
        'Printing of variables of type %s is not implemented.', ...
        class(mtx(2,f)))
end

% Determine column formats
nfn = size(mtx, 2);
fmt = cell(1, nfn);
fmt_header = cell(1, nfn);

i_isint = false(size(i_isnum));
if any(i_isnum)
    for ctr = 1:nfn
        if i_isnum(ctr)
            if all(cellfun(@(x)x==fix(x), mtx(2:end,ctr)))
                i_isint(ctr) = true;
            end
        end
    end
end

for p = 1:nfn
    if i_isnum(p)
        ln = num2str(max(length(mtx{1,p}) + 2, 10));
        if i_islgc(p)
            fmt{p} = ['%' ln 'g'];
        elseif i_isint(p)
            fmt{p} = ['%' ln 'i'];
        else
            fmt{p} = ['%' ln '.4f'];
        end
        fmt_header{p} = ['%' ln 's'];
    else
        ln = num2str(max(cellfun(@length,[selection(p);mtx(:,p)])) + 2);
        fmt{p} = ['%' ln 's'];
        fmt_header{p} = fmt{p};
    end
end

% Print
mtx = mtx';
fprintf([fmt_header{:} '\n'], mtx{:,1})
fprintf([fmt{:} '\n'], mtx{:,2:end})

end
