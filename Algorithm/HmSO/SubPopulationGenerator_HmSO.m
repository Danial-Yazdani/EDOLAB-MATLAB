%*********************************HmSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Nov 7, 2021
%
% ------------
% Reference:
% ------------
%
%  M. Kamosi, A. B. Hashemi, and M. R. Meybodi, 
%  "A hibernating multi-swarm optimization algorithm for dynamic environments," 
%  in Proc. World Congr. Nat. Biol. Inspir. Comput. (NaBIC), Fukuoka, Japan, 2010, pp. 363-369.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Optimizer,Problem] = SubPopulationGenerator_HmSO(Optimizer,Problem,popType)
if(strcmp(popType,'child'))
    [ChildPop,Optimizer.ParentPop,Problem] = SubPopulationGeneratorChild_HmSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ParentSize,Optimizer.ChildSize,Optimizer.ParentPop,Optimizer.Rpc,Problem);
    Optimizer.ChildPop = [Optimizer.ChildPop, ChildPop];
elseif(strcmp(popType,'parent'))
    [Optimizer.ParentPop,Problem] = SubPopulationGeneratorParent_HmSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ParentSize,Problem);
end
end

function [Swarm,Parent,Problem] = SubPopulationGeneratorChild_HmSO(Dimension,MinCoordinate,MaxCoordinate,ParentSize,ChildSize,Parent,Rpc,Problem)
%% Initialize child
Swarm.Gbest_past_environment = NaN(1,Dimension);
ParticleCount = 0;
Swarm.X = zeros(ChildSize,Dimension);
Swarm.Velocity = -10 + (20)*rand(ChildSize,Dimension);
Swarm.X(1,:) = Parent.GbestPosition(1,:);
Swarm.PbestPosition(1,:) = Parent.GbestPosition(1,:);
Swarm.FitnessValue(1,1) = Parent.FitnessValue(Parent.GbestID);
ParticleCount = ParticleCount + 1;

for ii = 1:size(Parent.X,1)
    if(sqrt(sum((Parent.PbestPosition(ii,:) - Parent.GbestPosition(1,:)).^2)) < Rpc && ii ~= Parent.GbestID)
        if(ParticleCount < ChildSize)
            ParticleCount = ParticleCount + 1;
            Swarm.X(ParticleCount,:) = Parent.PbestPosition(ii,:);
            Swarm.PbestPosition(ParticleCount,:) = Parent.PbestPosition(ii,:);
            Swarm.FitnessValue(ParticleCount,1) = Parent.FitnessValue(ii);
            Swarm.PbestValue(ParticleCount,1) = Parent.PbestValue(ii);
        end
    end
end
while(ParticleCount < ChildSize)
    Swarm.X(ParticleCount+1,:) = Swarm.X(1,:) + (-1 + 2*rand(1,Dimension))*Rpc/3;
%     Swarm.Velocity(ParticleCount+1,:) = (-1 + 2*rand(1,Dimension))*Rpc/3;
    Swarm.PbestPosition(ParticleCount+1,:) = Swarm.X(ParticleCount+1,:);
    [Swarm.FitnessValue(ParticleCount+1,1),Problem] = fitness(Swarm.X(ParticleCount+1,:),Problem);
    ParticleCount = ParticleCount + 1;
end

Swarm.Center = zeros(1,Dimension);
for kk = 1:size(Swarm.X,2)
    for ii = 1:size(Swarm.X,1)
        Swarm.Center(kk) = Swarm.Center(kk) + Swarm.PbestPosition(ii,kk);
    end
    Swarm.Center(kk) = Swarm.Center(kk)/size(Swarm.PbestPosition,1);
end
Swarm.CurRadius = 0.0;
for ii = 1:size(Swarm.PbestPosition,1)
    Swarm.CurRadius = Swarm.CurRadius + sqrt(sum((Swarm.PbestPosition(ii,:) - Swarm.Center).^2));
end
Swarm.CurRadius = Swarm.CurRadius/ChildSize;
Swarm.IsConverged = 0;
Swarm.IsRemove = 0;
if Problem.RecentChange == 0
    Swarm.PbestValue = Swarm.FitnessValue;
    [Swarm.GbestValue,Swarm.GbestID] = max(Swarm.PbestValue);
    Swarm.GbestPosition = Swarm.PbestPosition(Swarm.GbestID,:);
else
    Swarm.FitnessValue = -inf(ChildSize,1);
    Swarm.PbestValue = Swarm.FitnessValue;
    [Swarm.GbestValue,Swarm.GbestID] = max(Swarm.PbestValue);
    Swarm.GbestPosition = Swarm.PbestPosition(Swarm.GbestID,:);
end
Parent = [];
[Parent, Problem] = SubPopulationGeneratorParent_HmSO(Dimension,MinCoordinate,MaxCoordinate,ParentSize,Problem);
end


function [Swarm , Problem] = SubPopulationGeneratorParent_HmSO(Dimension,MinCoordinate,MaxCoordinate,ParentSize,Problem)
%% Initialize parent
Swarm.Gbest_past_environment = NaN(1,Dimension);
Swarm.Velocity = -50 + (100)*rand(ParentSize,Dimension);
Swarm.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(ParentSize,Dimension));
[Swarm.FitnessValue,Problem] = fitness(Swarm.X,Problem);
Swarm.PbestPosition = Swarm.X;
Swarm.Center = zeros(1,Dimension);
for kk = 1:size(Swarm.X,2)
    for ii = 1:size(Swarm.X,1)
        Swarm.Center(kk) = Swarm.Center(kk) + Swarm.PbestPosition(ii,kk);
    end
    Swarm.Center(kk) = Swarm.Center(kk)/size(Swarm.PbestPosition,1);
end
Swarm.CurRadius = 0.0;
for ii = 1:size(Swarm.PbestPosition,1)
    Swarm.CurRadius = Swarm.CurRadius + sqrt(sum((Swarm.PbestPosition(ii,:) - Swarm.Center).^2));
end
Swarm.CurRadius = Swarm.CurRadius/ParentSize;
Swarm.IsConverged = 0;
Swarm.IsRemove = 0;
if Problem.RecentChange == 0
    Swarm.PbestValue = Swarm.FitnessValue;
    [Swarm.GbestValue,Swarm.GbestID] = max(Swarm.PbestValue);
    Swarm.GbestPosition = Swarm.PbestPosition(Swarm.GbestID,:);
else
    Swarm.FitnessValue = -inf(ParentSize,1);
    Swarm.PbestValue = Swarm.FitnessValue;
    [Swarm.GbestValue,Swarm.GbestID] = max(Swarm.PbestValue);
    Swarm.GbestPosition = Swarm.PbestPosition(Swarm.GbestID,:);
end
end

