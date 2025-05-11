%********************************mDE*****************************************************
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
function [Optimizer , Problem] = IterativeComponents_mDE(Optimizer,Problem)
TmpSwarmNum = Optimizer.SwarmNumber;
%%Sub-swarm movement
for ii=1 : Optimizer.SwarmNumber
    [~,Optimizer.pop(ii).BestID] = max(Optimizer.pop(ii).FitnessValue);
    Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).X(Optimizer.pop(ii).BestID,:);
    Optimizer.pop(ii).BestFitness = Optimizer.pop(ii).FitnessValue(Optimizer.pop(ii).BestID);
    Optimizer.pop(ii).F = rand(Optimizer.PopulationSize,1);
    Optimizer.pop(ii).Cr = rand(Optimizer.PopulationSize,1);
    %% Mutation
    for jj=1:Optimizer.PopulationSize
        R = randperm(Optimizer.PopulationSize);
        R(R==jj) = [];
        Optimizer.pop(ii).Donor(jj,:) =  Optimizer.pop(ii).BestPosition + Optimizer.pop(ii).F(jj) .* (Optimizer.pop(ii).X(R(1),:)+Optimizer.pop(ii).X(R(2),:)-Optimizer.pop(ii).X(R(3),:)-Optimizer.pop(ii).X(R(4),:));%DE/best/2
    end
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
    Optimizer.pop(ii).X(better,:) = Optimizer.pop(ii).OffspringPosition(better,:);
    Optimizer.pop(ii).FitnessValue(better) = Optimizer.pop(ii).OffspringFitness(better);
    [~,Optimizer.pop(ii).BestID] = max(Optimizer.pop(ii).FitnessValue);
    Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).X(Optimizer.pop(ii).BestID,:);
    Optimizer.pop(ii).BestFitness = Optimizer.pop(ii).FitnessValue(Optimizer.pop(ii).BestID);
end
%% Exclusion
if Optimizer.SwarmNumber>1
    RemoveList = zeros(Optimizer.SwarmNumber,1);
    for ii=1 : Optimizer.SwarmNumber-1
        for jj=ii+1 : Optimizer.SwarmNumber
            if  pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit
                if Optimizer.pop(ii).BestFitness<Optimizer.pop(jj).BestFitness
                    if Optimizer.FreeSwarmID~=ii
                        RemoveList(ii) = 1;
                    else
                        [Optimizer.pop(ii),Problem] = SubPopulationGenerator_mDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                        if Problem.RecentChange == 1
                            return;
                        end
                    end
                else
                    if Optimizer.FreeSwarmID~=jj
                        RemoveList(jj) = 1;
                    else
                        [Optimizer.pop(jj),Problem] = SubPopulationGenerator_mDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
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
    [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_mDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
%% Updating Thresholds
if TmpSwarmNum ~= Optimizer.SwarmNumber
    Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber) ^ (1 / Optimizer.Dimension)));
    Optimizer.ConvergenceLimit = Optimizer.ExclusionLimit;
end