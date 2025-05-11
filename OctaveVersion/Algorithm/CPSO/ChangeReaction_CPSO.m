%*********************************CPSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Oct 25, 2021
%
% ------------
% Reference:
% ------------
%
%  Shengxiang Yang & Changhe Li,
%            "A Clustering pop Swarm Optimizer for Locating and Tracking Multiple Optima in Dynamic Environments"
%            IEEE Transactions on Evolutionary Computation (2010).
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer,Problem] = ChangeReaction_CPSO(Optimizer,Problem)
%% Save best pop in all swarms
    savepop.X = zeros(Optimizer.initPopulationSize,Optimizer.Dimension);
    for ii=1 : Optimizer.SwarmNumber
        savepop.X(ii,:) = Optimizer.pop(ii).GbestPosition;
    end
    if(Optimizer.initPopulationSize - Optimizer.SwarmNumber > 0)
        savepop.X(ii+1:end,:) = Optimizer.MinCoordinate + ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate).*rand(Optimizer.initPopulationSize - Optimizer.SwarmNumber,Optimizer.Dimension));
    end
    Optimizer.pop = [];
    Optimizer.SwarmNumber = 0;
    [Optimizer.pop,Problem] = SubPopulationGenerator_CPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,savepop,Optimizer.maxSubsize,Problem);
    Optimizer.SwarmNumber = length(Optimizer.pop);
end