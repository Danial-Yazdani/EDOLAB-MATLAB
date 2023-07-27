%**************RPSO***********************************************
%Author: Danial Yazdani
% e-mail: danial DOT yazdani AT gmail DOT com
%Last Edited: February 10, 2022
%
% ------------
% Reference:
% ------------
%
%  Xiaohui Hu and Russell C. Eberhart,
%            "Adaptive particle swarm optimization: detection and response to dynamic systems,"
%             IEEE Congress on Evolutionary Computation, 2002.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_RPSO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.Velocity = zeros(PopulationSize,Dimension);
Optimizer.Shifts = [];
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
Optimizer.PbestPosition = Optimizer.X;
Optimizer.PbestValue = Optimizer.FitnessValue;
[Optimizer.BestValue,GbestID] = max(Optimizer.PbestValue);
Optimizer.BestPosition = Optimizer.PbestPosition(GbestID,:);
end