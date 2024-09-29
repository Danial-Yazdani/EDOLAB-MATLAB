%********************************ACFPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: September 29, 2024
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
function [Problem,E_bbc,E_o,T_r,CurrentError,VisualizationInfo,Iteration] = main_ACFPSO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName)
BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ChangeFrequency*EnvironmentNumber);
Runtime = NaN(1,RunNumber);

% The above lines define the parameters used for gathering data for outputs including 
% performance indicators, plots, and runtime. 
% These are common across all algorithms implemented in EDOLAB and facilitate tracking 
% key metrics throughout the optimization process.

for RunCounter=1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter);%This random seed setting is used to initialize the Problem
    end
    Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
    rng('shuffle');%Set a random seed for the optimizer
    tic; % Start runtime tracking for the current run
    % The lines above (including the start of the loop) are common between the main files of all EDOAs.
    %% Initialiing Optimizer
    clear Optimizer;
    Optimizer.SwarmNumber = 1;
    Optimizer.Dimension = Problem.Dimension;
    Optimizer.PopulationSize = 5;
    Optimizer.MaxCoordinate   = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    Optimizer.FreeSwarmID = 1;%Index of the free swarm
    Optimizer.Radius = ones(1,Optimizer.Dimension) * (Optimizer.MaxCoordinate-Optimizer.MinCoordinate) / Optimizer.SwarmNumber ;
    Optimizer.ConvergenceSleepLayer = 0.05;
    Optimizer.ConvergenceOuterLayer = 0.8;
    Optimizer.ConvergenceInnerLayer = 0.3;
    Optimizer.ExclusionOuterLayer = 1;
    Optimizer.ExclusionInnerLayer = 0.3;
    Optimizer.DiversityPlus = 1;
    Optimizer.x = 0.729843788;
    Optimizer.c1 = 2.05;
    Optimizer.c2 = 2.05;
    Optimizer.ShiftSeverity = ones(1,Optimizer.Dimension);%initial shift severity
    Optimizer.Relocations = NaN(Problem.EnvironmentNumber,Optimizer.Dimension);
    Optimizer.Relocations(1,:) = Optimizer.ShiftSeverity;
    for ii=1 : Optimizer.SwarmNumber
        [Optimizer.pop(ii),Problem] = SubPopulationGenerator_ACFPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    end
        VisualizationFlag=0;
    Iteration=0;
    if VisualizationOverOptimization==1
        VisualizationInfo = cell(1,Problem.MaxEvals);
    else
        VisualizationInfo = [];
    end
    %% main loop
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
            VisualizationInfo{Iteration}.Problem.PeakVisibility = Problem.PeakVisibility(Problem.Environmentcounter , :);
            VisualizationInfo{Iteration}.Problem.OptimumID = Problem.OptimumID(Problem.Environmentcounter);
            VisualizationInfo{Iteration}.Problem.PeaksPosition = Problem.PeaksPosition(:,:,Problem.Environmentcounter);
            VisualizationInfo{Iteration}.CurrentEnvironment = Problem.Environmentcounter;
            counter = 0;
            for ii=1 : Optimizer.SwarmNumber
                for jj=1 : Optimizer.PopulationSize
                    counter = counter + 1;
                    VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.pop(ii).X(jj,:);
                end
            end
            VisualizationInfo{Iteration}.IndividualNumber = counter;
            VisualizationInfo{Iteration}.FE = Problem.FE;
        end
        %% Optimization
        [Optimizer,Problem] = IterativeComponents_ACFPSO(Optimizer,Problem);
        if Problem.RecentChange == 1%When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_ACFPSO(Optimizer,Problem);
            VisualizationFlag = 0;
            clc; disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
        end
        if  Problem.FE >= Problem.MaxEvals%When termination criteria has been met
            break;
        end
    end
    %% Runtime, Performance Indicator, and Plot Data Gathering
    % This section is common across all EDOAs and must be executed after each run to gather runtime, performance indicators, and plot data.
    elapsedTime = toc;  % Stop the timer for the current run and record runtime
    Runtime(1,RunCounter) = elapsedTime;  % Store the runtime for the current run
    BestErrorBeforeChange(1,RunCounter) = mean(Problem.Ebbc);  % Calculate and store average best error before each environmental change
    OfflineError(1,RunCounter) = mean(Problem.CurrentError);  % Calculate and store the offline error across all function evaluations
    CurrentError(RunCounter,:) = Problem.CurrentError;  % Record current error values for plotting convergence behavior over time
end
%% Output Preparation: Common Across All EDOAs
% This section gathers and summarizes the results of the experiment, including
% performance indicators (E_bbc for Best Error Before Change, E_o for Offline Error),
% runtime statistics (T_r), and any visualization data if enabled.
E_bbc.mean = mean(BestErrorBeforeChange);
E_bbc.median = median(BestErrorBeforeChange);
E_bbc.StdErr = std(BestErrorBeforeChange)/sqrt(RunNumber);
E_bbc.AllResults = BestErrorBeforeChange;
E_o.mean = mean(OfflineError);
E_o.median = median(OfflineError);
E_o.StdErr = std(OfflineError)/sqrt(RunNumber);
E_o.AllResults =OfflineError;
T_r.mean = mean(Runtime);
T_r.median = median(Runtime);
T_r.StdErr = std(Runtime)/sqrt(RunNumber);
T_r.AllResults = Runtime;
if VisualizationOverOptimization==1
    tmp = cell(1, Iteration);
    for ii=1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end