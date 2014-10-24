function [str out] = structural(coda,cmd)
% STRUCTURAL  Add a structural parameter to a coda structure
%  Compute a structural parameter inside a coda structure. STRUCTURAL takes
%  two input variables: a coda structure, and a string containing a valid
%  MATLAB command to form a structural parameter.
%
%    [STR OUT] = STRUCTURAL(CODA,CMD), where CODA is an array of coda
%    structures and CMD is a valid MATLAB command, returns STR, an array of
%    extended coda structures and OUT, a cell array with output from CMD.
%
%  Example:
%    >> coda = [struct('a',4,'b',3) struct('a',1.5,'b',2)];
%    >> [str out] = structural(coda,'c = a*b');
%    >> str(1)
%    ans = 
%        a: 4
%        b: 3
%        c: 12
% 
%  Restriction:
%    The input coda structure cannot contain fields that start with
%    'do_not_call_your_fields_this_'.

if iscell(coda)
    for f = numel(coda):-1:1
        [str{f} out{f}] = structural_internal(coda{f},cmd);
    end
else
    for f = numel(coda):-1:1
        [str(f) out{f}] = structural_internal(coda(f),cmd);
    end
end

function [do_not_call_your_fields_this_structure ...
    do_not_call_your_fields_this_output] = ...
    structural_internal(do_not_call_your_fields_this_structure,...
    do_not_call_your_fields_this_command)

if ~isempty(do_not_call_your_fields_this_structure)
    unravel(do_not_call_your_fields_this_structure)
    do_not_call_your_fields_this_output = ...
        evalc(do_not_call_your_fields_this_command);
    do_not_call_your_fields_this_structure = rmfield(wrap(whos),...
        {'do_not_call_your_fields_this_structure'
        'do_not_call_your_fields_this_command'
        'do_not_call_your_fields_this_output'});
else
    do_not_call_your_fields_this_output = 'No changes made to empty input';
end

function unravel(w)
fls = fieldnames(w);
for f = 1:numel(fls)
    assignin('caller',fls{f},w.(fls{f}))
end

function do_not_call_your_fields_this_structure = wrap(d)

v = {d.name};
for f = 1:numel(v)
    do_not_call_your_fields_this_structure.(v{f}) = ...
        evalin('caller',v{f});
end

