%*********************************AMSO*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Oct 21, 2021
%
% ------------
% Reference:
% ------------
%
% Changhe Li, Ming Yang & Shengxiang Yang. 
% An Adaptive Multi-Swarm Optimizer for Dynamic Optimization Problems. 
% Evolutionary Computation, MIT press,2014,22(4) :559-594.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Swarm , Problem] = SubPopulationGenerator_AMSO(Dimension,MinCoordinate,MaxCoordinate,InitSwarm,maxSize,Problem)
%% create sub swarms with single-linkage hierarchical clustering
for i = 1:size(InitSwarm.X,1)
   m_group(i).X = InitSwarm.X(i,:);
   m_group(i).id(1) = i;
end
dis = pdist(InitSwarm.X,'euclidean');
dis=squareform(dis);
while(1)
   i = 1;
   while(i ~= size(m_group,2)+1 && size(m_group(i).X,1)>1)
       i = i + 1;
   end
   if(i == size(m_group,2)+1)
       break;
   end
   
   Min_dis = inf;
   g1 = 0; g2 = 0;
   for i = 1:size(m_group,2)
        for j = i+1:size(m_group,2)
            if(maxSize > 0 && (size(m_group(i).X,1) + size(m_group(j).X,1)) > maxSize) 
                continue;
            end
            dist = dis(m_group(i).id(1),m_group(j).id(1));
            for k = 1:length(m_group(i).id)
                for m = 1:length(m_group(j).id)
                    if(dist < dis(m_group(i).id(k),m_group(j).id(m)))
                        dist = dis(m_group(i).id(k),m_group(j).id(m));
                    end
                end
            end
            
            if(Min_dis > dist)
               Min_dis = dist;
               g1 = i;
               g2 = j;
            end
        end
   end
   if g1 == 0 && g2 == 0
       break;
   end
   temp = [m_group(g1).X;m_group(g2).X];
   m_group(g1).X = temp;
   temp_id =  [m_group(g1).id,m_group(g2).id];
   m_group(g1).id = temp_id;
   m_group(g2) = [];
end

population = struct('X',[],'Gbest_past_environment',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsConverged',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[]);
Swarm = repmat(population,[length(m_group),1]);
for i=1:length(m_group)
    Swarm(i).X =m_group(i).X;
    Swarm(i).Gbest_past_environment = NaN(1,Dimension);
    Swarm(i).Shifts = [];
    [Swarm(i).FitnessValue,Problem] = fitness(Swarm(i).X,Problem);
    Swarm(i).PbestPosition = Swarm(i).X;
    Swarm(i).IsConverged = 0;
    Swarm(i).Center = zeros(1,size(Swarm(i).X,2));
    for kk = 1:size(Swarm(i).X,2)
        for ii = 1:size(Swarm(i).X,1)
            Swarm(i).Center(kk) = Swarm(i).Center(kk) + Swarm(i).X(ii,kk);
        end
        Swarm(i).Center(kk) = Swarm(i).Center(kk)/size(Swarm(i).X,1);
    end
    Swarm(i).InitRadius = 0.0;
    for ii = 1:size(Swarm(i).X,1)
        Swarm(i).InitRadius = Swarm(i).InitRadius + sqrt(sum((Swarm(i).X(ii,:) - Swarm(i).Center).^2));
    end
    Swarm(i).InitRadius = Swarm(i).InitRadius/size(Swarm(i).X,1);
    Swarm(i).Velocity = -(Swarm(i).InitRadius) + 2 * (Swarm(i).InitRadius) *rand(size(m_group(i).X,1),Dimension);
    Swarm(i).CurrentRadius = Swarm(i).InitRadius;
    if Problem.RecentChange == 0
        Swarm(i).PbestValue = Swarm(i).FitnessValue;
        [Swarm(i).GbestValue,Swarm(i).GbestID] = max(Swarm(i).PbestValue);
        Swarm(i).GbestPosition = Swarm(i).PbestPosition(Swarm(i).GbestID,:);
    else
        Swarm(i).FitnessValue = -inf(size(Swarm(i).X,1),1);
        Swarm(i).PbestValue = Swarm(i).FitnessValue;
        [Swarm(i).GbestValue,Swarm(i).GbestID] = max(Swarm(i).PbestValue);
        Swarm(i).GbestPosition = Swarm(i).PbestPosition(Swarm(i).GbestID,:);
    end
end