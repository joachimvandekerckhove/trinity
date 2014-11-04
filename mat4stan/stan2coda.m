function out = stan2coda(options)
% STAN2CODA  Read Stan output into a MATLAB structure
%   OUT = STAN2CODA(OPTIONS); where OPTIONS is an options structure that contains
%   at least the field .coda_files, will provide a structure OUT with fields
%   .samples (containing a structure in which each field is a samples-by-chains
%   matrix of a tracked parameter), .tuning (containing a similar structure for
%   the tuning parameters lp__, step_size, etc.), and .info (containing the
%   header information).
%   
%   Also valid is OUT = STAN2CODA(CODA_FILES); where CODA_FILES is a cell matrix
%   of coda file names to process.
%
%   See also: BUGS2CODA, JAGS2CODA, TRINITY_READCODA

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if isstruct(options)
    coda_files = options.coda_files  ;
elseif iscell(options)
    coda_files = options             ;
else
    error_tag('trinity:stan2coda:badInput', ['STAN2CODA accepts as input either an' ...
        ' options structure or a cell list of coda file names.'])
end

% Find all header lines
if ~exist(coda_files{1}, 'file')
    error_tag('trinity:stan2coda:stansamplesfilemissing', ...
        'Samples file %s not found. Bailing out.', coda_files{1})
end

[fid, stream] = robust_fopen(coda_files{1}, 'r');

nheaderlines = 0;
info = [];
alllabels = [];
while ~feof(fid)
    buffer = fgetl(fid);
    if numel(buffer)==0
        continue
    elseif ~isnan(str2double(strtok(buffer, ',')))  % hit a number, progress to next stage
        break;
    elseif length(buffer) > 3 && strcmp(buffer(1:4), 'lp__')  % process labels
        ctr = 1;
        while ~isempty(buffer)
            [alllabels{ctr}, buffer] = strtok(buffer, ','); 
            ctr = ctr + 1;
        end
        alllabels = cellfun(@(x)strrep(x, '.', '_'), alllabels, 'uni', 0);
        alllabels = genvarname(alllabels);
    elseif buffer(1) == '#'  % process info
        buffer(1) = [];
        if any(buffer=='=')
            [fnm, buffer] = strtok(buffer, '=');
            fnm = strtrim(fnm); 
            fnm(fnm==' ') = '_';
            buffer(1) = [];
            info.(genvarname(fnm)) = buffer;
        end
    end
    nheaderlines = nheaderlines + 1;  % increment head count
end
delete(stream);

if isempty(alllabels)
    error_tag('trinity:stan2coda:stansamplesmissing', ...
        'Samples file %s contains no samples. Bailing out.', coda_files{1})
end

nchains = numel(coda_files);
is_tuning = false(size(alllabels));
for idx = 1:nchains
    fn = coda_files{idx};
    
    % Read in data
    A = importdata(fn, ',', nheaderlines);
    for p = 1:numel(alllabels)
        if length(alllabels{p}) >=2 && ...
                strcmp(alllabels{p}(end-1:end), '__')
            tuning.chain.(alllabels{p})(:,idx) = A.data(:,p);
            is_tuning(p) = true;
        else
            samples.(alllabels{p})(:,idx) = A.data(:,p);
        end
    end
end

% Providing tuning data
for p = 1:numel(alllabels)
    if is_tuning(p)
        tuning.mean.(alllabels{p}) = mean(tuning.chain.(alllabels{p}));
        tuning.std.(alllabels{p}) = std(tuning.chain.(alllabels{p}));
    end
end

out.samples = samples;
out.tuning = tuning;
out.info = info;
