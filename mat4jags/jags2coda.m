function out = jags2coda(options)
% JAGS2CODA  Reads JAGS samples file into a MATLAB CODA structure.
%   OUT = JAGS2CODA(OPTIONS); where OPTIONS is an options structure that contains
%   at least the field .coda_files, will provide a structure OUT with fields
%   .samples (containing a structure in which each field is a samples-by-chains
%   matrix of a tracked parameter).
%   
%   Also valid is OUT = JAGS2CODA(CODA_FILES); where CODA_FILES is a cell matrix
%   of coda file names to process.
%
%   See also BUGS2CODA, STAN2CODA, TRINITY_READCODA.

if isstruct(options)
    coda_files = options.coda_files  ;
    workingdir = options.workingdir  ;
    verbosity  = options.verbosity   ;
elseif iscell(options)
    coda_files = options  ;
    workingdir =       '' ;
    verbosity  =       0  ;
else
    error('trinity:jags2coda:badInput', ['JAGS2CODA accepts as input either an' ...
        ' options structure or a cell list of coda file names.'])
end

out = trinity_readcoda(workingdir, coda_files, verbosity);
