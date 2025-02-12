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
function [Optimizer, Problem] = IterativeComponents_DPCPSO(Optimizer, Problem)
    % Iterative optimization process for DPCPSO including PSO local search, stagnation detection, exclusion, and convergence detection.
    
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
        omega_current = Optimizer.omega_max - (Optimizer.omega_max - Optimizer.omega_min) * (Optimizer.pop(ii).localIter / Optimizer.MaxSubPopIterations);
        
        % Update velocity using the PSO equation
        % Get the number of particles using the length of X
        num_particles = length(Optimizer.pop(ii).X);

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
        
        Optimizer.pop(ii).FitnessValue = Fitness;
       
        % Update individual best positions and values
        for jj = 1 : size(Optimizer.pop(ii).X,1)
            if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
                Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
                Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
                Optimizer.pop(ii).StagnationCounter(jj) = 0;
            else
                Optimizer.pop(ii).StagnationCounter(jj) = Optimizer.pop(ii).StagnationCounter(jj) + 1;
            end
        end
        
        % Update sub-population global best
        [BestPbestValue, BestPbestID] = max(Optimizer.pop(ii).PbestValue);
        if BestPbestValue > Optimizer.pop(ii).GbestValue
            Optimizer.pop(ii).GbestValue = BestPbestValue;
            Optimizer.pop(ii).GbestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID, :);
        end

        % Reinitialize stagnant particles if stagnation exceeds the threshold
        for jj = 1 : size(Optimizer.pop(ii).X,1)
            if Optimizer.pop(ii).StagnationCounter(jj) >= Optimizer.StagnationThreshold
                Optimizer.pop(ii).X(jj,:) = Optimizer.MinCoordinate + (Optimizer.MaxCoordinate - Optimizer.MinCoordinate) * rand(1, Optimizer.Dimension);
                Optimizer.pop(ii).Velocity(jj,:) = -4 + (4 - (-4)) * rand(size(Optimizer.pop(ii).X(jj,:)));
                Optimizer.pop(ii).StagnationCounter(jj) = 0;
                [Optimizer.pop(ii).FitnessValue(jj), Problem] = fitness(Optimizer.pop(ii).X(jj,:), Problem);
                Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
                Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);

            end
        end
    end
    
    %% Exclusion Mechanism: Prevent multiple sub-populations from exploring the same peak
    toDelete = [];
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
                    toDelete = [toDelete, jj];
                else
                    Optimizer.pop(jj) = mergeSubPopulations(Optimizer.pop(ii), Optimizer.pop(jj));
                    Optimizer.pop(ii).IsExcluded = 1;
                    toDelete = [toDelete, ii];
                end
            end
        end
    end
    toDelete = unique(toDelete);
    Optimizer.SwarmNumber = Optimizer.SwarmNumber - length(toDelete);
    for i = length(toDelete):-1:1
        Optimizer.pop(toDelete(i):end-1) = Optimizer.pop(toDelete(i)+1:end);
        Optimizer.pop(end) = [];
    end

    % Convergence Detection: Check if sub-populations have converged
    for ii = 1 : Optimizer.SwarmNumber
        % Calculate convergence radius
        % Initialize the radius as 0
        radius = 0;
        
        % Calculate center position
        center = mean(Optimizer.pop(ii).X, 1);  % center is the average position of all particles
        
        % Iterate through each particle to calculate distance to the center
        total_dist = 0;
        num_particles = size(Optimizer.pop(ii).X, 1);
        
        for jj = 1 : num_particles
            % Calculate the Euclidean distance between particle jj and the center
            dist = norm(Optimizer.pop(ii).X(jj,:) - center);
            
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
