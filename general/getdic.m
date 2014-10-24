function varargout = getdic(ch)

chains.deviance = ch.deviance;

dicfn = @(y)codatable(y, 'deviance', @(x)mean(x)+0.5*var(x));

dic = dicfn(chains);

nsamples = size(chains.deviance, 1);
h1 = 1:(nsamples/2);
h2 = (nsamples/2+1):nsamples;
q1 = 1:(nsamples/4);
q2 = (1/4*nsamples+1):(nsamples/2);
q3 = (nsamples/2+1):(3/4*nsamples);
q4 = (3/4*nsamples+1):nsamples;

info = [ dicfn(structfun(@(x)x(h1,:), chains, 'uni', 0))
         dicfn(structfun(@(x)x(h2,:), chains, 'uni', 0))
         dicfn(structfun(@(x)x(q1,:), chains, 'uni', 0))
         dicfn(structfun(@(x)x(q2,:), chains, 'uni', 0))
         dicfn(structfun(@(x)x(q3,:), chains, 'uni', 0))
         dicfn(structfun(@(x)x(q4,:), chains, 'uni', 0)) ]';
     
if ~nargout
    varargout = {};
    fprintf('DIC %9s%8.0f\n', sprintf('(%i)', nsamples), dic)
    fprintf('1/2 %9s%8.0f%8.0f\n', sprintf('(%i)', nsamples/2), info(1:2))
    fprintf('1/4 %9s%8.0f%8.0f%8.0f%8.0f\n', sprintf('(%i)', nsamples/4), info(3:6))
elseif nargout==1
    varargout = {dic};
else
    varargout = {dic, info};
end