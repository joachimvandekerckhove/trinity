function [filename, datastr] = trinity_string2datastruct(varargin)
% TRINITY_STRING2DATASTRUCT  Parses string input to data structure

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

filename = varargin{1};

if nargin==2 && isstruct(varargin{2})
    datastr = varargin{2};    
else
    if all(cellfun(@ischar, varargin(2:end)))
        for xx = 2:nargin
            datastr.(varargin{xx}) = ...
                evalin('caller', varargin{xx});
        end
    else
        for xx = 2:2:nargin
            datastr.(varargin{xx}) = varargin{xx+1};
        end
    end
end


