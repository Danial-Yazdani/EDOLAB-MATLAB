%*********************************DynPopDE*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Nov 23, 2021
%
% ------------
% Reference:
% ------------
%
%  M. du Plessis and A. Engelbrecht, 
%  "Differential evolution for dynamic environments with unknown numbers of optima, 
%  J. of Global Optim(2013).
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer,Problem] = ChangeReaction_DynPopDE(Optimizer,Problem)
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
   [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
    [Optimizer.pop(jj).BestValue,Optimizer.pop(jj).GbestID] = max(Optimizer.pop(jj).FitnessValue);
    Optimizer.pop(jj).BestPosition = Optimizer.pop(jj).X(Optimizer.pop(jj).GbestID,:);
end
Optimizer.Iteration = 0;
Optimizer.EvolveID = 0;
end