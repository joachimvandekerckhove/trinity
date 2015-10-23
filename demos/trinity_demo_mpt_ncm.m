%% Fit a model using Trinity
% Cleanup first
clear all
close all

proj_id = 'ncm';

%% First, enter the data
cons = [  78 ,  70 ,   7 ,  15 ] ;
inco = [ 102 ,  55 ,  40 ,  53 ] ;
neut = [  63 ,  45 ,  13 ,  21 ] ;
N = [sum(cons) sum(inco) sum(neut)];

% Plot the data
figure(1), clf
bar([cons; inco; neut], 'linestyle', 'none')
for ctr = 1:4
    text(0.5 + 0.185*ctr, cons(ctr)+6, num2str(cons(ctr)))
    text(1.5 + 0.185*ctr, inco(ctr)+6, num2str(inco(ctr)))
    text(2.5 + 0.185*ctr, neut(ctr)+6, num2str(neut(ctr)))
end
ylabel Frequency
legend 'Correct-Correct'   'Correct-Incorrect'   ...
       'Incorrect-Correct' 'Incorrect-Incorrect'
set(gca, ...
    'XTickLabel', {'Consistent' 'Inconsistent' 'Neutral'}, ...
    'Linewidth', 2, 'layer', 'top')
set(gcf, 'position', [100 400 450 250])
% savepic ../figs/data

%% Now, make all inputs that Trinity needs
% Write the model into a variable (cell variable)
model = {
    'model {'
    '   # ---- Consistent condition --------------- #'
    '   theta[1,1] <- ( 1 + p + q - pq + 4 * pc ) / 6'
    '   theta[1,2] <- ( 1 + p + q - pq - 2 * pc ) / 3'
    '   theta[1,3] <- ( 1 - p - q + pq ) / 6'
    '   theta[1,4] <- 1 - theta[1,1] - theta[1,2] - theta[1,3]'
    '   '
    '   # ---- Inconsistent condition ------------- #'
    '   theta[2,1] <- ( 1 + p - q + pq + 4 * pc ) / 6'
    '   theta[2,2] <- ( 1 + p - q + pq - 2 * pc ) / 3'
    '   theta[2,3] <- ( 1 - p + q - pq ) / 6'
    '   theta[2,4] <- 1 - theta[2,1] - theta[2,2] - theta[2,3]'
    '   '
    '   # ---- Neutral condition------------------- #'
    '   theta[3,1] <- ( 1 + p + 4 * pc ) / 6'
    '   theta[3,2] <- ( 1 + p - 2 * pc ) / 3'
    '   theta[3,3] <- ( 1 - p ) / 6'
    '   theta[3,4] <- 1 - theta[3,1] - theta[3,2] - theta[3,3]'
    '   '
    '   # ---- Data ------------------------------- #'
    '   cons[1:4] ~ dmulti(theta[1,1:4], N[1])'
    '   inco[1:4] ~ dmulti(theta[2,1:4], N[2])'
    '   neut[1:4] ~ dmulti(theta[3,1:4], N[3])'
    '   '
    '   # ---- Priors ----------------------------- #'
    '   p ~ dbeta(2, 2)'
    '   q ~ dbeta(2, 2)'
    '   c ~ dbeta(2, 2)'
    '   '
    '   # ---- Efficiency tweaks ------------------ #'
    '   pq  <- p * q'
    '   pc  <- p * c'
    '   cpq <- c * pq'
    '}'
    };

% List all the parameters of interest (cell variable)
parameters = {
    'c' 'p' 'q'
    };

% Write a function that generates a structure with one random value for
% each parameter in a field
generator = @()struct(...
    'c', rand, ...
    'p', rand, ...
    'q', rand  ...
    );

% Make a structure with the data (note that the name of the field needs to
% match the name of the variable in the JAGS model)
data = struct(...
    'cons', cons, ...
    'inco', inco, ...
    'neut', neut, ...
    'N'   , N     ...
    );

% Tell Trinity which engine to use
engine = 'jags';


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes(engine, ...
    'model'          ,     model , ...
    'data'           ,      data , ...
    'outputname'     , 'samples' , ...
    'init'           , generator , ...
    'modelfilename'  ,   proj_id , ...
    'datafilename'   ,   proj_id , ...
    'initfilename'   ,   proj_id , ...
    'scriptfilename' ,   proj_id , ...
    'logfilename'    ,   proj_id , ...
    'nchains'        ,        4  , ...
    'nburnin'        ,      1e4  , ...
    'nsamples'       ,      1e4  , ...
    'monitorparams'  ,   parameters  , ...
    'thin'           ,        5  , ...
    'refresh'        ,        1  , ...
    'workingdir'     ,    ['/tmp/' proj_id]  , ...
    'verbosity'      ,        0  , ...
    'saveoutput'     ,     true  , ...
    'parallel'       ,  isunix() );

fprintf('%s took %f seconds!\n', upper(engine), toc)


%% Inspect the results
% First, inspect convergence
if any(codatable(chains, @gelmanrubin) > 1.1)
    grtable(chains, 1.1)
    warning('Some chains were not converged!')
else
    disp('Convergence looks good.')
end

% Now, inspect the mean of each parameter in each chain
disp('Posterior means by chain:')
disp(stats.mean)

% Now check some basic descriptive statistics averaged over all chains
disp('Descriptive statistics for all chains:')
codatable(chains)


%% Make some figures
figure(2)
h = smhist(chains, '^c$|^q$|^p$');
axis([0 1 0 13])
line(xlim, [1 1], 'color', [.6 .6 .6], 'linestyle', '--')
legend c p q prior
xlabel 'parameter value'
ylabel 'posterior density'
set(get(h(1), 'children'), 'Linewidth', 3)
set(gca, 'Linewidth', 2, 'layer', 'top')
set(gcf, 'position', [417   437   416   215])
% savepic ../figs/posteriors
