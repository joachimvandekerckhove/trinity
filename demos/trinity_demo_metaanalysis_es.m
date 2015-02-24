%% Meta-analysis using Trinity and JAGS
% Data come from Au et al.


%% Preamble
% Cleanup first
clearvars -except p_ind Bs
p = @sprintf;


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

[x, labels_x] = replace_by_index(cov(:,1));  x = x - 1;
[y, labels_y] = replace_by_index(cov(:,2));  y = y - 1;
z = [cov{:,3}];

disp 'X Labels are:', disp(labels_x')
disp 'Y Labels are:', disp(labels_y')

data = struct('K', numel(d), 'd', d, 's', s);

%% Set priors
% n = 49;
% priors = linspace(.1/(n+1), 2, n);
theta_sd = 1;

%% Make all inputs that Trinity needs
% Write the JAGS model into a variable (cell variable)
type = 6;
switch type
    case {1 'fixed'}
        model = {
            'model {'
            '   for (i in 1:K) {'
            '      precision[i] <- pow(s[i], -2);'
            '      d[i] ~ dnorm(theta, precision[i]);'
            '   }'
            ''
            '   # Prior'
          p('   theta ~ dnorm(0, %g);', theta_sd.^-2)
            '}'
            };
        parameters = {'theta'};
    case {2 'random'}
        model = {
            'model {'
            '   for (i in 1:K) {'
            '      precision[i] <- pow(s[i], -2);'
            '      d[i] ~ dnorm(b0[i], precision[i])'
            '      b0[i] ~ dnorm(theta, tau)'
            '   }'
            ''
            '   # Priors'
          p('   theta ~ dnorm(0, %g);', theta_sd.^-2)
            '   tau ~ dgamma(.001, .001);'
            '   sigma <- pow(tau, -0.5) ;'
            '}'
            };
        parameters = {'theta', 'sigma', 'b0'};
    case {3 'regression_x'}
        model = {
            'model {'
            '   for (i in 1:K) {'
            '      precision[i] <- pow(s[i], -2);'
            '      d[i] ~ dnorm(b0[i], precision[i])'
            '      b0[i] <- theta + gamma * x[i] + u0[i]'
            '      u0[i] ~ dnorm(0, tau)'
            '   }'
            ''
            '   # Priors'
          p('   theta ~ dnorm(0, %g);', theta_sd.^-2)
          p('   gamma ~ dnorm(0, %g);', theta_sd.^-2)
            '   tau ~ dgamma(.001, .001);'
            '   sigma <- pow(tau, -0.5) ;'
            '}'
            };
        data.x = x;
        parameters = {'theta', 'sigma', 'b0', 'gamma'};
    case {4 'multipleregression'}
        model = {
            'model {'
            '   for (i in 1:K) {'
            '      precision[i] <- pow(s[i], -2);'
            '      d[i] ~ dnorm(b0[i], precision[i])'
            '      b0[i] <- theta + gamma * x[i] + delta * y[i] + u0[i]'
            '      u0[i] ~ dnorm(0, tau)'
            '   }'
            ''
            '   # Priors'
          p('   theta ~ dnorm(0, %g);', theta_sd.^-2)
          p('   gamma ~ dnorm(0, %g);', theta_sd.^-2)
          p('   delta ~ dnorm(0, %g);', theta_sd.^-2)
            '   tau ~ dgamma(.001, .001);'
            '   sigma <- pow(tau, -0.5) ;'
            '}'
            };
        data.x = x;
        data.y = y;
        parameters = {'theta', 'sigma', 'b0', 'gamma', 'delta'};
    case {5 'fullregression'}
        model = {
            'model {'
            '   for (i in 1:K) {'
            '      precision[i] <- pow(s[i], -2);'
            '      d[i] ~ dnorm(b0[i], precision[i])'
            '      b0[i] <- theta + gamma * x[i] + delta * y[i] + lambda * z[i] + u0[i]'
            '      u0[i] ~ dnorm(0, tau)'
            '   }'
            ''
            '   # Priors'
          p('   theta ~ dnorm(0, %g);', theta_sd.^-2)
          p('   gamma ~ dnorm(0, %g);', theta_sd.^-2)
          p('   delta ~ dnorm(0, %g);', theta_sd.^-2)
          p('   lambda ~ dnorm(0, %g);', theta_sd.^-2)
            '   tau ~ dgamma(.001, .001);'
            '   sigma <- pow(tau, -0.5) ;'
            '}'
            };
        data.x = x;
        data.y = y;
        data.z = z;
        parameters = {'theta', 'sigma', 'b0', 'gamma', 'delta', 'lambda'};
    case {6 'regression_y'}
        model = {
            'model {'
            '   for (i in 1:K) {'
            '      precision[i] <- pow(s[i], -2);'
            '      d[i] ~ dnorm(b0[i], precision[i])'
            '      b0[i] <- theta + gamma * x[i] + u0[i]'
            '      u0[i] ~ dnorm(0, tau)'
            '   }'
            ''
            '   # Priors'
          p('   theta ~ dnorm(0, %g);', theta_sd.^-2)
          p('   gamma ~ dnorm(0, %g);', theta_sd.^-2)
            '   tau ~ dgamma(.001, .001);'
            '   sigma <- pow(tau, -0.5) ;'
            '}'
            };
        data.x = x;
        parameters = {'theta', 'sigma', 'b0', 'gamma'};
end


%% 
% Write a function that generates a structure with one random value for
% at least one _random_ parameter
generator = @()struct('theta', randn());


%% Run Trinity with the CALLBAYES() function
tic
[stats, chains, diagnostics, info] = callbayes('jags', ...
    'model'         ,         model , ...
    'data'          ,          data , ...
    'nchains'       ,            4  , ...
    'nsamples'      ,          5e2  , ...
    'nburnin'       ,          5e2  , ...
    'thin'          ,            2  , ...
    'monitorparams' ,    parameters , ...
    'init'          ,     generator );
toc


%% Inspect the results
% First, inspect convergence
grtable(chains, 1.01)


%%
% Now check some basic descriptive statistics averaged over all chains
subplot(1, 2, 1)
h = caterpillar(chains, 'theta');
set(h, 'xgrid', 'on')

subplot(1, 2, 2)
pM = codatable(chains, 'theta', @mean);
pS = codatable(chains, 'theta', @std);
BHA = normpdf(0, pM, pS);
BH0 = normpdf(0, 0, theta_sd);
B = BHA ./ BH0;
xax = linspace(-.5, .5, 200);
plot(xax, normpdf(xax, 0, theta_sd), 'b', ...
    xax, normpdf(xax, pM, pS), 'r', 'linewidth', 2);
line([0 0], ylim, 'color', 'k', 'linestyle', '--', 'linewidth', 2)
line(0, BHA, 'color', 'r', 'marker', 'o', 'linewidth', 4)
line(0, BH0, 'color', 'b', 'marker', 'o', 'linewidth', 4)
fprintf('BF in favor of the null: %.2f.\n', B)

% Bs(p_ind) = B;