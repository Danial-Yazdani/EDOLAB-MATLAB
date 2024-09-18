%*********************************CDE*****************************************
%Author: Mai Peng
%e-mail: pengmai1998 AT gmail DOT com
%Last Edited: Nov 13, 2021
%
% ------------
% Reference:
% ------------
%
% Plessis, M., &  Engelbrecht, A. P.
% "Using competitive population evaluation in a differential evolution algorithm for dynamic environments",
% European Journal of Operational Research, 218(1), 7-20.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License 
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%**************************************************************************************************
function [Problem,E_bbc,E_o,T_r,CurrentError,VisualizationInfo,Iteration] = main_CDE(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName)
BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ChangeFrequency*EnvironmentNumber);
Runtime = NaN(1,RunNumber);
for RunCounter=1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter);%This random seed setting is used to initialize the Problem
    end
    Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
    tic;
    rng('shuffle');%Set a random seed for the optimizer
    %% Initialiing Optimizer
    clear Optimizer;
    Optimizer.Dimension = Problem.Dimension;
    Optimizer.initPopulationSize = 100;
    Optimizer.MaxCoordinate = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    Optimizer.CR = 0.6;
    Optimizer.F = 0.5;
    Optimizer.SwarmNumber = 10;
    Optimizer.BrownNumber = 5;
    Optimizer.IndivSize = 10;
    Optimizer.ConvergenceLimit = 0.01;
    Optimizer.ExclusionLimit = (Optimizer.MaxCoordinate - Optimizer.MinCoordinate)/(2*PeakNumber.^(1/Dimension));
    Optimizer.OverlapDegree = 0.1;
    Optimizer.WorstPopID = -1;
    Optimizer.EvolveID = -1;
    %Choose Diversity StrategyFlag
    Optimizer.DiversityFlag = 1;    % 1: Brownian Individuals    
                                    % 2: Quantum Individuals    
    %Random CR/F or Not
    Optimizer.RandomFlag = 2;       % 1: Random CR/F             
                                    % 2: Fixed CR/F
    %Choose DE Strategy
    Optimizer.StrategyFlag = 4;     % 0: Random Strategy
                                    % 1: DE/RAND/1    
                                    % 2: DE/RAND/2    
                                    % 3: DE/BEST/1   
                                    % 4: DE/BEST/2    
                                    % 5: DE/RAND-TO-BEST/1     
                                    % 6: DE/CURRENT-TO-RAND/1     
                                    % 7: DE/CURRENT-TO-BEST/1 
    [Optimizer.pop,Problem] = SubPopulationGenerator_CDE(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.SwarmNumber,Optimizer.IndivSize,Problem,Optimizer.DiversityFlag,Optimizer.RandomFlag,Optimizer.StrategyFlag);
    Optimizer.SwarmNumber = length(Optimizer.pop);
    Optimizer.PreFitness = zeros(Optimizer.SwarmNumber,1);
    Optimizer.CurFitness = zeros(Optimizer.SwarmNumber,1);
    Optimizer.Performance = zeros(Optimizer.SwarmNumber,1);
    Optimizer.Iteration = 0;
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
        %% Optimization
        [Optimizer,Problem] = IterativeComponents_CDE(Optimizer,Problem);
        if Problem.RecentChange == 1%When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_CDE(Optimizer,Problem);
            VisualizationFlag = 0;
            clc; disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
        end
        if  Problem.FE >= Problem.MaxEvals%When termination criteria has been met
            break;
        end
    end
    elapsedTime = toc;
    %% Performance indicator calculation
    BestErrorBeforeChange(1,RunCounter) = mean(Problem.Ebbc);
    OfflineError(1,RunCounter) = mean(Problem.CurrentError);
    CurrentError(RunCounter,:) = Problem.CurrentError;
    Runtime(1,RunCounter) = elapsedTime;
end
%% Output preparation
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