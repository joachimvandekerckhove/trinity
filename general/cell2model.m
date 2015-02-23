function cell2model(model_cell, filename)
% CELL2MODEL  Writes cell string to text file

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

[fid, stream] = robust_fopen(filename, 'w');

for r = 1:numel(model_cell)
    fprintf(fid, '%s\n', model_cell{r});
end
fprintf(fid, '\n# File written by %s on %s', ...
    upper(mfilename), datestr(now));
fprintf(fid, '\n# Do not edit -- changes will be overwritten!\n');

delete(stream);