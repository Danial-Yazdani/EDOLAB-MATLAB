%********************************CESO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: November 4, 2022
%
% ------------
% Reference:
% ------------
%
%  Rodica Ioana Lung and Dumitru Dumitrescu,
%            "A collaborative model for tracking optima in dynamic environments"
%            IEEE Congress on Evolutionary Computation, pp. 564-567, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_CESO(Optimizer,Problem)

[Optimizer.pop,Problem] = SubPopulationGeneratorPop_CESO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSizeSwarm,Problem);
[Optimizer.CRDE,Problem] = SubPopulationGeneratorCRDE_CESO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSizeCRDE,Problem);
end
%% Swarm generator
function [swarm,Problem] = SubPopulationGeneratorPop_CESO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
swarm.Velocity = zeros(PopulationSize,Dimension);
swarm.Shifts = [];
swarm.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[swarm.FitnessValue,Problem] = fitness(swarm.X,Problem);
swarm.PbestPosition = swarm.X;
swarm.PopulationSize = PopulationSize; % Add for different swarm, different size
if Problem.RecentChange == 0
    swarm.PbestValue = swarm.FitnessValue;
    [swarm.BestValue,GbestID] = max(swarm.PbestValue);
    swarm.BestPosition = swarm.PbestPosition(GbestID,:);
else
    swarm.FitnessValue = -inf(PopulationSize,1);
    swarm.PbestValue = swarm.FitnessValue;
    [swarm.BestValue,GbestID] = max(swarm.PbestValue);
    swarm.BestPosition = swarm.PbestPosition(GbestID,:);
end
end
%% CRDE generator 
function [swarm,Problem] = SubPopulationGeneratorCRDE_CESO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
swarm.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[swarm.FitnessValue,Problem] = fitness(swarm.X,Problem);
if Problem.RecentChange == 0
    [swarm.BestValue,GbestID] = max(swarm.FitnessValue);
    swarm.BestPosition = swarm.X(GbestID,:);
else
    swarm.FitnessValue = -inf(PopulationSize,1);
    [swarm.BestValue,GbestID] = max(swarm.FitnessValue);
    swarm.BestPosition = swarm.X(GbestID,:);
end
end

