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
function [Swarm,RemainIndivs,Problem] = SubPopulationGenerator_AMPPSO(Dimension,InitSwarm,Problem)
RemainIndivs = [];
%% create sub swarms with single-linkage hierarchical clustering
for i = 1:size(InitSwarm.X,1)
   m_group(i).X = InitSwarm.X(i,:);
   m_group(i).id(1) = i;
end
dis = pdist(InitSwarm.X,'euclidean');
dis=squareform(dis);
d_intra =  0;                                                               %intra distance
d_inter =  sum(sum(dis))/2;                                                 %inter distance
while(1)
   if d_intra>=d_inter
       break;
   end
   Min_dis = inf;
   g1 = 0; g2 = 0;
   for i = 1:size(m_group,2)
        for j = i+1:size(m_group,2)
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
   [d_intra,d_inter] = updateDistance(m_group,dis);
end

while(1)
    returnflag = 0;
    for i=1:length(m_group)
        if(size(m_group(i).X,1) == 1)
            RemainIndivs(end+1,:) = m_group(i).X;
            m_group(i) = [];
            break;
        end
        if i == length(m_group)
            returnflag = 1;
        end
    end
    if(isempty(i) || returnflag == 1)
        break;
    end
end

population = struct('X',[],'Gbest_past_environment',[],'Velocity',[],'Shifts',[],'FitnessValue',[],'PbestPosition',[],'IsHibernated',[],'StagnatingCount',[],'IsStagnated',[],'PbestValue',[],'GbestValue',[],'GbestPosition',[],'GbestID',[],'Center',[],'InitRadius',[],'CurrentRadius',[]);
Swarm = repmat(population,[length(m_group),1]);
for i=1:length(m_group)
    Swarm(i).X =m_group(i).X;
    Swarm(i).Gbest_past_environment = NaN(1,Dimension);
    Swarm(i).Shifts = [];
    [Swarm(i).FitnessValue,Problem] = fitness(Swarm(i).X,Problem);
    Swarm(i).PbestPosition = Swarm(i).X;
    Swarm(i).IsHibernated = 0;
    Swarm(i).IsStagnated = 0;
    Swarm(i).StagnatingCount = 0;
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
    %Velocity -> -2.5 ~ 2.5 InitRadius
%     Swarm(i).Velocity = -2.5*Swarm(i).InitRadius + (5*Swarm(i).InitRadius) *rand(size(m_group(i).X,1),Dimension);
    Swarm(i).Velocity = 0 + 0 *rand(size(m_group(i).X,1),Dimension);    
    Swarm(i).CurrentRadius = Swarm(i).InitRadius;
    if Problem.RecentChange == 0
        Swarm(i).PbestValue = Swarm(i).FitnessValue;
        [Swarm(i).GbestValue,GbestID] = max(Swarm(i).PbestValue);
        Swarm(i).GbestPosition = Swarm(i).PbestPosition(GbestID,:);
        Swarm(i).GbestID = GbestID;
    else
        Swarm(i).FitnessValue = -inf(size(Swarm(i).X,1),1);
        Swarm(i).PbestValue = Swarm(i).FitnessValue;
        [Swarm(i).GbestValue,GbestID] = max(Swarm(i).PbestValue);
        Swarm(i).GbestPosition = Swarm(i).PbestPosition(GbestID,:);
        Swarm(i).GbestID = GbestID;
    end
end

function [intra,inter] = updateDistance(group,dis)
intra = 0;
inter = 0;
%caculate inter distance
for ii = 1:size(group,2)-1
    for jj = ii + 1:size(group,2)
        min_dis = inf;
        for kk = 1:length(group(ii).id)
            for gg = 1:length(group(jj).id)
                if(min_dis > dis(group(ii).id(kk),group(jj).id(gg)))
                     min_dis = dis(group(ii).id(kk),group(jj).id(gg));
                end
            end
        end
        inter = inter + min_dis;
    end
end
%caculate intra distance
for ii = 1:size(group,2)
    cdis = 0;
    for kk = 1:length(group(ii).id)-1
        for gg = kk + 1:length(group(ii).id)
            cdis = cdis + dis(group(ii).id(kk),group(ii).id(gg));
        end
    end
    intra = intra + cdis;
end