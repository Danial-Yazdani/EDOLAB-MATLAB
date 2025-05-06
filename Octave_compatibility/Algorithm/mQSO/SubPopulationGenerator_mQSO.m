%********************************mQSO*****************************************************
%Author: Danial Yazdani
%E-mail: danial DOT yazdani AT gmail DOT com
%Last Edited: October 5, 2022
%
% ------------
% Reference:
% ------------
%
%  Tim Blackwell and Juergen Branke,
%            "Multiswarms, exclusion, and anti-convergence in dynamic environments"
%            IEEE Transactions on Evolutionary Computation, vol 10(4), pp. 459-472, 2006.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% E-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_mQSO(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.Velocity = zeros(PopulationSize,Dimension);
Optimizer.Shifts = [];
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
Optimizer.PbestPosition = Optimizer.X;
Optimizer.IsConverged = 0;
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