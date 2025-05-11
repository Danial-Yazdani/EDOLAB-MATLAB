%********************************TMIPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 21, 2022
%
% ------------
% Reference:
% ------------
%
%  Hongfeng Wang et al.,
%            "Triggered Memory-Based Swarm Optimization in Dynamic Environments"
%            Applications of Evolutionary Computing, pp. 637-646, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_TMIPSO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Velocity = zeros(PopulationSize,Dimension);
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
Optimizer.PbestPosition = Optimizer.X;
if Problem.RecentChange == 0
    Optimizer.PbestValue = Optimizer.FitnessValue;
    [Optimizer.BestValue,GbestID] = max(Optimizer.PbestValue);
    Optimizer.BestPosition = Optimizer.PbestPosition(GbestID,:);
else
    Optimizer.FitnessValue = -inf(PopulationSize,1);
    Optimizer.PbestValue = Optimizer.FitnessValue;
    [Optimizer.BestValue,GbestID] = max(Optimizer.PbestValue);
    Optimizer.BestPosition = Optimizer.PbestPosition(GbestID,:);
end
Optimizer.fitness_history = Optimizer.BestValue;
