%*********************************DynPopDE*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Nov 23, 2021
%
% ------------
% Reference:
% ------------
%
%  M. du Plessis and A. Engelbrecht, 
%  "Differential evolution for dynamic environments with unknown numbers of optima, 
%  J. of Global Optim(2013).
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Swarm,Problem] = SubPopulationGenerator_DynPopDE(Dimension,MinCoordinate,MaxCoordinate,NumPop,IndivSize,Problem,DiversityFlag,RandomFlag,StrategyFlag)
%% create swarms
population = struct('X',[],'Donor',[],'Trial',[],'CR',[],'F',[],'Strategy',[],'IndivType',[],'Gbest_past_environment',[],'FitnessValue',[],'BestValue',[],'BestPosition',[],'GbestID',[],'Center',[],'CurrentRadius',[],'ReInitState',0,'DeleteState',0,'Pen',0);
Swarm = repmat(population,[NumPop,1]);
Rcloud = 1;
for i=1:length(Swarm)
    Swarm(i).Gbest_past_environment = NaN(1,Dimension);
    if StrategyFlag == 0
        Swarm(i).Strategy = randi(7,IndivSize,1);
    else
        Swarm(i).Strategy = repmat(StrategyFlag,IndivSize,1);
    end
    if RandomFlag == 2
        Swarm(i).CR = repmat(0.6,IndivSize,1);
        Swarm(i).F = repmat(0.5,IndivSize,1);
    else
        Swarm(i).CR = rand(IndivSize,1);
        Swarm(i).F = rand(IndivSize,1);
    end

    % IndivType:
    % 0: Normal Individual
    % 1: Brownian Individual
    % 2: Quantum Individual
    if DiversityFlag == 1
        BrownNumber = 5;
        Swarm(i).IndivType = ones(IndivSize,1);
        Swarm(i).X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(IndivSize,Dimension));
        [Swarm(i).FitnessValue,Problem] = fitness(Swarm(i).X,Problem);
        FitnessSort = Swarm(i).FitnessValue;
        [~,SortID] = sort(FitnessSort);
        SortID = SortID(1:BrownNumber);
        for jj = SortID'
            sigma = 0.2;
            [Swarm(i).BestValue,Swarm(i).GbestID] = max(Swarm(i).FitnessValue);
            BestPosition(1,:) = Swarm(i).X(Swarm(i).GbestID,:);
            for gg = 1:Problem.Dimension
                BestPosition(1,gg) = BestPosition(1,gg) + normrnd(0,sigma);
                if BestPosition(1,gg) > MaxCoordinate
                   BestPosition(1,gg) = MaxCoordinate;
                elseif BestPosition(1,gg) < MinCoordinate
                   BestPosition(1,gg) = MinCoordinate;
                end
            end
            Swarm(i).X(jj,:) = BestPosition(1,:);
            [BestResult,Problem] = fitness(BestPosition(1,:),Problem);
            Swarm(i).FitnessValue(Swarm(i).GbestID) = BestResult;
            [BestValue,BestID] = max(Swarm(i).FitnessValue);
            if BestValue>Swarm(i).BestValue
               Swarm(i).BestValue = BestValue;
               Swarm(i).BestPosition = Swarm(i).X(BestID,:);
               Swarm(i).GbestID = BestID;
            end
        end
    elseif DiversityFlag == 2
        NormalIndiv = 5;
        QuantumIndiv = IndivSize - 5;
        Swarm(i).IndivType(1:NormalIndiv,1) = zeros(NormalIndiv,1);
        Swarm(i).IndivType(NormalIndiv+1:IndivSize,1) = repmat(2,QuantumIndiv,1);
        Swarm(i).X(1:NormalIndiv,:) = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(NormalIndiv,Dimension));
        [Swarm(i).FitnessValue(1:NormalIndiv),Problem] = fitness(Swarm(i).X(1:NormalIndiv,:),Problem);
        [~,ID] = max(Swarm(i).FitnessValue(1:NormalIndiv));
        XQuantum = normrnd(0,1,QuantumIndiv,Dimension);
        Swarm(i).X(NormalIndiv+1:IndivSize,:) = Swarm(i).X(ID,:) + (XQuantum .* Rcloud * rand(1,1))/sqrt(sum(XQuantum.^2));
        [Swarm(i).FitnessValue(NormalIndiv+1:IndivSize),Problem] = fitness(Swarm(i).X(NormalIndiv+1:IndivSize,:),Problem);
    elseif DiversityFlag == 3
        Swarm(i).IndivType = zeros(IndivSize,1);
        Swarm(i).X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(IndivSize,Dimension));
        [Swarm(i).FitnessValue,Problem] = fitness(Swarm(i).X,Problem);
    end
    Swarm(i).Center = zeros(1,size(Swarm(i).X,2));
    for kk = 1:size(Swarm(i).X,2)
        for ii = 1:size(Swarm(i).X,1)
            Swarm(i).Center(kk) = Swarm(i).Center(kk) + Swarm(i).X(ii,kk);
        end
        Swarm(i).Center(kk) = Swarm(i).Center(kk)/size(Swarm(i).X,1);
    end
    Swarm(i).CurrentRadius = 0.0;
    for ii = 1:size(Swarm(i).X,1)
        Swarm(i).CurrentRadius = Swarm(i).CurrentRadius + sqrt(sum((Swarm(i).X(ii,:) - Swarm(i).Center).^2));
    end
    Swarm(i).CurrentRadius = Swarm(i).CurrentRadius/size(Swarm(i).X,1); 
    Swarm(i).ReInitState = 0;
    if Problem.RecentChange == 0
        [Swarm(i).BestValue,Swarm(i).GbestID] = max(Swarm(i).FitnessValue);
        Swarm(i).BestPosition = Swarm(i).X(Swarm(i).GbestID,:);
    else
        Swarm(i).FitnessValue = -inf(size(Swarm(i).X,1),1);
        [Swarm(i).BestValue,Swarm(i).GbestID] = max(Swarm(i).FitnessValue);
        Swarm(i).BestPosition = Swarm(i).X(Swarm(i).GbestID,:);
    end
end
end