%*********************************psfNBC**********************
%
%Author: Zeneng She
%Last Edited: October 30, 2022
% e-mail: shezeneng AT qq DOT com
%
% ------------
% Reference:
% ------------
%
%  Wenjian Luo et al.,
%       "Identifying Species for Particle Swarm Optimization under Dynamic Environments," 
%       Proceedings of the 2018 IEEE Symposium Series on Computational Intelligence, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial.yazdani AT gmail dot com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_psfNBC(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.Velocity = zeros(PopulationSize,Dimension);
Optimizer.Shifts = [];
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
Optimizer.PbestPosition = Optimizer.X;
Optimizer.PbestValue = Optimizer.FitnessValue;
[Optimizer.BestValue,GbestID] = max(Optimizer.PbestValue);
Optimizer.BestPosition = Optimizer.PbestPosition(GbestID,:);


max_v=(MaxCoordinate-MinCoordinate)/2;              
min_v=-max_v;
Optimizer.Velocity = rand(PopulationSize,Dimension)*(max_v-min_v)+min_v;
end