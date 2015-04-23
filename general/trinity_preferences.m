function a = trinity_preferences(variable)
% TRINITY_PREFERENCES  Collect user preferences and settings for Trinity
%
%  Use this file to adapt user settings.
%

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

switch variable
    
%% ----- JAGS ---------------------------------------------------------- %%
    case 'libpath_lnx'
        % To call JAGS from MATLAB under linux, you need to explicitly set the library path
        % (LD_LIBRARY_PATH), to prevent MATLAB from using its own libraries.
        % In a shell (*not from inside MATLAB*), call:
        %    $ ldd /usr/lib/jags/jags-terminal
        % Typical output on 64-bit Ubuntu would be this:
        %    linux-vdso.so.1 =>  (0x00007ffff2800000)
        %    libltdl.so.7 => /usr/lib/x86_64-linux-gnu/libltdl.so.7 (0x00007fd59b788000)
        %    libjags.so.3 => /usr/local/lib/libjags.so.3 (0x00007fd59b4f8000)
        %    libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007fd59b1f8000)
        %    libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007fd59afe0000)
        %    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fd59ac20000)
        %    libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fd59aa18000)
        %    libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fd59a718000)
        %    /lib64/ld-linux-x86-64.so.2 (0x00007fd59b9b0000)
        % Then copy the directories into the string below, separated by colons.
        a = '/usr/lib/x86_64-linux-gnu/:/lib/x86_64-linux-gnu/:/lib64/' ;
        % a = '/usr/lib/x86_64-linux-gnu/:/usr/lib/:/lib/x86_64-linux-gnu/:/lib64/';
        
    case 'libpath_mac'
        % To call JAGS from MATLAB on Mac, you need to specify the location
        % of the JAGS executable. Usually that is this:
        a = '/usr/local/bin/' ;

    case 'libpath_win'
        % Nothing to do here, Windows gets the Path environmental variable
        % as part of the installation process.
        a = '';
        
        
%% ----- STAN ---------------------------------------------------------- %%
    case 'stan_main_dir'
        % Where is Stan (full, absolute paths only)?
        a = '/home/joachim/stan/cmdstan/';
        
    case 'stan_model_dir'
        % Where are the model files (relative to Stan)?
        a = ['src' filesep 'models' filesep 'cognitive' filesep];
        

%% ----- All ----------------------------------------------------------- %%
    case 'colororder'
        a = [ 3 1 1
              1 1 3
              1 3 1
              3 1 3
              1 3 3
              3 3 1
              3 2 1
              1 2 3
              1 3 2
              0 0 0
              2 1 1
              1 1 2
              1 2 1
              2 1 2
              1 2 2
              2 2 1
              2 2 2
              3 2 2
              2 2 3
              2 3 2
              3 2 3
              2 3 3
              3 3 2
              1 1 1] / 3;

%% ----- OTHERWISE ----------------------------------------------------- %%
    otherwise
        error_tag('trinity:trinity_preferences:badswitch', ...
            'Unknown preference option "%s".', variable)
end
