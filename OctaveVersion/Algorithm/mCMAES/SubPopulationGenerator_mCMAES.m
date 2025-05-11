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
function [Optimizer,Problem] = SubPopulationGenerator_mCMAES(Dimension,MinCoordinate,MaxCoordinate,PopulationSize,Problem)
Optimizer.Gbest_past_environment = NaN(1,Dimension);
Optimizer.FGbest_past_environment = NaN(1,1);
Optimizer.X = MinCoordinate + ((MaxCoordinate-MinCoordinate).*rand(Dimension,1));
[Optimizer.FitnessValue,Problem] = fitness(Optimizer.X',Problem);
Optimizer.sigma = round((MaxCoordinate-MinCoordinate)/3);
  % Initialize dynamic (internal) strategy parameters and constants
Optimizer.pc = zeros(Dimension,1); 
Optimizer.ps = zeros(Dimension,1);   % evolution paths for C and Optimizer.sigma
Optimizer.B = eye(Dimension);                       % B defines the coordinate system
Optimizer.D = ones(Dimension,1);                      % diagonal D defines the scaling
Optimizer.C = Optimizer.B * diag(Optimizer.D.^2) * Optimizer.B';            % covariance matrix C
Optimizer.invsqrtC = Optimizer.B * diag(Optimizer.D.^-1) * Optimizer.B';    % C^-1/2 
Optimizer.eigeneval = 0;                      % track update of B and D
Optimizer.counteval = 0;  % the next 40 lines contain the 20 lines of interesting code 
Optimizer.Shifts = [];
Optimizer.ShiftSeverity = 1;