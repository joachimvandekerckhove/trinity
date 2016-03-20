%% Meta-analysis using Trinity and JAGS
% Data come from Au et al.


%% Preamble
% Cleanup first
clear all
% close all
clf

p = @sprintf;
standardize = @(x) (x - ones(size(x, 1), 1) * mean(x)) ...
    ./ (ones(size(x, 1), 1) * std(x));


%% Prepare data
d = [ 0.0231387997 -0.2084716202  0.4162562400 -0.0529089425 ...
    0.5515000375  0.1844419800 -0.0696433222 -0.0190827661 ...
    0.2121666622 -0.2762157630  0.7591683888  0.3486053737 ...
    0.6398299183  0.2834192216  1.1089055124  0.2196846575 ...
    -0.2796257216  0.3888557781  0.8159869503  0.3368980889 ...
    0.0536370365  0.6446718592  0.2629486435 -0.1572002931 ];
s = [ 0.4126855194  0.3988373634  0.2746994925  0.2727759485 ...
    0.2609609627  0.2737156257  0.2640219195  0.2997825859 ...
    0.2646244224  0.3161792348  0.2755661365  0.3081557893 ...
    0.4860702336  0.4124281792  0.5117600089  0.4887536095 ...
    0.3632103195  0.3593327085  0.3315631027  0.5562613357 ...
    0.2528452930  0.3346639456  0.2977497609  0.4396353140 ];
cov = {'US'            'active'      0.7500
    'US'            'active'      1.2000
    'US'            'no-contact'  0.0000
    'US'            'active'      3.5800
    'international' 'no-contact'  0.2000
    'US'            'active'      0.0000
    'US'            'active'      1.5000
    'US'            'active'      1.6000
    'international' 'no-contact'  2.6000
    'US'            'active'      8.4000
    'international' 'no-contact'  1.5200
    'international' 'active'      1.5200
    'international' 'no-contact'  0.0000
    'international' 'no-contact'  0.0000
    'international' 'no-contact'  0.0000
    'international' 'no-contact'  0.0000
    'international' 'no-contact'  0.5350
    'international' 'no-contact'  1.9950
    'international' 'no-contact'  0.9399
    'US'            'active'      5.5500
    'US'            'active'      3.5200
    'international' 'active'      1.1150
    'US'            'no-contact'  1.2100
    'international' 'active'      0.0000 };


cont = standardize;            % for continuous variables
cate = @replace_by_index;      % for categorical variables
dumb = @(x) dummyvar(cate(x)); % for dummy-coded variables

x = dumb(cov(:,1)); x(:,end) = [];
y = dumb(cov(:,2)); y(:,end) = [];
z = cont([cov{:,3}])';

o = ones(size(x));
X = [ o  x  y  z  x.*y  x.*z ]';
K = size(X, 1);
N = length(d);

data = struct( ...
    'X', X, 'd', d, ...
    'K', K, 'N', N);

%% Set priors
% n = 49;
% priors = linspace(.1/(n+1), 2, n);
beta_sd = 31.6228;

data.MP = zeros(K, 1);
data.S0 = diag(s).^2;
data.S1S = eye(N);
data.S1v = N;
data.SP = eye(K) * 1e-3;

%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
type = 7;
proj_id = sprintf('meta%i', type);
engine = 'jags';

model = {
    'model {'
    '   beta ~ dmnorm(MP, SP)        # Prior weights'
    '   S1 ~ dwish(S1S[,], S1v)      # Prior covariance'
    '   b0 ~ dmnorm(beta %*% X, S1)  # Level 1'
    '   d ~ dmnorm(b0, S0)           # Level 0'
    '}'
    };
parameters = {'beta', 'sigma', 'b0'};



%%
% Write a function that generates a structure with one random value for
% at least one _random_ parameter
generator = @()struct('beta', randn(1, K));


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
    'refresh'        ,     1  , ...
    'workingdir'     ,    ['/tmp/' proj_id]  , ...
    'verbosity'      ,        0  , ...
    'saveoutput'     ,     true  , ...
    'parallel'       ,  isunix() );

toc


%% Inspect the results
% First, inspect convergence
grtable(chains, 1.01)


%%
% Now check some basic descriptive statistics averaged over all chains
subplot(1, 2, 1)
h = caterpillar(chains, 'beta');
set(h, 'xgrid', 'on')

subplot(1, 2, 2)
pM = codatable(chains, 'beta', @mean);
pS = codatable(chains, 'beta', @std);
BHA = normpdf(0, pM(1), pS(1));
BH0 = normpdf(0, 0, beta_sd);
B = BHA ./ BH0;
xax = linspace(-5, 10, 200);
plot(xax, normpdf(xax, 0, beta_sd), 'b', ...
    xax, normpdf(xax, pM(1), pS(1)), 'r', 'linewidth', 2);
line([0 0], ylim, 'color', 'k', 'linestyle', '--', 'linewidth', 2)
line(0, BHA, 'color', 'r', 'marker', 'o', 'linewidth', 4)
line(0, BH0, 'color', 'b', 'marker', 'o', 'linewidth', 4)
fprintf('BF in favor of the null: %.2f.\n', B)

% Bs(p_ind) = B;