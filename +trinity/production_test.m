%% PRODUCTION_TEST Test functionality of Trinity before commit
clc
clear all
close all
clear all functions
restoredefaultpath
pause(.5)
trinity silent

fprintf('+------------------------------------------------------+\n')
fprintf('| Running production tests for Trinity                 |\n')
fprintf('+------------------------------------------------------+\n')

%% Engines
if ispc() % Windows
    fprintf('| Testing engines available on Windows (BUGS, JAGS)    |\n')
    trinity.unit_test( @trinity.test, 'bugs');
elseif isunix()  % otherwise
    fprintf('| Testing engines available on unix (Stan, JAGS)       |\n')
    trinity.unit_test( @trinity.test, 'stan');
end
chains = trinity.unit_test( @trinity.test, 'jags');
fprintf('+------------------------------------------------------+\n')

%% Coda tools
fprintf('| Testing coda tools                                   |\n')
trinity.unit_test( @whocoda              , chains                   );
trinity.unit_test( @get_matrix_from_coda , chains   , 'c'           );
trinity.unit_test( @structural           , chains   , 'r = a ./ b;' );
trinity.unit_test( @cstats               , chains.a                 );
trinity.unit_test( @cstats               , chains                   );
fprintf('+------------------------------------------------------+\n')

%% Figures
fprintf('| Testing figures                                      |\n')
trinity.unit_test( @aucoplot    , chains.a       );
trinity.unit_test( @caterpillar , chains.a       );
trinity.unit_test( @edfplot     , chains.a       );
trinity.unit_test( @smhist      , chains.a       );
trinity.unit_test( @traceplot   , chains.a       );
trinity.unit_test( @violinplot  , chains.a       );
trinity.unit_test( @aucoplot    , chains   , 'c' );
trinity.unit_test( @caterpillar , chains   , 'c' );
trinity.unit_test( @edfplot     , chains   , 'c' );
trinity.unit_test( @smhist      , chains   , 'c' );
trinity.unit_test( @traceplot   , chains   , 'c' );
trinity.unit_test( @violinplot  , chains   , 'c' );
fprintf('+------------------------------------------------------+\n')
fprintf('| All Trinity production tests completed without error |\n')
fprintf('+------------------------------------------------------+\n')