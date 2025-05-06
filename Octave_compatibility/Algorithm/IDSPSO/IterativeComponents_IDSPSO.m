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
function [Optimizer , Problem] = IterativeComponents_IDSPSO(Optimizer,Problem)
Optimizer.Active = ones(1,Optimizer.PopulationSize);
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
            Species(jj).members = [Species(jj).members;SortedIndeces(ii)];  %#ok<*SAGROW>
            break;
        end
    end
    if found == 0
        SpeciesNumber = SpeciesNumber+1;
        Species(SpeciesNumber).members = SortedIndeces(ii);
        Species(SpeciesNumber).seed = SortedIndeces(ii);
    end
end
%% Check Pmax
for jj=1 : SpeciesNumber
    if numel(Species(jj).members) > Optimizer.Pmax
        [~,SortedIndeces] = sort(Optimizer.pop.PbestValue(Species(jj).members));
        for kk = 1 : (numel(Species(jj).members)-Optimizer.Pmax)
            Optimizer.pop.Active(Species(jj).members(SortedIndeces(kk))) = 0;
            Optimizer.pop.X(Species(jj).members(SortedIndeces(kk)),:) = Optimizer.MinCoordinate + (Optimizer.MaxCoordinate-Optimizer.MinCoordinate)*rand(1,Optimizer.Dimension);
            [Optimizer.pop.FitnessValue(Species(jj).members(SortedIndeces(kk))),Problem] = fitness(Optimizer.pop.X(Species(jj).members(SortedIndeces(kk)),:),Problem);
            if Problem.RecentChange == 1
                return
            end
            Optimizer.pop.PbestPosition(Species(jj).members(SortedIndeces(kk)),:) = Optimizer.pop.X(Species(jj).members(SortedIndeces(kk)),:);
            Optimizer.pop.PbestValue(Species(jj).members(SortedIndeces(kk))) = Optimizer.pop.FitnessValue(Species(jj).members(SortedIndeces(kk)));
            Optimizer.pop.Velocity(Species(jj).members(SortedIndeces(kk)),:) = zeros(1,Optimizer.Dimension);
        end
    end
end
%% Anti Convergence
WorstSwarmValue = inf;
WorstSwarmIndex = [];
for ii=1 : SpeciesNumber
    if Optimizer.pop.PbestValue(Species(ii).seed) < WorstSwarmValue
        WorstSwarmValue = Optimizer.pop.PbestValue(Species(ii).seed);
        WorstSwarmIndex = ii;
    end
end
for jj = 1 : numel(Species(WorstSwarmIndex).members)
    if Optimizer.Active(Species(WorstSwarmIndex).members(jj))==1
        Optimizer.pop.Active(Species(WorstSwarmIndex).members(jj)) = 0;
        Optimizer.pop.X(Species(WorstSwarmIndex).members(jj),:) = Optimizer.MinCoordinate + (Optimizer.MaxCoordinate-Optimizer.MinCoordinate)*rand(1,Optimizer.Dimension);
        [Optimizer.pop.FitnessValue(Species(WorstSwarmIndex).members(jj)),Problem] = fitness(Optimizer.pop.X(Species(WorstSwarmIndex).members(jj),:),Problem);
        if Problem.RecentChange == 1
            return
        end
        Optimizer.pop.PbestPosition(Species(WorstSwarmIndex).members(jj),:) = Optimizer.pop.X(Species(WorstSwarmIndex).members(jj),:);
        Optimizer.pop.PbestValue(Species(WorstSwarmIndex).members(jj)) = Optimizer.pop.FitnessValue(Species(WorstSwarmIndex).members(jj));
        Optimizer.pop.Velocity(Species(WorstSwarmIndex).members(jj),:) = zeros(1,Optimizer.Dimension);
    end
end
%% Optimization
for ii=1 : SpeciesNumber
    for jj = 1 : numel(Species(ii).members)
        if Optimizer.Active(Species(ii).members(jj))==1
            Optimizer.pop.LbestPosition = Optimizer.pop.PbestPosition(Species(ii).seed,:);
            Optimizer.pop.Velocity(Species(ii).members(jj),:) =  Optimizer.x * (Optimizer.pop.Velocity(Species(ii).members(jj),:) + (Optimizer.c1*rand(1,Optimizer.Dimension).*(Optimizer.pop.PbestPosition(Species(ii).members(jj),:)-Optimizer.pop.X(Species(ii).members(jj),:))) + (Optimizer.c2*rand(1,Optimizer.Dimension).*(Optimizer.pop.LbestPosition-Optimizer.pop.X(Species(ii).members(jj),:))));
            Optimizer.pop.X(Species(ii).members(jj),:) = Optimizer.pop.X(Species(ii).members(jj),:) +Optimizer.pop.Velocity(Species(ii).members(jj),:);
            for kk=1 : Optimizer.Dimension
                if Optimizer.pop.X(Species(ii).members(jj),kk)>Optimizer.MaxCoordinate
                    Optimizer.pop.X(Species(ii).members(jj),kk)=Optimizer.MaxCoordinate;
                    Optimizer.pop.Velocity(Species(ii).members(jj),kk)=0;
                elseif Optimizer.pop.X(Species(ii).members(jj),kk)<Optimizer.MinCoordinate
                    Optimizer.pop.X(Species(ii).members(jj),kk)=Optimizer.MinCoordinate;
                    Optimizer.pop.Velocity(Species(ii).members(jj),kk)=0;
                end
            end
            [Optimizer.pop.FitnessValue(Species(ii).members(jj)),Problem] = fitness(Optimizer.pop.X(Species(ii).members(jj),:),Problem);
            if Problem.RecentChange == 1
                return
            end
        end
    end
end
tmp = Optimizer.pop.FitnessValue>Optimizer.pop.PbestValue ;
Optimizer.pop.PbestValue(tmp)  = Optimizer.pop.FitnessValue(tmp);
Optimizer.pop.PbestPosition(tmp , :) = Optimizer.pop.X(tmp , :);
[Optimizer.pop.BestValue,BestIndex] = max(Optimizer.pop.PbestValue);
Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(BestIndex,:);
