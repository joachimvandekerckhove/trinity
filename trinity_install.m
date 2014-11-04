function trinity_install()
% TRINITY_INSTALL  Add Trinity folders to path
%  TRINITY_INSTALL adds the folder in which it resides and all its
%  subfolders to the MATLAB path.

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

addpath(genpath(fileparts(mfilename('fullpath'))))
