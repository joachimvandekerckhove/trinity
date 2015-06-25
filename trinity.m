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
        trinity_install()
        disp 'Trinity install complete.'
    case 'new'
        % You can use the functional form "trinity_new <name>" to avoid the
        % interactive function
        name = '';
        while ~isvarname(name)
            name = input('Give your new project a name: ', 's');
            if ~isvarname(name)
                disp('Not a valid name. Please begin with [a-Z] and use only [a-Z,0-9].')
            end
        end
        trinity_new(name)
    case 'help'
        help('trinity')
    otherwise
        error('trinity:trinity:unknownCommand', ...
            'Allowed commands are "install", "new", "help".')
end
