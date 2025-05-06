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
function [Optimizer, Problem] = ChangeReaction_APCPSO(Optimizer, Problem)
    % Change Reaction Algorithm for APCPSO
    % This function handles the change reaction process which involves
    % Optimal Particle Calibration and Diversity Maintenance.
    
    for i = 1:Optimizer.SwarmNumber
        GbestValues_before(i) = Optimizer.pop(i).GbestValue;
    end
    [~, SortIndex_before] = sort(GbestValues_before, 'descend');
    for i = 1:Optimizer.SwarmNumber
        Swarm_Sort_before(i) = Optimizer.pop(SortIndex_before(i));
    end
    Optimizer.pop = Swarm_Sort_before;
    
    GbestValues = zeros(Optimizer.SwarmNumber, 1);
    for i = 1:Optimizer.SwarmNumber
        [Optimizer.pop(i).GbestValue, Problem] = fitness(Optimizer.pop(i).GbestPosition, Problem);
        GbestValues(i) = Optimizer.pop(i).GbestValue;
    end
    [~, SortIndex] = sort(GbestValues, 'descend');
    for i = 1:Optimizer.SwarmNumber
        Swarm_Sort(i) = Optimizer.pop(SortIndex(i));
    end
    Optimizer.pop = Swarm_Sort;

    % 1. Optimal Particle Calibration
    new_X = zeros(Optimizer.PopulationSize,Optimizer.Dimension);
    new_fitnewss = zeros(Optimizer.PopulationSize,1);
    for i = 1:Optimizer.SwarmNumber
        tryBestPositon = Optimizer.pop(i).GbestPosition;
        tryBestValue = Optimizer.pop(i).GbestValue;
        % Particle calibration: Adjust the historical best in each dimension
        for j = 1:Problem.Dimension
            tempTryPosition = Optimizer.pop(i).GbestPosition;
            % Perform local search for each dimension by adjusting the current best
            tempTryPosition(j) = Optimizer.pop(i).GbestPosition(j) + rand(); % small increment
            if (tempTryPosition(j) > Optimizer.MaxCoordinate)
                tempTryPosition(j) = Optimizer.MaxCoordinate;
            end
            [tempTryFitness, Problem] = fitness(tempTryPosition, Problem);
            if tempTryFitness > tryBestValue
                tryBestPositon = tempTryPosition;
                tryBestValue = tempTryFitness;
            else
                tempTryPosition(j) = Optimizer.pop(i).GbestPosition(j) - rand();
                if (tempTryPosition(j) < Optimizer.MinCoordinate)
                    tempTryPosition(j) = Optimizer.MinCoordinate;
                end
                [tempTryFitness, Problem] = fitness(tempTryPosition, Problem);
                if tempTryFitness > tryBestValue
                    tryBestPositon = tempTryPosition;
                    tryBestValue = tempTryFitness;
                end
            end
        end
        new_X(i,:) = tryBestPositon;
        new_fitnewss(i, 1) = tryBestValue;
    end
    
    % 2. Diversity Maintenance
    % Re-initialize N - n particles randomly to maintain diversity
    N = Optimizer.PopulationSize;
    n = Optimizer.SwarmNumber;
    
    % Re-initialize the remaining particles randomly

    new_X(n+1:end, :) = Optimizer.MinCoordinate + ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate).*rand(N-n,Optimizer.Dimension));

    [SubPops, Centers] = AffinityPropagationClustering(new_X);
    population = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[]);
    Swarm = repmat(population,[length(SubPops),1]);
    
    for k=1:length(SubPops)
        Swarm(k).X =SubPops{k};
        Swarm(k).Velocity = -5 + (5 - (-5)) * rand(size(Swarm(k).X));
        Swarm(k).Shifts = [];
        [Swarm(k).FitnessValue,Problem] = fitness(Swarm(k).X,Problem);
        Swarm(k).PbestPosition = Swarm(k).X;
        Swarm(k).PbestValue = Swarm(k).FitnessValue;
        Swarm(k).IsConverged = 0;
        Swarm(k).IsStagnated = 0;
        Swarm(k).IsExcluded = 0;
        Swarm(k).StagnationCounter = zeros(size(Swarm(k).X, 1), 1);
    
        [max_fitness, best_idx] = max(Swarm(k).FitnessValue);
        Swarm(k).GbestID = best_idx;
        Swarm(k).GbestPosition = Swarm(k).PbestPosition(best_idx, :);
        Swarm(k).GbestValue = max_fitness;
    end
    Optimizer.pop = Swarm;
    Optimizer.SwarmNumber = length(Optimizer.pop);  % Number of sub-populations (to be determined by DPC)
    Optimizer.ExclusionRadius = 0.5 * ((Optimizer.MaxCoordinate - Optimizer.MinCoordinate) / (Optimizer.SwarmNumber^(1/Optimizer.Dimension)));
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