%********************************AmQSO*****************************************************
%Author: Danial Yazdani
%E-mail: danial DOT yazdani AT gmail DOT com        
%Last Edited: May 15, 2022
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
function [Optimizer , Problem] = IterativeComponents_AmQSO(Optimizer,Problem)
TmpSwarmNum = Optimizer.SwarmNumber;
%% Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    Optimizer.pop(ii).Velocity = Optimizer.x * ...
        (Optimizer.pop(ii).Velocity + (Optimizer.c1 * rand(Optimizer.PopulationSize , Optimizer.Dimension).*(Optimizer.pop(ii).PbestPosition - Optimizer.pop(ii).X)) + ...
        (Optimizer.c2*rand(Optimizer.PopulationSize , Optimizer.Dimension).*(repmat(Optimizer.pop(ii).BestPosition,Optimizer.PopulationSize,1) - Optimizer.pop(ii).X)));
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
end
%% Exclusion
if Optimizer.SwarmNumber>1
    RemoveList = zeros(Optimizer.SwarmNumber,1);
    for ii=1 : Optimizer.SwarmNumber-1
        for jj=ii+1 : Optimizer.SwarmNumber
            if  pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit
                if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                    if Optimizer.FreeSwarmID~=ii
                        RemoveList(ii) = 1;
                    else
                        [Optimizer.pop(ii),Problem] = SubPopulationGenerator_AmQSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                        if Problem.RecentChange == 1
                            return;
                        end
                    end
                else
                    if Optimizer.FreeSwarmID~=jj
                        RemoveList(jj) = 1;
                    else
                        [Optimizer.pop(jj),Problem] = SubPopulationGenerator_AmQSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                        if Problem.RecentChange == 1
                            return;
                        end
                    end
                end
            end
        end
    end
    for kk=Optimizer.SwarmNumber: -1 : 1
        if RemoveList(kk) == 1
            Optimizer.pop(kk) = [];
            Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
            Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
        end
    end
end
%% FreeSwarm Convergence
Radius = 0;
for jj=1 : Optimizer.PopulationSize
    for kk=1 : Optimizer.PopulationSize
        Radius = max(Radius,max(abs(Optimizer.pop(Optimizer.FreeSwarmID).X(jj,:)-Optimizer.pop(Optimizer.FreeSwarmID).X(kk,:))));
    end
end
if Radius<Optimizer.ConvergenceLimit
    Optimizer.SwarmNumber = Optimizer.SwarmNumber+1;
    Optimizer.FreeSwarmID = Optimizer.SwarmNumber;
    [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_AmQSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
%% Updating Thresholds
if TmpSwarmNum ~= Optimizer.SwarmNumber
    Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber) ^ (1 / Optimizer.Dimension)));
    Optimizer.ConvergenceLimit = Optimizer.ExclusionLimit;
end