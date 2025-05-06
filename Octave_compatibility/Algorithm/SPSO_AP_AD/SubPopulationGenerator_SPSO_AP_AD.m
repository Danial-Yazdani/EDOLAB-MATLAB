%********************************SPSO_AP_AD*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: July 12, 2023
%
% ------------
% Reference:
% ------------
%
%  Delaram Yazdani et al.,
%            "A Species-based Particle Swarm Optimization with Adaptive Population Size and Deactivation of Species for Dynamic Optimization Problems"
%            ACM Transactions on Evolutionary Learning and Optimization, 2023.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Optimizer,Problem]= SubPopulationGenerator_SPSO_AP_AD(LB,UB,npop,dimension,Problem)
Optimizer.X = LB + (UB-LB).*rand(npop,dimension);
Optimizer.PbestPosition = Optimizer.X;
Optimizer.Velocity = zeros(npop,dimension);
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X,Problem);
if Problem.RecentChange == 0
    Optimizer.PbestFitness = Optimizer.FitnessValue;
else
    Optimizer.FitnessValue = -inf(npop,1);
    Optimizer.PbestFitness = Optimizer.FitnessValue;
end
Optimizer.Processed = 0;
Optimizer.Shifts = [];
Optimizer.Pbest_past_environment=[];