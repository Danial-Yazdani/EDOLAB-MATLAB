%*********************************CPSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Oct 25, 2021
%
% ------------
% Reference:
% ------------
%
%  Shengxiang Yang & Changhe Li,
%            "A Clustering pop Swarm Optimizer for Locating and Tracking Multiple Optima in Dynamic Environments"
%            IEEE Transactions on Evolutionary Computation (2010).
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer , Problem] = IterativeComponents_CPSO(Optimizer,Problem)
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
         for kk = 1:size(Optimizer.pop(ii).PbestPosition,2)
            for jj = 1:size(Optimizer.pop(ii).PbestPosition,1)
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
        for jj=1 : size(Optimizer.pop(ii).X,1)
            CurrentRadius = CurrentRadius + sqrt(sum((Optimizer.pop(ii).PbestPosition(jj,:) - Optimizer.pop(ii).Center).^2));
        end
        CurrentRadius = CurrentRadius / size(Optimizer.pop(ii).PbestPosition,1);
        Optimizer.pop(ii).CurrentRadius = CurrentRadius;
    end
end
%% All-Converged
IsAllConverged = 0;
for ii=1 : Optimizer.SwarmNumber
    if Optimizer.pop(ii).CurrentRadius < Optimizer.ConvergenceLimit
        Optimizer.pop(ii).IsConverged = 1;
        IsAllConverged = IsAllConverged + Optimizer.pop(ii).IsConverged;
%         if(Optimizer.pop(ii).InitRadius == 0)
%             for jj=1 : Optimizer.SwarmNumber
%                 Optimizer.pop(ii).InitRadius = -1;
%                 if(jj ~= ii)
%                     dist = sqrt(sum((Optimizer.pop(ii).GbestPosition - Optimizer.pop(jj).GbestPosition).^2));
%                     if(dist < Optimizer.ExclusionLimit)
%                         Optimizer.pop(ii) = [];
%                         Optimizer.SwarmNumber = Optimizer.SwarmNumber -1;
%                         IsAllConverged = IsAllConverged - 1;
%                         break;
%                     end
%                 end
%             end
%         end
    else
        Optimizer.pop(ii).IsConverged = 0;
    end
end
if IsAllConverged == Optimizer.SwarmNumber
    [Optimizer.pop(end+1),Problem] = CPSOInitlizingPSO(Optimizer,Problem);
    Optimizer.SwarmNumber = Optimizer.SwarmNumber+1;
    if Problem.RecentChange == 1
        return;
    end
end
end

function [A_SWARM , Problem] = CPSOInitlizingPSO(Optimizer,Problem)
%CPSO INITLIZING PSO 
    A_SWARM.X = Optimizer.MinCoordinate + ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate).*rand(Optimizer.maxSubsize,Optimizer.Dimension));
    A_SWARM.Gbest_past_environment = NaN(1,Optimizer.Dimension);
    A_SWARM.Velocity = -(Optimizer.MaxCoordinate-Optimizer.MinCoordinate)/5 + (2 * (Optimizer.MaxCoordinate-Optimizer.MinCoordinate)/5) *rand(size(A_SWARM.X,1),Optimizer.Dimension);    
    A_SWARM.Shifts = [];
    [A_SWARM.FitnessValue,Problem] = fitness(A_SWARM.X,Problem);
    A_SWARM.PbestPosition = A_SWARM.X;
    A_SWARM.IsConverged = 0;
    A_SWARM.Center = zeros(1,size(A_SWARM.X,2));
    A_SWARM.InitRadius = 0.0;

    for kk = 1:size(A_SWARM.X,2)
        for jj = 1:size(A_SWARM.X,1)
            A_SWARM.Center(kk) = A_SWARM.Center(kk) + A_SWARM.PbestPosition(jj,kk);
        end
        A_SWARM.Center(kk) = A_SWARM.Center(kk)/size(A_SWARM.PbestPosition,1);
    end
    CurrentRadius = 0;
    for jj=1 : size(A_SWARM.X,1)
        CurrentRadius = CurrentRadius + sqrt(sum((A_SWARM.PbestPosition(jj,:) - A_SWARM.Center).^2));
    end
    CurrentRadius = CurrentRadius / size(A_SWARM.X,1);
    A_SWARM.CurrentRadius = CurrentRadius;
    if Problem.RecentChange == 0
        A_SWARM.PbestValue = A_SWARM.FitnessValue;
        [A_SWARM.GbestValue,A_SWARM.GbestID] = max(A_SWARM.PbestValue);
        A_SWARM.GbestPosition = A_SWARM.PbestPosition(A_SWARM.GbestID,:);
    else
        A_SWARM.FitnessValue = -inf(Optimizer.maxSubsize,1);
        A_SWARM.PbestValue = A_SWARM.FitnessValue;
        [A_SWARM.GbestValue,A_SWARM.GbestID] = max(A_SWARM.PbestValue);
        A_SWARM.GbestPosition = A_SWARM.PbestPosition(A_SWARM.GbestID,:);
    end
end