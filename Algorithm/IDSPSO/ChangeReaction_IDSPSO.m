%********************************IDSPSO*****************************************************
%Authors: Delaram Yazdani and Danial Yazdani
%E-mails: delaram DOT yazdani AT yahoo DOT com
%         danial DOT yazdani AT gmail DOT com
%Last Edited: September 23, 2021
%
% ------------
% Reference:
% ------------
%
%  Tim Blackwell et al.,
%            "Particle swarms for dynamic optimization problems"
%             In Swarm Intelligence: Introduction and Applications, Christian Blum and Daniel Merkle (Eds.). Springer Lecture Notes in Computer Science, pp. 193–217, 2008.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_IDSPSO(Optimizer,Problem)
[SortedValues,SortedIndeces] = sort(Optimizer.pop.PbestValue,'descend');
clear Species;
SpeciesNumber = 1;
Species(1).seed = SortedIndeces(1);
Species(1).members = SortedIndeces(1);
for ii=2:Optimizer.PopulationSize
    found = 0;
    for jj=1 : SpeciesNumber
        if pdist2(Optimizer.pop.PbestPosition(Species(jj).seed,:),Optimizer.pop.PbestPosition(SortedIndeces(ii),:))<Optimizer.Radius
            found = 1;
            Species(jj).members = [Species(jj).members;SortedIndeces(ii)];
            break;
        end
    end
    if found == 0
        SpeciesNumber = SpeciesNumber+1;
        Species(SpeciesNumber).members = SortedIndeces(ii);
        Species(SpeciesNumber).seed = SortedIndeces(ii);
    end
end

for ii=1 : SpeciesNumber
    for jj=1 : numel(Species(ii).members)
        Optimizer.pop.X(Species(ii).members(jj),:) = Optimizer.pop.PbestPosition(Species(ii).seed,:) + (2*rand(1,Optimizer.Dimension)-1)*Optimizer.QuantumRadius;
        [Optimizer.pop.FitnessValue(Species(ii).members(jj)),Problem] = fitness(Optimizer.pop.X(Species(ii).members(jj),:),Problem);
        Optimizer.pop.PbestValue(Species(ii).members(jj)) = Optimizer.pop.FitnessValue(Species(ii).members(jj));
        Optimizer.pop.PbestPosition(Species(ii).members(jj),:) = Optimizer.pop.X(Species(ii).members(jj),:);
    end
end
[Optimizer.pop.BestValue,BestIndex] = max(Optimizer.pop.PbestValue);
Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestIndex,:);