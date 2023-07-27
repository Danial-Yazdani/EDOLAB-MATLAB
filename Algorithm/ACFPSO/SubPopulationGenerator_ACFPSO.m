%********************************ACFPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: October 5, 2022
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "Adaptive control of subpopulations in evolutionary dynamic optimization"
%            IEEE Transactions on Cybernetics, vol. 52(7), pp. 6476 - 6489, 2020.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_ACFPSO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.PreviousGbestPosition = NaN(1,Dimension);
Optimizer.Velocity = zeros(PopulationSize,Dimension);
Optimizer.Shifts = [];
Optimizer.Sleep = 0;
Optimizer.IterationCounter = 0;
Optimizer.phase = 1;% 1=explorere, 2= exploiter, 3=tracker
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
Optimizer.PbestPosition = Optimizer.X;
Optimizer.Center = mean(Optimizer.PbestPosition);
Optimizer.Diversity = max([(max(Optimizer.PbestPosition) - Optimizer.Center) ; (Optimizer.Center-min(Optimizer.PbestPosition))]);
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