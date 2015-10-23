function trinity(cmd)
% TRINITY  Begin the Trinity experience
%    Try:
%      > trinity install
%      > trinity new

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

if ~nargin
    help('trinity')
end

switch cmd
    case 'install'
        % You can place trinity_install() in a startup script for silent
        % install at MATLAB boot
        trinity silent
        disp 'Trinity install complete.'
    case 'silent'
        % You can place call trinity('silent') in a startup script for silent
        % install at MATLAB boot
        trindir = fileparts(mfilename('fullpath'));
        subf = {'' 'general' 'codatools' 'figures' 'demos'};
        list = cellfun(@(x)fullfile(trindir, x), subf, 'uni', 0);
        addpath(list{:});
    case 'new'
        name = '';
        while ~isvarname(name)
            name = input('Give your new project a name: ', 's');
            if ~isvarname(name)
                disp('Not a valid name. Please begin with [a-Z] and use only [a-Z,0-9].')
            end
        end
        trinity.new(name)
    case 'test'
        n = 0;
        while ~ismember(n, 1:3)
            n = input('Which engine would you like to test?\n[1] WinBUGS\n[2] JAGS\n[3] Stan\n  : ');
            if ~ismember(n, 1:3)
                disp('Not a valid options. Please choose [1-3].')
            end
        end
        list = {'bugs' 'jags' 'stan'};
        trinity.test(list{n})
    case 'help'
        help('trinity')
    otherwise
        error('trinity:trinity:unknownCommand', ...
            'Allowed commands are "install", "silent", "new", "test", "help".')
end
 