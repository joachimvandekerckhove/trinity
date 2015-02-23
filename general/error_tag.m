function error_tag(tag, msg, varargin)
% ERROR_TAG  Throw error message and print error tag

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

throwAsCaller(MException(tag, ...
    [msg '\n * Error tag: {%s}'], varargin{:}, tag));