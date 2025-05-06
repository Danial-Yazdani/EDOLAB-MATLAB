%*********************************AMP-DE*****************************************
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
% Copyright notice: (c) 2022 Danial Yazdani
%**************************************************************************************************
function [Optimizer,Problem] = ChangeReaction_AMPDE(Optimizer,Problem)
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
   [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
    [Optimizer.pop(jj).BestValue,Optimizer.pop(jj).GbestID] = max(Optimizer.pop(jj).FitnessValue);
    Optimizer.pop(jj).BestPosition = Optimizer.pop(jj).X(Optimizer.pop(jj).GbestID,:);
end
end