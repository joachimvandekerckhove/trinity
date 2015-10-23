% MAT4STAN
%
% Files
%   callstan          - Executes a call to Stan
%   callstan_lnx      - Executes a call to Stan on Linux
%   callstan_mac      - [Not yet implemented] Executes a call to Stan on Mac
%   callstan_win      - [Not yet implemented] Executes a call to Stan on Windows
%   stan2coda         - Read Stan output into a MATLAB structure
%   assert_parallel   - Check if parallellization infrastructure exists
%   bugs2coda         - Reads BUGS samples file into a MATLAB CODA structure
%   callbugs          - [Not yet implemented] Executes a call to WinBUGS
%   callbugs_lnx      - [Not yet implemented] Executes a call to WinBUGS on Linux
%   callbugs_mac      - [Not yet implemented] Executes a call to WinBUGS on Mac
%   callbugs_win      - [Not yet implemented] Executes a call to WinBUGS on Windows
%   calljags          - Use this function to run JAGS
%   calljags_lnx      - Executes a call to JAGS on Linux
%   calljags_mac      - Executes a call to JAGS on Linux
%   calljags_win      - Executes a call to JAGS on Windows
%   cell2model        - Writes cell string to text file
%   coda2inits        - Try to make initial values structure from coda structure
%   error_tag         - Throw error message and print error tag
%   generic_script    - Fit a model using Trinity
%   get_full_path     - Get absolute canonical path of a file or folder
%   input_parser      - Parses label-value input pairs into an options structure
%   jags2coda         - Reads JAGS samples file into a MATLAB CODA structure
%   matbugs           - a Matlab interface for WinBugs, similar to R2WinBUGS
%   model2cell        - Reads text file to cell string
%   move_to_wdir      - Move to working directory with return handle
%   new               - Start a new Trinity project
%   parse_jags_errors - Give intelligent feedback on JAGS errors
%   prctile           - Compute percentiles of a vector
%   prechecks         - Checks preconditions before launching engine
%   preferences       - Collect user preferences and settings for Trinity
%   production_test   - Test functionality of Trinity before commit
%   readcoda          - Reads a BUGS or JAGS CODA file to a MATLAB structure
%   research_complete - Plays the Starcraft (terran) audio "Research complete"
%   robust_fopen      - Opens stream and returns file ID and close handle
%   select_fields     - Returns list of fields that match a regular expression
%   set_permissions   - Set permissions for executable scripts
%   str2data          - Write data file from structure
%   string2datastruct - Parses string input to data structure
%   summary_stats     - Computes default STATS from CODA as output by CALLBAYES
%   test              - Test some of the Trinity functionality
%   unit_test         - Provide unit tests for Trinity functions
%   untitled          - Makes unique if unimaginative names for temporary files
