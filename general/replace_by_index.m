function [newList, oldLabels, newLabels] = replace_by_index(oldList)
%  REPLACE_BY_INDEX  Generate index vector with predictable values
% 
%    [NEWLIST, OLDLABELS, NEWLABELS] = REPLACE_BY_INDEX(OLDLIST), where
%    OLDLIST is a vector of length N containing C unique values, returns
%    NEWLIST, a vector of length N containing only the integer values 1
%    through N so that each integer corresponds to exactly one value from
%    OLDLIST. OLDLABELS is a vector of length C containing the unique
%    values of OLDLIST, and NEWLABELS a vector of length C containing the
%    corresponding integers.
% 
%    Note that oldList = oldLabels(newList);
% 

% (c)2013- Joachim Vandekerckhove. See license.txt for licensing information.

newList = zeros(size(oldList));
oldLabels = reshape(unique(oldList), 1, []);
newLabels = 1:numel(oldLabels);
for c = newLabels
    newList(ismember(oldList, oldLabels(c))) = c;
end
