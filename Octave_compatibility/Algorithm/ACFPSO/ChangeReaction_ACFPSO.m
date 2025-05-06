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
function [Optimizer,Problem] = ChangeReaction_ACFPSO(Optimizer,Problem)
%% Updating Shift Severity
dummy = NaN(Optimizer.SwarmNumber,Optimizer.Dimension);
for jj=1 : Optimizer.SwarmNumber
    if Optimizer.pop(jj).phase==3
        if sum(isnan(Optimizer.pop(jj).Gbest_past_environment))==0%i.e. it experienced at least one environmental change
            dummy(jj,:) = abs(Optimizer.pop(jj).Gbest_past_environment-Optimizer.pop(jj).BestPosition);
        end
    end
end
dummy(any(isnan(dummy), 2), :) = [];
if ~isempty(dummy)
    Optimizer.Relocations(Problem.Environmentcounter,:) = mean(dummy);
end
tmp = Optimizer.Relocations;
tmp(any(isnan(tmp), 2), :) = [];
Optimizer.ShiftSeverity = mean(tmp);
%% Introducing diversity (all except free swarm)
for jj=1 : Optimizer.SwarmNumber
    if jj~=Optimizer.FreeSwarmID
        if Optimizer.pop(jj).phase==3
            tmp=randi(2,[Optimizer.PopulationSize,Optimizer.Dimension])-1;
            tmp(~tmp)=-1;%generating 1 and -1 numbers randomly.
            Optimizer.pop(jj).X = repmat(Optimizer.pop(jj).BestPosition,Optimizer.PopulationSize,1)+ (repmat(Optimizer.ShiftSeverity,Optimizer.PopulationSize,1).*tmp);
            Optimizer.pop(jj).X(1,:) = Optimizer.pop(jj).BestPosition;
        end
    end
end
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
    Optimizer.pop(jj).Sleep=0;
   [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);
    Optimizer.pop(jj).PbestValue = Optimizer.pop(jj).FitnessValue;
    Optimizer.pop(jj).PbestPosition = Optimizer.pop(jj).X;
    if Optimizer.pop(jj).phase==3%if it is not a tracker, so it cannot participate in calculating the shift severity in the next environment
        Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
    end
    [Optimizer.pop(jj).BestValue,BestPbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).BestPosition = Optimizer.pop(jj).PbestPosition(BestPbestID,:);
end
end