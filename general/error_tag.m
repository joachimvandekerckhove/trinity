function error_tag(tag, msg, varargin)
% ERROR_TAG  Throw error message and print error tag

error(tag, [msg '\nError tag is:  %s\n'], varargin{:}, tag);