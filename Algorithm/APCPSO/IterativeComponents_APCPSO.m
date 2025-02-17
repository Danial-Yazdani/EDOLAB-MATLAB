%********************************APCPSO*****************************************************
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
function [Optimizer, Problem] = IterativeComponents_APCPSO(Optimizer, Problem)
    % Iterative optimization process for APCPSO including PSO local search, stagnation detection, exclusion, and convergence detection.
    
    %% PSO Local Search Update for Each Sub-Population
    for ii = 1 : Optimizer.SwarmNumber
        % Update the local iteration counter for this sub-population
        if ~isfield(Optimizer.pop(ii), 'localIter') || isempty(Optimizer.pop(ii).localIter)
            Optimizer.pop(ii).localIter = 1;
        else
            Optimizer.pop(ii).localIter = Optimizer.pop(ii).localIter + 1;
        end
        
        % Compute adaptive inertia weight using:
        % omega = omega_max - (omega_max - omega_min) * (localIter / MaxSubPopIterations)
        % Since the problem is unknown, the paper uses the change frequency to calculate MaxSubPopIterations. Here, it is replaced with a constant.
        omega_current = Optimizer.omega_max - (Optimizer.omega_max - Optimizer.omega_min) * (Optimizer.pop(ii).localIter / Optimizer.MaxSubPopIterations);
        
        % Update velocity using the PSO equation
        % Get the number of particles using the length of X
        num_particles = size(Optimizer.pop(ii).X, 1);
        % Update the velocity using the parameters from the population structure
        Optimizer.pop(ii).Velocity = omega_current * Optimizer.pop(ii).Velocity + ...
            Optimizer.c1 * rand(num_particles, Optimizer.Dimension) .* (Optimizer.pop(ii).PbestPosition - Optimizer.pop(ii).X) + ...
            Optimizer.c2 * rand(num_particles, Optimizer.Dimension) .* (repmat(Optimizer.pop(ii).GbestPosition, num_particles, 1) - Optimizer.pop(ii).X);

        
        % Update position
        Optimizer.pop(ii).X = Optimizer.pop(ii).X + Optimizer.pop(ii).Velocity;
        
        % Boundary check for particle positions
        for jj = 1 : size(Optimizer.pop(ii).X,1)
            for kk = 1 : Optimizer.Dimension
                if Optimizer.pop(ii).X(jj,kk) > Optimizer.MaxCoordinate
                    Optimizer.pop(ii).X(jj,kk) = Optimizer.MaxCoordinate;
                    Optimizer.pop(ii).Velocity(jj,kk) = 0;
                elseif Optimizer.pop(ii).X(jj,kk) < Optimizer.MinCoordinate
                    Optimizer.pop(ii).X(jj,kk) = Optimizer.MinCoordinate;
                    Optimizer.pop(ii).Velocity(jj,kk) = 0;
                end
            end
        end
        
        % Evaluate fitness for the sub-population
        [Fitness, Problem] = fitness(Optimizer.pop(ii).X, Problem);
        if Problem.RecentChange == 1
            return;
        end
        Optimizer.pop(ii).FitnessValue = Fitness;
       
        % Update individual best positions and values
        for jj = 1 : size(Optimizer.pop(ii).X,1)
            if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
                Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
                Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
            end
        end
        
        % Update sub-population global best
        [BestPbestValue, BestPbestID] = max(Optimizer.pop(ii).PbestValue);
        if BestPbestValue > Optimizer.pop(ii).GbestValue
            Optimizer.pop(ii).GbestValue = BestPbestValue;
            Optimizer.pop(ii).GbestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID, :);
        end
    end
    
    %% Exclusion Mechanism: Prevent multiple sub-populations from exploring the same peak
    rex = (Optimizer.MaxCoordinate - Optimizer.MinCoordinate)/(2 * Optimizer.SwarmNumber^(1/Optimizer.Dimension));
    for ii = 1 : Optimizer.SwarmNumber-1
        for jj = ii+1 : Optimizer.SwarmNumber
            if Optimizer.pop(ii).IsExcluded == 1 || Optimizer.pop(jj).IsExcluded == 1
                continue;
            end
            % Compute the Euclidean distance between the best positions of two sub-populations
            distance = pdist2(Optimizer.pop(ii).GbestPosition, Optimizer.pop(jj).GbestPosition);
            % If the distance between the best positions is smaller than the exclusion threshold, merge them
            if distance < rex
                if Optimizer.pop(ii).GbestValue > Optimizer.pop(jj).GbestValue
                    Optimizer.pop(ii) = mergeSubPopulations(Optimizer.pop(ii), Optimizer.pop(jj));
                    Optimizer.pop(jj).IsExcluded = 1;
                else
                    Optimizer.pop(jj) = mergeSubPopulations(Optimizer.pop(ii), Optimizer.pop(jj));
                    Optimizer.pop(ii).IsExcluded = 1;
                end
            end
        end
    end
    
    for ii = 1 : Optimizer.SwarmNumber
        if Optimizer.pop(ii).IsExcluded == 1
            Optimizer.pop(ii).X = Optimizer.MinCoordinate + (Optimizer.MaxCoordinate - Optimizer.MinCoordinate) .* rand(size(Optimizer.pop(ii).X));
            Optimizer.pop(ii).Velocity = -5 + (5 - (-5)) * rand(size(Optimizer.pop(ii).X));  % Initialize particle velocities
            Optimizer.pop(ii).Shifts = [];  % No shifts at the start
            [Optimizer.pop(ii).FitnessValue, Problem] = fitness(Optimizer.pop(ii).X, Problem);  % Compute fitness
            if Problem.RecentChange == 1
                return;
            end
            Optimizer.pop(ii).PbestPosition = Optimizer.pop(ii).X;  % Set personal best position to current position
            Optimizer.pop(ii).PbestValue = Optimizer.pop(ii).FitnessValue;  % Set personal best value to current fitness
            Optimizer.pop(ii).IsConverged = 0;  % Initially, not converged
            Optimizer.pop(ii).IsStagnated = 0;  % Initially, not stagnated
            Optimizer.pop(ii).IsExcluded = 0;  % Initially, not excluded

            Optimizer.pop(ii).StagnationCounter = zeros(size(Optimizer.pop(ii).X, 1), 1);  % Initialize stagnation counter
            [max_fitness, best_idx] = max(Optimizer.pop(ii).FitnessValue);  % Find the best fitness value in the sub-population
            Optimizer.pop(ii).GbestID = best_idx;  % Store the index of the best fitness
            Optimizer.pop(ii).GbestPosition = Optimizer.pop(ii).PbestPosition(best_idx, :);  % Set the global best position
            Optimizer.pop(ii).GbestValue = max_fitness;  % Set the global best value
        end
        
    end

    % Convergence Detection: Check if sub-populations have converged
    for ii = 1 : Optimizer.SwarmNumber
        % Calculate convergence radius
        % Initialize the radius as 0
        radius = 0;
        
        % Calculate center position
        center = mean(Optimizer.pop(ii).PbestPosition, 1);  % center is the average position of all particles
        
        % Iterate through each particle to calculate distance to the center
        total_dist = 0;
        num_particles = size(Optimizer.pop(ii).X, 1);
        
        for jj = 1 : num_particles
            % Calculate the Euclidean distance between particle jj and the center
            dist = norm(Optimizer.pop(ii).PbestPosition(jj,:) - center);
            
            % Sum up the distances
            total_dist = total_dist + dist;
        end
        
        % Calculate the average distance (radius)
        radius = total_dist / num_particles;


        % Check if the convergence radius is below the threshold
        if radius < Optimizer.ConvergenceThreshold
            Optimizer.pop(ii).IsConverged = 1;
        else
            Optimizer.pop(ii).IsConverged = 0;
        end
    end
    
    converge_count = 0;
    Gbest_fitness = zeros(Optimizer.SwarmNumber, 1);
    for ii = 1 : Optimizer.SwarmNumber
        Gbest_fitness(ii, 1) = Optimizer.pop(ii).GbestValue;
        if Optimizer.pop(ii).IsConverged == 1
            converge_count = converge_count + 1;
        end
    end
    if converge_count == Optimizer.SwarmNumber
        [~, worst_idx] = min(Gbest_fitness);
        Optimizer.pop(worst_idx).X = Optimizer.MinCoordinate + (Optimizer.MaxCoordinate - Optimizer.MinCoordinate) .* rand(size(Optimizer.pop(ii).X));
        Optimizer.pop(worst_idx).Velocity = -5 + (5 - (-5)) * rand(size(Optimizer.pop(worst_idx).X));  % Initialize particle velocities
        Optimizer.pop(worst_idx).Shifts = [];  % No shifts at the start
        [Optimizer.pop(worst_idx).FitnessValue, Problem] = fitness(Optimizer.pop(worst_idx).X, Problem);  % Compute fitness
        if Problem.RecentChange == 1
            return;
        end
        Optimizer.pop(worst_idx).PbestPosition = Optimizer.pop(worst_idx).X;  % Set personal best position to current position
        Optimizer.pop(worst_idx).PbestValue = Optimizer.pop(worst_idx).FitnessValue;  % Set personal best value to current fitness
        Optimizer.pop(worst_idx).IsConverged = 0;  % Initially, not converged
        Optimizer.pop(worst_idx).IsStagnated = 0;  % Initially, not stagnated
        Optimizer.pop(worst_idx).IsExcluded = 0;  % Initially, not excluded
        Optimizer.pop(worst_idx).StagnationCounter = zeros(size(Optimizer.pop(worst_idx).X, 1), 1);  % Initialize stagnation counter
        [max_fitness, best_idx] = max(Optimizer.pop(worst_idx).FitnessValue);  % Find the best fitness value in the sub-population
        Optimizer.pop(worst_idx).GbestID = best_idx;  % Store the index of the best fitness
        Optimizer.pop(worst_idx).GbestPosition = Optimizer.pop(worst_idx).PbestPosition(best_idx, :);  % Set the global best position
        Optimizer.pop(worst_idx).GbestValue = max_fitness;  % Set the global best value
    end
    if Problem.RecentChange == 1
       return;
    end
end

% Helper function to merge two sub-populations 
function mergedPop = mergeSubPopulations(pop1, pop2)
    mergedPop = struct('X',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'StagnationCounter',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[]);
    % Merge the particles of two sub-populations
    mergedPop.X = [pop1.X; pop2.X];
    mergedPop.FitnessValue = [pop1.FitnessValue; pop2.FitnessValue];
    mergedPop.PbestPosition = [pop1.PbestPosition; pop2.PbestPosition];
    mergedPop.PbestValue = [pop1.PbestValue; pop2.PbestValue];
    mergedPop.GbestValue = max(mergedPop.PbestValue);
    mergedPop.GbestPosition = mergedPop.PbestPosition(find(mergedPop.PbestValue == mergedPop.GbestValue, 1), :);
    mergedPop.Velocity = [pop1.Velocity; pop2.Velocity];
    mergedPop.StagnationCounter = zeros(size(mergedPop.FitnessValue));

    % Step 1: Sort the merged population by fitness value (ascending or descending as required)
    [~, sortedIdx] = sort(mergedPop.FitnessValue, 'descend');  % Sorting in descending order (maximize fitness)

    % Step 2: Remove the worst k particles where k is the size of pop2 (i.e., the number of particles in pop2)
    k = size(pop2.X, 1);  % Number of particles in pop2
    bestIdx = sortedIdx(1:end-k);  % Keep the best particles, excluding the worst k

    % Step 3: Update the merged population by keeping only the best particles
    mergedPop.X = mergedPop.X(bestIdx, :);
    mergedPop.FitnessValue = mergedPop.FitnessValue(bestIdx);
    mergedPop.PbestPosition = mergedPop.PbestPosition(bestIdx, :);
    mergedPop.PbestValue = mergedPop.PbestValue(bestIdx);
    mergedPop.Velocity = mergedPop.Velocity(bestIdx, :);
    mergedPop.StagnationCounter = mergedPop.StagnationCounter(bestIdx);
    
    % Recalculate the GbestValue and GbestPosition for the merged population
    mergedPop.GbestValue = max(mergedPop.PbestValue);
    mergedPop.GbestPosition = mergedPop.PbestPosition(find(mergedPop.PbestValue == mergedPop.GbestValue, 1), :);
    mergedPop.IsConverged = 0;
    mergedPop.IsStagnated = 0;
    mergedPop.IsExcluded = 0;
    mergedPop.localIter = max(pop1.localIter, pop2.localIter);
end
