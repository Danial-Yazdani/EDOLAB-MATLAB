%*********************************AMP-PSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Aug 23, 2022
%
% ------------
% Reference:
% ------------
%
%  C. Li, T. T. Nguyen, M. Yang, M. Mavrovouniotis and S. Yang,
%  "An Adaptive Multipopulation Framework for Locating and Tracking Multiple Optima," 
%  IEEE Transactions on Evolutionary Computation, vol. 20, no. 4, pp. 590-605, Aug. 2016, doi: 10.1109/TEVC.2015.2504383.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer,Problem] = ChangeReaction_AMPPSO(Optimizer,Problem)
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
   [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);
    Optimizer.pop(jj).PbestValue = Optimizer.pop(jj).FitnessValue;
    Optimizer.pop(jj).PbestPosition = Optimizer.pop(jj).X;
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).GbestPosition;
    [Optimizer.pop(jj).GbestValue,Optimizer.pop(jj).GbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).GbestPosition = Optimizer.pop(jj).PbestPosition(Optimizer.pop(jj).GbestID,:);
    Optimizer.pop(jj).Velocity = -1 + (2) *rand(size(Optimizer.pop(jj).X,1),Optimizer.Dimension);
end
end