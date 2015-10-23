function [fields, n_sel] = select_fields(coda, target)
% SELECT_FIELDS  Returns list of fields that match a regular expression

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

fields = fieldnames(coda);

match = @(x)~isempty(regexp(x, target, 'once'));

sel = cellfun(match, fields);

fields = fields(sel);

n_sel = sum(sel);
if ~n_sel
    warning('trinity:select_fields:noMoreFields', ...
        'No fields match regular expression "%s". To match any field, use ''.''.', target)
end