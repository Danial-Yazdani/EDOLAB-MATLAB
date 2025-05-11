%********************************TMIPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 21, 2022
%
% ------------
% Reference:
% ------------
%
%  Hongfeng Wang et al.,
%            "Triggered Memory-Based Swarm Optimization in Dynamic Environments"
%            Applications of Evolutionary Computing, pp. 637-646, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer , Problem] = IterativeComponents_TMIPSO(Optimizer,Problem)
%% ExploitPop movement
Optimizer.ExploitPop.Velocity = Optimizer.x * ...
    (Optimizer.ExploitPop.Velocity + (Optimizer.c1 * rand(Optimizer.ExploitPopSize , Optimizer.Dimension).*(Optimizer.ExploitPop.PbestPosition - Optimizer.ExploitPop.X)) + ...
    (Optimizer.c2*rand(Optimizer.ExplorePopSize , Optimizer.Dimension).*(repmat(Optimizer.ExploitPop.BestPosition,Optimizer.ExploitPopSize,1) - Optimizer.ExploitPop.X)));
Optimizer.ExploitPop.X = Optimizer.ExploitPop.X + Optimizer.ExploitPop.Velocity;
for jj=1 : Optimizer.ExploitPopSize
    for kk=1 : Optimizer.Dimension
        if Optimizer.ExploitPop.X(jj,kk) > Optimizer.MaxCoordinate
            Optimizer.ExploitPop.X(jj,kk) = Optimizer.MaxCoordinate;
            Optimizer.ExploitPop.Velocity(jj,kk) = 0;
        elseif Optimizer.ExploitPop.X(jj,kk) < Optimizer.MinCoordinate
            Optimizer.ExploitPop.X(jj,kk) = Optimizer.MinCoordinate;
            Optimizer.ExploitPop.Velocity(jj,kk) = 0;
        end
    end
end
[tmp,Problem] = fitness(Optimizer.ExploitPop.X,Problem);
if Problem.RecentChange == 1
    return;
end
Optimizer.ExploitPop.FitnessValue = tmp;
for jj=1 : Optimizer.ExploitPopSize
    if Optimizer.ExploitPop.FitnessValue(jj) > Optimizer.ExploitPop.PbestValue(jj)
        Optimizer.ExploitPop.PbestValue(jj) = Optimizer.ExploitPop.FitnessValue(jj);
        Optimizer.ExploitPop.PbestPosition(jj,:) = Optimizer.ExploitPop.X(jj,:);
    end
end
[BestPbestValue,BestPbestID] = max(Optimizer.ExploitPop.PbestValue);
if BestPbestValue>Optimizer.ExploitPop.BestValue
    Optimizer.ExploitPop.BestValue = BestPbestValue;
    Optimizer.ExploitPop.BestPosition = Optimizer.ExploitPop.PbestPosition(BestPbestID,:);
end
%% ExplorePop movement
Optimizer.ExplorePop.Velocity = Optimizer.x * ...
    (Optimizer.ExplorePop.Velocity + (Optimizer.c1 * rand(Optimizer.ExplorePopSize , Optimizer.Dimension).*(Optimizer.ExplorePop.PbestPosition - Optimizer.ExplorePop.X)) + ...
    (Optimizer.c2*rand(Optimizer.ExplorePopSize , Optimizer.Dimension).*(repmat(Optimizer.ExplorePop.BestPosition,Optimizer.ExplorePopSize,1) - Optimizer.ExplorePop.X)));
Optimizer.ExplorePop.X = Optimizer.ExplorePop.X + Optimizer.ExplorePop.Velocity;
for jj=1 : Optimizer.ExplorePopSize
    for kk=1 : Optimizer.Dimension
        if Optimizer.ExplorePop.X(jj,kk) > Optimizer.MaxCoordinate
            Optimizer.ExplorePop.X(jj,kk) = Optimizer.MaxCoordinate;
            Optimizer.ExplorePop.Velocity(jj,kk) = 0;
        elseif Optimizer.ExplorePop.X(jj,kk) < Optimizer.MinCoordinate
            Optimizer.ExplorePop.X(jj,kk) = Optimizer.MinCoordinate;
            Optimizer.ExplorePop.Velocity(jj,kk) = 0;
        end
    end
end
[tmp,Problem] = fitness(Optimizer.ExplorePop.X,Problem);
if Problem.RecentChange == 1
    return;
end
Optimizer.ExplorePop.FitnessValue = tmp;
for jj=1 : Optimizer.ExplorePopSize
    if Optimizer.ExplorePop.FitnessValue(jj) > Optimizer.ExplorePop.PbestValue(jj)
        Optimizer.ExplorePop.PbestValue(jj) = Optimizer.ExplorePop.FitnessValue(jj);
        Optimizer.ExplorePop.PbestPosition(jj,:) = Optimizer.ExplorePop.X(jj,:);
    end
end
[BestPbestValue,BestPbestID] = max(Optimizer.ExplorePop.PbestValue);
if BestPbestValue>Optimizer.ExplorePop.BestValue
    Optimizer.ExplorePop.BestValue = BestPbestValue;
    Optimizer.ExplorePop.BestPosition = Optimizer.ExplorePop.PbestPosition(BestPbestID,:);
end
Optimizer.ExplorePop.fitness_history = [Optimizer.ExplorePop.fitness_history; Optimizer.ExplorePop.BestValue];

%% ExplorPop reinitializing
    %averfit
% InitializeFlag = 0 ;
if numel(Optimizer.ExplorePop.fitness_history)==6
    tmp1 = sum(Optimizer.ExplorePop.fitness_history(1:5));
    tmp2 = sum(Optimizer.ExplorePop.fitness_history(2:6));
    Optimizer.ExplorePop.fitness_history(1) = [];    
    averfit = (tmp2 - tmp1)/tmp2;
    if averfit < Optimizer.b1
        memorysize = numel(Optimizer.MemoryFitness);
        % Memory Replacement Strategy
        if memorysize >= Optimizer.MemorySize            
            tmp5 = inf;
            for ii=1 : memorysize-1
                for jj=ii+1 : memorysize
                    distance = pdist2(Optimizer.MemoryPosition(ii,:), Optimizer.MemoryPosition(jj,:));
                    if distance < tmp5
                        tmp5 = distance;
                        first = ii;
                        second = jj;
                    end
                end
            end
            if Optimizer.MemoryFitness(first) < Optimizer.MemoryFitness(second)
                Optimizer.MemoryFitness(first) = [];
                Optimizer.MemoryPosition(first,:) = [];
            else
                Optimizer.MemoryFitness(second) = [];
                Optimizer.MemoryPosition(second,:) = [];
            end   
        end
        Optimizer.MemoryPosition = [Optimizer.MemoryPosition ; Optimizer.ExplorePop.BestPosition];
        Optimizer.MemoryFitness = [Optimizer.MemoryFitness ; Optimizer.ExplorePop.BestValue];        
        %memory-based resetting
        [BestMemoryValue,BestMemoryID] = max(Optimizer.MemoryFitness);
        if BestMemoryValue > Optimizer.ExploitPop.BestValue
            Optimizer.ExploitPop.BestValue = BestMemoryValue;
            Optimizer.ExploitPop.BestPosition = Optimizer.MemoryPosition(BestMemoryID,:);
        end    
        %memory-based immigrants
        [~,worstIndexIndividuals] = sort(Optimizer.ExploitPop.PbestValue);
        for ii=1 : memorysize
            Optimizer.ExploitPop.PbestPosition(worstIndexIndividuals(ii),:) = Optimizer.MemoryPosition(ii,:);
            Optimizer.ExploitPop.PbestValue(worstIndexIndividuals(ii)) = Optimizer.MemoryFitness(ii);
        end
        %re-initialize explore pop
        [Optimizer.ExplorePop,Problem] = SubPopulationGenerator_TMIPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ExplorePopSize,Problem);
        if Problem.RecentChange == 1
            return;
        end
    end
end