function c = trinity_move_to_wdir(options)
% TRINITY_MOVE_TO_WDIR  Move to working directory with return handle
%  C = TRINITY_MOVE_TO_WDIR(OPTIONS) changes the current directory to the
%  working directory specified in the OPTIONS structure and returns C, an
%  onCleanup object that will cause MATLAB to return to the previous
%  directory on being deleted.

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

origindir = pwd;
c = onCleanup(@()cd(origindir));

cd(options.workingdir)
