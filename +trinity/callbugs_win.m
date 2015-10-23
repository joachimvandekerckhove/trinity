function options = callbugs_win(options)
% CALLBUGS_WIN  [Not yet implemented] Executes a call to WinBUGS on Windows
%   CALLBUGS_WIN will execute a call to JAGS. Supply a set of options
%   as a structure. See the Trinity manual for a list of options.
%   
%    See also: CALLBAYES
%

% (c) 2013- Joachim Vandekerckhove. See license.txt for licensing information.

% This function is a Trinity wrapper for matbugs.
% matbugs due to Maryam Mahdaviani and Kevin Murphy

% 'nChains'  - number of chains [3]
nChains    = options.nchains ;

% 'nBurnin'  - num samples for burn-in per chain [1000]
nBurnin    = options.nburnin ;

% 'nSamples' - num samples to keep after burn-in [5000]
nSamples   = options.nsamples ;

% 'thin'     - keep every n'th step [1]
thin       = options.thin     ;

% 'init' - init(i).v is a struct containing initial values for variable 'v'
%          for chain i.  Uninitialized variables are given random initial
%          values by WinBUGS.  It is highly recommended that you specify the
%          initial values of all root (founder) nodes.
init = options.init;
% for ch = 1:nChains
%     init(ch) = options.generator(); %#ok<AGROW>
% end

% 'monitorParams' - cell array of field names (use 'a_b' instead of 'a.b')
%                   [defaults to *, which currently does nothing...]
monitorParams = options.monitorparams;

% 'view'     - set to 1 if you want to view WinBUGS output (then close the WinBUGS
%                window to return control to matlab)
%              set to 0 to close WinBUGS automatically without pausing [default 0]
view = 0;

% 'openBugs' - set to 1 to use openBugs file format [0]
openBugs = 0;

% 'Bugdir'   - location of winbugs executable
%               Default is 'C:/Program Files/WinBUGS14' if not openBugs
%               Default is 'C:/Program Files/OpenBUGS' if OpenBugs.
Bugdir = trinity.preferences('bugs_main_dir');

% 'workingDir' - directory to store temporary data/init/coda files [pwd/tmp]
options.workingdir = trinity.get_full_path(options.workingdir);
workingDir = options.workingdir;

% 'DICstatus' - takes value 1 to set the DIC tool and 0 otherwise
DICstatus = 0;

% 'refreshrate' - sets the refresh rate for the updater. Default is 100. Values
%               of 10 prevent the computer from hanging too much if the model
%               is very slow to run.
refreshrate = options.refresh;

% store two copies of the model file (wdir\*.bugs and *.bugs.txt)
bugsModel = options.modelfilename;

% call matbugs
dataStruct = options.data;
trinity.matbugs(dataStruct, bugsModel, ...
    'init'           , init          , ...
    'monitorParams'  , monitorParams , ...
    'nChains'        , nChains       , ...
    'nBurnin'        , nBurnin       , ...
    'nSamples'       , nSamples      , ...
    'thin'           , thin          , ...
    'view'           , view          , ...
    'openBugs'       , openBugs      , ...
    'Bugdir'         , Bugdir        , ...
    'workingDir'     , workingDir    , ...
    'DICstatus'      , DICstatus     , ...
    'refreshrate'    , refreshrate   ...
);

for c = 1:nChains
    options.coda_files{c} = sprintf('coda%i', c); 
end
