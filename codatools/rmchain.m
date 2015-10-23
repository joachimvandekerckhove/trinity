function [z, y] = rmchain(chains, num)
% RMCHAIN  Remove a chain from a coda structure
%   CODA = RMCHAIN(CODA, N) removes the Nth chain from a coda structure.
%   The N input can be a vector to remove multiple chains at once.
%   CODA = RMCHAIN(CODA) removes the chain with the highest mean deviance
%      from the coda structure (requires that the chain was generated with
%      the DIC module loaded).
%   [CODA, CODA2] = RMCHAIN(...) also returns a coda structure with the
%      removed chains.
% 
%   RMCHAIN can be useful to inspect separate modes of a posterior
%   individually.

% Pick any field, get number of chains
fnm = fieldnames(chains); 
ind = fnm{1};
ch = 1:size(chains.(ind),2);

if nargin<2  % Choose a chain based on highest mean deviance
    if ~ismember(fnm, 'deviance')
        trinity.error_tag('trinity:rmchain:insufficientInput', ...
            'RMCHAIN with one input parameter requires a ''deviance'' field in the coda structure.')
    end
    [~, num] = max(mean(chains.deviance));
end

% Return coda structure without that chain
z = structfun(@(x)x(:,setdiff(ch, num)), chains, 'uni', 0);

% Optionally, also return the removed chain(s)
if nargout > 1
    y = structfun(@(x)x(:,num), chains, 'uni', 0);
end
