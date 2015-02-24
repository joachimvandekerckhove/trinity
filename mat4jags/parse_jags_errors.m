function feedbackStr = parse_jags_errors(options, result)
% PARSE_JAGS_ERRORS  Give intelligent feedback on JAGS errors

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

model          = options.model          ;

findSyntax = strfind(result, 'syntax error on line'); 
findCompil = strfind(result, 'Compilation error on line'); 
findMismat = strfind(result, 'Dimension mismatch in values supplied for'); 
findIncons = strfind(result, 'Observed node inconsistent with unobserved parents at initialization.');
findIdxoor = strfind(result, 'Index out of range for'); 
findUnexpe = strfind(result, 'unexpected ENDDATA, expecting ENDCMD');
findNoncon = strfind(result, 'Non-conforming parameters in function');
nojags     = strfind(result, 'jags: command not found');

if ~isempty(nojags)
    errorCase = 0;
elseif ~isempty(findSyntax)
    errorCase = 1;
elseif ~isempty(findCompil)
    errorCase = 2;
elseif ~isempty(findMismat)
    errorCase = 3;
elseif ~isempty(findIdxoor)
    errorCase = 4;
elseif ~isempty(findUnexpe)
    errorCase = 5;
elseif ~isempty(findIncons)
    errorCase = 6;
elseif ~isempty(findNoncon)
    errorCase = 7;
else
    feedbackStr = sprintf(['%%\n' ...
                           '%% No JAGS syntax errors found.\n' ...
                           '%% I don''t know what''s going on.\n' ...
                           '%% Probably a human should read the JAGS output above.\n' ...
                           '%%\n']);
    return
end

modelCell = model2cell(model);

switch errorCase
    case 0
        feedbackStr = sprintf('%%\n%% JAGS was not found!\n%%');
        return

    case 1
        findSyntax = findSyntax(end);
        
        syntaxLine = result(findSyntax:end);
        syntaxLine(1) = 'S';
        
        lineBreak = find(double(syntaxLine)==10, 1, 'first');
        errorMessage = strtrim(syntaxLine(1:lineBreak));
        spaces = find(errorMessage(21:end)==' ');
        lineNumber = str2double(strtrim(errorMessage(22+(0:spaces(1)))));

        if lineNumber > numel(modelCell)
            errorMessage = sprintf('%s (missing bracket?)', ...
                errorMessage);
            lineNumber = 1;
        end
        
    case 2
        findCompil = findCompil(end);
        
        compilLine = result(findCompil:end);
        
        lineBreak = find(double(compilLine)==10, 1, 'first');
        errorMessage = strtrim(compilLine(1:lineBreak));
        spaces = find(errorMessage(26:end)==' ');
        lineNumber = str2double(strtrim(errorMessage(27+(0:spaces(1)))));
        errorMessage(end) = [];
        
    case {3 6}
        feedbackStr = sprintf('%%\n%% Error is in initial values file!\n%%');
        return
        
    case 4
        feedbackStr = sprintf('%%\n%% Error is in indexing!\n%%');
        return

    case 5
        feedbackStr = sprintf('%%\n%% Is the generator empty?\n%%');
        return
        
    case 7
        feedbackStr = sprintf('%%\n%% Do matrix sizes match for multiplication?\n%%');
        return
        
end


feedbackStr = '';
feedbackStr = sprintf('%s |\n', feedbackStr);
feedbackStr = sprintf('%s | %s:\n', feedbackStr, errorMessage);
feedbackStr = sprintf('%s |\n', feedbackStr);
for ctr = 1:numel(modelCell)
    feedbackStr = sprintf('%s | ', feedbackStr);
    if ctr==lineNumber
        notSpace = find(modelCell{ctr}~=' ', 1, 'first');
        feedbackStr = sprintf('%s%s<a href="matlab:edit(''%s'')">%s</a>\n', ...
            feedbackStr, repmat(' ', 1, notSpace+5), ...
            model, strtrim(modelCell{ctr}));
    else
        feedbackStr = sprintf('%s      %s\n', feedbackStr, modelCell{ctr});
    end
end
feedbackStr = sprintf('%s |\n', feedbackStr);
