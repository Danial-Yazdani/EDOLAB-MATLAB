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
function [Optimizer , Problem] = IterativeComponents_mCMAES(Optimizer,Problem)
TmpSwarmNum = Optimizer.SwarmNumber;
%% Sub-population movement
for ii=1 : Optimizer.SwarmNumber
    % Generate and evaluate Optimizer.lambda offspring
    arx = Optimizer.pop(ii).X + Optimizer.pop(ii).sigma * Optimizer.pop(ii).B * (Optimizer.pop(ii).D .* randn(Optimizer.Dimension,Optimizer.lambda)); % m + sig * Normal(0,C)
    
    % Handle the elements of the variable which violate the boundary
    I = find(arx > Optimizer.MaxCoordinate);
    if ~isempty(I)
        arx(I) = 2 * Optimizer.MaxCoordinate - arx(I);
        arx(I(arx(I) < Optimizer.MinCoordinate)) = Optimizer.MinCoordinate;
    end
    I = find(arx < Optimizer.MinCoordinate);
    if ~isempty(I)
        arx(I) = 2 * Optimizer.MinCoordinate - arx(I);
        arx(I(arx(I) > Optimizer.MaxCoordinate)) = Optimizer.MaxCoordinate;
    end
    
    [arfitness,Problem] = fitness(arx',Problem); % objective function call
    if Problem.RecentChange == 1
        return;
    end
    Optimizer.pop(ii).counteval = Optimizer.pop(ii).counteval + Optimizer.lambda;
    
    % Sort by fitness and compute weighted mean into Optimizer.X
    [~, arindex] = sort(arfitness,'descend');  % minimization
    xold = Optimizer.pop(ii).X;
    Optimizer.pop(ii).X = arx(:,arindex(1:Optimizer.mu)) * Optimizer.weights;  % recombination, new mean value
    [Optimizer.pop(ii).FitnessValue,Problem] = fitness(Optimizer.pop(ii).X',Problem);
    if Problem.RecentChange == 1
        return;
    end
    % Cumumulation: Update evolution paths
    Optimizer.pop(ii).ps = (1-Optimizer.cs) * Optimizer.pop(ii).ps + sqrt(Optimizer.cs*(2-Optimizer.cs)*Optimizer.mueff) * Optimizer.pop(ii).invsqrtC * (Optimizer.pop(ii).X-xold) / Optimizer.pop(ii).sigma;
    hsig = sum(Optimizer.pop(ii).ps.^2)/(1-(1-Optimizer.cs)^(2*Optimizer.pop(ii).counteval/Optimizer.lambda))/Optimizer.Dimension < 2 + 4/(Optimizer.Dimension+1);
    Optimizer.pop(ii).pc = (1-Optimizer.cc) * Optimizer.pop(ii).pc + hsig * sqrt(Optimizer.cc*(2-Optimizer.cc)*Optimizer.mueff) * (Optimizer.pop(ii).X-xold) / Optimizer.pop(ii).sigma;
    
    % Adapt covariance matrix C
    artmp = (1/Optimizer.pop(ii).sigma) * (arx(:,arindex(1:Optimizer.mu)) - repmat(xold,1,Optimizer.mu));  % mu difference vectors
    Optimizer.pop(ii).C = (1-Optimizer.c1-Optimizer.cmu ) * Optimizer.pop(ii).C ...            % regard old matrix
        + Optimizer.c1 * (Optimizer.pop(ii).pc * Optimizer.pop(ii).pc' ...                % plus rank one update
        + (1-hsig) * Optimizer.cc*(2-Optimizer.cc) * Optimizer.pop(ii).C) ... % minor correction if hsig==0
        + Optimizer.cmu  * artmp * diag(Optimizer.weights) * artmp'; % plus rank mu update
    
    % Adapt step size Optimizer.sigma
    Optimizer.pop(ii).sigma = Optimizer.pop(ii).sigma * exp((Optimizer.cs/Optimizer.damps)*(norm(Optimizer.pop(ii).ps)/Optimizer.chiN - 1));
    
    % Update B and D from C
    if Optimizer.pop(ii).counteval - Optimizer.pop(ii).eigeneval > Optimizer.lambda/(Optimizer.c1+Optimizer.cmu )/Optimizer.Dimension/10  % to achieve O(N^2)
        Optimizer.pop(ii).eigeneval = Optimizer.pop(ii).counteval;
        Optimizer.pop(ii).C = triu(Optimizer.pop(ii).C) + triu(Optimizer.pop(ii).C,1)'; % enforce symmetry
        [Optimizer.pop(ii).B,Optimizer.pop(ii).D] = eig(Optimizer.pop(ii).C);           % eigen decomposition, B==normalized eigenvectors
        Optimizer.pop(ii).D = sqrt(diag(Optimizer.pop(ii).D));        % D contains standard deviations now
        Optimizer.pop(ii).invsqrtC = Optimizer.pop(ii).B * diag(Optimizer.pop(ii).D.^-1) * Optimizer.pop(ii).B';
    end
end
%% Exclusion
if Optimizer.SwarmNumber>1
    RemoveList = zeros(Optimizer.SwarmNumber,1);
    for ii=1 : Optimizer.SwarmNumber-1
        for jj=ii+1 : Optimizer.SwarmNumber
            if  pdist2(Optimizer.pop(ii).X',Optimizer.pop(jj).X')<Optimizer.ExclusionLimit
                if Optimizer.pop(ii).FitnessValue<Optimizer.pop(jj).FitnessValue
                    if Optimizer.FreeSwarmID~=ii
                        RemoveList(ii) = 1;
                    else
                        [Optimizer.pop(ii),Problem] = SubPopulationGenerator_mCMAES(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate, Optimizer.PopulationSize,Problem);
                        if Problem.RecentChange == 1
                            return;
                        end
                    end
                else
                    if Optimizer.FreeSwarmID~=jj
                        RemoveList(jj) = 1;
                    else
                        [Optimizer.pop(jj),Problem] = SubPopulationGenerator_mCMAES(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
                        if Problem.RecentChange == 1
                            return;
                        end
                    end
                end
            end
        end
    end
    for kk=Optimizer.SwarmNumber: -1 : 1
        if RemoveList(kk) == 1
            Optimizer.pop(kk) = [];
            Optimizer.SwarmNumber = Optimizer.SwarmNumber-1;
            Optimizer.FreeSwarmID = Optimizer.FreeSwarmID-1;
        end
    end
end
%% FreeSwarm Convergence
arx = arx';
Distances = pdist2(arx,arx)>Optimizer.ConvergenceLimit;
if sum(Distances(:))==0
    Optimizer.SwarmNumber = Optimizer.SwarmNumber+1;
    Optimizer.FreeSwarmID = Optimizer.SwarmNumber;
    [Optimizer.pop(Optimizer.FreeSwarmID),Problem] = SubPopulationGenerator_mCMAES(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    if Problem.RecentChange == 1
        return;
    end
end
%% Updating Thresholds
if TmpSwarmNum ~= Optimizer.SwarmNumber
    Optimizer.ExclusionLimit = 0.5 * ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / ((Optimizer.SwarmNumber) ^ (1 / Optimizer.Dimension)));
    Optimizer.ConvergenceLimit = Optimizer.ExclusionLimit;
end