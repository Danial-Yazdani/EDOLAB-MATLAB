%********************************DPCPSO*****************************************************
%Author: Mai Peng
%E-mail: pengmai1998 AT gmail DOT com
%Last Edited: February 9, 2025
%
% ------------
% Reference:
% ------------
%
%  Li, Fei, et al. 
%       "A fast density peak clustering based particle swarm optimizer for dynamic optimization." 
%       Expert Systems with Applications 236 (2024): 121254.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer, Problem] = ChangeReaction_DPCPSO(Optimizer, Problem)
    % Change Reaction Algorithm for DPCPSO
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
            tempTryPosition(j) = Optimizer.pop(i).GbestPosition(j) + 0.0001; % small increment
            if (tempTryPosition(j) > Optimizer.MaxCoordinate)
                tempTryPosition(j) = Optimizer.MaxCoordinate;
            end
            [tempTryFitness, Problem] = fitness(tempTryPosition, Problem);
            if tempTryFitness > Optimizer.pop(i).GbestValue
                a = 1; % Adjust in the positive direction
            else
                a = -1; % Adjust in the negative direction
            end

            % Perform a local search for a few iterations to find a better position
            tryPosition = repmat(Optimizer.pop(i).GbestPosition, 10, 1);
            for m = 1:10
                tryPosition(m, j) = Optimizer.pop(i).GbestPosition(j) + a * 0.1 * m;
                if (tryPosition(m, j) > Optimizer.MaxCoordinate)
                    tryPosition(m, j) = Optimizer.MaxCoordinate;
                elseif (tryPosition(m, j) < Optimizer.MinCoordinate)
                    tryPosition(m, j) = Optimizer.MinCoordinate;
                end
            end
            [allTryFitness, Problem] = fitness(tryPosition, Problem);

            [bestFitness, bestIdx] = max(allTryFitness);
            if(bestFitness > tryBestValue)
                tryBestPositon = tryPosition(bestIdx, :);
                tryBestValue = bestFitness;
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

    [SubPops, Centers] = DensityPeakClustering(new_X, Problem.PeakNumber);
    population = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[]);
    Swarm = repmat(population,[length(SubPops),1]);
    for k = 1:length(SubPops)
        current_pop = SubPops{k};  % 当前子种群的粒子
        
        % === 新增部分：筛选粒子（数量>5时保留适应度最大的5个） ===
        if size(current_pop, 1) > 5
            % 计算当前子种群所有粒子的适应度
            [current_fitness, Problem] = fitness(current_pop, Problem);
            
            % 按适应度降序排序并选择前5个
            [~, sorted_indices] = sort(current_fitness, 'descend');
            selected_indices = sorted_indices(1:5);
            current_pop = current_pop(selected_indices, :);  % 保留Top5粒子
            
            % 重新计算筛选后粒子的适应度（确保Problem状态更新）
            [current_fitness, Problem] = fitness(current_pop, Problem);
        end
        
        % === 原始代码：初始化种群 ===
        Swarm(k).X = current_pop;
        Swarm(k).Velocity = -4 + (4 - (-4)) .* rand(size(Swarm(k).X));
        Swarm(k).Shifts = [];
        
        % === 调整部分：避免重复计算适应度 ===
        if exist('current_fitness', 'var')
            Swarm(k).FitnessValue = current_fitness;  % 直接使用已计算的适应度
            clear current_fitness  % 清除临时变量避免干扰后续循环
        else
            [Swarm(k).FitnessValue, Problem] = fitness(Swarm(k).X, Problem);
        end
        
        Swarm(k).PbestPosition = Swarm(k).X;
        Swarm(k).PbestValue = Swarm(k).FitnessValue;
        Swarm(k).IsConverged = 0;
        Swarm(k).IsStagnated = 0;
        Swarm(k).IsExcluded = 0;
        Swarm(k).localIter = 0;
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

%% Clustering Function
function [SubPopulations, Centers] = DensityPeakClustering(Population, P)
    PersistentParameter.ThresholdFormula = @(N, P) -6.07 * N * log(P) + 50.5 * N; % Formula (8)
    
    % Stage 1: Compute density and distance
    N = size(Population, 1);  % Number of particles
    D = pdist2(Population, Population);  % Pairwise distances between particles
    D = D.^2;
    % Initialize distance matrix and set diagonal elements to Inf
    dist = D;
    dist(1:N+1:end) = Inf;

    % Calculate dc based on percentiles of distances
    sda = sort(dist(:));  % Sort all distance values in ascending order
    percent = 2;  % Set the percentage of distances to determine dc
    position = round(numel(sda) * percent / 100);  % Find the index for the 2% percentile
    dc = sda(position);  % Select the distance at that percentile

    % Gaussian kernel density calculation
    rho = zeros(N, 1);  % Density initialization
    for i = 1:N
       for j = 1:N
           if(i ~= j)
              rho(i) = rho(i) + exp(-(dist(i,j) / dc)^2);  % Compute density based on distance
           end
       end
    end

    % Compute relative distance delta
    maxd = max(max(dist(isfinite(dist))));  % Maximum distance
    [rho_sorted, ordrho] = sort(rho, 'descend');  % Sort rho in descending order

    % Initialize delta and nneigh arrays
    delta = maxd * ones(N, 1);  % Initialize delta to maxd
    nneigh = zeros(N, 1);  % Initialize nearest neighbors

    % Compute delta and nearest neighbors
    for ii = 2:N
        for jj = 1:ii-1
            if dist(ordrho(ii), ordrho(jj)) < delta(ordrho(ii))
                delta(ordrho(ii)) = dist(ordrho(ii), ordrho(jj));
                nneigh(ordrho(ii)) = ordrho(jj);  % Nearest neighbor with higher density
            end
        end
    end

    % Assign delta value to the first (highest density) point
    delta(ordrho(1)) = max(delta);

    % Compute gamma (density * relative distance)
    gamma = rho .* delta;
    [sort_gamma, Index] = sort(gamma, 'descend');
    gamma_threshold = -6.077 * N * log(P) + 50.49 * N;
    CentersIdx = [];
    count = 0;
    for ii = 1:length(sort_gamma)
        if (sort_gamma(ii) > gamma_threshold)
            count = count + 1;
            CentersIdx(count) = Index(ii);
        end
        if (count >= 30) 
            break;
        end
    end

    % Stage 3: Assign samples to the nearest centers
    if isempty(CentersIdx)
        SubPopulations = {Population};
        Centers = mean(Population, 1);
        return;
    end

    Centers = Population(CentersIdx, :);
    distances = pdist2(Population, Centers);
    [~, clusterIndices] = min(distances, [], 2);
    numClusters = length(CentersIdx);
    SubPopulations = cell(numClusters, 1);
    for k = 1:numClusters
        SubPopulations{k} = Population(clusterIndices == k, :);
    end

    validClusters = cellfun(@(x) size(x,1) >= 3, SubPopulations);
    SubPopulations = SubPopulations(validClusters);
    Centers = Centers(validClusters, :);
end