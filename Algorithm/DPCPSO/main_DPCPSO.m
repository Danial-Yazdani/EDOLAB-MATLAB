%********************************DPCPSO*****************************************************
%Author: Mai Peng
%E-mail: pengmai1998 AT gmail DOT com
%Last Edited: May 6, 2025
%
% ------------
% Reference:
% ------------
%
%  Li, Fei, et al. 
%       "A fast density peak clustering based particle swarm optimizer for dynamic optimization." 
%       Expert Systems with Applications 236 (2024): 121254.
%
% ------------
% Description:
% ------------
%   This code implements a Dynamic Optimization algorithm called DPCPSO,
%   which uses a fast density peak clustering method to partition the swarm
%   into sub-populations. It then applies Particle Swarm Optimization (PSO)
%   for local search, along with stagnation detection, exclusion scheme,
%   convergence detection, and change reaction (optimal particle calibration
%   and diversity maintenance) to efficiently solve dynamic optimization problems.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*****************************************************************************************
function [Problem,Results,CurrentError,VisualizationInfo,Iteration] = main_DPCPSO(VisualizationOverOptimization, RunNumber, BenchmarkName, ConfigurableProParameters, ConfigurableAlgParameters, progressInfo)
%% Send Progress if Parallel is ON
if isfield(progressInfo, 'IsParallel') && progressInfo.IsParallel
    send(progressInfo.Queue, struct('TaskID', progressInfo.TaskID, 'Status', 'Running', 'Progress', '0%'));
end

BestErrorBeforeChange = NaN(1,RunNumber);
OfflineError = NaN(1,RunNumber);
CurrentError = NaN (RunNumber,ConfigurableProParameters.ChangeFrequency.value*ConfigurableProParameters.EnvironmentNumber.value);
Runtime = NaN(1,RunNumber);
indicators = struct();

for RunCounter = 1 : RunNumber
    if VisualizationOverOptimization ~= 1
        rng(RunCounter); % Fix random seed for problem initialization
    end
    Problem = BenchmarkGenerator(BenchmarkName, ConfigurableProParameters);
    rng('shuffle'); % Set a random seed for the optimizer
    tic;  % Start runtime tracking
    
    %% Initialize DPCPSO Optimizer Parameters
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
    % Generate initial sub-populations via fast density peak clustering
    [Optimizer.pop, Problem] = SubPopulationGenerator_DPCPSO(Optimizer.Dimension,Optimizer.MinCoordinate,Optimizer.MaxCoordinate,Optimizer.PopulationSize,Problem);
    % Exclusion radius (used for preventing multiple sub-populations from 
    % exploring the same peak). Here set as a fraction of the search space range.
    Optimizer.SwarmNumber = length(Optimizer.pop);  % Number of sub-populations (to be determined by DPC)
    Optimizer.ExclusionRadius = 0.5 * ((Optimizer.MaxCoordinate - Optimizer.MinCoordinate) / (Optimizer.SwarmNumber^(1/Optimizer.Dimension)));
    
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
        
        %% Optimization Step: Call the DPCPSO Iterative Components
        [Optimizer,Problem] = IterativeComponents_DPCPSO(Optimizer,Problem);
        
        %% Change Reaction: Environment Change Detected
        if Problem.RecentChange == 1
            Problem.RecentChange = 0;
            [Optimizer,Problem] = ChangeReaction_DPCPSO(Optimizer,Problem);
            VisualizationFlag = 0;
            disp(['Run number: ',num2str(RunCounter),'   Environment number: ',num2str(Problem.Environmentcounter)]);
            if isfield(progressInfo, 'IsParallel') && progressInfo.IsParallel && mod(Problem.Environmentcounter, 2) == 0
                progressValue = 100 * (Problem.Environmentcounter + (RunCounter-1) * Problem.EnvironmentNumber) /(Problem.EnvironmentNumber * RunNumber);
                progressStr = [sprintf('%.2f', progressValue), '%'];
                send(progressInfo.Queue, struct('TaskID', progressInfo.TaskID, 'Status', 'Running', 'Progress', progressStr));
            end
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

%% Output Preparation: Summarize Results

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
    for ii = 1 : Iteration
        tmp{ii} = VisualizationInfo{ii};
    end
    VisualizationInfo = tmp;
end
end