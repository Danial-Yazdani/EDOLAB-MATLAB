%********************************FTMPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 12, 2021
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "A novel multi-swarm algorithm for optimization in dynamic environments based on particle swarm optimization"
%             Applied Soft Computing 13, 4 (2013), pp. 2144–2158.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer , Problem] = IterativeComponents_FTMPSO(Optimizer,Problem)
%% -------------------Finder Part-----------------------
TmpSwarmNum = Optimizer.SwarmNumber;
Optimizer.Finder.Velocity = Optimizer.x * (Optimizer.Finder.Velocity + (Optimizer.c1 * rand(Optimizer.FinderPopulationSize , Optimizer.Dimension).*(Optimizer.Finder.PbestPosition - Optimizer.Finder.X)) + (Optimizer.c2*rand(Optimizer.FinderPopulationSize , Optimizer.Dimension).*(repmat(Optimizer.Finder.BestPosition,Optimizer.FinderPopulationSize,1) - Optimizer.Finder.X)));
Optimizer.Finder.X = Optimizer.Finder.X + Optimizer.Finder.Velocity;
for jj=1 : Optimizer.FinderPopulationSize
    for kk=1 : Optimizer.Dimension
        if Optimizer.Finder.X(jj,kk) > Optimizer.MaxCoordinate
            Optimizer.Finder.X(jj,kk) = Optimizer.MaxCoordinate;
            Optimizer.Finder.Velocity(jj,kk) = 0;
        elseif Optimizer.Finder.X(jj,kk) < Optimizer.MinCoordinate
            Optimizer.Finder.X(jj,kk) = Optimizer.MinCoordinate;
            Optimizer.Finder.Velocity(jj,kk) = 0;
        end
    end
end
[tmp,Problem] = fitness(Optimizer.Finder.X,Problem);
if Problem.RecentChange == 1
    return;
end
Optimizer.Finder.FitnessValue = tmp;
for jj=1 : Optimizer.FinderPopulationSize
    if Optimizer.Finder.FitnessValue(jj) > Optimizer.Finder.PbestValue(jj)
        Optimizer.Finder.PbestValue(jj) = Optimizer.Finder.FitnessValue(jj);
        Optimizer.Finder.PbestPosition(jj,:) = Optimizer.Finder.X(jj,:);
    end
end
[BestPbestValue,BestPbestID] = max(Optimizer.Finder.PbestValue);
if BestPbestValue>Optimizer.Finder.BestValue
    Optimizer.Finder.BestValue = BestPbestValue;
    Optimizer.Finder.BestPosition = Optimizer.Finder.PbestPosition(BestPbestID,:);
end
% Exclusion between Finder and Trackers
if Optimizer.SwarmNumber>0
    for jj=1 : Optimizer.SwarmNumber
        if  pdist2(Optimizer.Finder.BestPosition,Optimizer.pop(jj).BestPosition) < Optimizer.ExclusionLimit
            [Optimizer.Finder,Problem] = SubPopulationGenerator_FTMPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.FinderPopulationSize,Problem);
            if Problem.RecentChange == 1
                return;
            end
        end
    end
end
% Finder Convergence
if pdist2(Optimizer.Finder.GbestPositionHistory(1,:),Optimizer.Finder.BestPosition) < Optimizer.ConvergenceLimit
    ConvergenceFlag=1;
else
    ConvergenceFlag=0;
end
Optimizer.Finder.GbestPositionHistory = [Optimizer.Finder.GbestPositionHistory;Optimizer.Finder.BestPosition];
if size(Optimizer.Finder.GbestPositionHistory,1) > Optimizer.Finder.k
    Optimizer.Finder.GbestPositionHistory(1,:) = [];
end
if ConvergenceFlag==1% Creating a tracker
    Optimizer.SwarmNumber = Optimizer.SwarmNumber+1;
    [~,SortedIndeces] = sort(Optimizer.Finder.PbestValue,'descend');
    Optimizer.pop(Optimizer.SwarmNumber).Shifts = [];
    Optimizer.pop(Optimizer.SwarmNumber).Sleeping = 0;
    Optimizer.pop(Optimizer.SwarmNumber).Gbest_past_environment = NaN(1,Optimizer.Dimension);
    Optimizer.pop(Optimizer.SwarmNumber).Velocity = Optimizer.Finder.Velocity(SortedIndeces(1:Optimizer.PopulationSize),:);
    Optimizer.pop(Optimizer.SwarmNumber).X = Optimizer.Finder.PbestPosition(SortedIndeces(1:Optimizer.PopulationSize),:);
    Optimizer.pop(Optimizer.SwarmNumber).FitnessValue = Optimizer.Finder.FitnessValue(SortedIndeces(1:Optimizer.PopulationSize));
    Optimizer.pop(Optimizer.SwarmNumber).PbestPosition = Optimizer.pop(Optimizer.SwarmNumber).X;
    Optimizer.pop(Optimizer.SwarmNumber).PbestValue = Optimizer.pop(Optimizer.SwarmNumber).FitnessValue;
    Optimizer.pop(Optimizer.SwarmNumber).BestValue = Optimizer.Finder.BestValue;
    Optimizer.pop(Optimizer.SwarmNumber).BestPosition = Optimizer.Finder.BestPosition;
    [Optimizer.Finder,Problem] = SubPopulationGenerator_FTMPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.FinderPopulationSize,Problem);%Randomly reinitializing the finder
    if Problem.RecentChange == 1
        return;
    end
end
% Updating Thresholds
if TmpSwarmNum ~= Optimizer.SwarmNumber
    Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber) ^ (1 / Optimizer.Dimension)));
end
%% -------------------Tracker Part-----------------------
if Optimizer.SwarmNumber > 0
    TmpSwarmNum = Optimizer.SwarmNumber;
    % Tracker movement
    if Optimizer.SwarmNumber>0
        for ii=1 : Optimizer.SwarmNumber
            if Optimizer.pop(ii).Sleeping==0
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
            end
        end
        % Exclusion between tracker sub-populations
        if Optimizer.SwarmNumber>=2
            ExclusionFlag = 0;
            for ii=1 : Optimizer.SwarmNumber
                for jj=ii+1 : Optimizer.SwarmNumber
                    if  ExclusionFlag==0 && pdist2(Optimizer.pop(ii).BestPosition,Optimizer.pop(jj).BestPosition)<Optimizer.ExclusionLimit
                        if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                            Optimizer.pop(ii) = [];
                            Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                            Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                        else
                            Optimizer.pop(jj) = [];
                            Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                            Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                        end
                        ExclusionFlag = 1;
                    end
                end
            end
        end
        % Sleeping
        BestSwarmValue = -inf;
        BestSwarmIndex = NaN;
        if Optimizer.SwarmNumber>1
            for ii=1 : Optimizer.SwarmNumber
                tmp = Optimizer.pop(ii).Velocity;
                tmp(tmp>-1*Optimizer.SleepingLimit & tmp<Optimizer.SleepingLimit) = 0;
                if sum(tmp(:))==0
                    Optimizer.pop(ii).Sleeping = 1;
                end
                if Optimizer.pop(ii).BestValue>BestSwarmValue
                    BestSwarmValue = Optimizer.pop(ii).BestValue;
                    BestSwarmIndex = ii;
                end
            end
            Optimizer.pop(BestSwarmIndex).Sleeping = 0;%the best tracker never sleeps.
        end
    end
    % Local search around the best tracker's Gbest
    if Optimizer.SwarmNumber==1
        BestSwarmIndex = 1;
    end
    if Optimizer.SwarmNumber>0
        for ii=1 : Optimizer.TryNumber
            DummyPosition = Optimizer.pop(BestSwarmIndex).BestPosition + (2*rand(1,Optimizer.Dimension)-1)*Optimizer.Cloud;
            [DummyFitnessValue,Problem] = fitness(DummyPosition,Problem);
            if Problem.RecentChange == 1
                return;
            end
            if Optimizer.pop(BestSwarmIndex).BestValue<DummyFitnessValue
                Optimizer.pop(BestSwarmIndex).BestValue=DummyFitnessValue;
                Optimizer.pop(BestSwarmIndex).BestPosition = DummyPosition;
            end
        end
        Optimizer.Cloud = Optimizer.Cloud * (Optimizer.CFmin + rand*(1-Optimizer.CFmin));
    end
    % Updating Thresholds
        if TmpSwarmNum ~= Optimizer.SwarmNumber
            Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber) ^ (1 / Optimizer.Dimension)));
        end
end
end