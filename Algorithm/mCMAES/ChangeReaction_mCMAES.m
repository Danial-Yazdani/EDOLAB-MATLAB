%********************************mCMAES*****************************************************
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
function [Optimizer,Problem] = ChangeReaction_mCMAES(Optimizer,Problem)
%% Updating Shift Severity
dummy = NaN(Optimizer.SwarmNumber,Problem.EnvironmentNumber);
for jj=1 :Optimizer.SwarmNumber
    if jj~=Optimizer.FreeSwarmID
        if sum(isnan(Optimizer.pop(jj).Gbest_past_environment))==0
           Optimizer.pop(jj).Shifts = [Optimizer.pop(jj).Shifts , pdist2(Optimizer.pop(jj).Gbest_past_environment',Optimizer.pop(jj).X')];
        end
        dummy(jj,1:length(Optimizer.pop(jj).Shifts)) =Optimizer.pop(jj).Shifts;
    end
end
dummy = dummy(~isnan(dummy(:)));
if ~isempty(dummy)
   Optimizer.ShiftSeverity = mean(dummy);
end
%% Introducing diversity (all except free swarm)
    for jj=1 :Optimizer.SwarmNumber
        if jj~=Optimizer.FreeSwarmID
           Optimizer.pop(jj).sigma =Optimizer.pop(jj).ShiftSeverity/2;
            % Initialize dynamic (internal) strategy parameters and constants
           Optimizer.pop(jj).pc = zeros(Optimizer.Dimension,1);
           Optimizer.pop(jj).ps = zeros(Optimizer.Dimension,1);   % evolution paths for C andOptimizer.sigma
           Optimizer.pop(jj).B = eye(Optimizer.Dimension);                       % B defines the coordinate system
           Optimizer.pop(jj).D = ones(Optimizer.Dimension,1);                      % diagonal D defines the scaling
           Optimizer.pop(jj).C =Optimizer.pop(jj).B * diag(Optimizer.pop(jj).D.^2) *Optimizer.pop(jj).B';            % covariance matrix C
           Optimizer.pop(jj).invsqrtC =Optimizer.pop(jj).B * diag(Optimizer.pop(jj).D.^-1) *Optimizer.pop(jj).B';    % C^-1/2
           Optimizer.pop(jj).eigeneval = 0;                      % track update of B and D
           Optimizer.pop(jj).counteval = 0;  % the next 40 lines contain the 20 lines of interesting code
        end
    end
%% Updating memory
for jj=1 :Optimizer.SwarmNumber
   Optimizer.pop(jj).Gbest_past_environment =Optimizer.pop(jj).X;
   Optimizer.pop(jj).FGbest_past_environment =Optimizer.pop(jj).FitnessValue;
end
end