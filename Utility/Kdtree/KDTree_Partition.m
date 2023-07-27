%% this function is used to partition the space by k-d tree.
%  It is call by mexFunction between matlab and C++
%   the 1st input is the number of partitions
%   the 2nd input is the boundary of the domain, [l u;l u;l u...]
%   the 1st output is the partitioned subspaces
%   the 2nd output is the neighborhood relationships of these subspaces
function [a,b]=KDTree_Partition(num,boundary)
    [x,y]=ConstructKDTree(num,boundary);
    a=x;
    b=y;
end

