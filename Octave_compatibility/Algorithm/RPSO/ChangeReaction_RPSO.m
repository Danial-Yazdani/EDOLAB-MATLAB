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
function [Optimizer,Problem] = ChangeReaction_RPSO(Optimizer,Problem)
[~,SortedList]=sort(Optimizer.pop.PbestValue);
for jj=1: Optimizer.NumberOfRandomizingParticles
    Optimizer.pop.X(SortedList(jj),:) =  Optimizer.MinCoordinate + (( Optimizer.MaxCoordinate- Optimizer.MinCoordinate).*rand(1,Optimizer.Dimension));
    Optimizer.pop.Velocity(SortedList(jj),:) = zeros(1,Optimizer.Dimension);
    Optimizer.pop.PbestPosition(SortedList(jj),:) = Optimizer.pop.X(SortedList(jj),:);
end
[Optimizer.pop.PbestValue,Problem] = fitness(Optimizer.pop.PbestPosition,Problem);
[Optimizer.pop.BestValue,BestPbestID] = max(Optimizer.pop.PbestValue);
Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestPbestID,:);
end