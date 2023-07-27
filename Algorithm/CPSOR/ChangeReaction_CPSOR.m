%*********************************CPSOR*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Oct 29, 2021
%
% ------------
% Reference:
% ------------
%
% Changhe Li & Shengxiang Yang,
%    "A general framework of multi-population methods with clustering in undetectable dynamic environments," 
%    IEEE Trans. Evol. Comput., vol. 16, no. 4, pp. 556?577, 2012.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer,Problem] = ChangeReaction_CPSOR(Optimizer,Problem)
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
   [Optimizer.pop(jj).PbestValue,Problem] = fitness(Optimizer.pop(jj).PbestPosition , Problem);
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).GbestPosition;
    [Optimizer.pop(jj).GbestValue,BestPbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).GbestPosition = Optimizer.pop(jj).PbestPosition(BestPbestID,:);
    Optimizer.pop(jj).Velocity = -2 + (4) *rand(size(Optimizer.pop(jj).X,1),Optimizer.Dimension);
end
end