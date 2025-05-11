%********************************mjDE*****************************************************
%Authors: Delaram Yazdani and Danial Yazdani
%E-mails: delaram DOT yazdani AT yahoo DOT com
%         danial DOT yazdani AT gmail DOT com
%Last Edited: January 12, 2022
%
% ------------
% Reference:
% ------------
%
%  Danial Yazdani et al.,
%            "Scaling up dynamic optimization problems: A divide-and-conquer approach"
%             IEEE Transactions on Evolutionary Computation, vol. 24(1), pp. 1 - 15, 2019.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% E-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem] = ChangeReaction_mjDE(Optimizer,Problem)
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
%% Introducing diversity (all except free swarm)
for jj=1 : Optimizer.SwarmNumber
    if jj~=Optimizer.FreeSwarmID
        Optimizer.pop(jj).X = repmat(Optimizer.pop(jj).BestPosition,Optimizer.PopulationSize,1)+ ((2*rand(Optimizer.PopulationSize,Optimizer.Dimension)-1)*Optimizer.ShiftSeverity);
        Optimizer.pop(jj).X(1,:) = Optimizer.pop(jj).BestPosition;
    end
end
%% Updating memory
for jj=1 : Optimizer.SwarmNumber
   [Optimizer.pop(jj).FitnessValue,Problem] = fitness(Optimizer.pop(jj).X , Problem);    
    Optimizer.pop(jj).Gbest_past_environment = Optimizer.pop(jj).BestPosition;
end
end