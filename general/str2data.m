function str2data(engine, varargin)
% STR2DATA  Write data file from structure
%
%   STR2DATA(ENGINE, DATAFILENAME, DATASTRUCT) writes the variables in 
%   DATASTRUCT to a file named DATAFILENAME in a format appropriate for
%   ENGINE.
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

% Force input into data structure
[filename, datastr] = trinity_string2datastruct(varargin{:});

% Sort field names by number of data points (makes the file more human-readable)
[~, idx] = sort(structfun(@(x)numel(x).*(~ischar(x)), datastr));
fn = fieldnames(orderfields(datastr, idx));

% Select correct grammar
switch lower(engine)
    case 'bugs'
        writeaway = @writeaway_b;
        codeprefix = 'list(';
        delimiter = ',';
        tag = sprintf(')\n\n# This file was written for WinBUGS by %s on %s.\n', ...
            upper(mfilename), datestr(now));
    case 'jags'
        writeaway = @writeaway_s;
        codeprefix = '';
        delimiter = '\n';
        tag = sprintf('\n\n# This file was written for JAGS by %s on %s.\n', ...
            upper(mfilename), datestr(now));
    case 'stan'
        writeaway = @writeaway_s;
        codeprefix = '';
        delimiter = '\n';
        tag = sprintf('\n\n# This file was written for Stan by %s on %s.\n', ...
            upper(mfilename), datestr(now));
    otherwise
        error_tag('trinity:str2data:unknownEngine', ...
            'Unknown engine "%s".', engine)
end

% Incrementally build ascii variable
code = codeprefix;
for c = 1:numel(fn) %#ok<*AGROW> 
    str = writeaway(datastr.(fn{c}), fn{c});  % make variable into string
    if c==1
        code = [code, str]; % add first field
    elseif c<=numel(fn)
        code = [code, delimiter, str]; % subsequent fields need delimiter
    end
end

% For bookkeeping
code = [code, tag];

% Copy-to-clipboard option instead of writing file
if (strcmp(filename, 'c-')||strcmp(filename, '-c'))
    clipboard('copy', code)
    disp 'Data copied to clipboard.'
else
    [fid, stream] = robust_fopen(filename, 'wt');
    fprintf(fid, code);
    delete(stream);
end


%% --------------------------------------------------------------------- %%
function str = writeaway_s(x,varnm)
% WRITEAWAY_S  Produces string variable suitable for STR2JAGS and STR2STAN

% Decide if we're writing integers and choose smart fprintf flag
isint = islogical(x(:)) || all((round(x(:))==x(:)|isnan(x(:))));
if isint
    fl = '%i'; 
else
    fl = '%f'; 
end

% Poorly documented feature: Force collection operator c() on scalar
% variables whose name starts with COLOP_. Helps to get JAGS do vector
% operations (such as indexing) even if scalars involved.
forceColop = numel(varnm)>10 && strcmp(varnm(1:10), 'AS_VECTOR_');
forceMatop = numel(varnm)>10 && strcmp(varnm(1:10), 'AS_MATRIX_');
if forceColop || forceMatop
    varnm(1:10) = [];
end

if ischar(x)
    str = sprintf('"%s" <- %s', varnm, x);
elseif isempty(x) % Decide on dimensionality
    warning('trinity:writeaway_s:emptyvar',...
        'Variable "%s" was empty. Not writing anything.', varnm )
    str = '';
elseif isscalar(x) 
    % scalar
    if forceColop
        str = sprintf(sprintf('"%%s" <-\nc(%s)', fl), varnm, x);
    elseif forceMatop
        str = [sprintf('"%s" <-\nstructure(c(', varnm), ...
            sprintf(sprintf('%s)', fl), x), ...
            sprintf(',.Dim=c(%i,%i))', size(x))];
    else
        str = sprintf(sprintf('"%%s" <-\n%s', fl), varnm, x);
    end
elseif isvector(x)
    % vector
    if forceMatop
        str = [sprintf('"%s" <-\nstructure(c(', varnm), ...
            sprintf(sprintf('%s,', fl), x(1:end-1)), ...
            sprintf(sprintf('%s)', fl), x(end)), ...
            sprintf(',.Dim=c(%i,%i))', size(x))];
    else
        str = [sprintf('"%s" <-\nc(', varnm), ...
            sprintf(sprintf('%s,', fl), x(1:end-1)), ...
            sprintf(sprintf('%s)', fl), x(end))];
    end
elseif ismatrix(x)
    % 2D matrix
    str = [sprintf('"%s" <-\nstructure(c(', varnm), ...
        sprintf(sprintf('%s,', fl), x(1:end-1)), ...
        sprintf(sprintf('%s)', fl), x(end)), ...
        sprintf(',.Dim=c(%i,%i))', size(x))];
elseif ~ismatrix(x)
    % ND matrix
    sz = size(x); 
    str = [sprintf('"%s" <-\nstructure(c(', varnm), ...
        sprintf(sprintf('%s,', fl), x(1:end-1)), ...
        sprintf(sprintf('%s)', fl), x(end)), ...
        sprintf(',.Dim=c(%i%s))', ...
        sz(1), num2str(sz(2:end), ',%i'))];
end

% Fix special variable RNG_seed__
str = strrep(str, 'RNG_seed__', '.RNG.seed');
str = strrep(str, 'RNG_name__', '.RNG.name');

% Fix NaNs and turn _ into . per policy
str = strrep(str, 'NaN', 'NA');
str = strrep(str, '_', '.');

% Get rid of unnecessary trailing zeros
if ~isint
    % save dimension vectors from zero culling
    olddim = str(strfind(str, '.Dim'):end);
    for a = 1:5
        str = strrep(str,'0,', ',');
        str = strrep(str,'0)', ')');
    end
    str(strfind(str,'.Dim'):end) = [];
    str = [str, olddim];
end


%% --------------------------------------------------------------------- %%
function str = writeaway_b(x, varnm)
% WRITEAWAY_B  Produces string variable suitable for STR2BUGS

% Decide if we're writing integers and choose smart fprintf flag
isint = islogical(x(:)) || all((round(x(:))==x(:)|isnan(x(:))));
if isint
    fl = '%i'; 
else
    fl = '%f'; 
end

if ischar(x)
    str = sprintf('%s = %s', varnm, x);
elseif isempty(x) % Decide on dimensionality
    warning('trinity:writeaway_b:emptyvar',...
        'Variable "%s" was empty. Not writing.', varnm )
    str = '' ;
elseif isscalar(x)
    % scalar
    str = sprintf(sprintf('%%s=%s', fl), varnm, x);
elseif isvector(x)
    % vector
    str = [sprintf('%s=c(', varnm), ...
    sprintf(sprintf('%s,', fl), x(1:end-1)), ...
    sprintf(sprintf('%s)', fl), x(end))];
elseif ismatrix(x)
    % 2D matrix
    x = x';
    str = [sprintf('%s=structure(.Data=c(',varnm), ...
        sprintf(sprintf('%s,', fl), x(1:end-1)), ...
        sprintf(sprintf('%s)', fl), x(end)), ...
        sprintf(',.Dim=c(%i,%i))', size(x, 2), size(x, 1))];
elseif ~ismatrix(x)
    % N-D matrix
    sz = size(x);
    x = permute(x, [2 1 3:ndims(x)]) ;
    str = [sprintf('%s=structure(.Data=c(', varnm),...
        sprintf(sprintf('%s,', fl), x(1:end-1)),...
        sprintf(sprintf('%s)', fl), x(end)),...
        sprintf(',.Dim=c(%i,%i%s))', sz(2), sz(1), sprintf(',%i', sz(3:end)))];
end

% Fix special variable RNG_seed__
str = strrep(str, 'RNG_seed__', '.RNG.seed');
str = strrep(str, 'RNG_name__', '.RNG.name');

% Fix NaNs and turn _ into . per policy
str = strrep(str, 'NaN', 'NA');
str = strrep(str, '_', '.');

% Get rid of unnecessary trailing zeros
if ~isint
    % save dimension vectors from zero culling
    olddim = str(strfind(str, '.Dim'):end);
    for a=1:5
        str = strrep(str, '0,', ',');
        str = strrep(str, '0)', ')');
    end
    str(strfind(str, '.Dim'):end) = [];
    str = [str, olddim];
end
