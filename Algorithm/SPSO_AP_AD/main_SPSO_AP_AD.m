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
function [Problem,E_bbc,E_o,CurrentError,VisualizationInfo,Iteration] = main_SPSO_AP_AD(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName)
BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ChangeFrequency*EnvironmentNumber);
for RunCounter=1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter);%This random seed setting is used to initialize the Problem
    end
    Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
    rng('shuffle');%Set a random seed for the optimizer
    %% Initialiing Optimizer
    clear Optimizer Species;
    Optimizer.SwarmMember = 5;%Species size
    Optimizer.NewlyAddedPopulationSize = 5;
    Optimizer.Dimension = Problem.Dimension ; 
    Optimizer.MaxCoordinate = Problem.MaxCoordinate; 
    Optimizer.MinCoordinate = Problem.MinCoordinate; 
    Optimizer.ShiftSeverity = 1;
    Optimizer.x = 0.729843788;
    Optimizer.c1 = 2.05;
    Optimizer.c2 = 2.05;
    Optimizer.ExclusionLimit = 0.5* ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate)/(Problem.PeakNumber ^ (1/Optimizer.Dimension)));
    Optimizer.GenerateRadious =  0.3* ((Optimizer.MaxCoordinate-Optimizer.MinCoordinate)/(Problem.PeakNumber ^ (1/Optimizer.Dimension)));
    Optimizer.teta = Optimizer.ShiftSeverity;
    Optimizer.tracker = [];
    Optimizer.rho = 0.7;
    Optimizer.MaxDeactivation = Optimizer.rho * Optimizer.ShiftSeverity;
    Optimizer.mu = 0.2;
    Optimizer.MinDeactivation = Optimizer.mu * sqrt(Optimizer.Dimension);
    Optimizer.CurrentDeactivation = Optimizer.MaxDeactivation;
    Optimizer.beta = 1;
    Optimizer.gama = 0.1;
    Optimizer.Nmax = 30;
    Optimizer.InitialPopulationSize = 50;%The initial population size. Note that the overal population size is adaptive. Therefore, the population size adaptively changes over time. The minimum value for this parameter is Optimizer.SwarmMember and the maximum value is Optimizer.SwarmMember*Optimizer.Nmax.
    for n=1 :Optimizer.InitialPopulationSize%Initializing the population
        [Optimizer.Particle(n),Problem] = SubPopulationGenerator_SPSO_AP_AD(Optimizer.MinCoordinate,Optimizer.MaxCoordinate,1,Optimizer.Dimension,Problem);
    end
    [Species,~]=CreatingSpecies(Optimizer);
    Iteration=0;
    VisualizationFlag=0;
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
            for ii=1 : numel(Species)
                for jj=1 : Optimizer.SwarmMember
                    counter = counter + 1;
                    VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.Particle(Species(ii).member(jj)).X;
                end
            end
            VisualizationInfo{Iteration}.IndividualNumber = counter;
            VisualizationInfo{Iteration}.FE = Problem.FE;
        end
        %% Optimization
        [Optimizer,Problem,Species] = IterativeComponents_SPSO_AP_AD(Optimizer,Problem);
        if Problem.RecentChange == 1%When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_SPSO_AP_AD(Optimizer,Problem, Species);
            VisualizationFlag = 0;
            clc; disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
        end
        if  Problem.FE >= Problem.MaxEvals%When termination criteria has been met
            break;
        end
    end
    %% Performance indicator calculation
    BestErrorBeforeChange(1,RunCounter) = mean(Problem.Ebbc);
    OfflineError(1,RunCounter) = mean(Problem.CurrentError);
    CurrentError(RunCounter,:) = Problem.CurrentError;
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
if VisualizationOverOptimization==1
    tmp = cell(1, Iteration);
    for ii=1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end