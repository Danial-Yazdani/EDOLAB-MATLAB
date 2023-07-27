%********************************FTMPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 12, 2021
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "A novel multi-swarm algorithm for optimization in dynamic environments based on particle swarm optimization"
%             Applied Soft Computing 13, 4 (2013), pp. 2144–2158.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_FTMPSO(Optimizer,Problem)
%% Updating Shift Severity
dummy = NaN(Optimizer.SwarmNumber,Problem.EnvironmentNumber);
for jj=1 : Optimizer.SwarmNumber
    if jj~=Optimizer.FreeSwarmID
        if sum(isnan(Optimizer.pop(jj).Gbest_past_environment))==0
            Optimizer.pop(jj).Shifts = [Optimizer.pop(jj).Shifts , pdist2(Optimizer.pop(jj).Gbest_past_environment,Optimizer.pop(jj).BestPosition)];
        end
        dummy(jj,1:length(Optimizer.pop(jj).Shifts)) = Optimizer.pop(jj).Shifts;
    end
end
dummy = dummy(~isnan(dummy(:)));
if ~isempty(dummy)
    Optimizer.ShiftSeverity = mean(dummy);
end
Optimizer.Cloud = 0.2 * Optimizer.ShiftSeverity;
%% Introducing diversity (all except free swarm)
for jj=1 : Optimizer.SwarmNumber
    Optimizer.pop(jj).X = repmat(Optimizer.pop(jj).BestPosition,Optimizer.PopulationSize,1)+ (rands(Optimizer.PopulationSize,Optimizer.Dimension)*Optimizer.P*Optimizer.ShiftSeverity);
    Optimizer.pop(jj).X(1,:) = Optimizer.pop(jj).BestPosition;
    Optimizer.pop(jj).Velocity = rands(Optimizer.PopulationSize,Optimizer.Dimension)*Optimizer.Q*Optimizer.ShiftSeverity;
    Optimizer.pop(jj).Sleeping = 0;
end
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
    [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);
    Optimizer.pop(jj).PbestValue = Optimizer.pop(jj).FitnessValue;
    Optimizer.pop(jj).PbestPosition = Optimizer.pop(jj).X;
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
    [Optimizer.pop(jj).BestValue,BestPbestID] = max(Optimizer.pop(jj).PbestValue);
    Optimizer.pop(jj).BestPosition = Optimizer.pop(jj).PbestPosition(BestPbestID,:);
end
end