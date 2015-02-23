% 
% The main function of the Trinity toolbox is CALLBAYES.  The documentation
% for CALLBAYES lists most of the available options.
% 
% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.
% 
% TRINITY
%   trinity_install - Add Trinity folders to path
%
% TRINITY/CODATOOLS
%   aucoplot          - Make an autocorrelation plot
%   caterpillar       - Make a caterpillar plot
%   codatable         - Print a table with custom posterior statistics
%   cstats            - Print a table with basic posterior statistics
%   gelmanrubin       - Computes Gelman-Rubin convergence statistic R-hat
%   getMatrixFromCoda - Extract statistics of a matrix of posteriors
%   grtable           - Print a table with basic convergence statistics
%   select_fields     - Returns list of fields that match a regular expression
%   smhist            - Plot a smoothed histogram
%   traceplot         - Make a trace plot
%   violinplot        - Make a violin plot
%
% TRINITY/EXAMPLES
%   trinity_diffusion       - Fit a diffusion model using Trinity and JAGS
%   trinity_normal          - Fit a Gaussian distribution using Trinity and JAGS
%   trinity_test            - Test some of the Trinity functionality
%   trinity_unequalvariance - Fit an unequal-variance 2-group Gaussian model using Trinity and JAGS
%   trinity_rasch           - Fit a Rasch model using Trinity and JAGS
%   trinity_rasch_ppc       - Generate posterior predictives using Trinity and JAGS
%
% TRINITY/GENERAL
%   callbayes                 - Use this function to run a Bayesian model
%   cell2model                - Writes cell string to text file
%   error_tag                 - Throw error message and print error tag
%   get_full_path             - Get absolute canonical path of a file or folder
%   getdic                    - Compute Plummer's DIC from chains
%   model2cell                - Reads text file to cell string
%   replace_by_index          - Generate index vector with predictable values
%   robust_fopen              - Opens stream and returns file ID and close handle
%   str2data                  - Write data file from structure
%   structural                - Add a structural parameter to a coda structure
%   trinity_assert_parallel   - Check if parallellization infrastructure exists
%   trinity_input_parser      - Parses label-value input pairs into an options structure.
%   trinity_prechecks         - Checks preconditions before launching engine
%   trinity_preferences       - Collect user preferences and settings for Trinity
%   trinity_readcoda          - Reads a BUGS or JAGS CODA file to a MATLAB structure.
%   trinity_set_permissions   - Set permissions for executable scripts
%   trinity_string2datastruct - Parses string input to data structure. Internal Trinity function.
%   trinity_untitled          - Makes unique if unimaginative names for temporary files
%   trinity_move_to_wdir      - Move to working directory with return handle
%   trinity_summary_stats     - Computes default STATS from CODA as output by CALLBAYES
%
% TRINITY/MAT4BUGS
%   bugs2coda    - Reads BUGS samples file into a MATLAB CODA structure
%   callbugs     - [Not yet implemented] Executes a call to WinBUGS
%   callbugs_lnx - [Not yet implemented] Executes a call to WinBUGS on Linux
%   callbugs_mac - [Not yet implemented] Executes a call to WinBUGS on Mac
%   callbugs_win - [Not yet implemented] Executes a call to WinBUGS on Windows
%
% TRINITY/MAT4JAGS
%   calljags          - Use this function to run JAGS
%   calljags_lnx      - Executes a call to JAGS on Linux
%   calljags_mac      - Executes a call to JAGS on Linux
%   calljags_win      - Executes a call to JAGS on Windows
%   jags2coda         - Reads JAGS samples file into a MATLAB CODA structure
%   parse_jags_errors - Give intelligent feedback on JAGS errors
%
% TRINITY/MAT4STAN
%   callstan     - Executes a call to Stan
%   callstan_lnx - Executes a call to Stan on Linux
%   callstan_mac - [Not yet implemented] Executes a call to Stan on Mac
%   callstan_win - [Not yet implemented] Executes a call to Stan on Windows
%   stan2coda    - Read Stan output into a MATLAB structure
%
