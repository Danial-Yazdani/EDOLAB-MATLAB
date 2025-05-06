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
function [Optimizer, Problem] = IterativeComponents_RPSO(Optimizer,Problem)
%% Sub-swarm movement
Optimizer.pop.Velocity = Optimizer.x * (Optimizer.pop.Velocity + (Optimizer.c1 * rand(Optimizer.PopulationSize , Optimizer.Dimension).*(Optimizer.pop.PbestPosition - Optimizer.pop.X)) + (Optimizer.c2*rand(Optimizer.PopulationSize , Optimizer.Dimension).*(repmat(Optimizer.pop.BestPosition,Optimizer.PopulationSize,1) - Optimizer.pop.X)));
Optimizer.pop.X = Optimizer.pop.X + Optimizer.pop.Velocity;
for jj=1 : Optimizer.PopulationSize
    for kk=1 : Optimizer.Dimension
        if Optimizer.pop.X(jj,kk) > Optimizer.MaxCoordinate
            Optimizer.pop.X(jj,kk) = Optimizer.MaxCoordinate;
            Optimizer.pop.Velocity(jj,kk) = 0;
        elseif Optimizer.pop.X(jj,kk) < Optimizer.MinCoordinate
            Optimizer.pop.X(jj,kk) = Optimizer.MinCoordinate;
            Optimizer.pop.Velocity(jj,kk) = 0;
        end
    end
end
[tmp,Problem] = fitness(Optimizer.pop.X,Problem);
if Problem.RecentChange == 1
    return;
end
Optimizer.pop.FitnessValue = tmp;
for jj=1 : Optimizer.PopulationSize
    if Optimizer.pop.FitnessValue(jj) > Optimizer.pop.PbestValue(jj)
        Optimizer.pop.PbestValue(jj) = Optimizer.pop.FitnessValue(jj);
        Optimizer.pop.PbestPosition(jj,:) = Optimizer.pop.X(jj,:);
    end
end
[BestPbestValue,BestPbestID] = max(Optimizer.pop.PbestValue);
if BestPbestValue>Optimizer.pop.BestValue
    Optimizer.pop.BestValue = BestPbestValue;
    Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestPbestID,:);
end
