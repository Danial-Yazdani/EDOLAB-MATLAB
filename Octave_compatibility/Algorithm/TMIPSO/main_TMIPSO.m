%********************************TMIPSO*****************************************************
%Author: Delaram Yazdani
%E-mail: delaram DOT yazdani AT yahoo DOT com
%Last Edited: April 17, 2025
%
% ------------
% Reference:
% ------------
%
%  Hongfeng Wang et al.,
%            "Triggered Memory-Based Swarm Optimization in Dynamic Environments"
%            Applications of Evolutionary Computing, pp. 637-646, 2007.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Problem,Results,CurrentError,VisualizationInfo,Iteration] = main_TMIPSO(VisualizationOverOptimization, RunNumber, BenchmarkName, ConfigurableProParameters, ConfigurableAlgParameters, progressInfo)
%% Send Progress if Parallel is ON
if isfield(progressInfo, 'IsParallel') && progressInfo.IsParallel
    send(progressInfo.Queue, struct('TaskID', progressInfo.TaskID, 'Status', 'Running', 'Progress', '0%'));
end

BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ConfigurableProParameters.ChangeFrequency.value*ConfigurableProParameters.EnvironmentNumber.value);
Runtime = NaN(1,RunNumber);
indicators = struct();

% The above lines define the parameters used for gathering data for outputs including 
% performance indicators, plots, and runtime. 
% These are common across all algorithms implemented in EDOLAB and facilitate tracking 
% key metrics throughout the optimization process.
for RunCounter=1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter);%This random seed setting is used to initialize the Problem
    end
    Problem = BenchmarkGenerator(BenchmarkName, ConfigurableProParameters);
    rng('shuffle');%Set a random seed for the optimizer
    tic; % Start runtime tracking for the current run
    % The lines above (including the start of the loop) are common between the main files of all EDOAs.
    %% Initialiing Optimizer
    clear Optimizer;
    % Set Configurable Parameters
    fieldNames = fieldnames(ConfigurableAlgParameters);
    for i = 1:length(fieldNames)
        Optimizer.(fieldNames{i}) = ConfigurableAlgParameters.(fieldNames{i}).value;
    end

    % Other Parameters
    Optimizer.Dimension = Problem.Dimension;
    Optimizer.MaxCoordinate   = Problem.MaxCoordinate;
    Optimizer.MinCoordinate = Problem.MinCoordinate;
    Optimizer.DiversityPlus = 1;
    Optimizer.x = 0.729843788;
    Optimizer.c1 = 2.05;
    Optimizer.c2 = 2.05;
    Optimizer.ShiftSeverity = 1;%initial shift severity    
    Optimizer.SwarmNumber = 1;
    [Optimizer.ExploitPop,Problem] = SubPopulationGenerator_TMIPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ExploitPopSize,Problem);
    [Optimizer.ExplorePop,Problem] = SubPopulationGenerator_TMIPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.ExplorePopSize,Problem);
    Optimizer.MemoryPosition = [];
    Optimizer.MemoryFitness = [];  
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
        if (VisualizationOverOptimization==1 && Optimizer.Dimension == 2)
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
            for jj=1 : Optimizer.ExploitPopSize
                counter = counter + 1;
                VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.ExploitPop.X(jj,:);
            end                                    
            for jj=1 : Optimizer.ExplorePopSize
                counter = counter + 1;
                VisualizationInfo{Iteration}.Individuals(counter,:) = Optimizer.ExplorePop.X(jj,:);
            end            
            VisualizationInfo{Iteration}.IndividualNumber = counter;
            VisualizationInfo{Iteration}.FE = Problem.FE;
        end
        %% Optimization
        [Optimizer,Problem] = IterativeComponents_TMIPSO(Optimizer,Problem);
        if Problem.RecentChange == 1%When an environmental change has happened
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_TMIPSO(Optimizer,Problem);
            VisualizationFlag = 0;
            disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
            if isfield(progressInfo, 'IsParallel') && progressInfo.IsParallel && mod(Problem.Environmentcounter, 2) == 0
                progressValue = 100 * (Problem.Environmentcounter + (RunCounter-1) * Problem.EnvironmentNumber) /(Problem.EnvironmentNumber * RunNumber);
                progressStr = [sprintf('%.2f', progressValue), '%'];
                send(progressInfo.Queue, struct('TaskID', progressInfo.TaskID, 'Status', 'Running', 'Progress', progressStr));
            end
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
     CurrentError(RunCounter,:) = Problem.CurrentError; % Record current error values for plotting convergence behavior over time
    % User defined Indicators for all EDOAs.
    fnames = fieldnames(Problem.Indicators);
    for m = 1 : numel(fnames)
        name = fnames{m};
        info = Problem.Indicators.(name);
        indicators.(name).type = info.type;
        switch info.type
          case {'FE based','Environment based'}
            indicators.(name).trend(RunCounter, :) = Problem.Indicators.(name).trend;
            indicators.(name).final(RunCounter) = mean(Problem.Indicators.(name).trend);
          case 'None'
            indicators.(name).final(RunCounter) = Problem.Indicators.(name).final;
          otherwise
            error('Unknown indicator type "%s" for %s', info.type, name);
        end
    end
    %% Send Progress if Parallel is ON
    if isfield(progressInfo, 'IsParallel') && progressInfo.IsParallel
        send(progressInfo.Queue, struct('TaskID', progressInfo.TaskID, 'Status', 'Running', 'Progress', [num2str(sprintf('%.2f', RunCounter/RunNumber * 100)), '%']));
    end    
end
%% Output Preparation: Common Across All EDOAs
% This section gathers and summarizes the results of the experiment, including
% performance indicators (E_bbc for Best Error Before Change, E_o for Offline Error),
% runtime statistics (T_r), and any visualization data if enabled.

% User defined indicators for all EDOAs
fnames = fieldnames(indicators);
for m = 1 : numel(fnames)
    name = fnames{m};
    indicator  = indicators.(name);
    type = indicator.type;
    Results.(name).type = type;
    switch type
      case {'FE based','Environment based'}
        data = indicator.trend;
        final = indicator.final;
        Results.(name).AllResults = final;
        Results.(name).trend  = data;
        Results.(name).mean   = mean(final);
        Results.(name).median = median(final);
        Results.(name).StdErr = std(final)/sqrt(RunNumber);
      case 'None'
        final = indicator.final;
        Results.(name).AllResults = final;
        Results.(name).mean   = mean(final);
        Results.(name).median = median(final);
        Results.(name).StdErr = std(final)/sqrt(RunNumber);
      otherwise
        error('Unknown indicator type "%s" for %s', type, name);
    end
end
Results.T_r.mean = mean(Runtime);
Results.T_r.median = median(Runtime);
Results.T_r.StdErr = std(Runtime)/sqrt(RunNumber);
Results.T_r.AllResults = Runtime;

if VisualizationOverOptimization==1
    tmp = cell(1, Iteration);
    for ii=1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end