%*********************************AMP-PSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Aug 23, 2022
%
% ------------
% Reference:
% ------------
%
%  C. Li, T. T. Nguyen, M. Yang, M. Mavrovouniotis and S. Yang,
%  "An Adaptive Multipopulation Framework for Locating and Tracking Multiple Optima," 
%  IEEE Transactions on Evolutionary Computation, vol. 20, no. 4, pp. 590-605, Aug. 2016, doi: 10.1109/TEVC.2015.2504383.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer, Problem] = IterativeComponents_AMPPSO(Optimizer,Problem)
Optimizer.domainS = sqrt(Problem.Dimension*(Problem.MaxCoordinate - Problem.MinCoordinate).^2);
% Optimizer.domainS = Problem.MaxCoordinate - Problem.MinCoordinate;
%% Sub-swarm movements
for ii=1 : Optimizer.SwarmNumber
    before_radius = Optimizer.pop(ii).CurrentRadius;
    if(Optimizer.pop(ii).IsHibernated == 0)
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
        
        if(Optimizer.AvoidanceFlag == 1)
            for jj=1 : size(Optimizer.pop(ii).X,1)
                [temp,Optimizer,Problem] = decreaseFitness(Optimizer,Problem,ii,jj); 
                Optimizer.pop(ii).FitnessValue(jj) = temp;
            end
        else
            [Optimizer.pop(ii).FitnessValue,Problem] = fitness(Optimizer.pop(ii).X,Problem);
        end
        
        if Problem.RecentChange == 1
            return;
        end
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
            end
        end
    end
    Optimizer.pop(ii).Center = UpdateCenter(Optimizer.pop(ii));
    Optimizer.pop(ii).CurrentRadius = UpdateCurRadius(Optimizer.pop(ii));
    if(Optimizer.pop(ii).CurrentRadius/(before_radius + 0.000001) < 0.9) 
        Optimizer.pop(ii).StagnatingCount = 0;
    else
        Optimizer.pop(ii).StagnatingCount = Optimizer.pop(ii).StagnatingCount + 1;
    end
    %Brownian move
    if(Optimizer.pop(ii).IsStagnated == 0)
        for tries = 1:2
            for gg = 1:Problem.Dimension
                Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,gg) = Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg) + randn()*Optimizer.pop(ii).CurrentRadius ;
                if Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,gg) > Optimizer.MaxCoordinate
                   Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,gg) = Optimizer.MaxCoordinate;
                   Optimizer.pop(ii).Velocity(Optimizer.pop(ii).GbestID,gg) = 0;
                elseif Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,gg) < Optimizer.MinCoordinate
                   Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,gg) = Optimizer.MinCoordinate;
                   Optimizer.pop(ii).Velocity(Optimizer.pop(ii).GbestID,gg) = 0;
                end
            end
            [BestResult,Problem] = fitness(Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:),Problem);
            Optimizer.pop(ii).FitnessValue(Optimizer.pop(ii).GbestID) = BestResult;
            if(BestResult > Optimizer.pop(ii).PbestValue(Optimizer.pop(ii).GbestID))
                Optimizer.pop(ii).PbestValue(Optimizer.pop(ii).GbestID) = BestResult;
                Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,:) = Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:);
                Optimizer.pop(ii).GbestPosition = Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,:);
                Optimizer.pop(ii).GbestValue = BestResult;
            end
            if Problem.RecentChange == 1
                return;
            end
        end
    elseif(Optimizer.pop(ii).IsStagnated == 1)
        %Cauchy move
        for gg = 1:Problem.Dimension
            pd= makedist('tLocationScale','mu',Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg),'sigma',(Optimizer.MaxCoordinate - Optimizer.MinCoordinate)/10,'nu',1);
            Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg) = random(pd,1,1);
            if Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg) > Optimizer.MaxCoordinate
            Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg) = Optimizer.MaxCoordinate;
            Optimizer.pop(ii).Velocity(Optimizer.pop(ii).GbestID,gg) = 0;
            elseif Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg) < Optimizer.MinCoordinate
                Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,gg) = Optimizer.MinCoordinate;
                Optimizer.pop(ii).Velocity(Optimizer.pop(ii).GbestID,gg) = 0;
            end
        end
        if(Optimizer.AvoidanceFlag == 1)
            [StagnatedBestResult,Optimizer,Problem] = decreaseFitness(Optimizer,Problem,ii,Optimizer.pop(ii).GbestID);
        else
            [StagnatedBestResult,Problem] = fitness(Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:),Problem);
        end
        Optimizer.pop(ii).PbestValue(Optimizer.pop(ii).GbestID) = StagnatedBestResult;
        Optimizer.pop(ii).FitnessValue(Optimizer.pop(ii).GbestID) = StagnatedBestResult;
        Optimizer.pop(ii).X(Optimizer.pop(ii).GbestID,:) = Optimizer.pop(ii).PbestPosition(Optimizer.pop(ii).GbestID,:);
        [BestPbestValue,BestPbestID] = max(Optimizer.pop(ii).PbestValue);
        Optimizer.pop(ii).GbestValue = BestPbestValue;
        Optimizer.pop(ii).GbestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
        Optimizer.pop(ii).GbestID = BestPbestID;
        Optimizer.pop(ii).StagnatingCount = 0;
        if Problem.RecentChange == 1
            return;
        end
    end
    if(Optimizer.pop(ii).CurrentRadius < Optimizer.ConvergenceLimit)
        Optimizer.pop(ii).IsHibernated = 1;
        Optimizer.pop(ii).IsStagnated = 0;
        if(isempty(Optimizer.HiberArea))
            HiberArea = struct('Optima',[],'Bounds',[]);
            Optimizer.HiberArea = repmat(HiberArea,0);
            Optimizer.HiberArea(end+1).Optima = Optimizer.pop(ii).GbestPosition;
        end
    end
    if(Optimizer.pop(ii).IsHibernated == 1)
        Optimizer.pop(ii).InitRadius = Optimizer.DisAccuracy;
    end
end

%% Check stagnant
AveRadius = 0;
Avercount = 0;
for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).IsHibernated == 1) 
        continue;
    end
    Avercount = Avercount + 1;
    AveRadius = AveRadius + Optimizer.pop(ii).CurrentRadius;
end
AveRadius = AveRadius/Avercount;
for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).IsHibernated == 1)
        continue;
    end
    if(Optimizer.pop(ii).StagnatingCount > size(Optimizer.pop(ii).X,1) && Optimizer.pop(ii).CurrentRadius >= AveRadius && ...
          Optimizer.pop(ii).CurrentRadius >= 0.005 * Optimizer.domainS ...
          || Optimizer.pop(ii).StagnatingCount > 10 * size(Optimizer.pop(ii).X,1))
        Optimizer.pop(ii).IsStagnated = 1;
    else
        Optimizer.pop(ii).IsStagnated = 0;
    end
end

%% Check overlapping
idx = inf;
while(idx ~= -1)
    idx = -1;
    for ii=1 : Optimizer.SwarmNumber
        if(size(Optimizer.pop(ii).X,1) == 0) 
           continue;
        end
        for jj=ii+1 : Optimizer.SwarmNumber
            if(size(Optimizer.pop(jj).X,1) == 0)
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
                if(c1 > 0 && c2 > 0)
                    if(Optimizer.pop(ii).GbestValue > Optimizer.pop(jj).GbestValue)
                        Optimizer.pop(ii).IsHibernated = 0;
                        Optimizer.pop(ii).StagnatingCount = 0;
                        Optimizer.pop(ii).IsStagnated = 0;
                        Optimizer.SwarmNumber = Optimizer.SwarmNumber - 1;
                        Optimizer.pop(jj) = [];
                        idx = jj;
                        break;
                    else
                        Optimizer.pop(jj).IsHibernated = 0;
                        Optimizer.pop(jj).StagnatingCount = 0;
                        Optimizer.pop(jj).IsStagnated = 0;
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
%% Check Diversity
NonStagnatedRadius = 0;
NonStagnatedCount = 0;
for ii=1 : Optimizer.SwarmNumber
    if(Optimizer.pop(ii).IsStagnated == 0 && Optimizer.pop(ii).IsHibernated == 0)
        NonStagnatedRadius = NonStagnatedRadius + Optimizer.pop(ii).CurrentRadius;
        NonStagnatedCount = NonStagnatedCount+1;
    end
end
if(NonStagnatedCount == 0) 
    NonStagnatedRadius = 0;
else
    NonStagnatedRadius = NonStagnatedRadius/NonStagnatedCount;
end
%activate diversity
if(NonStagnatedRadius < 0.005 * Optimizer.domainS)
    Optimizer.RecordPopInfo(end+1) = Optimizer.SwarmNumber;
    %wake up
    for ii=1 : Optimizer.SwarmNumber
        if(Optimizer.pop(ii).IsHibernated == 1)
            Optimizer.pop(ii).IsHibernated = 0;
        end
    end
    Optimizer.HiberArea = [];

    Optimizer.IterPopSizeEnd(end+1) = Optimizer.SwarmNumber;
    if(length(Optimizer.IterPopSizeEnd) > 2)
        Optimizer.IterPopSizeEnd(1) = [];
    end
    if(Optimizer.AdjustIter == 0)
        numIndividuals = 0;
        for i = 1:Optimizer.SwarmNumber
            numIndividuals = numIndividuals + size(Optimizer.pop(i).X,1);
        end
        Optimizer.IterIndividualsBegin = numIndividuals;
    end

    Optimizer.MapPopInds = UpdateMemory(Optimizer);
    if(Optimizer.FirstUpdate == 1)
        Optimizer.CurPopSize = Optimizer.IterPopSizeEnd(end);
        Optimizer.PrePopSize = Optimizer.CurPopSize;
        Optimizer.FirstUpdate = 0;
    else
        Optimizer.CurPopSize = Optimizer.IterPopSizeEnd(end);
        Optimizer.PrePopSize = Optimizer.IterPopSizeEnd(end-1);
    end

    ritio = abs(Optimizer.CurPopSize - Optimizer.PrePopSize)/Optimizer.OffPeak;
    if(ritio >= 1)
        NextIndividuals = (Optimizer.MapPopInds(Optimizer.CurPopSize).Mean + Optimizer.MapPopInds(Optimizer.CurPopSize).StdDev*randn()) + Optimizer.StepIndivs * 1 * (Optimizer.CurPopSize - Optimizer.PrePopSize);
    elseif(ritio == 0)
        NextIndividuals = (Optimizer.MapPopInds(Optimizer.CurPopSize).Mean + Optimizer.MapPopInds(Optimizer.CurPopSize).StdDev*randn());
    else
        p = rand(1,1);
        if(p <= ritio)
            NextIndividuals = (Optimizer.MapPopInds(Optimizer.CurPopSize).Mean + Optimizer.MapPopInds(Optimizer.CurPopSize).StdDev*randn()) + Optimizer.StepIndivs * 1 * (Optimizer.CurPopSize - Optimizer.PrePopSize);
        else
            NextIndividuals = (Optimizer.MapPopInds(Optimizer.CurPopSize).Mean + Optimizer.MapPopInds(Optimizer.CurPopSize).StdDev*randn());
        end
    end
    
    totalSurvive = 0;
    for i = 1:Optimizer.SwarmNumber
        totalSurvive = totalSurvive + size(Optimizer.pop(i).X,1);
    end
    if(NextIndividuals <= totalSurvive)
        NextIndividuals = totalSurvive + Optimizer.StepIndivs * 2;
    end

    if(NextIndividuals > Optimizer.maxIndivs)
        NextIndividuals = Optimizer.maxIndivs;
    elseif(NextIndividuals < Optimizer.minIndivs)
        NextIndividuals = Optimizer.minIndivs;
    end
    Optimizer.IterIndividualsBegin = ceil(NextIndividuals);
    NumRemain = size(Optimizer.remainIndivs,1);
    NumAddParticles = (ceil(NextIndividuals) - totalSurvive - NumRemain);
    if(NumAddParticles > 0)
        AddParticles.X = Optimizer.MinCoordinate + ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate).*rand(NumAddParticles,Optimizer.Dimension));
        AddParticles.X = [AddParticles.X;Optimizer.remainIndivs];
        Optimizer.remainIndivs = [];
        [Swarms,remainIndivs,Problem] = SubPopulationGenerator_AMPPSO(Optimizer.Dimension,AddParticles,Problem);
        Optimizer.remainIndivs = remainIndivs;
        if Problem.RecentChange == 1
            return;
        end
        NewSwarms = [Optimizer.pop;Swarms];
        Optimizer.pop = NewSwarms;
        Optimizer.SwarmNumber = length(Optimizer.pop);
    end
    Optimizer.AdjustIter = Optimizer.AdjustIter + 1;
end
end
%% Update Current Raduis
function Center = UpdateCenter(Swarm)
Center = zeros(1,size(Swarm.PbestPosition,2));
for kk = 1:size(Swarm.PbestPosition,2)
   for jj = 1:size(Swarm.PbestPosition,1)
       Center(kk) = Center(kk) + Swarm.PbestPosition(jj,kk);
   end
   Center(kk) = Center(kk)/size(Swarm.PbestPosition,1);
end
end


function CurrentRadius = UpdateCurRadius(Swarm)
    CurrentRadius = 0.0;
    for jj=1 : size(Swarm.PbestPosition,1)
        CurrentRadius = CurrentRadius + sqrt(sum((Swarm.PbestPosition(jj,:) - Swarm.Center).^2));
    end
    CurrentRadius = CurrentRadius / size(Swarm.PbestPosition,1);
end

function MapRecord = UpdateMemory(Optimizer)
Map = struct('Mean',0,'StdDev',0,'Num',0,'Indivs',[]);
if(Optimizer.SwarmNumber > size(Optimizer.MapPopInds,1))
    temp = Optimizer.MapPopInds;
    MapRecord = repmat(Map,Optimizer.SwarmNumber,1);
    MapRecord(1:size(temp,1)) = temp;
else
    MapRecord = Optimizer.MapPopInds;
end
MapRecord(Optimizer.SwarmNumber).Num = MapRecord(Optimizer.SwarmNumber).Num + 1;
MapRecord(Optimizer.SwarmNumber).Indivs(end+1) = Optimizer.IterIndividualsBegin(end);
mean = MapRecord(Optimizer.SwarmNumber).Mean;

MapRecord(Optimizer.SwarmNumber).Mean = (mean * (MapRecord(Optimizer.SwarmNumber).Num - 1) + Optimizer.IterIndividualsBegin(end))/MapRecord(Optimizer.SwarmNumber).Num;
MapRecord(Optimizer.SwarmNumber).StdDev = 0;
for ii = 1:length(MapRecord(Optimizer.SwarmNumber).Indivs)
  MapRecord(Optimizer.SwarmNumber).StdDev = (MapRecord(Optimizer.SwarmNumber).StdDev + (MapRecord(Optimizer.SwarmNumber).Indivs(ii) - MapRecord(Optimizer.SwarmNumber).Mean).^2);
end
MapRecord(Optimizer.SwarmNumber).StdDev = sqrt(MapRecord(Optimizer.SwarmNumber).StdDev/MapRecord(Optimizer.SwarmNumber).Num);
end

%% Update database
function [FitnessValue,Optimizer,Problem] = decreaseFitness(Optimizer,Problem,popid,individ)        
stepfitness = [];
        if(isempty(Optimizer.HiberArea))
            [FitnessValue,Problem] = fitness(Optimizer.pop(popid).X(individ,:),Problem);
            return;
        else
            for hh = 1:length(Optimizer.HiberArea)
                vect = Optimizer.pop(popid).X(individ,:) - Optimizer.HiberArea(hh).Optima;
                if(size(Optimizer.HiberArea(hh).Bounds,1) == 0)
                      stepx = Optimizer.HiberArea(hh).Optima;
                      stepfitness = [];
                      while(length(stepfitness) < 2)
                            stepx = stepx + vect/sqrt(sum(vect.^2)).*Optimizer.HiberStep;
                            [stepfitness(end+1),Problem] = fitness(stepx,Problem);
                      end
                      while(stepfitness(2) < stepfitness(1))
                            stepx = stepx + vect/sqrt(sum(vect.^2)).*Optimizer.HiberStep;
                            stepfitness(1) = stepfitness(2);
                            [stepfitness(end+1),Problem] = fitness(stepx,Problem);
                            for i = 1:Optimizer.Dimension
                                if(stepx(i) > Optimizer.MaxCoordinate)
                                    stepx(i) = Optimizer.MaxCoordinate;
                                    stepfitness(1) = 0;
                                    stepfitness(2) = 0;
                                elseif(stepx(i) < Optimizer.MinCoordinate)
                                    stepx(i) = Optimizer.MinCoordinate;
                                    stepfitness(1) = 0;
                                    stepfitness(2) = 0;
                                end
                            end
                      end
                      Optimizer.HiberArea(hh).Bounds(end+1,:) = stepx - vect/sqrt(sum(vect.^2)).*Optimizer.HiberStep;
                      addvect = Optimizer.HiberArea(hh).Bounds(end,:) - Optimizer.HiberArea(hh).Optima;
                      if(sqrt(sum(vect.^2)) > sqrt(sum(addvect.^2)))
                            [FitnessValue,Problem] = fitness(Optimizer.pop(popid).X(individ,:),Problem);
                            if Problem.RecentChange == 1
                                   return;
                            end
                      else
                            FitnessValue = 0;
                      end
                      return;
                else
                    for bb = 1:size(Optimizer.HiberArea(hh).Bounds,1)
                        boundvect = Optimizer.HiberArea(hh).Bounds(bb,:) - Optimizer.HiberArea(hh).Optima;
                        cosReg = sum(vect.*boundvect)/(sqrt(sum(vect.^2))*sqrt(sum(boundvect.^2)));
                        if(cosReg >= cos(3/360))
                            if(sqrt(sum(vect.^2)) > sqrt(sum(boundvect.^2)))
                                [FitnessValue,Problem] = fitness(Optimizer.pop(popid).X(individ,:),Problem);
                                if Problem.RecentChange == 1
                                   return;
                                end
                            else
                                FitnessValue = 0;
                            end
                            return;
                        elseif(cosReg < cos(3/360))
                            if(bb == size(Optimizer.HiberArea(hh).Bounds,1))
                                stepx = Optimizer.HiberArea(hh).Optima;
                                stepfitness = [];
                                while(length(stepfitness) < 2)
                                    stepx = stepx + vect/sqrt(sum(vect.^2)).*Optimizer.HiberStep;
                                    [stepfitness(end+1),Problem] = fitness(stepx,Problem);
                                end
                                while(stepfitness(2) < stepfitness(1))
                                    stepx = stepx + vect/sqrt(sum(vect.^2)).*Optimizer.HiberStep;
                                    stepfitness(1) = stepfitness(2);
                                    [stepfitness(end+1),Problem] = fitness(stepx,Problem);
                                    for i = 1:Optimizer.Dimension
                                        if(stepx(i) > Optimizer.MaxCoordinate)
                                            stepx(i) = Optimizer.MaxCoordinate;
                                            stepfitness(1) = 0;
                                            stepfitness(2) = 0;
                                        elseif(stepx(i) < Optimizer.MinCoordinate)
                                            stepx(i) = Optimizer.MinCoordinate;
                                            stepfitness(1) = 0;
                                            stepfitness(2) = 0;
                                        end
                                    end
                                end
                                Optimizer.HiberArea(hh).Bounds(end+1,:) = stepx - vect/sqrt(sum(vect.^2)).*Optimizer.HiberStep;
                                addvect = Optimizer.HiberArea(hh).Bounds(end,:) - Optimizer.HiberArea(hh).Optima;
                                if(sqrt(sum(vect.^2)) > sqrt(sum(addvect.^2)))
                                    [FitnessValue,Problem] = fitness(Optimizer.pop(popid).X(individ,:),Problem);
                                    if Problem.RecentChange == 1
                                        return;
                                    end
                                else
                                    FitnessValue = 0;
                                end
                                return;
                            end
                        end
                    end
                end
            end
        end
end