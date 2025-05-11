%*********************************CPSOR*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Oct 29, 2021
%
% ------------
% Reference:
% ------------
%
% Changhe Li & Shengxiang Yang,
%    "A general framework of multi-population methods with clustering in undetectable dynamic environments," 
%    IEEE Trans. Evol. Comput., vol. 16, no. 4, pp. 556?577, 2012.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer , Problem] = IterativeComponents_CPSOR(Optimizer,Problem)
%% Sub-swarm movements
for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).IsConverged == 0)
        Optimizer.pop(ii).Velocity = Optimizer.w * (Optimizer.pop(ii).Velocity + (Optimizer.c1 * rand(size(Optimizer.pop(ii).X,1) , Optimizer.Dimension).*(Optimizer.pop(ii).PbestPosition - Optimizer.pop(ii).X)) + (Optimizer.c2*rand(size(Optimizer.pop(ii).X,1), Optimizer.Dimension).*(repmat(Optimizer.pop(ii).GbestPosition,size(Optimizer.pop(ii).X,1),1) - Optimizer.pop(ii).X)));
        Optimizer.pop(ii).X = Optimizer.pop(ii).X + Optimizer.pop(ii).Velocity;
        for jj=1 : size(Optimizer.pop(ii).X,1)
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
        for jj=1 : size(Optimizer.pop(ii).X,1)
            if Optimizer.pop(ii).FitnessValue(jj) > Optimizer.pop(ii).PbestValue(jj)
                Optimizer.pop(ii).PbestValue(jj) = Optimizer.pop(ii).FitnessValue(jj);
                Optimizer.pop(ii).PbestPosition(jj,:) = Optimizer.pop(ii).X(jj,:);
                
                [BestPbestValue,BestPbestID] = max(Optimizer.pop(ii).PbestValue);
                if BestPbestValue>Optimizer.pop(ii).GbestValue
                    Optimizer.pop(ii).GbestValue = BestPbestValue;
                    Optimizer.pop(ii).GbestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
                    Optimizer.pop(ii).GbestID = BestPbestID;
                end
%% Local search            
                for gg = 1:Optimizer.Dimension
                    temp_pop = Optimizer.pop(ii).GbestPosition;
                    temp_pop(gg) = Optimizer.pop(ii).X(jj,gg);
                    [temp_fitness,Problem] = fitness(temp_pop,Problem);
                    if Problem.RecentChange == 1
                       return;
                    end
                    if(temp_fitness > Optimizer.pop(ii).GbestValue)
                        Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:) = temp_pop;
                        Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,:) = temp_pop;
                        Optimizer.pop(ii).FitnessValue(Optimizer.pop(ii).GbestID) = temp_fitness;
                        Optimizer.pop(ii).PbestValue(Optimizer.pop(ii).GbestID) = temp_fitness;
                        Optimizer.pop(ii).GbestPosition = temp_pop;
                        Optimizer.pop(ii).GbestValue = temp_fitness;
                    end
                end
            end
        end
    end
end
%% Update swarm center
for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).IsConverged == 0)
         Optimizer.pop(ii).Center = zeros(1,size(Optimizer.pop(ii).X,2));
         for kk = 1:size(Optimizer.pop(ii).X,2)
            for jj = 1:size(Optimizer.pop(ii).X,1)
                Optimizer.pop(ii).Center(kk) = Optimizer.pop(ii).Center(kk) + Optimizer.pop(ii).PbestPosition(jj,kk);
            end
            Optimizer.pop(ii).Center(kk) = Optimizer.pop(ii).Center(kk)/size(Optimizer.pop(ii).PbestPosition,1);
         end
    end
end
%% Check overlapping
idx = inf;
while(idx ~= -1)
    idx = -1;
    for ii=1 : Optimizer.SwarmNumber
        if(size(Optimizer.pop(ii).X,1) == 0 || Optimizer.pop(ii).IsConverged == 1) 
           continue;
        end
        for jj=ii+1 : Optimizer.SwarmNumber
            if(size(Optimizer.pop(jj).X,1) == 0 || Optimizer.pop(jj).IsConverged == 1) 
                continue;
            end
            dist = sqrt(sum((Optimizer.pop(ii).GbestPosition - Optimizer.pop(jj).GbestPosition).^2));
            if(dist < Optimizer.pop(ii).InitRadius && dist < Optimizer.pop(jj).InitRadius)
                c1 = 0;
                c2 = 0;
                for kk=1:size(Optimizer.pop(jj).X,1)
                    dist_temp = sqrt(sum((Optimizer.pop(ii).Center - Optimizer.pop(jj).X(kk,:)).^2));
                    if(dist_temp < Optimizer.pop(ii).InitRadius)
                        c1 = c1 + 1;
                    end
                end
                for kk=1:size(Optimizer.pop(ii).X,1)
                    dist_temp = sqrt(sum((Optimizer.pop(jj).Center - Optimizer.pop(ii).X(kk,:)).^2));
                    if(dist_temp < Optimizer.pop(jj).InitRadius)
                        c2 = c2 + 1;
                    end
                end
                if(c1 > Optimizer.OverlapDegree * size(Optimizer.pop(jj).X,1) && c2 > Optimizer.OverlapDegree * size(Optimizer.pop(ii).X,1))
                    if(Optimizer.pop(ii).GbestValue > Optimizer.pop(jj).GbestValue)
                        temp_pop = [Optimizer.pop(ii).X;Optimizer.pop(jj).X];
                        temp_pbest_pop = [Optimizer.pop(ii).PbestPosition;Optimizer.pop(jj).PbestPosition];
                        temp_velocity = [Optimizer.pop(ii).Velocity;Optimizer.pop(jj).Velocity];
                        temp_fitnessValue = [Optimizer.pop(ii).FitnessValue;Optimizer.pop(jj).FitnessValue];
                        temp_pbestValue = [Optimizer.pop(ii).PbestValue;Optimizer.pop(jj).PbestValue];
                        Optimizer.pop(ii).X = temp_pop;
                        Optimizer.pop(ii).PbestPosition = temp_pbest_pop;
                        Optimizer.pop(ii).Velocity = temp_velocity;
                        Optimizer.pop(ii).FitnessValue = temp_fitnessValue;
                        Optimizer.pop(ii).PbestValue = temp_pbestValue;
                        Optimizer.pop(ii).InitRadius = (Optimizer.pop(ii).InitRadius + Optimizer.pop(jj).InitRadius)/2;
                        Optimizer.pop(ii).IsConverged = 0;
                        Optimizer.SwarmNumber = Optimizer.SwarmNumber - 1;
                        Optimizer.pop(jj) = [];
                        idx = jj;
                        break;
                    else
                        temp_pop = [Optimizer.pop(jj).X;Optimizer.pop(ii).X];
                        temp_pbest_pop = [Optimizer.pop(jj).PbestPosition;Optimizer.pop(ii).PbestPosition];
                        temp_velocity = [Optimizer.pop(jj).Velocity;Optimizer.pop(ii).Velocity];
                        temp_fitnessValue = [Optimizer.pop(jj).FitnessValue;Optimizer.pop(ii).FitnessValue];
                        temp_pbestValue = [Optimizer.pop(jj).PbestValue;Optimizer.pop(ii).PbestValue];
                        Optimizer.pop(jj).X = temp_pop;
                        Optimizer.pop(jj).PbestPosition = temp_pbest_pop;
                        Optimizer.pop(jj).Velocity = temp_velocity;
                        Optimizer.pop(jj).FitnessValue = temp_fitnessValue;
                        Optimizer.pop(jj).PbestValue = temp_pbestValue;
                        Optimizer.pop(jj).InitRadius = (Optimizer.pop(ii).InitRadius + Optimizer.pop(jj).InitRadius)/2;
                        Optimizer.pop(jj).IsConverged = 0;
                        Optimizer.SwarmNumber = Optimizer.SwarmNumber - 1;
                        Optimizer.pop(ii) = [];                       
                        idx = ii;
                        break;
                    end
                end
            end
        end
        if(idx ~= -1) 
            break;
        end
    end
end
%% Check overcrowding
for ii=1 : Optimizer.SwarmNumber
    if(size(Optimizer.pop(ii).X,1) > Optimizer.maxSubsize)
       [aftersort, index] =sort(Optimizer.pop(ii).PbestValue);
       aftersort = flip(aftersort);
       index = flip(index);
       temp_x = zeros(Optimizer.maxSubsize,Optimizer.Dimension);
       temp_v = zeros(Optimizer.maxSubsize,Optimizer.Dimension);
       temp_f = zeros(Optimizer.maxSubsize,1);
       temp_px = zeros(Optimizer.maxSubsize,Optimizer.Dimension);
       temp_pf = zeros(Optimizer.maxSubsize,1);
       for jj=1 : size(aftersort,1)
           if(jj <= Optimizer.maxSubsize)
               temp_x(jj,:) = Optimizer.pop(ii).X(index(jj),:);
               temp_v(jj,:) = Optimizer.pop(ii).Velocity(index(jj),:);
               temp_f(jj,:) = Optimizer.pop(ii).FitnessValue(index(jj));
               temp_px(jj,:) = Optimizer.pop(ii).PbestPosition(index(jj),:);
               temp_pf(jj,:) = Optimizer.pop(ii).PbestValue(index(jj));
           end
       end
       Optimizer.pop(ii).X = temp_x;
       Optimizer.pop(ii).Velocity = temp_v;
       Optimizer.pop(ii).FitnessValue = temp_f;
       Optimizer.pop(ii).PbestPosition = temp_px;
       Optimizer.pop(ii).PbestValue = temp_pf;
       Optimizer.pop(ii).Center = zeros(1,size(Optimizer.pop(ii).X,2));
       for gg = 1:size(Optimizer.pop(ii).X,2)
           for xx = 1:size(Optimizer.pop(ii).X,1)
               Optimizer.pop(ii).Center(gg) = Optimizer.pop(ii).Center(gg) + Optimizer.pop(ii).PbestPosition(xx,gg);
           end
           Optimizer.pop(ii).Center(gg) = Optimizer.pop(ii).Center(gg)/size(Optimizer.pop(ii).PbestPosition,1);
       end
    end
end
%% Update Current Raduis
for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).IsConverged == 0)
        CurrentRadius = 0.0;
        for jj=1 : size(Optimizer.pop(ii).PbestPosition,1)
            CurrentRadius = CurrentRadius + sqrt(sum((Optimizer.pop(ii).PbestPosition(jj,:) - Optimizer.pop(ii).Center).^2));
        end
        CurrentRadius = CurrentRadius / size(Optimizer.pop(ii).PbestPosition,1);
        Optimizer.pop(ii).CurrentRadius = CurrentRadius;
    end
end
%% Check Diversity
AnyConverged = 0;
BestID = GetBestChildID(Optimizer);
for ii=1 : Optimizer.SwarmNumber
    if Optimizer.pop(ii).CurrentRadius < Optimizer.ConvergenceLimit && ii ~= BestID
        Optimizer.pop(ii).IsConverged = 1;
        AnyConverged = AnyConverged + 1;
    end
end

SurvivedParticles = 0;
for ii = 1:Optimizer.SwarmNumber
    if(~Optimizer.pop(ii).IsConverged)
        SurvivedParticles = SurvivedParticles + size(Optimizer.pop(ii).X,1);
    end
end

count = 0;
SaveBestPosition = zeros(AnyConverged+1,Optimizer.Dimension);
if(SurvivedParticles < Optimizer.initPopulationSize * Optimizer.DiversityDegree)
    SaveBestPosition(1,:) = Optimizer.pop(BestID).GbestPosition;
    Optimizer.pop(BestID) = [];
    Optimizer.SwarmNumber = Optimizer.SwarmNumber - 1;
    count = count + 1;
    while(AnyConverged)
        for ii = 1:Optimizer.SwarmNumber
            if(Optimizer.pop(ii).IsConverged)
                count = count + 1;
                SaveBestPosition(count,:) = Optimizer.pop(ii).GbestPosition;
                Optimizer.pop(ii) = [];
                Optimizer.SwarmNumber = Optimizer.SwarmNumber - 1;
                break;
            end
        end
        AnyConverged = AnyConverged - 1;
    end

    NumAddParticles = Optimizer.initPopulationSize - SurvivedParticles - count;
    AddParticles.X = Optimizer.MinCoordinate + ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate).*rand(NumAddParticles,Optimizer.Dimension));
    AddParticles.X = [AddParticles.X;SaveBestPosition];
    [Swarms,Problem] = SubPopulationGenerator_CPSOR(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,AddParticles,Optimizer.maxSubsize,Problem);
    if Problem.RecentChange == 1
        return;
    end
    for gg = 1: length(Optimizer.pop)
        if(Optimizer.pop(gg).CurrentRadius < 10 * Optimizer.ConvergenceLimit)
           Optimizer.pop(gg).Velocity = -(Optimizer.pop(gg).InitRadius) + 2 * (Optimizer.pop(gg).InitRadius) *rand(size(Optimizer.pop(gg).X,1),Optimizer.Dimension);
        end
    end
    NewSwarms = [Optimizer.pop;Swarms];
    Optimizer.pop = NewSwarms;
    Optimizer.SwarmNumber = length(Optimizer.pop);
end
end

%% Get Best Child ID
function ID = GetBestChildID(Optimizer)
GbestValue = zeros(length(Optimizer.pop),1);
for i = 1:length(Optimizer.pop)
    GbestValue(i) = Optimizer.pop(i).GbestValue;
end
[~,ID] = max(GbestValue);
end