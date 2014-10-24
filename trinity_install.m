function trinity_install()
% TRINITY_INSTALL  Install Trinity (i.e., add files to path)
%  TRINITY_INSTALL adds the folder in which it resides and all its
%  subfolders to the MATLAB path.

addpath(genpath(fileparts(mfilename('fullpath'))))
