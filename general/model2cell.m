function model_cell = model2cell(fileName)
% MODEL2CELL  Reads text file to cell string

[fid, stream] = robust_fopen(fileName, 'r');

ctr = 1;
while ~feof(fid)
    model_cell{ctr,1} = fgetl(fid); %#ok<*AGROW>
    ctr = ctr + 1;
end

delete(stream);