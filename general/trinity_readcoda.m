function out = trinity_readcoda(wdir, sfns, verbosity)
% TRINITY_READCODA  Reads a BUGS or JAGS CODA file to a MATLAB structure.
%   OUT = TRINITY_READCODA(FILENAME, [CHAIN NUMBER], [VARIABLE TO SKIP]), will
%   provide a structure OUT with fields .samples (containing a structure in 
%   which each field is a samples-by-chains matrix of a tracked parameter).
%
%   See also BUGS2CODA, JAGS2CODA, STAN2CODA.

if nargin < 3
    verbosity = 5;
end

indf = cellfun(@(x) fullfile(wdir, sprintf('%sindex.txt', x)), sfns, 'uni', 0);
codf = cellfun(@(x) fullfile(wdir, sprintf('%schain1.txt', x)), sfns, 'uni', 0);

if exist(indf{1}, 'file')
    [fid, stream] = robust_fopen(indf{1}, 'r');
else
    indf{1} = fullfile(wdir, sprintf('%sindex.txt', sfns{1}(1:end-1)));
    [fid, stream] = robust_fopen(indf{1}, 'r');
    codf = cellfun(@(x) fullfile(wdir, sprintf('%s.txt', x)), sfns, 'uni', 0);
end

while ~feof(fid)
    a = fscanf(fid, '%s', 1);
    a = strrep(a, '[', '_');
    a = strrep(a, ',', '_');
    a = strrep(a, ']', '');
    a = strrep(a, '.', '');
    b = fscanf(fid, '%i%i', 2);
    if ~isempty(a)
        index.(a) = b;
    end
end
delete(stream);

varnms = fieldnames(index);

for chain = 1:numel(codf)
    [fid, stream] = robust_fopen(codf{chain}, 'r');
    
    if verbosity>=1
        fprintf('Reading from chain %i - ', chain)
    end
    nb = 0;
    for ctr = 1:numel(varnms)
        if verbosity>=1
            fprintf([repmat('\b', 1, nb) varnms{ctr}])
        end
        nb = numel(varnms{ctr});
        nmx = diff(index.(varnms{ctr})) + 1;
        out.(varnms{ctr})(:,chain) = fscanf(fid, '%*i%f', nmx);
    end
    delete(stream);
    
    if verbosity>=1
        fprintf([repmat('\b', 1, nb) 'done.\n'])
    end
end
