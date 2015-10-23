function varargout = unit_test(cmd, varargin)
% UNIT_TEST Provide unit tests for Trinity functions

try
    try
        [~, varargout{1}] = evalc('cmd(varargin{:})');
    catch  %#ok<CTCH>
        evalc('cmd(varargin{:})');
    end
    fprintf('|  * Succesfully completed %-27s |\n', ...
        upper(func2str(cmd)));
catch me
    disp(me)
    disp(me.message)
    keyboard
end

close all
