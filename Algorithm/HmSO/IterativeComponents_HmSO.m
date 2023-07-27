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
function [Optimizer, Problem] = IterativeComponents_HmSO(Optimizer,Problem)
%% Parent movements
Optimizer.ParentPop.Velocity = Optimizer.w * (Optimizer.ParentPop.Velocity + (Optimizer.c1 * rand(size(Optimizer.ParentPop.X,1) , Optimizer.Dimension).*(Optimizer.ParentPop.PbestPosition - Optimizer.ParentPop.X)) + (Optimizer.c2*rand(size(Optimizer.ParentPop.X,1), Optimizer.Dimension).*(repmat(Optimizer.ParentPop.GbestPosition,size(Optimizer.ParentPop.X,1),1) - Optimizer.ParentPop.X)));
Optimizer.ParentPop.X = Optimizer.ParentPop.X + Optimizer.ParentPop.Velocity;
for jj=1 : size(Optimizer.ParentPop.X,1)
   for kk=1 : Optimizer.Dimension
      if Optimizer.ParentPop.X(jj,kk) > Optimizer.MaxCoordinate
         Optimizer.ParentPop.X(jj,kk) = Optimizer.MaxCoordinate;
         Optimizer.ParentPop.Velocity(jj,kk) = 0;
      elseif Optimizer.ParentPop.X(jj,kk) < Optimizer.MinCoordinate
         Optimizer.ParentPop.X(jj,kk) = Optimizer.MinCoordinate;
         Optimizer.ParentPop.Velocity(jj,kk) = 0;
      end
   end
end
[tmp,Problem] = fitness(Optimizer.ParentPop.X,Problem);
if Problem.RecentChange == 1
   return;
end
Optimizer.ParentPop.FitnessValue = tmp;
for jj=1 : size(Optimizer.ParentPop.X,1)
    if Optimizer.ParentPop.FitnessValue(jj) > Optimizer.ParentPop.PbestValue(jj)
       Optimizer.ParentPop.PbestValue(jj) = Optimizer.ParentPop.FitnessValue(jj);
       Optimizer.ParentPop.PbestPosition(jj,:) = Optimizer.ParentPop.X(jj,:);
       [BestPbestValue,BestPbestID] = max(Optimizer.ParentPop.PbestValue);
       if BestPbestValue>Optimizer.ParentPop.GbestValue
          Optimizer.ParentPop.GbestValue = BestPbestValue;
          Optimizer.ParentPop.GbestPosition = Optimizer.ParentPop.PbestPosition(BestPbestID,:);
          Optimizer.ParentPop.GbestID = BestPbestID;
       end
    end
end

for ii=1 : size(Optimizer.ParentPop.X,1)
    for jj=1 : length(Optimizer.ChildPop)
        if sqrt(sum((Optimizer.ParentPop.PbestPosition(ii,:) - Optimizer.ChildPop(jj).GbestPosition).^2)) < Optimizer.Rpc
            if Optimizer.ParentPop.PbestValue(ii,:) > Optimizer.ChildPop(jj).GbestValue
                GbestID = Optimizer.ChildPop(jj).GbestID;
                Optimizer.ChildPop(jj).X(GbestID,:) = Optimizer.ParentPop.X(ii,:);
                Optimizer.ChildPop(jj).PbestPosition(GbestID,:) = Optimizer.ParentPop.PbestPosition(ii,:);
                Optimizer.ChildPop(jj).PbestValue(GbestID) = Optimizer.ParentPop.PbestValue(ii);
                Optimizer.ChildPop(jj).Velocity(GbestID,:) = Optimizer.ParentPop.Velocity(ii,:);
                Optimizer.ChildPop(jj).FitnessValue(GbestID) = Optimizer.ParentPop.FitnessValue(ii);
                [Optimizer.ChildPop(jj).GbestValue,Optimizer.ChildPop(jj).GbestID] = max(Optimizer.ChildPop(jj).PbestValue);
                Optimizer.ChildPop(jj).GbestPosition = Optimizer.ChildPop(jj).PbestPosition(GbestID,:);
            end
            Optimizer.ParentPop.X(ii,:) = Optimizer.MinCoordinate + ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate).*rand(1,Optimizer.Dimension));
            [Optimizer.ParentPop.FitnessValue(ii),Problem] = fitness(Optimizer.ParentPop.X(ii,:),Problem);
            if Problem.RecentChange == 1
               return;
            end
            Optimizer.ParentPop.PbestPosition(ii,:) = Optimizer.ParentPop.X(ii,:);
            Optimizer.ParentPop.PbestValue(ii) = Optimizer.ParentPop.FitnessValue(ii);
            Optimizer.ParentPop.Velocity(ii,:) = (-1 + 2*rand(1,Problem.Dimension))*Optimizer.Rpc/3;
            [Optimizer.ParentPop.GbestValue,Optimizer.ParentPop.GbestID] = max(Optimizer.ParentPop.PbestValue);
            Optimizer.ParentPop.GbestPosition = Optimizer.ParentPop.PbestPosition(Optimizer.ParentPop.GbestID,:);
        end
    end
end
Optimizer.CurGbestValue = Optimizer.ParentPop.GbestValue;
if(Optimizer.CurGbestValue > Optimizer.PreGbestValue)
    % Create Child Swarm
%     [ChildPop,Optimizer.ParentPop,Problem] = SubPopulationGeneratorChild_HmSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ParentSize,Optimizer.ChildSize,Optimizer.ParentPop,Optimizer.Rpc,Problem);
    [Optimizer,Problem] = SubPopulationGenerator_HmSO(Optimizer,Problem,'child');
    if Problem.RecentChange == 1
        return;
    end
%     Optimizer.ChildPop = [Optimizer.ChildPop;ChildPop];
end
Optimizer.PreGbestValue = Optimizer.CurGbestValue;

%% Child movements
for ii=1 : length(Optimizer.ChildPop)
    if(Optimizer.ChildPop(ii).IsConverged == 1) 
        continue;
    end
    Optimizer.ChildPop(ii).Velocity = Optimizer.w * (Optimizer.ChildPop(ii).Velocity + (Optimizer.c1 * rand(size(Optimizer.ChildPop(ii).X,1) , Optimizer.Dimension).*(Optimizer.ChildPop(ii).PbestPosition - Optimizer.ChildPop(ii).X)) + (Optimizer.c2*rand(size(Optimizer.ChildPop(ii).X,1), Optimizer.Dimension).*(repmat(Optimizer.ChildPop(ii).GbestPosition,size(Optimizer.ChildPop(ii).X,1),1) - Optimizer.ChildPop(ii).X)));
    Optimizer.ChildPop(ii).X = Optimizer.ChildPop(ii).X + Optimizer.ChildPop(ii).Velocity;
    for jj=1 : size(Optimizer.ChildPop(ii).X,1)
       for kk=1 : Optimizer.Dimension
          if Optimizer.ChildPop(ii).X(jj,kk) > Optimizer.MaxCoordinate
             Optimizer.ChildPop(ii).X(jj,kk) = Optimizer.MaxCoordinate;
             Optimizer.ChildPop(ii).Velocity(jj,kk) = 0;
          elseif Optimizer.ChildPop(ii).X(jj,kk) < Optimizer.MinCoordinate
             Optimizer.ChildPop(ii).X(jj,kk) = Optimizer.MinCoordinate;
             Optimizer.ChildPop(ii).Velocity(jj,kk) = 0;
          end
       end
    end
    [tmp,Problem] = fitness(Optimizer.ChildPop(ii).X,Problem);
    if Problem.RecentChange == 1
       return;
    end
    Optimizer.ChildPop(ii).FitnessValue = tmp;    
    for jj=1 : size(Optimizer.ChildPop(ii).X,1)
        if Optimizer.ChildPop(ii).FitnessValue(jj) > Optimizer.ChildPop(ii).PbestValue(jj)
           Optimizer.ChildPop(ii).PbestValue(jj) = Optimizer.ChildPop(ii).FitnessValue(jj);
           Optimizer.ChildPop(ii).PbestPosition(jj,:) = Optimizer.ChildPop(ii).X(jj,:);
           [BestPbestValue,BestPbestID] = max(Optimizer.ChildPop(ii).PbestValue);
           if BestPbestValue>Optimizer.ChildPop(ii).GbestValue
              Optimizer.ChildPop(ii).GbestValue = BestPbestValue;
              Optimizer.ChildPop(ii).GbestPosition = Optimizer.ChildPop(ii).PbestPosition(BestPbestID,:);
           end        
        end
    end
    Optimizer.ChildPop(ii).Center = UpdateCenter(Optimizer.ChildPop(ii));
    Optimizer.ChildPop(ii).CurRadius = UpdateCurRadius(Optimizer.ChildPop(ii));
    BestChildID = GetBestChildID(Optimizer);
    if(Optimizer.ChildPop(ii).CurRadius < Optimizer.Rconv && Optimizer.ChildPop(ii).GbestValue < (Optimizer.ChildPop(BestChildID).GbestValue - Optimizer.Margin))
        Optimizer.ChildPop(ii).IsConverged = 1;
    end
end
%% Remove Overlapping
for ii=1 : length(Optimizer.ChildPop)-1
    for jj=ii+1 : length(Optimizer.ChildPop)
        if (sqrt(sum(Optimizer.ChildPop(ii).GbestPosition - Optimizer.ChildPop(jj).GbestPosition).^2) < Optimizer.Rexcl)
            if(Optimizer.ChildPop(ii).GbestValue > Optimizer.ChildPop(jj).GbestValue)
                Optimizer.ChildPop(jj).IsRemove = 1;
            else
                Optimizer.ChildPop(ii).IsRemove = 1;
            end
        end
    end
end

while(1)
    count = 0;
    for ii=1 : length(Optimizer.ChildPop)
        if(Optimizer.ChildPop(ii).IsRemove == 1)
            Optimizer.ChildPop(ii) = [];
            count = count + 1;
            break;
        end
    end
    if(count == 0)
        break;
    end
end

Optimizer.pop = [Optimizer.ParentPop,Optimizer.ChildPop];
end

function ID = GetBestChildID(Optimizer)
GbestValue = zeros(length(Optimizer.ChildPop),1);
for i = 1:length(Optimizer.ChildPop)
    GbestValue(i) = Optimizer.ChildPop(i).GbestValue;
end
[~,ID] = max(GbestValue);
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