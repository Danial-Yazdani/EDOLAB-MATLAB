%********************************CESO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: November 4, 2022
%
% ------------
% Reference:
% ------------
%
%  Rodica Ioana Lung and Dumitru Dumitrescu,
%            "A collaborative model for tracking optima in dynamic environments"
%            IEEE Congress on Evolutionary Computation, pp. 564-567, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer, Problem] = IterativeComponents_CESO(Optimizer, Problem)
%% Transmitting information from CRDE to pop    
if pdist2(Optimizer.CRDE.BestPosition,Optimizer.pop.BestPosition)<Optimizer.theta
    if Optimizer.PopulationSizeCRDE > Optimizer.PopulationSizeSwarm
        [~,SortedIndeces] = sort(Optimizer.CRDE.FitnessValue,'descend');
        Optimizer.pop.X = Optimizer.CRDE.X(SortedIndeces(1:Optimizer.PopulationSizeSwarm),:);
    else
        Optimizer.pop.X = Optimizer.CRDE.X;
    end
    Optimizer.pop.PbestPosition = Optimizer.pop.X;
    Optimizer.pop.Velocity = Optimizer.Vmin + (Optimizer.Vmax-Optimizer.Vmin).*rand(Optimizer.PopulationSizeSwarm,Optimizer.Dimension);
end
%% Update SWARM
Optimizer.pop.Velocity = Optimizer.x * (Optimizer.pop.Velocity + (Optimizer.c1 * rand(Optimizer.PopulationSizeSwarm , Optimizer.Dimension).*(Optimizer.pop.PbestPosition - Optimizer.pop.X)) + (Optimizer.c2*rand(Optimizer.PopulationSizeSwarm , Optimizer.Dimension).*(repmat(Optimizer.pop.BestPosition,Optimizer.PopulationSizeSwarm,1) - Optimizer.pop.X)));
Optimizer.pop.X = Optimizer.pop.X + Optimizer.pop.Velocity;
for jj=1 : Optimizer.PopulationSizeSwarm
    for kk=1 : Optimizer.Dimension
        if Optimizer.pop.X(jj,kk) > Optimizer.MaxCoordinate
            Optimizer.pop.X(jj,kk) = Optimizer.MaxCoordinate;
            Optimizer.pop.Velocity(jj,kk) = 0;
        elseif Optimizer.pop.X(jj,kk) < Optimizer.MinCoordinate
            Optimizer.pop.X(jj,kk) = Optimizer.MinCoordinate;
            Optimizer.pop.Velocity(jj,kk) = 0;
        end
    end
end 
[tmp,Problem] = fitness(Optimizer.pop.X,Problem);
if Problem.RecentChange == 1
    return;
end
Optimizer.pop.FitnessValue = tmp;
for jj=1 : Optimizer.PopulationSizeSwarm
    if Optimizer.pop.FitnessValue(jj) > Optimizer.pop.PbestValue(jj)
        Optimizer.pop.PbestValue(jj) = Optimizer.pop.FitnessValue(jj);
        Optimizer.pop.PbestPosition(jj,:) = Optimizer.pop.X(jj,:);
    end
end
[BestPbestValue,GbestID] = max(Optimizer.pop.PbestValue);
if BestPbestValue>Optimizer.pop.BestValue
    Optimizer.pop.BestValue = BestPbestValue;
    Optimizer.pop.BestPosition = Optimizer.pop.PbestPosition(GbestID,:);
end

%% Evolve CRDE
V = NaN(Optimizer.PopulationSizeCRDE,Optimizer.Dimension);
for jj=1 : Optimizer.PopulationSizeCRDE
    r = randperm(Optimizer.PopulationSizeCRDE);
    r1 = r(1);
    r2 = r(2);
    r3 = r(3);
    v = Optimizer.CRDE.X(r1,:)+Optimizer.F.*(Optimizer.CRDE.X(r2,:)-Optimizer.CRDE.X(r3,:));
    r_mut2 = rand();
    v = (1-r_mut2)*Optimizer.CRDE.BestPosition+r_mut2*v;
    v = max(v,Optimizer.MinCoordinate);
    v = min(v,Optimizer.MaxCoordinate);
    V(jj,:) = Optimizer.CRDE.X(jj,:);
    for kk=1:Optimizer.Dimension
        if rand() < Optimizer.CR
            V(jj,kk) = v(kk);
        else
            break;
        end
    end
end 
[tmp,Problem] = fitness(V,Problem);
if Problem.RecentChange == 1
    return;
end
for jj=1 : Optimizer.PopulationSizeCRDE
    mindist = inf;
    nearestId = 0;
    for kk=1 : Optimizer.PopulationSizeCRDE
        dist = pdist2(V(jj,:),Optimizer.CRDE.X(kk,:));
        if dist < mindist
            mindist = dist;
            nearestId = kk;
        end
    end
    if tmp(jj)>Optimizer.CRDE.FitnessValue(nearestId)
        Optimizer.CRDE.X(nearestId,:) = V(jj,:);
        Optimizer.CRDE.FitnessValue(nearestId) = tmp(jj);
    end
end

[BestValue,CRDE_BestID] = max(Optimizer.CRDE.FitnessValue);
if BestValue>Optimizer.CRDE.BestValue
    Optimizer.CRDE.BestValue = BestValue;
    Optimizer.CRDE.BestPosition = Optimizer.CRDE.X(CRDE_BestID,:);
end

%% Transmitting information from pop to CRDE
if Optimizer.CRDE.BestValue < Optimizer.pop.BestValue
    Optimizer.CRDE.BestValue = Optimizer.pop.BestValue;
    Optimizer.CRDE.BestPosition = Optimizer.pop.BestPosition;
end
end