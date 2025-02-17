%********************************APCPSO*****************************************************
%Author: Mai Peng
%E-mail: pengmai1998 AT gmail DOT com
%Last Edited: February 17, 2025
%
% ------------
% Reference:
% ------------
%
%       "Liu, Yuanchao, et al. 
%           "An affinity propagation clustering based particle swarm optimizer for dynamic optimization." 
%               Knowledge-Based Systems 195 (2020): 105711.
%
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Problem,E_bbc,E_o,T_r,CurrentError,VisualizationInfo,Iteration] = main_APCPSO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName)

BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ChangeFrequency*EnvironmentNumber);
Runtime = NaN(1,RunNumber);

for RunCounter = 1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter); % Fix random seed for problem initialization
    end
    Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
    rng('shuffle'); % Set a random seed for the optimizer
    tic;  % Start runtime tracking
    
    %% Initialize APCPSO Optimizer Parameters
    clear Optimizer;
    Optimizer.Dimension = Problem.Dimension;
    Optimizer.PopulationSize = 100;  % Number of particles per sub-population
    Optimizer.MaxCoordinate   = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    
    % PSO local search parameters
    Optimizer.c1 = 1.7;
    Optimizer.c2 = 1.7;

    Optimizer.omega_max = 0.6;    % Upper bound for inertia weight (ω_max)
    Optimizer.omega_min = 0.3;    % Lower bound for inertia weight (ω_min)
    Optimizer.MaxSubPopIterations = 50; % Maximum iterations for sub-population (S_i)
    
    % Stagnation detection parameter
    Optimizer.StagnationThreshold = 15;
    
    % Generate initial sub-populations via fast density peak clustering
    [Optimizer.pop, Problem] = SubPopulationGenerator_APCPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);


    % Exclusion radius (used for preventing multiple sub-populations from 
    % exploring the same peak). Here set as a fraction of the search space range.
    Optimizer.SwarmNumber = length(Optimizer.pop);  % Number of sub-populations (to be determined by DPC)
    Optimizer.ExclusionRadius = 0.5 * ((Optimizer.MaxCoordinate - Optimizer.MinCoordinate) / (Optimizer.SwarmNumber^(1/Optimizer.Dimension)));
    
    % Convergence detection threshold (set equal to the exclusion radius for simplicity)
    Optimizer.ConvergenceThreshold = 0.1;
    
    VisualizationFlag = 0;
    Iteration = 0;
    if VisualizationOverOptimization==1
        VisualizationInfo = cell(1,Problem.MaxEvals);
    else
        VisualizationInfo = [];
    end
    
    %% Main Loop
    while 1
        Iteration = Iteration + 1;
        %% Visualization for education module
        if (VisualizationOverOptimization==1 && Dimension == 2)
            if VisualizationFlag==0
                VisualizationFlag=1;
                T = Problem.MinCoordinate : ( Problem.MaxCoordinate-Problem.MinCoordinate)/100 :  Problem.MaxCoordinate;
                L=length(T);
                F=zeros(L);
                for i=1:L
                    for j=1:L
                        F(i,j) = EnvironmentVisualization([T(i), T(j)],Problem);
                    end
                end
            end
            VisualizationInfo{Iteration}.T=T;
            VisualizationInfo{Iteration}.F=F;
            VisualizationInfo{Iteration}.Problem.PeakVisibility = Problem.PeakVisibility(Problem.Environmentcounter,:);
            VisualizationInfo{Iteration}.Problem.OptimumID = Problem.OptimumID(Problem.Environmentcounter);
            VisualizationInfo{Iteration}.Problem.PeaksPosition = Problem.PeaksPosition(:,:,Problem.Environmentcounter);
            VisualizationInfo{Iteration}.CurrentEnvironment = Problem.Environmentcounter;
            counter = 0;
            for ii=1 : Optimizer.SwarmNumber
                for jj=1 :size(Optimizer.pop(ii).X,1)
                    counter = counter + 1;
                    VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.pop(ii).X(jj,:);
                end
            end
            VisualizationInfo{Iteration}.IndividualNumber = counter;
            VisualizationInfo{Iteration}.FE = Problem.FE;
        end
        
        %% Optimization Step: Call the APCPSO Iterative Components
        [Optimizer,Problem] = IterativeComponents_APCPSO(Optimizer, Problem);
        
        %% Change Reaction: Environment Change Detected
        if Problem.RecentChange == 1
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_APCPSO(Optimizer,Problem);
            VisualizationFlag = 0;
            clc; disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
        end
        
        if Problem.FE >= Problem.MaxEvals % Termination criteria met
            break;
        end
    end
    
    %% Gather Runtime and Performance Indicators
    elapsedTime = toc;
    Runtime(1,RunCounter) = elapsedTime;
    BestErrorBeforeChange(1,RunCounter) = mean(Problem.Ebbc);
    OfflineError(1,RunCounter) = mean(Problem.CurrentError);
    CurrentError(RunCounter,:) = Problem.CurrentError;
end

%% Output Preparation: Summarize Results
E_bbc.mean = mean(BestErrorBeforeChange);
E_bbc.median = median(BestErrorBeforeChange);
E_bbc.StdErr = std(BestErrorBeforeChange)/sqrt(RunNumber);
E_bbc.AllResults = BestErrorBeforeChange;
E_o.mean = mean(OfflineError);
E_o.median = median(OfflineError);
E_o.StdErr = std(OfflineError)/sqrt(RunNumber);
E_o.AllResults = OfflineError;
T_r.mean = mean(Runtime);
T_r.median = median(Runtime);
T_r.StdErr = std(Runtime)/sqrt(RunNumber);
T_r.AllResults = Runtime;
if VisualizationOverOptimization==1
    tmp = cell(1, Iteration);
    for ii = 1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end
end