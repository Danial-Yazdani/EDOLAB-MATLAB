function [a,b]=KDTree_Partition(num, boundary, weights)
    % This function partitions a space into num subspaces using KDTree.
    % Inputs:
    %   - num: Number of subspaces (int).
    %   - boundary: The boundary of each subspace, specified as an m x 2 matrix, 
    %     where m is the dimensionality of the space.
    %   - weights: A vector specifying the volumetric proportions for each subspace. 
    %     The length of this vector must be equal to num.
    %
    % Outputs:
    %   - a: Boundaries of the partitioned subspaces.
    %   - b: Adjacency matrix indicating whether two subspaces are adjacent.

    % Call ConstructKDTree with the weights parameter
    [x, y] = ConstructKDTree(num, boundary, weights);
    
    % Assign the outputs to a and b
    a = x;  % Subspace boundaries
    b = y;  % Adjacency matrix
end
