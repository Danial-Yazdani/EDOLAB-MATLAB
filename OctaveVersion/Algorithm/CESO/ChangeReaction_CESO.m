%********************************CESO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: November 4, 2022
%
% ------------
% Reference:
% ------------
%
%  Rodica Ioana Lung and Dumitru Dumitrescu,
%            "A collaborative model for tracking optima in dynamic environments"
%            IEEE Congress on Evolutionary Computation, pp. 564-567, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_CESO(Optimizer,Problem)
%% Transmitting information from CRDE to pop    
if pdist2(Optimizer.CRDE.BestPosition,Optimizer.pop.BestPosition)<Optimizer.theta
    if Optimizer.PopulationSizeCRDE > Optimizer.PopulationSizeSwarm
        [~,SortedIndeces] = sort(Optimizer.CRDE.FitnessValue,'descend');
        Optimizer.pop.X = Optimizer.CRDE.X(SortedIndeces(1:Optimizer.PopulationSizeSwarm),:);
    else
        Optimizer.pop.X = Optimizer.CRDE.X;
    end
    Optimizer.pop.PbestPosition = Optimizer.pop.X;
    Optimizer.pop.Velocity = Optimizer.Vmin + (Optimizer.Vmax-Optimizer.Vmin).*rand(Optimizer.PopulationSizeSwarm,Optimizer.Dimension);
end

%% Re-evaluate population
[Optimizer.pop.PbestValue,Problem] = fitness(Optimizer.pop.PbestPosition , Problem);
[Optimizer.pop.BestValue,BestPbestID] = max(Optimizer.pop.PbestValue);
Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestPbestID,:);

[Optimizer.CRDE.FitnessValue,Problem] = fitness(Optimizer.CRDE.X , Problem);
Optimizer.CRDE.BestPosition = Optimizer.pop.BestPosition;
Optimizer.CRDE.BestValue = Optimizer.pop.BestValue;
end