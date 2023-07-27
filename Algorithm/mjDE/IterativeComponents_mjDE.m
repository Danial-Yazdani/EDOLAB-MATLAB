%********************************mjDE*****************************************************
%Authors: Delaram Yazdani and Danial Yazdani
%E-mails: delaram DOT yazdani AT yahoo DOT com
%         danial DOT yazdani AT gmail DOT com
%Last Edited: January 12, 2022
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "Scaling up dynamic optimization problems: A divide-and-conquer approach"
%             IEEE Transactions on Evolutionary Computation, vol. 24(1), pp. 1 - 15, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% E-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer , Problem] = IterativeComponents_mjDE(Optimizer,Problem)
TmpSwarmNum = Optimizer.SwarmNumber;
%% Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    F_Old = Optimizer.pop(ii).F;
    Cr_Old = Optimizer.pop(ii).Cr;
    F_tmp = rand(Optimizer.PopulationSize,1)<Optimizer.pop(ii).r1;
    Cr_tmp = rand(Optimizer.PopulationSize,1)<Optimizer.pop(ii).r2;
    Optimizer.pop(ii).F(F_tmp) = Optimizer.MinCoordinate + (rand(sum(F_tmp),1) * Optimizer.MaxCoordinate);
    Optimizer.pop(ii).Cr(Cr_tmp) = rand(sum(Cr_tmp),1);
    %% Mutation
    R0 = (1:Optimizer.PopulationSize)';
    R1 = randi(Optimizer.PopulationSize,[Optimizer.PopulationSize,1]);
    R1(R1==R0)=[];
    x=length(R1);
    while(x<Optimizer.PopulationSize)
        tmp = NaN(Optimizer.PopulationSize,1);
        tmp(1:x) = R1;
        tmp(x+1:Optimizer.PopulationSize) = randi(Optimizer.PopulationSize,[Optimizer.PopulationSize-x,1]);
        R1 = tmp;
        R1(R1==R0)=[];
        x=length(R1);
    end
    R2 = randi(Optimizer.PopulationSize,[Optimizer.PopulationSize,1]);
    R2(R2==R0)=NaN;
    R2(R2==R1)=NaN;
    R2(isnan(R2))=[];
    x=length(R2);
    while(x<Optimizer.PopulationSize)
        tmp = NaN(Optimizer.PopulationSize,1);
        tmp(1:x) = R2;
        tmp(x+1:Optimizer.PopulationSize) = randi(Optimizer.PopulationSize,[Optimizer.PopulationSize-x,1]);
        R2 = tmp;
        R2(R2==R0)=NaN;
        R2(R2==R1)=NaN;
        R2(isnan(R2))=[];
        x=length(R2);
    end
    R3 = randi(Optimizer.PopulationSize,[Optimizer.PopulationSize,1]);
    R3(R3==R0)=NaN;
    R3(R3==R1)=NaN;
    R3(R3==R2)=NaN;
    R3(isnan(R3))=[];
    x=length(R3);
    while(x<Optimizer.PopulationSize)
        tmp = NaN(Optimizer.PopulationSize,1);
        tmp(1:x) = R3;
        tmp(x+1:Optimizer.PopulationSize) = randi(Optimizer.PopulationSize,[Optimizer.PopulationSize-x,1]);
        R3 = tmp;
        R3(R3==R0)=NaN;
        R3(R3==R1)=NaN;
        R3(R3==R2)=NaN;
        R3(isnan(R3))=[];
        x=length(R3);
    end
    Optimizer.pop(ii).Donor = Optimizer.pop(ii).X(R1,:) + Optimizer.pop(ii).F .* (Optimizer.pop(ii).X(R2,:)-Optimizer.pop(ii).X(R3,:));%DE/rand/1
    %% Crossover==>binomial
    Optimizer.pop(ii).OffspringPosition = Optimizer.pop(ii).X;%U
    K = sub2ind([Optimizer.PopulationSize,Optimizer.Dimension],(1:Optimizer.PopulationSize)',randi(Optimizer.Dimension,[Optimizer.PopulationSize,1]));
    Optimizer.pop(ii).OffspringPosition(K) = Optimizer.pop(ii).Donor(K);
    CrossoverBinomial = rand(Optimizer.PopulationSize,Optimizer.Dimension)<repmat(Optimizer.pop(ii).Cr,1,Optimizer.Dimension);
    Optimizer.pop(ii).OffspringPosition(CrossoverBinomial) = Optimizer.pop(ii).Donor(CrossoverBinomial);
    %% boundary checking
    LB_tmp1 = Optimizer.pop(ii).OffspringPosition<Optimizer.MinCoordinate;
    LB_tmp2 = ((Optimizer.MinCoordinate + Optimizer.pop(ii).X).*LB_tmp1)/2;
    Optimizer.pop(ii).OffspringPosition(LB_tmp1) = LB_tmp2(LB_tmp1);
    UB_tmp1 = Optimizer.pop(ii).OffspringPosition>Optimizer.MaxCoordinate;
    UB_tmp2 = ((Optimizer.MaxCoordinate + Optimizer.pop(ii).X).*UB_tmp1)/2;
    Optimizer.pop(ii).OffspringPosition(UB_tmp1) = UB_tmp2(UB_tmp1);
    [tmp,Problem] = fitness(Optimizer.pop(ii).OffspringPosition,Problem);
    if Problem.RecentChange == 1
        return;
    end    
    Optimizer.pop(ii).OffspringFitness  = tmp;
    %% Selection==>greedy
    better = Optimizer.pop(ii).OffspringFitness > Optimizer.pop(ii).FitnessValue;
    worse = ~better;
    Optimizer.pop(ii).X(better,:) = Optimizer.pop(ii).OffspringPosition(better,:);
    Optimizer.pop(ii).FitnessValue(better) = Optimizer.pop(ii).OffspringFitness(better);
    Optimizer.pop(ii).F(worse) = F_Old(worse);
    Optimizer.pop(ii).Cr(worse) = Cr_Old(worse);
    [Optimizer.pop(ii).BestValue,Optimizer.pop(ii).GbestID] = max(Optimizer.pop(ii).FitnessValue);
    Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:);
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
                        [Optimizer.pop(ii),Problem] = SubPopulationGenerator_mjDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                        if Problem.RecentChange == 1
                            return;
                        end
                    end
                else
                    if Optimizer.FreeSwarmID~=jj
                        RemoveList(jj) = 1;
                    else
                        [Optimizer.pop(jj),Problem] = SubPopulationGenerator_mjDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
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
Distances = pdist2(Optimizer.pop(Optimizer.FreeSwarmID).X,Optimizer.pop(Optimizer.FreeSwarmID).X)>Optimizer.ConvergenceLimit;
if sum(Distances(:))==0
    Optimizer.SwarmNumber = Optimizer.SwarmNumber+1;
    Optimizer.FreeSwarmID = Optimizer.SwarmNumber;
    [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_mjDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
%% Updating Thresholds
if TmpSwarmNum ~= Optimizer.SwarmNumber
    Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber) ^ (1 / Optimizer.Dimension)));
    Optimizer.ConvergenceLimit = Optimizer.ExclusionLimit;
end