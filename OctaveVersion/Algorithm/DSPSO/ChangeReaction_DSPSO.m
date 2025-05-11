%********************************DSPSO*****************************************************
%Authors: Delaram Yazdani and Danial Yazdani
%E-mails: delaram DOT yazdani AT yahoo DOT com
%         danial DOT yazdani AT gmail DOT com
%Last Edited: September 23, 2021
%
% ------------
% Reference:
% ------------
%
%  Daniel Parrott and Xiaodong Li,
%            "Locating and tracking multiple dynamic optima by a particle swarm model using speciation"
%             IEEE Transactions on Evolutionary Computation 10, 4 (2006), pp. 440–458.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_DSPSO(Optimizer,Problem)
for ii=1 : Optimizer.PopulationSize
    [Optimizer.pop.PbestValue(ii),Problem] = fitness(Optimizer.pop.PbestPosition(ii,:),Problem);    
end
[BestValue,BestIndex] = max(Optimizer.pop.PbestValue);
Optimizer.pop.BestValue = BestValue;
Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestIndex,:);
