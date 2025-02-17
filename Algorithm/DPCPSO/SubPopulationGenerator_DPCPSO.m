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
function [Swarm, Problem] = SubPopulationGenerator_DPCPSO(Dimension, MinCoordinate, MaxCoordinate, PopulationSize, Problem)
%% Perform Density Peak Clustering
[SubPops, Centers] = DensityPeakClustering(... 
    MinCoordinate + ((MaxCoordinate - MinCoordinate) .* rand(PopulationSize, Dimension)), ...
    Problem.PeakNumber);

population = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[], 'IsExcluded', []); 
Swarm = repmat(population, [length(SubPops), 1]);

% for k = 1:length(SubPops)
%     Swarm(k).X = SubPops{k};  % Assign the sub-population's particles
%     Swarm(k).Velocity = -4 + (4 - (-4)) * rand(size(Swarm(k).X));  % Initialize particle velocities
%     Swarm(k).Shifts = [];  % No shifts at the start
%     [Swarm(k).FitnessValue, Problem] = fitness(Swarm(k).X, Problem);  % Compute fitness
%     Swarm(k).PbestPosition = Swarm(k).X;  % Set personal best position to current position
%     Swarm(k).PbestValue = Swarm(k).FitnessValue;  % Set personal best value to current fitness
%     Swarm(k).IsConverged = 0;  % Initially, not converged
%     Swarm(k).IsStagnated = 0;  % Initially, not stagnated
%     Swarm(k).IsExcluded = 0;  % Initially, not excluded
%     Swarm(k).localIter = 0;
%     Swarm(k).StagnationCounter = zeros(size(Swarm(k).X, 1), 1);  % Initialize stagnation counter
% 
%     [max_fitness, best_idx] = max(Swarm(k).FitnessValue);  % Find the best fitness value in the sub-population
%     Swarm(k).GbestID = best_idx;  % Store the index of the best fitness
%     Swarm(k).GbestPosition = Swarm(k).PbestPosition(best_idx, :);  % Set the global best position
%     Swarm(k).GbestValue = max_fitness;  % Set the global best value
% end

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

    % if ~isempty(CentersIdx)
    %     [~, ClusterID] = min(pdist2(Population, Population(CentersIdx, :)), [], 2);  % Assign each particle to the nearest center
    %     SubPopulations = arrayfun(@(k) Population(ClusterID == k, :), 1:length(CentersIdx), 'UniformOutput', false);  % Create sub-populations
    %     Centers = Population(CentersIdx, :);  % The centers are the particles identified as cluster centers
    % else
    %     SubPopulations = {Population};  % If no centers are found, treat the whole population as a single cluster
    %     Centers = mean(Population, 1);  % The center is the mean of the population
    % end
end
end