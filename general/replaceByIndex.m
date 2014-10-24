function [newList, oldLabels, newLabels] = replaceByIndex(oldList)
%  REPLACEBYINDEX  Generate index vector with predictable values
%    [NEWLIST, OLDLABELS, NEWLABELS] = REPLACEBYINDEX(OLDLIST), where
%    OLDLIST is a vector of length N containing C unique values, returns
%    NEWLIST, a vector of length N containing only the integer values 1
%    through N so that each integer corresponds to exactly one value from
%    OLDLIST. OLDLABELS is a vector of length C containing the unique
%    values of OLDLIST, and NEWLABELS a vector of length C containing the
%    corresponding integers.
%    Note that oldList = oldLabels(newList);

newList = zeros(size(oldList));
oldLabels = reshape(unique(oldList), 1, []);
newLabels = 1:numel(oldLabels);
for c = newLabels
    newList(ismember(oldList, oldLabels(c))) = c;
end
