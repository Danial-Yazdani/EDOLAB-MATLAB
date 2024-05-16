%*********************************DynDE*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Nov 9, 2021
%
% ------------
% Reference:
% ------------
%
%  Mendes, R., Mohais, A.
%  "DynDE: a differential evolution for dynamic optimization problems",
%  Proceedings of the IEEE Congress on Evolutionary Computation (CEC 05), pp. 2808-2815. IEEE (2005)
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Swarm,Problem] = SubPopulationGenerator_DynDE(Dimension,MinCoordinate,MaxCoordinate,NumPop,IndivSize,Problem,DiversityFlag,RandomFlag,StrategyFlag)
%% create swarms
population = struct('X',[],'Donor',[],'Trial',[],'CR',[],'F',[],'Strategy',[],'IndivType',[],'Gbest_past_environment',[],'FitnessValue',[],'BestValue',[],'BestPosition',[],'GbestID',[],'Center',[],'CurrentRadius',[],'ReInitState',0);
Swarm = repmat(population,[NumPop,1]);
Rcloud = 1;
for i=1:length(Swarm)
    Swarm(i).Gbest_past_environment = NaN(1,Dimension);
    if StrategyFlag == 0
        Swarm(i).Strategy = randi(7,IndivSize,1);
    else
        Swarm(i).Strategy = repmat(StrategyFlag,IndivSize,1);
    end
    if RandomFlag == 0
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
        Swarm(i).IndivType = ones(IndivSize,1);
        Swarm(i).X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(IndivSize,Dimension));
        [Swarm(i).FitnessValue,Problem] = fitness(Swarm(i).X,Problem);
    elseif DiversityFlag == 2
        NormalIndiv = 5;
        QuantumIndiv = IndivSize - 5;
        Swarm(i).IndivType(1:NormalIndiv,1) = zeros(NormalIndiv,1);
        Swarm(i).IndivType(NormalIndiv+1:IndivSize,1) = repmat(2,QuantumIndiv,1);
        Swarm(i).X(1:NormalIndiv,:) = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(NormalIndiv,Dimension));
        [Swarm(i).FitnessValue(1:NormalIndiv),Problem] = fitness(Swarm(i).X(1:NormalIndiv,:),Problem);
        [~,ID] = max(Swarm(i).FitnessValue(1:NormalIndiv));
        XQuantum = randn(QuantumIndiv,Dimension);
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