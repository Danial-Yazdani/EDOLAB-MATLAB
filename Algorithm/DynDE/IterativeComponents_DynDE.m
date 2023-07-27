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
function [Optimizer, Problem] = IterativeComponents_DynDE(Optimizer,Problem)
%% Sub-pop movements
for ii=1 : Optimizer.SwarmNumber
     Optimizer.pop(ii).Donor = zeros(size(Optimizer.pop(ii).X,1),Optimizer.Dimension);
     Optimizer.pop(ii).Trial = zeros(size(Optimizer.pop(ii).X,1),Optimizer.Dimension);
   %% Mutation
     Optimizer.pop(ii).Donor = Mutation(Optimizer.pop(ii));
   %% Crossover
     for pp =1 : size(Optimizer.pop(ii).X,1)
         if(Optimizer.pop(ii).IndivType(pp) ~= 2)
             for dd = 1:Optimizer.Dimension
                 rnd = rand(1,1);
                 randj = randi([1,Optimizer.Dimension]);
                 if(rnd < Optimizer.pop(ii).CR(pp) || dd == randj)
                     Optimizer.pop(ii).Trial(pp,dd) = Optimizer.pop(ii).Donor(pp,dd);
                 else
                     Optimizer.pop(ii).Trial(pp,dd) = Optimizer.pop(ii).X(pp,dd);
                 end
                 if Optimizer.pop(ii).Trial(pp,dd) > Optimizer.MaxCoordinate
                        Optimizer.pop(ii).Trial(pp,dd) = Optimizer.MaxCoordinate;
                 elseif(Optimizer.pop(ii).Trial(pp,dd) < Optimizer.MinCoordinate)
                        Optimizer.pop(ii).Trial(pp,dd) = Optimizer.MinCoordinate;
                 end
             end
            %% Select
             [tempFit,Problem] = fitness(Optimizer.pop(ii).Trial(pp,:),Problem);
             if(tempFit > Optimizer.pop(ii).FitnessValue(pp))
                 Optimizer.pop(ii).X(pp,:) = Optimizer.pop(ii).Trial(pp,:);
                 Optimizer.pop(ii).FitnessValue(pp) = tempFit;
             end
             if Problem.RecentChange == 1
                 return;
             end
         end
     end
     [BestValue,BestID] = max(Optimizer.pop(ii).FitnessValue);
     if BestValue>Optimizer.pop(ii).BestValue
        Optimizer.pop(ii).BestValue = BestValue;
        Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).X(BestID,:);
        Optimizer.pop(ii).GbestID = BestID;
     end
     if(Optimizer.DiversityFlag == 2)
         Rcloud = 1;
         for pp =1 : size(Optimizer.pop(ii).X,1)
             if(Optimizer.pop(ii).IndivType(pp) == 2)
                 if(pp ~= Optimizer.pop(ii).GbestID)
                    XQuantum = normrnd(0,1,1,Optimizer.Dimension);
                    Optimizer.pop(ii).X(pp,:) = Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:) + (XQuantum .* Rcloud * rand(1,1))/sqrt(sum(XQuantum.^2));
                    for dd = 1:Optimizer.Dimension
                        if Optimizer.pop(ii).X(pp,dd) > Optimizer.MaxCoordinate
                                Optimizer.pop(ii).X(pp,dd) = Optimizer.MaxCoordinate;
                        elseif(Optimizer.pop(ii).X(pp,dd) < Optimizer.MinCoordinate)
                                Optimizer.pop(ii).X(pp,dd) = Optimizer.MinCoordinate;
                        end
                    end
                    [Optimizer.pop(ii).FitnessValue(pp),Problem] = fitness(Optimizer.pop(ii).X(pp,:),Problem);
                 end
             end
         end
         [BestValue,BestID] = max(Optimizer.pop(ii).FitnessValue);
         if BestValue>Optimizer.pop(ii).BestValue
            Optimizer.pop(ii).BestValue = BestValue;
            Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).X(BestID,:);
            Optimizer.pop(ii).GbestID = BestID;
         end
         if Problem.RecentChange == 1
            return;
         end
     end
end
%% Brownian Individuals
if(Optimizer.DiversityFlag == 1)
    for ii=1 : Optimizer.SwarmNumber
        FitnessSort = Optimizer.pop(ii).FitnessValue;
        [~,SortID] = sort(FitnessSort);
        SortID = SortID(1:Optimizer.BrownNumber);
        for jj = SortID'
            sigma = 0.2;
            BestPosition(1,:) = Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:);
            for gg = 1:Problem.Dimension
                BestPosition(1,gg) = BestPosition(1,gg) + normrnd(0,sigma);
                if BestPosition(1,gg) > Optimizer.MaxCoordinate
                   BestPosition(1,gg) = Optimizer.MaxCoordinate;
                elseif BestPosition(1,gg) < Optimizer.MinCoordinate
                   BestPosition(1,gg) = Optimizer.MinCoordinate;
                end
            end
            [BestResult,Problem] = fitness(BestPosition(1,:),Problem);
            if(BestResult > Optimizer.pop(ii).FitnessValue(jj))
                Optimizer.pop(ii).X(jj,:) = BestPosition(1,:);
                Optimizer.pop(ii).FitnessValue(jj) = BestResult;
                [BestValue,BestID] = max(Optimizer.pop(ii).FitnessValue);
                if(BestValue > Optimizer.pop(ii).BestValue)
                    Optimizer.pop(ii).BestValue = BestValue;
                    Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).X(BestID,:);
                    Optimizer.pop(ii).GbestID = BestID;
                end
            end
            if Problem.RecentChange == 1
                return;
            end
        end
    end
    Optimizer.pop(ii).Center = UpdateCenter(Optimizer.pop(ii));
    Optimizer.pop(ii).CurrentRadius = UpdateCurRadius(Optimizer.pop(ii));
end

%% Check overlapping
for ii=1 : Optimizer.SwarmNumber-1
    for jj=ii+1 : Optimizer.SwarmNumber
        dis = sqrt(sum((Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:) - Optimizer.pop(jj).X(Optimizer.pop(jj).GbestID,:)).^2));
        if(Optimizer.pop(ii).ReInitState == 0 && Optimizer.pop(jj).ReInitState == 0 && dis < Optimizer.ExclusionLimit)
            if(Optimizer.pop(ii).FitnessValue(Optimizer.pop(ii).GbestID) > Optimizer.pop(jj).FitnessValue(Optimizer.pop(ii).GbestID))
                Optimizer.pop(jj).ReInitState = 1;
            else
                Optimizer.pop(ii).ReInitState = 1;
            end
        end
    end
end

for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).ReInitState == 1)
        [Optimizer.pop(ii),Problem] = SubPopulationGenerator_DynDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,1,Optimizer.IndivSize,Problem,Optimizer.DiversityFlag,Optimizer.RandomFlag,Optimizer.StrategyFlag);
    end
end

end
%% Update Current Raduis
function Center = UpdateCenter(Swarm)
Center = zeros(1,size(Swarm.X,2));
for kk = 1:size(Swarm.X,2)
   for jj = 1:size(Swarm.X,1)
       Center(kk) = Center(kk) + Swarm.X(jj,kk);
   end
   Center(kk) = Center(kk)/size(Swarm.X,1);
end
end


function CurrentRadius = UpdateCurRadius(Swarm)
    CurrentRadius = 0.0;
    for jj=1 : size(Swarm.X,1)
        CurrentRadius = CurrentRadius + sqrt(sum((Swarm.X(jj,:) - Swarm.Center).^2));
    end
    CurrentRadius = CurrentRadius / size(Swarm.X,1);
end

%% Mutation
function Donor = Mutation(Swarm)
Donor = zeros(size(Swarm.X,1),size(Swarm.X,2));
for pp =1 : size(Swarm.X,1)
    if(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 4) %DE/BEST/2 
        ID = 1:size(Swarm.X,1);
        Xb = Swarm.BestPosition;
        ID(Swarm.GbestID) = [];
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        ID4 = randi([1,length(ID)]);
        X4 = Swarm.X(ID(ID4),:);
        ID(ID4) = [];
        ID5 = randi([1,length(ID)]);
        X5 = Swarm.X(ID(ID5),:);
        ID(ID5) = [];
        Donor(pp,:) = Xb + Swarm.F(pp) * (X2 + X3 - X4 - X5);
    elseif(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 3) %DE/BEST/1 
        ID = 1:size(Swarm.X,1);
        Xb = Swarm.BestPosition;
        ID(Swarm.GbestID) = [];
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        Donor(pp,:) = Xb + Swarm.F(pp) * (X2 - X3);
    elseif(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 2) %DE/RAND/2
        ID = 1:size(Swarm.X,1);
        ID1 = randi([1,length(ID)]);
        X1 = Swarm.X(ID(ID1),:);
        ID(ID1) = [];
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        ID4 = randi([1,length(ID)]);
        X4 = Swarm.X(ID(ID4),:);
        ID(ID4) = [];
        ID5 = randi([1,length(ID)]);
        X5 = Swarm.X(ID(ID5),:);
        ID(ID5) = [];
        Donor(pp,:) = X1 + Swarm.F(pp) * (X2 + X3 - X4 - X5);
    elseif(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 1) %DE/RAND/1
        ID = 1:size(Swarm.X,1);
        ID1 = randi([1,length(ID)]);
        X1 = Swarm.X(ID(ID1),:);
        ID(ID1) = [];
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        Donor(pp,:) = X1 + Swarm.F(pp) * (X2 - X3);
    elseif(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 5) %DE/RAND-TO-BEST/1
        Lamda = Swarm.F(pp);
        ID = 1:size(Swarm.X,1);
        Xb = Swarm.BestPosition;
        ID(Swarm.GbestID) = [];
        ID1 = randi([1,length(ID)]);
        X1 = Swarm.X(ID(ID1),:);
        ID(ID1) = [];
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        Donor(pp,:) = X1 + Lamda * (Xb - X1) + Swarm.F(pp) * (X2 - X3);
    elseif(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 6) %DE/CURRENT-TO-RAND/1 
        Lamda = Swarm.F(pp);
        ID = 1:size(Swarm.X,1);
        X_Current = Swarm.X(pp,:);
        ID(pp) = [];
        ID1 = randi([1,length(ID)]);
        X1 = Swarm.X(ID(ID1),:);
        ID(ID1) = [];
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        Donor(pp,:) = X_Current + Lamda * (X1 - X_Current) + Swarm.F(pp) * (X2 - X3);        
    elseif(Swarm.IndivType(pp) ~= 2 && Swarm.Strategy(pp) == 7) %DE/CURRENT-TO-BEST/1
        Lamda = Swarm.F(pp);
        ID = 1:size(Swarm.X,1);
        X_Current = Swarm.X(pp,:);
        Xb = Swarm.BestPosition;
        if(pp == Swarm.GbestID)
            ID(pp) = [];
        else
            for trys = 1:2
                for kk = 1:length(ID)
                    if(ID(kk) == pp || ID(kk) == Swarm.GbestID)
                        ID(kk) =[];
                        break;
                    end
                end
            end
        end
        ID2 = randi([1,length(ID)]);
        X2 = Swarm.X(ID(ID2),:);
        ID(ID2) = [];
        ID3 = randi([1,length(ID)]);
        X3 = Swarm.X(ID(ID3),:);
        ID(ID3) = [];
        Donor(pp,:) = X_Current + Lamda * (Xb - X_Current) + Swarm.F(pp) * (X2 - X3);     
    end
end
end

