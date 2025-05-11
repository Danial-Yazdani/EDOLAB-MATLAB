%********************************DPCPSO*****************************************************
%Author: Mai Peng
%E-mail: pengmai1998 AT gmail DOT com
%Last Edited: February 17, 2025
%
% ------------
% Reference:
% ------------
%
%       "Liu, Yuanchao, et al. 
%           "An affinity propagation clustering based particle swarm optimizer for dynamic optimization." 
%               Knowledge-Based Systems 195 (2020): 105711.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Swarm, Problem] = SubPopulationGenerator_APCPSO(Dimension, MinCoordinate, MaxCoordinate, PopulationSize, Problem)
%% Perform APC
[SubPops, Centers] = AffinityPropagationClustering(MinCoordinate + ((MaxCoordinate - MinCoordinate) .* rand(PopulationSize, Dimension)));

population = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[], 'IsExcluded', []); 
Swarm = repmat(population, [length(SubPops), 1]);

for k = 1:length(SubPops)
    Swarm(k).X = SubPops{k};  % Assign the sub-population's particles
    Swarm(k).Velocity = -5 + (5 - (-5)) * rand(size(Swarm(k).X));  % Initialize particle velocities
    Swarm(k).Shifts = [];  % No shifts at the start
    [Swarm(k).FitnessValue, Problem] = fitness(Swarm(k).X, Problem);  % Compute fitness
    Swarm(k).PbestPosition = Swarm(k).X;  % Set personal best position to current position
    Swarm(k).PbestValue = Swarm(k).FitnessValue;  % Set personal best value to current fitness
    Swarm(k).IsConverged = 0;  % Initially, not converged
    Swarm(k).IsStagnated = 0;  % Initially, not stagnated
    Swarm(k).IsExcluded = 0;  % Initially, not excluded
    Swarm(k).StagnationCounter = zeros(size(Swarm(k).X, 1), 1);  % Initialize stagnation counter
    
    [max_fitness, best_idx] = max(Swarm(k).FitnessValue);  % Find the best fitness value in the sub-population
    Swarm(k).GbestID = best_idx;  % Store the index of the best fitness
    Swarm(k).GbestPosition = Swarm(k).PbestPosition(best_idx, :);  % Set the global best position
    Swarm(k).GbestValue = max_fitness;  % Set the global best value
end

%% Clustering Function (Modified for Affinity Propagation)
    function [SubPopulations, Centers] = AffinityPropagationClustering(Population)
    lambda = 0.5;
    max_iter = 200;
    stable_iter = 50;
    
    N = size(Population, 1);
    
    s = -pdist2(Population, Population, 'squaredeuclidean');
    
    Med = median(s(:));
    for k = 1:N
        s(k, k) = Med;
    end
    
    r = zeros(N, N);
    a = zeros(N, N);
    
    iter = 0;
    converged = false;
    last_exemplars = [];
    stable_count = 0;
    
    while iter < max_iter && ~converged
        iter = iter + 1;
        r_prev = r;
        a_prev = a;
        
        r_new = zeros(N, N);
        for i = 1:N
            as_i = a_prev(i, :) + s(i, :);
            for k = 1:N
                if k == 1
                    mask = 2:N;
                elseif k == N
                    mask = 1:N-1;
                else
                    mask = [1:k-1, k+1:N];
                end
                if ~isempty(mask)
                    max_val = max(as_i(mask));
                else
                    max_val = -inf;
                end
                r_new(i, k) = s(i, k) - max_val;
            end
        end
        r = lambda * r_prev + (1 - lambda) * r_new;
        
        a_new = zeros(N, N);
        sum_contrib = sum(max(0, r), 1) - max(0, diag(r))';
        for k = 1:N
            sum_contrib_k = sum_contrib(k);
            r_kk = r(k, k);
            for i = 1:N
                if i == k
                    a_new(i, k) = sum_contrib_k;
                else
                    temp = r_kk + (sum_contrib_k - max(0, r(i, k)));
                    a_new(i, k) = min(0, temp);
                end
            end
        end
        a = lambda * a_prev + (1 - lambda) * a_new;
        
        Su = a + r;
        [~, exemplar_indices] = max(Su, [], 2);
        current_exemplars = unique(exemplar_indices);
        
        current_sorted = sort(current_exemplars);
        last_sorted = sort(last_exemplars);
        if isequal(current_sorted, last_sorted)
            stable_count = stable_count + 1;
            if stable_count >= stable_iter
                converged = true;
            end
        else
            stable_count = 0;
            last_exemplars = current_exemplars;
        end
    end
    
    [ClusterID, ~, CentersIdx] = unique(exemplar_indices);
    SubPopulations = arrayfun(@(k) Population(exemplar_indices == k, :), unique(ClusterID), 'UniformOutput', false);
    Centers = Population(ClusterID, :);
    
    if isempty(Centers)
        SubPopulations = {Population};
        Centers = mean(Population, 1);
    end
end
end