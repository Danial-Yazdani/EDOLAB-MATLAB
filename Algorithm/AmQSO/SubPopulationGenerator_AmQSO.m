%********************************AmQSO*****************************************************
%Author: Danial Yazdani
%E-mail: danial DOT yazdani AT gmail DOT com        
%Last Edited: May 15, 2022
%
% ------------
% Reference:
% ------------
%
%  Tim Blackwell et al.,
%            "Particle swarms for dynamic optimization problems"
%             In Swarm Intelligence: Introduction and Applications, Christian Blum and Daniel Merkle (Eds.). Springer Lecture Notes in Computer Science, pp. 193–217, 2008.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_AmQSO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.Velocity = zeros(PopulationSize,Dimension);
Optimizer.Shifts = [];
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