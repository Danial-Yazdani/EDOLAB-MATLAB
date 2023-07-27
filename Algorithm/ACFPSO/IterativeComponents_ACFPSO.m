%********************************ACFPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: October 5, 2022
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "Adaptive control of subpopulations in evolutionary dynamic optimization"
%            IEEE Transactions on Cybernetics, vol. 52(7), pp. 6476 - 6489, 2020.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer , Problem] = IterativeComponents_ACFPSO(Optimizer,Problem)
% global TicketWinners;
% TmpSwarmNum = Optimizer.SwarmNumber;
%% Sub-swarm movement
MaxValue=-inf;
for jj=1 : Optimizer.SwarmNumber
    if Optimizer.pop(jj).BestValue > MaxValue
        MaxValue = Optimizer.pop(jj).BestValue;
        BestIndex=jj;
    end
end
% Optimizer.pop(BestIndex).Sleep=0;
counter=0;
GbestValue=[];
for ii=1 : Optimizer.SwarmNumber
    if ii~=Optimizer.FreeSwarmID && Optimizer.pop(ii).Sleep==0
        counter = counter +1;
        GbestValue(counter,1) = ii; %#ok<*AGROW>
        GbestValue(counter,2) = Optimizer.pop(ii).BestValue;
    end
end
ActiveSubPopulationNumber = counter;
if ~isnan(GbestValue)
    Tickets = sortrows(GbestValue,2,'descend')';
    Tickets(3,:) = size(Tickets,2):-1:1;
    Tickets(4,1) = 1;
    Tickets(5,1) = Tickets(3,1);
    for ii=2 : size(Tickets,2)
        Tickets(4,ii) = Tickets(5,ii-1)+1;
        Tickets(5,ii) = Tickets(4,ii) + Tickets(3,ii)-1;
    end
    RandomTickets = randi(sum(Tickets(3,:)),1,ActiveSubPopulationNumber);
    TicketWinners = NaN(length(RandomTickets),2);
    for ii=1: numel(RandomTickets)
        for jj=1 : size(Tickets,2)
            if RandomTickets(ii)>=Tickets(4,jj) && RandomTickets(ii)<=Tickets(5,jj)
                TicketWinners(ii,1)=Tickets(1,jj);
                TicketWinners(ii,2)=Tickets(2,jj);
                break;
            end
        end
    end
    TicketWinners = sortrows(TicketWinners,2,'descend')';
    TicketWinners(2,:) = [];
    TicketWinners = [TicketWinners,BestIndex,Optimizer.FreeSwarmID];
else
    TicketWinners = [Optimizer.FreeSwarmID];
end
while 1
    if isempty(TicketWinners)
        break;
    end
    ii = TicketWinners(1);
    TicketWinners(1)=[];
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
        Optimizer.pop(ii).PreviousGbestPosition=Optimizer.pop(ii).BestPosition;
        Optimizer.pop(ii).BestPosition = Optimizer.pop(ii).PbestPosition(BestPbestID,:);
    end
    Optimizer.pop(ii).Center = mean(Optimizer.pop(ii).PbestPosition);
    Optimizer.pop(ii).Diversity = max([(max(Optimizer.pop(ii).PbestPosition) - Optimizer.pop(ii).Center) ; (Optimizer.pop(ii).Center-min(Optimizer.pop(ii).PbestPosition))]);
    if(sum(Optimizer.pop(ii).Diversity>(Optimizer.ConvergenceInnerLayer*Optimizer.Radius))==0)
        Optimizer.pop(ii).phase = 3;%tracker
    elseif (sum(Optimizer.pop(ii).Diversity>(Optimizer.ConvergenceOuterLayer*Optimizer.Radius))==0)
        Optimizer.pop(ii).phase = 2;%exploiter
    else
        Optimizer.pop(ii).phase = 1;%explorer
    end
    if(sum(Optimizer.pop(ii).Diversity>(Optimizer.ConvergenceSleepLayer))==0)
        Optimizer.pop(ii).Sleep=1;
        TicketWinners(TicketWinners==ii)=[];
    end
    jj=0;
    while 1
        jj=jj+1;
        if jj==ii
            continue;
        end
        if jj>Optimizer.SwarmNumber
            break;
        end
        Distance = abs(Optimizer.pop(ii).BestPosition - Optimizer.pop(jj).BestPosition);
        if sum(Optimizer.ExclusionInnerLayer*Optimizer.Radius<Distance)==0%if two sub-population are inside the restricted exclusion area
            if Optimizer.FreeSwarmID==ii ||Optimizer.FreeSwarmID==jj%when one of them is explorer, the explorer will be re-initialized
                [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_ACFPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                if Problem.RecentChange == 1
                    return;
                end
            else%when sub-populations are not explorer, so one of them must be removed.
                if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                    Optimizer.pop(ii) = [];
                    TicketWinners(TicketWinners==ii)=[];
                    TicketWinners(TicketWinners>ii) = TicketWinners(TicketWinners>ii)-1;
                    Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                    Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                    break;
                else
                    Optimizer.pop(jj) = [];
                    TicketWinners(TicketWinners==jj)=[];
                    TicketWinners(TicketWinners>jj) = TicketWinners(TicketWinners>jj)-1;
                    jj=jj-1;
                    if jj<ii
                        ii=ii-1;
                    end
                    Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                    Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                end
            end
        elseif sum(Optimizer.ExclusionOuterLayer*Optimizer.Radius<Distance)==0
            if Optimizer.pop(ii).phase==3 && Optimizer.pop(jj).phase==3
                %Do nothing, trackers can continue until enter restericted radius.
            elseif Optimizer.pop(ii).phase==3 || Optimizer.pop(jj).phase==3% when one of the involved sub-pops in the warning area is a tracker
                if Optimizer.pop(ii).phase==3
                    if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                        %Do nothing
                    else
                        if jj==Optimizer.FreeSwarmID
                            [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_ACFPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                            if Problem.RecentChange == 1
                                return;
                            end
                        else
                            Optimizer.pop(jj) = [];
                            TicketWinners(TicketWinners==jj)=[];
                            TicketWinners(TicketWinners>jj) = TicketWinners(TicketWinners>jj)-1;
                            jj=jj-1;
                            if jj<ii
                                ii=ii-1;
                            end
                            Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                            Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                        end
                    end
                else%jj is the tracker
                    if Optimizer.pop(jj).BestValue<Optimizer.pop(ii).BestValue
                        %Do nothing
                    else
                        if ii==Optimizer.FreeSwarmID
                            [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_ACFPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                            if Problem.RecentChange == 1
                                return;
                            end
                        else
                            Optimizer.pop(ii) = [];
                            TicketWinners(TicketWinners==ii)=[];
                            TicketWinners(TicketWinners>ii) = TicketWinners(TicketWinners>ii)-1;
                            Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                            Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                            break;
                        end
                    end
                end
            else% if two exploiters, or the explorer and an exploiter are involved in the warning area
                if Optimizer.FreeSwarmID==ii ||Optimizer.FreeSwarmID==jj%when one of them is explorer, the explorer will be re-initialized
                    [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_ACFPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                    if Problem.RecentChange == 1
                        return;
                    end
                else%both are exploiters
                    if Optimizer.pop(ii).BestValue<Optimizer.pop(jj).BestValue
                        Optimizer.pop(ii) = [];
                        TicketWinners(TicketWinners==ii)=[];
                        TicketWinners(TicketWinners>ii) = TicketWinners(TicketWinners>ii)-1;
                        Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                        Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                        break;
                    else
                        Optimizer.pop(jj) = [];
                        TicketWinners(TicketWinners==jj)=[];
                        TicketWinners(TicketWinners>jj) = TicketWinners(TicketWinners>jj)-1;
                        jj=jj-1;
                        if jj<ii
                            ii=ii-1;
                        end
                        Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
                        Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
                    end
                end
            end
        end
    end
end
%% FreeSwarm Convergence
if(Optimizer.pop(Optimizer.FreeSwarmID).phase>1)
    if Optimizer.SwarmNumber>30
        WorstSwarmID=[];
        WorstSwarmValue = inf;
        for jj=1: Optimizer.SwarmNumber
            if jj~=Optimizer.FreeSwarmID
                if Optimizer.pop(jj).BestValue <WorstSwarmValue
                    WorstSwarmValue = Optimizer.pop(jj).BestValue;
                    WorstSwarmID = jj;
                end
            end
        end
        Optimizer.pop(WorstSwarmID) = [];
        Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
        Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
    end
    Optimizer.SwarmNumber = Optimizer.SwarmNumber+1;
    Optimizer.FreeSwarmID = Optimizer.SwarmNumber;
    [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_ACFPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
%% Updating Thresholds
TrackerNumber=0;
for ij=1:Optimizer.SwarmNumber
    if Optimizer.pop(ij).phase==3
        TrackerNumber = TrackerNumber + 1;
    end
end
Optimizer.Radius = ones(1,Optimizer.Dimension) * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / max(1,TrackerNumber));