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
function [Optimizer,Problem] = ChangeReaction_HmSO(Optimizer,Problem)
%% Updating memory - Parent Pop
[Optimizer.ParentPop.PbestValue,Problem] = fitness(Optimizer.ParentPop.PbestPosition , Problem);
Optimizer.ParentPop.Gbest_past_environment = Optimizer.ParentPop.GbestPosition;
[Optimizer.ParentPop.GbestValue,Optimizer.ParentPop.GbestID] = max(Optimizer.ParentPop.PbestValue);
Optimizer.ParentPop.GbestPosition = Optimizer.ParentPop.PbestPosition(Optimizer.ParentPop.GbestID,:);
Optimizer.PreGbestValue = Optimizer.ParentPop.GbestValue;
Optimizer.CurGbestValue = Optimizer.ParentPop.GbestValue;
%% Updating memory - Parent Pop
for ii=1 : length(Optimizer.ChildPop)
    [Optimizer.ChildPop(ii).PbestValue,Problem] = fitness(Optimizer.ChildPop(ii).PbestPosition , Problem);
    Optimizer.ChildPop(ii).Gbest_past_environment = Optimizer.ChildPop(ii).GbestPosition;
    [Optimizer.ChildPop(ii).GbestValue,Optimizer.ChildPop(ii).GbestID] = max(Optimizer.ChildPop(ii).PbestValue);
    Optimizer.ChildPop(ii).GbestPosition = Optimizer.ChildPop(ii).PbestPosition(Optimizer.ChildPop(ii).GbestID,:);
end

%% Wake up Child
for ii=1 : length(Optimizer.ChildPop)
    if(Optimizer.ChildPop(ii).IsConverged == 1)
       Optimizer.ChildPop(ii).IsConverged = 0;
    end
end
%% ReLaunch memory - Child Pop
for ii=1 : length(Optimizer.ChildPop)
    for jj=1 : size(Optimizer.ChildPop(ii).X,1)
        if(jj ~= Optimizer.ChildPop(ii).GbestID)
           for kk=1 : Optimizer.Dimension
               Optimizer.ChildPop(ii).X(jj,kk) =  Optimizer.ChildPop(ii).GbestPosition(1,kk) + (-1 + 2*rand(1,1))*Optimizer.Rsearch;
               Optimizer.ChildPop(ii).Velocity(jj,kk) = (-1 + 2*rand(1,1))*Optimizer.Rsearch;
           end
        end
    end
    [Optimizer.ChildPop(ii).FitnessValue,Problem] = fitness(Optimizer.ChildPop(ii).X , Problem);
    Optimizer.ChildPop(ii).PbestValue = Optimizer.ChildPop(ii).FitnessValue;
    Optimizer.ChildPop(ii).PbestPosition = Optimizer.ChildPop(ii).X;
    Optimizer.ChildPop(ii).Gbest_past_environment = Optimizer.ChildPop(ii).GbestPosition;
    [Optimizer.ChildPop(ii).GbestValue,Optimizer.ChildPop(ii).GbestID] = max(Optimizer.ChildPop(ii).PbestValue);
    Optimizer.ChildPop(ii).GbestPosition = Optimizer.ChildPop(ii).PbestPosition(Optimizer.ChildPop(ii).GbestID,:);
    Optimizer.ChildPop(ii).Center = zeros(1,Optimizer.Dimension);
    for kk = 1:size(Optimizer.ChildPop(ii).X,2)
        for gg = 1:size(Optimizer.ChildPop(ii).X,1)
            Optimizer.ChildPop(ii).Center(kk) = Optimizer.ChildPop(ii).Center(kk) + Optimizer.ChildPop(ii).PbestPosition(gg,kk);
        end
        Optimizer.ChildPop(ii).Center(kk) = Optimizer.ChildPop(ii).Center(kk)/size(Optimizer.ChildPop(ii).PbestPosition,1);
    end
    Optimizer.ChildPop(ii).CurRadius = 0.0;
    for gg = 1:size(Optimizer.ChildPop(ii).PbestPosition,1)
        Optimizer.ChildPop(ii).CurRadius = Optimizer.ChildPop(ii).CurRadius + sqrt(sum((Optimizer.ChildPop(ii).PbestPosition(gg,:) - Optimizer.ChildPop(ii).Center).^2));
    end
    Optimizer.ChildPop(ii).CurRadius =  Optimizer.ChildPop(ii).CurRadius/Optimizer.ChildSize;
end
end