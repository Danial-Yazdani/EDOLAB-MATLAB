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
    
    % 1. Optimal Particle Calibration
    new_X = zeros(Optimizer.PopulationSize,Optimizer.Dimension);
    new_fitnewss = zeros(Optimizer.PopulationSize,1);
    for i = 1:Optimizer.SwarmNumber
        tryBestPositon = Optimizer.pop(i).GbestPosition;
        Optimizer.pop(i).GbestValue = fitness(Optimizer.pop(i).GbestPosition, Problem);
        tryBestValue = Optimizer.pop(i).GbestValue;
        % Particle calibration: Adjust the historical best in each dimension
        for j = 1:Problem.Dimension
            tempTryPosition = Optimizer.pop(i).GbestPosition;
            % Perform local search for each dimension by adjusting the current best
            tempTryPosition(j) = Optimizer.pop(i).GbestPosition(j) + 0.0001; % small increment
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

    [SubPops, Centers] = DensityPeakClustering(new_X, 10);
    population = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[]);
    Swarm = repmat(population,[length(SubPops),1]);
    
    for k=1:length(SubPops)
        Swarm(k).X =SubPops{k};
        Swarm(k).Velocity = -4 + (4 - (-4)) * rand(size(Swarm(k).X));
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

%% 嵌套聚类函数
function [SubPopulations, Centers] = DensityPeakClustering(Population,P)
    PersistentParameter.ThresholdFormula = @(N,P) -6.07*N*log(P) + 50.5*N; % 公式(8)
    % 阶段1：计算密度和距离
    N = size(Population,1);
    D = pdist2(Population,Population);
    dc = 0.002;
    
    % 高斯核密度计算（公式4）
    rho = zeros(N,1);
    for i = 1:N
       for j = 1:N
           if(i ~= j)
               rho(i, 1) = rho(i, 1) + exp(-(dc/D(i,j)).^2);
           end
       end
    end
    % 相对距离计算（公式5）
    [~, ordrho] = sort(rho,'descend');
    delta = zeros(N,1);
    for i = 1:N
        if i == ordrho(1)
            delta(i) = max(D(i,:));
        else
            higher = ordrho(1:find(ordrho==i)-1);
            delta(i) = min(D(i,higher));
        end
    end
    
    % 阶段2：自动确定聚类中心（公式6,8）
    gamma = rho .* delta;
    gamma_threshold = PersistentParameter.ThresholdFormula(N,P);
    CentersIdx = find(gamma >= gamma_threshold);
    
    % 阶段3：分配样本到最近的中心
    if ~isempty(CentersIdx)
        [~, ClusterID] = min(pdist2(Population,Population(CentersIdx,:)),[],2);
        SubPopulations = arrayfun(@(k) Population(ClusterID==k,:), 1:length(CentersIdx), 'UniformOutput',false);
        Centers = Population(CentersIdx,:);
    else
        SubPopulations = {Population};
        Centers = mean(Population,1);
    end
end