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
%% DPC Clustering Core Parameters
PersistentParameter.PeakNumber = 10; % Default number of peaks (Please note that since the algorithm cannot obtain the number of peaks in real-world problems, a default value is used here as a substitute)

%% Perform Density Peak Clustering
[SubPops, Centers] = DensityPeakClustering(... 
    MinCoordinate + ((MaxCoordinate - MinCoordinate) .* rand(PopulationSize, Dimension)), ...
    PersistentParameter.PeakNumber);

population = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[], 'IsExcluded', []); 
Swarm = repmat(population, [length(SubPops), 1]);

for k = 1:length(SubPops)
    Swarm(k).X = SubPops{k};  % Assign the sub-population's particles
    Swarm(k).Velocity = -4 + (4 - (-4)) * rand(size(Swarm(k).X));  % Initialize particle velocities
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

%% Nested Clustering Function
function [SubPopulations, Centers] = DensityPeakClustering(Population, P)
    PersistentParameter.ThresholdFormula = @(N, P) -6.07 * N * log(P) + 50.5 * N; % Formula (8)
    
    % Stage 1: Compute density and distance
    N = size(Population, 1);  % Number of particles
    D = pdist2(Population, Population);  % Pairwise distances between particles
    dc = 0.002;  % A cutoff value for the distance
    
    % Gaussian kernel density calculation
    rho = zeros(N, 1);  % Density initialization
    for i = 1:N
       for j = 1:N
           if(i ~= j)
               rho(i, 1) = rho(i, 1) + exp(-(dc / D(i,j))^2);  % Compute density based on distance
           end
       end
    end
    
    % Relative distance calculation
    [~, ordrho] = sort(rho, 'descend');  % Sort the density in descending order
    delta = zeros(N, 1);  % Initialize relative distance
    for i = 1:N
        if i == ordrho(1)
            delta(i) = max(D(i, :));  % If the particle is the highest density, its relative distance is the largest distance
        else
            higher = ordrho(1:find(ordrho == i) - 1);  % Particles with higher density
            delta(i) = min(D(i, higher));  % The minimum distance to particles with higher density
        end
    end
    
    % Stage 2: Automatically determine cluster centers
    gamma = rho .* delta;  % Compute the gamma value based on density and relative distance
    gamma_threshold = PersistentParameter.ThresholdFormula(N, P);  % Threshold value based on formula
    CentersIdx = find(gamma >= gamma_threshold);  % Identify the potential cluster centers based on gamma
    
    % Stage 3: Assign samples to the nearest centers
    if ~isempty(CentersIdx)
        [~, ClusterID] = min(pdist2(Population, Population(CentersIdx, :)), [], 2);  % Assign each particle to the nearest center
        SubPopulations = arrayfun(@(k) Population(ClusterID == k, :), 1:length(CentersIdx), 'UniformOutput', false);  % Create sub-populations
        Centers = Population(CentersIdx, :);  % The centers are the particles identified as cluster centers
    else
        SubPopulations = {Population};  % If no centers are found, treat the whole population as a single cluster
        Centers = mean(Population, 1);  % The center is the mean of the population
    end
end
end