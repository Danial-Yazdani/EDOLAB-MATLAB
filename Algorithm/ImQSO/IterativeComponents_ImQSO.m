%********************************ImQSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: October 2, 2022
%
% ------------
% Reference:
% ------------
%
%  Javidan Kazemi Kordestani et al.,
%            "A note on the exclusion operator in multi-swarm PSO algorithms for dynamic environments"
%            Connection Science, pp. 1–25, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer , Problem] = IterativeComponents_ImQSO(Optimizer,Problem)
%% Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    %     if Optimizer.pop(ii).Active==1
    Optimizer.pop(ii).Velocity = Optimizer.x * (Optimizer.pop(ii).Velocity + (Optimizer.c1 * rand(Optimizer.PopulationSize , Optimizer.Dimension).*(Optimizer.pop(ii).PbestPosition - Optimizer.pop(ii).X)) + (Optimizer.c2*rand(Optimizer.PopulationSize , Optimizer.Dimension).*(repmat(Optimizer.pop(ii).BestPosition,Optimizer.PopulationSize,1) - Optimizer.pop(ii).X)));
    Optimizer.pop(ii).X = Optimizer.pop(ii).X + Optimizer.pop(ii).Velocity;
    for jj=1 : Optimizer.PopulationSize
        for kk=1 : Optimizer.Dimension
            if Optimizer.pop(ii).X(jj,kk) > Optimizer.MaxCoordinate
                Optimizer.pop(ii).X(jj,kk) = Optimizer.MaxCoordinate;
                Optimizer.pop(ii).Velocity(jj,kk) = 0;
            elseif Optimizer.pop(ii).X(jj,kk) < Optimizer.MinCoordinate
                Optimizer.pop(ii).X(jj,kk) = Optimizer.MinCoordinate;
                Optimizer.pop(ii).Velocity(jj,kk) = 0;
            end
        end
    end
    [tmp,Problem] = fitness(Optimizer.pop(ii).X,Problem);
    if Problem.RecentChange == 1
        return;
    end
    Optimizer.pop(ii).FitnessValue = tmp;
    for jj=1 : Optimizer.PopulationSize
        if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
            Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
            Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
        end
    end
    [BestPbestValue,BestPbestID] = max(Optimizer.pop(ii).PbestValue);
    if BestPbestValue>Optimizer.pop(ii).BestValue
        Optimizer.pop(ii).BestValue = BestPbestValue;
        Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
    end
    %     end
    for jj=1 : Optimizer.QuantumNumber
        QuantumPosition = Optimizer.pop(ii).BestPosition + (2*rand(1,Optimizer.Dimension)-1)*Optimizer.QuantumRadius;
        [QuantumFitnessValue,Problem] = fitness(QuantumPosition,Problem);
        if Problem.RecentChange == 1
            return;
        end
        if QuantumFitnessValue > Optimizer.pop(ii).BestValue
            Optimizer.pop(ii).BestValue = QuantumFitnessValue;
            Optimizer.pop(ii).BestPosition = QuantumPosition;
        end
    end
end
%% Exclusion
for ii=1 : Optimizer.SwarmNumber-1
    for jj=ii+1 : Optimizer.SwarmNumber
        if  pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit           
            Exclusion_Probability = ((Optimizer.ExclusionLimit - pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition))/Optimizer.ExclusionLimit) ^ Optimizer.alpha;
            r = rand;
            if r < Exclusion_Probability
                if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                    [Optimizer.pop(ii),Problem] = SubPopulationGenerator_ImQSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                    if Problem.RecentChange == 1
                        return;
                    end
                else
                    [Optimizer.pop(jj),Problem] = SubPopulationGenerator_ImQSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                    if Problem.RecentChange == 1
                        return;
                    end
                end
            end
        end
    end
end
%% Anti Convergence
IsAllConverged = 0;
WorstSwarmValue = inf;
WorstSwarmIndex = [];
for ii=1 : Optimizer.SwarmNumber
    Radius = 0;
    for jj=1 : Optimizer.PopulationSize
        for kk=1 : Optimizer.PopulationSize
            Radius = max(Radius,max(abs(Optimizer.pop(ii).X(jj,:)-Optimizer.pop(ii).X(kk,:))));
        end
    end
    if Radius<Optimizer.ConvergenceLimit
        Optimizer.pop(ii).IsConverged = 1;
    else
        Optimizer.pop(ii).IsConverged = 0;
    end
    IsAllConverged = IsAllConverged + Optimizer.pop(ii).IsConverged;
    if Optimizer.pop(ii).BestValue < WorstSwarmValue
        WorstSwarmValue = Optimizer.pop(ii).BestValue;
        WorstSwarmIndex = ii;
    end
end
if IsAllConverged == Optimizer.SwarmNumber
    [Optimizer.pop(WorstSwarmIndex),Problem] = SubPopulationGenerator_ImQSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
end