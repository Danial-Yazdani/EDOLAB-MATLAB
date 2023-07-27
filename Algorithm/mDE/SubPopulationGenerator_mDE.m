%********************************mDE*****************************************************
%Authors: Delaram Yazdani and Danial Yazdani
%E-mails: delaram DOT yazdani AT yahoo DOT com
%         danial DOT yazdani AT gmail DOT com
%Last Edited: January 12, 2022
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "Scaling up dynamic optimization problems: A divide-and-conquer approach"
%             IEEE Transactions on Evolutionary Computation, vol. 24(1), pp. 1 - 15, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% E-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_mDE(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.FGbest_past_environment = NaN(1,1);
Optimizer.OffspringPosition=NaN(PopulationSize,Dimension);
Optimizer.OffspringFitness=NaN(PopulationSize,1);
Optimizer.Donor = NaN(PopulationSize,Dimension);%V
Optimizer.Cr = ones(PopulationSize,1)*0.9;
Optimizer.F = ones(PopulationSize,1)*0.5;
Optimizer.F_LB = 0.1;
Optimizer.F_UB = 0.9;
Optimizer.r1 = 0.1;
Optimizer.r2 = 0.1;
Optimizer.Shifts = [];
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(PopulationSize,Dimension));
[Optimizer.FitnessValue,Problem] =  fitness(Optimizer.X,Problem);
if Problem.RecentChange == 0
    [~,Optimizer.BestID] = max(Optimizer.FitnessValue);
    Optimizer.BestPosition = Optimizer.X(Optimizer.BestID,:);
    Optimizer.BestFitness = Optimizer.FitnessValue(Optimizer.BestID);
else
    Optimizer.FitnessValue = -inf(PopulationSize,1);
    [~,Optimizer.BestID] = max(Optimizer.FitnessValue);
    Optimizer.BestPosition = Optimizer.X(Optimizer.BestID,:);
    Optimizer.BestFitness = Optimizer.FitnessValue(Optimizer.BestID);
end