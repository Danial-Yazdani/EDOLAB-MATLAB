%*********************************EDOLAB ver 2.00*********************************
%
% Author: Mai Peng, Danial Yazdani and Delaram Yazdani
% Last Edited: May 6, 2025
% e-mail: pengmai1998@gmail.com
%
% ------------
% Reference:
% ------------
%
%  Title: "EDOLAB: An Open-Source Platform for Education and Experimentation with Evolutionary Dynamic Optimization Algorithms"
%  ArXiv: arxiv.org/abs/2308.12644
%  Note: reference information will be completed after acceptance of the paper
%
% ------------
% Notification:
% ------------
% 
%  This function is used to run EDOLAB with GUI. EDOLAB's GUI is designed using
%  MATLAB R2020b and is not backward compatible. To use EDOLAB through its GUI,
%  the user must use MATLAB R2020b or newer versions. Users with older MATLAB 
%  versions can use EDOLAB without the GUI by running "RunWithoutGUI.m"
%  For optimal performance and compatibility, using the latest MATLAB version is recommended.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*********************************************************************************
classdef GUIMode < matlab.apps.AppBase

    % Properties
    properties (Access = public)
        UIFigure                                matlab.ui.Figure
        SAFigure                                matlab.ui.Figure
        TabGroup                                matlab.ui.container.TabGroup
        ExperimentalTab                         matlab.ui.container.Tab
        EducationalTab                          matlab.ui.container.Tab
        CleanRAMButton                          matlab.ui.control.Button
        SettingsWindow                          matlab.ui.Figure
                    
        % Experimental          
        % Parameters Selection          
        LeftPanel                               matlab.ui.container.Panel
        LeftGridLayout                          matlab.ui.container.GridLayout
        SelectGridLayout                        matlab.ui.container.GridLayout
        AlgorithmLabel                          matlab.ui.control.Label
        AlgorithmList                           matlab.ui.control.DropDown
        BenchmarkLabel                          matlab.ui.control.Label
        BenchmarkList                           matlab.ui.control.DropDown
        RunNumberLabel                          matlab.ui.control.Label
        RunNumberSpinner                        matlab.ui.control.Spinner
            
        AlgorithmParametersPanel                matlab.ui.container.Panel
        BenchmarkParametersPanel                matlab.ui.container.Panel
        AddTaskButton                           matlab.ui.control.Button
                    
        % UncompletedTasks          
        CenterPanel                             matlab.ui.container.Panel
        CenterGridLayout                        matlab.ui.container.GridLayout
        SelectAllUncompletedTasksCheckBox       matlab.ui.control.CheckBox
        UncompletedTasksTable                   matlab.ui.control.Table
        UseLogicalCheckbox                      matlab.ui.control.CheckBox
        UseLogicalLable                         matlab.ui.control.Label
        ThreadsLabel                            matlab.ui.control.Label
        PoolTypeLabel                           matlab.ui.control.Label        
        PoolTypeDropdown                        matlab.ui.control.DropDown
        ThreadsInput
        RunButton                               matlab.ui.control.Button
        FastDeletePendingButton                 matlab.ui.control.Button
                    
        % CompletedTasks            
        RightPanel                              matlab.ui.container.Panel
        RightGridLayout                         matlab.ui.container.GridLayout
        CompletedTasksTable                     matlab.ui.control.Table
        SelectAllCompletedTasksCheckBox         matlab.ui.control.CheckBox
        UnionIndicatorsGridLayout               matlab.ui.container.GridLayout
        FastSelectSAButton                      matlab.ui.control.Button
        FastDeleteButton                        matlab.ui.control.Button
        FastFilterButton                        matlab.ui.control.Button
        CurrentErrorPlotButton                  matlab.ui.control.Button
        ImportButton                            matlab.ui.control.Button
        ExportButton                            matlab.ui.control.Button
        ShowUnionIndicatorsLabel                matlab.ui.control.Label
        IntersectIndicatorsGridLayout           matlab.ui.container.GridLayout
        UnionIndicatorsPanel
        UnionIndicatorsCheckboxes
            
        % Statistical Analysis          
        SAPanel                                 matlab.ui.container.Panel
        SAGridLayout                            matlab.ui.container.GridLayout
        SATasksTable                            matlab.ui.control.Table
        SAMethodSelectLabel                     matlab.ui.control.Label
        SAMethodSelectDropdown                  matlab.ui.control.DropDown
        RankSumResultsTable                     matlab.ui.control.Table
        SignedRankResultsTable                  matlab.ui.control.Table
        FriedmanResultsTable                    matlab.ui.control.Table
        SAFastRemoveButton                      matlab.ui.control.Button
        TrendPlotButton                            matlab.ui.control.Button
        % CancelChoice
        BoxPlotButton                           matlab.ui.control.Button
        AnalyzeButton                           matlab.ui.control.Button
        ShowIntersectIndicatorsLabel            matlab.ui.control.Label
        SelectAllSATasksCheckBox                matlab.ui.control.CheckBox
        IntersectIndicatorsCheckboxes

        % Educational
        EducationalLeftPanel                    matlab.ui.container.Panel
        EducationalLeftGridLayout               matlab.ui.container.GridLayout
        EducationalSelectGridLayout             matlab.ui.container.GridLayout
        EducationalAlgorithmLabel               matlab.ui.control.Label
        EducationalAlgorithmList                matlab.ui.control.DropDown
        EducationalBenchmarkLabel               matlab.ui.control.Label
        EducationalBenchmarkList                matlab.ui.control.DropDown
        EducationalAlgorithmParametersPanel     matlab.ui.container.Panel
        EducationalBenchmarkParametersPanel     matlab.ui.container.Panel
        EducationalRunButton                    matlab.ui.control.Button
        EducationalDialog
        
        EducationalRightPanel                   matlab.ui.container.Panel
        EducationalVisualizationGrid            matlab.ui.container.GridLayout
        EducationalUIAxes                       matlab.ui.control.UIAxes
        EducationalUIAxes2                      matlab.ui.control.UIAxes
        EducationalPlayButton                   matlab.ui.control.Button
        EducationalResetButton                  matlab.ui.control.Button
        EducationalResizeButton
        EducationalSlider                       matlab.ui.control.Slider
        EducationalIterLabel                    matlab.ui.control.Label
        EducationalSpeedDropdown                matlab.ui.control.DropDown
        EducationalIterInput
        
    end

    properties (Access = private)
        projectPath
        RunNumber (1,1) double = 31
        Tasks
        PendingTasksSelectionStates
        CompletedTasksSelectionStates; 
        SATasksSelectionStates;
        SATasks
        SAResults
        SARowNames
        SAColNames
        TaskBubble
        NumberRunningTasks = 0
        ExperimentalConfigurableAlgorithmParameters
        ExperimentalConfigurableBenchmarkParameters
        EducationalConfigurableAlgorithmParameters
        EducationalConfigurableBenchmarkParameters
        EducationalTryCount = 0
        CurrentError
        CurrentIter double = 1   
        TotalIter double = 0     
        IsPlaying logical = false
        VisualizationData
        SpeedMap
        VisualizationLoop
        PreviousContourT
        PreviousContourF
        DefaultInteractions_1
        DefaultInteractions_2
        UserSettingNumberThreads

        PhysicalCores
        LogicalProcessors

        UnionIndicatorsItem
        IntersectIndicatorsItem

        PoolTypeItem
        PoolTypeValue
        NowPoolType
        
    end

    % Version
    properties (Access = private)
        isMATLABReleaseOlderThan_R2020b
        isMATLABReleaseOlderThan_R2024a
    end
    
    % parpool
    properties (Access = private)
        Futures = []
    end

    % Methods for Startup
    methods (Access = private)
        function checkMATLABVersion(app)
            try
                app.isMATLABReleaseOlderThan_R2020b = isMATLABReleaseOlderThan("R2020b");
                app.isMATLABReleaseOlderThan_R2024a = isMATLABReleaseOlderThan("R2024a");

            catch
                app.isMATLABReleaseOlderThan_R2020b = true;
                app.isMATLABReleaseOlderThan_R2024a = true;
            end
        
            if app.isMATLABReleaseOlderThan_R2020b
                error([
                    '❌ This application does not support MATLAB versions older than R2020b.' newline ...
                    'Please upgrade your MATLAB installation.'
                ]);
            elseif app.isMATLABReleaseOlderThan_R2024a
                warning([
                    '⚠ Your MATLAB version is older than R2024a. The thread-based parallel pool will be disabled.' newline ...
                    'You can still use the process-based parallel pool, but upgrading to R2024a or later is recommended.'
                ]);
                app.PoolTypeItem  = {'Process Pool'};
                app.PoolTypeValue = {'processes'};
                app.NowPoolType   = 'processes';
            else
                v = ['Release R' version('-release')];
                disp(['✅ Your MATLAB version (' v ') is compatible.']);
                disp('For optimal performance and compatibility, using the latest MATLAB version is recommended.');
                app.PoolTypeItem  = {'Thread Pool', 'Process Pool'};
                app.PoolTypeValue = {'threads', 'processes'};
                app.NowPoolType   = 'processes';
            end
        end


        function initializeTasks(app)
            app.Tasks = containers.Map('KeyType', 'char', 'ValueType', 'any');
            app.SATasks = containers.Map('KeyType', 'char', 'ValueType', 'any');
            app.CompletedTasksSelectionStates = containers.Map('KeyType', 'char', 'ValueType', 'logical');
            app.PendingTasksSelectionStates = containers.Map('KeyType', 'char', 'ValueType', 'logical');
            app.SATasksSelectionStates = containers.Map('KeyType', 'char', 'ValueType', 'logical');
        end

        function setTask(app, taskID, taskData)
            app.Tasks(taskID) = taskData;
        end
        
        function taskData = getTask(app, taskID)
            if isKey(app.Tasks, taskID)
                taskData = app.Tasks(taskID);
            else
                taskData = [];
                disp('Task not found.');
            end
        end

        function removeTask(app, taskID)
            if isKey(app.Tasks, taskID)
                remove(app.Tasks, taskID);
                disp(['Task ', num2str(taskID), ' has been removed.']);
            else
                disp(['Task ', num2str(taskID), ' not found.']);
            end
        end

        % Create UIFigure and components
        function createComponents(app)
            % Create the UI Window
            % app.UIFigure = uifigure('Name', 'EDOLAB', 'Resize', 'off');
            app.UIFigure = uifigure('Name', 'EDOLAB');
            app.UIFigure.Position = [100 100 1680 900];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [0 0 1680 900];
        
            % Create Experimental Tab
            app.ExperimentalTab = uitab(app.TabGroup, 'Title', 'Experimental');
        
            % Create Experimental GridLayout
            experimentalGrid = uigridlayout(app.ExperimentalTab, [1, 4]);
            experimentalGrid.ColumnWidth = {'1.15x','1.25x','2x', '1.25x'};
        
            % Left - Parameter selection area
            app.LeftPanel = uipanel(experimentalGrid, 'Title', 'Task Settings');
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;
        
            % Create LeftGridLayout
            app.LeftGridLayout = uigridlayout(app.LeftPanel, [8, 1]);
            app.LeftGridLayout.RowHeight = {100, 40, '3x', 40, '3x', 30, 50};
            app.LeftGridLayout.RowSpacing = 10;
            
            % Create a Panel container for the prompt box
            tiplabelPanel_1 = uipanel(app.LeftGridLayout);
            tiplabelPanel_1.Layout.Row = 1;
            tiplabelPanel_1.Layout.Column = 1;
            tiplabelPanel_1.BackgroundColor = [0.95 0.95 0.95];
            
            % Create a Label inside the Panel to display the prompt text
            tipText = ['Configure the algorithm and benchmark parameters for your experiment as above. ' ...
           'Click "Add Task" to save it to the pending task list for later execution, visualization, or statistical analysis. '];

            tipGridLayout_1 = uigridlayout(tiplabelPanel_1);
            tipGridLayout_1.RowHeight = {'1x'};
            tipGridLayout_1.ColumnWidth = {'1x'};
            tipGridLayout_1.Scrollable = 'on';

            uilabel(tipGridLayout_1, ...
                'Text', tipText, ...
                'FontSize', 10, ...                   
                'FontColor', [0.2 0.2 0.2], ...       
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'WordWrap', 'on', ...                
                'BackgroundColor', [0.95 0.95 0.95]); 
            
            % Select the algorithm drop-down menu
            app.SelectGridLayout = uigridlayout(app.LeftGridLayout, [1, 2]);
            app.SelectGridLayout.RowHeight = {30};
            app.SelectGridLayout.ColumnWidth = {'1x', 150};
            app.SelectGridLayout.Layout.Row = 2;

            app.AlgorithmLabel = uilabel(app.SelectGridLayout, 'Text', 'Algorithm:');
            app.AlgorithmLabel.Layout.Row = 1;
            app.AlgorithmLabel.Layout.Column = 1;

            
            app.AlgorithmList = uidropdown(app.SelectGridLayout);
            app.AlgorithmList.Layout.Row = 1;
            app.AlgorithmList.Layout.Column = 2;
        
            % Algorithm parameters panel
            app.AlgorithmParametersPanel = uipanel(app.LeftGridLayout, 'Title', 'Algorithm Parameters');
            app.AlgorithmParametersPanel.Layout.Row = 3;
            app.AlgorithmParametersPanel.Layout.Column = 1;
            app.AlgorithmParametersPanel.Tooltip = 'The default values shown in the algorithm and problem parameter panels are based on the settings from their original references.';

            % Select a benchmark drop-down menu
            app.SelectGridLayout = uigridlayout(app.LeftGridLayout, [1, 3]);
            app.SelectGridLayout.RowHeight = {30};
            app.SelectGridLayout.ColumnWidth = {'1x', 150, 30};
            app.SelectGridLayout.Layout.Row = 4;

            app.BenchmarkLabel = uilabel(app.SelectGridLayout, 'Text', 'Benchmark:');
            app.BenchmarkLabel.Layout.Row = 1;
            app.BenchmarkLabel.Layout.Column = 1;
        
            app.BenchmarkList = uidropdown(app.SelectGridLayout);
            app.BenchmarkList.Layout.Row = 1;
            app.BenchmarkList.Layout.Column = 2;

            helpBtn = uibutton(app.SelectGridLayout, 'Text', '', ...
                'Text', '', ...
                'Tooltip', 'View suggested benchmark settings.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'help.png'), ...
                'ButtonPushedFcn', @(btn, event) showSuggestedSettings(app));
            helpBtn.Layout.Row = 1;
            helpBtn.Layout.Column = 3;
        
            % Benchmark parameters panel
            app.BenchmarkParametersPanel = uipanel(app.LeftGridLayout, 'Title', 'Problem Parameters');
            app.BenchmarkParametersPanel.Layout.Row = 5;
            app.BenchmarkParametersPanel.Layout.Column = 1;
            app.BenchmarkParametersPanel.Tooltip = 'The default values shown in the algorithm and problem parameter panels are based on the settings from their original references.';

            app.SelectGridLayout = uigridlayout(app.LeftGridLayout, [1, 2]);
            app.SelectGridLayout.RowHeight = {20};
            app.SelectGridLayout.ColumnWidth = {'1x', 150};
            app.SelectGridLayout.Layout.Row = 6;

            app.RunNumberLabel = uilabel(app.SelectGridLayout, 'Text', 'RunNumber:');
            app.RunNumberLabel.Layout.Row = 1;
            app.RunNumberLabel.Layout.Column = 1;
            app.RunNumberSpinner = uispinner(app.SelectGridLayout, 'Value', app.RunNumber, 'Limits', [1, 100], 'Step', 1);
            app.RunNumberSpinner.Layout.Row = 1;
            app.RunNumberSpinner.Layout.Column = 2;

            app.SelectGridLayout = uigridlayout(app.LeftGridLayout, [1, 2]);
            app.SelectGridLayout.RowHeight = {20};
            app.SelectGridLayout.ColumnWidth = {'1x', 150};
            app.SelectGridLayout.Layout.Row = 7;
            
            % Add task button
            app.AddTaskButton = uibutton(app.LeftGridLayout, 'Text', 'Add Task', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'add.png'), ...
                'Tooltip', ['Create a new experiment with custom algorithm and benchmark settings. ' ...
                'The task will be added to the pending list for single or batch execution, ' ...
                'and can later be used for result visualization and statistical analysis.'], ...
                'ButtonPushedFcn', @(btn, event) addTask(app));
            app.AddTaskButton.Layout.Row = 7;
            app.AddTaskButton.Layout.Column = 1;
            
            % List of tasks to be run
            app.CenterPanel = uipanel(experimentalGrid, 'Title', 'Pending Tasks');
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;
            % Set the GridLayout in the CenterPanel to ensure that the Table fills the entire panel
            app.CenterGridLayout = uigridlayout(app.CenterPanel, [8, 3]);
            app.CenterGridLayout.RowHeight = {100, 40, '1x', 20, 20, 20, 30, 30};
            app.CenterGridLayout.ColumnWidth = {'2x', '1x', 20};

            % Create a Panel container for the prompt box
            tiplabelPanel_2 = uipanel(app.CenterGridLayout);
            tiplabelPanel_2.Layout.Row = 1;
            tiplabelPanel_2.Layout.Column = [1, 3];
            tiplabelPanel_2.BackgroundColor = [0.95 0.95 0.95];
            
            tipText = ['The table lists experiments you have configured but not yet completed. ' ...
                'Click a task to view its settings, execute it individually, or delete it. ' ...
                'Use "Run Selected Tasks" to execute selected pending tasks in parallel.'];
            tipGridLayout_2 = uigridlayout(tiplabelPanel_2);
            tipGridLayout_2.RowHeight = {'1x'};
            tipGridLayout_2.ColumnWidth = {'1x'};
            tipGridLayout_2.Scrollable = 'on';

            uilabel(tipGridLayout_2, ...
                'Text', tipText, ...
                'FontSize', 10, ...                   
                'FontColor', [0.2 0.2 0.2], ...       
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'WordWrap', 'on', ...                 
                'BackgroundColor', [0.95 0.95 0.95]);

            app.SelectAllUncompletedTasksCheckBox = uicheckbox(app.CenterGridLayout, ...
                'Text', 'Select All', ...
                'FontWeight', 'bold', ...
                'Value', true, ...
                'Tooltip', 'Selecting this checkbox will select all pending tasks; deselecting will deselect all pending tasks', ...
                'ValueChangedFcn', @(src, event) selectAllUncompletedTasksCallback(app, src));
            app.SelectAllUncompletedTasksCheckBox.Layout.Row = 2;
            app.SelectAllUncompletedTasksCheckBox.Layout.Column = 1;

            app.UncompletedTasksTable = uitable(app.CenterGridLayout);
            app.UncompletedTasksTable.Layout.Row = 3;
            app.UncompletedTasksTable.Layout.Column = [1,3];
            app.UncompletedTasksTable.RowName = {};
            app.UncompletedTasksTable.ColumnName = {'Task ID', 'Task Info', 'Status', 'Progress'};
            app.UncompletedTasksTable.ColumnWidth = {'fit','1x','1x','1x'};
            app.UncompletedTasksTable.Data = {};

            app.UseLogicalLable = uilabel(app.CenterGridLayout, ...
                'Text', '*Use Logical Processors (Advanced):', ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left');
            
            app.UseLogicalLable.Layout.Row = 4;
            app.UseLogicalLable.Layout.Column = [1,2];

            app.UseLogicalCheckbox = uicheckbox(app.CenterGridLayout, ...
                'Text', '', ...
                'Value', false, ...
                'Tooltip', ['Enable this option to use logical (hyper-threaded) cores instead of just physical cores. ' ...
                'This may increase available workers but can lead to performance trade-offs depending on your system.'], ...
                'ValueChangedFcn', @(cb, event) updateThreadLimits(app));
            app.UseLogicalCheckbox.Layout.Row = 4;
            app.UseLogicalCheckbox.Layout.Column = 3;

            app.PoolTypeLabel = uilabel(app.CenterGridLayout, ...
                'Text', '*Select Parallel Pool Type:', ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left');
           
            app.PoolTypeLabel.Layout.Row = 5;
            app.PoolTypeLabel.Layout.Column = 1;
            
            app.PoolTypeDropdown = uidropdown(app.CenterGridLayout, ...
                'Items', app.PoolTypeItem, ...
                'ItemsData', app.PoolTypeValue, ...
                'Tooltip', ['Choose between "Processes pool" (default, isolates memory) and "Threads pool" (faster setup, shared memory). ' ...
                    'Note: "Threads pool" requires R2024a or newer.'], ...
                'Value', app.NowPoolType, ... 
                'ValueChangedFcn', @(cb, event) updateThreadLimits(app));

            app.PoolTypeDropdown.Layout.Row = 5;
            app.PoolTypeDropdown.Layout.Column = [2,3];

            app.ThreadsLabel = uilabel(app.CenterGridLayout, ...
                'Text', '*Number of Parallel Works:', ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'left');
            
            app.ThreadsLabel.Layout.Row = 6;
            app.ThreadsLabel.Layout.Column = 1;

            app.CleanRAMButton = uibutton(app.CenterGridLayout,...
                'Text', '', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'clean.png'), ...
                'Tooltip', 'Shut down thread pool and free memory', ...
                'ButtonPushedFcn', @(btn,event) releaseRAM(app));
            app.CleanRAMButton.Layout.Row = 6;
            app.CleanRAMButton.Layout.Column = 3;

            % Get the maxThreads
            try
                [app.PhysicalCores, app.LogicalProcessors] = GUIMode.getCoreInfo();
            catch
                app.PhysicalCores = feature('numcores');
                app.LogicalProcessors = 2 * app.PhysicalCores;
            end
            maxThreads = updateThreadLimits(app);
            pool = gcp('nocreate');
            if isempty(pool)
                defaultThreads = maxThreads;
                app.CleanRAMButton.Enable = "off";
            else
                defaultThreads = pool.NumWorkers;
                app.CleanRAMButton.Enable = "on";
            end

            app.UserSettingNumberThreads = defaultThreads;
            
            app.ThreadsInput = uispinner(app.CenterGridLayout, ...
                 'Value', app.UserSettingNumberThreads, ...
                 'Limits', [1, maxThreads], ...
                 'Step', 1, ...
                 'ValueChangedFcn', @(field, event) updateThreadsSetting(app, event));

            app.ThreadsInput.Tooltip = sprintf('Select the number of parallel workers (1 to %d) to use during execution. The maximum depends on your MATLAB settings and the processor mode (physical or logical).', maxThreads);

            app.ThreadsInput.Layout.Row = 6;
            app.ThreadsInput.Layout.Column = 2;

            app.RunButton = uibutton(app.CenterGridLayout, 'Text', 'Run Selected Tasks', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'run.png'), ...
                'Tooltip', 'Click to start running the selected tasks in parallel', ...
                'ButtonPushedFcn', @(btn, event) runSelectedUncompletedTasks(app));
            app.RunButton.Layout.Row = 7;
            app.RunButton.Layout.Column = [1,3];
            app.FastDeletePendingButton = uibutton(app.CenterGridLayout, ...
                'Text', 'Delete Selected Pending Tasks', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [1, 0.7, 0.7], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete2.png'), ...
                'Tooltip', 'Click to delete selected pending tasks', ...
                'ButtonPushedFcn', @(btn, event) deleteSelectedPendingTasks(app));  
            app.FastDeletePendingButton.Layout.Row = 8;
            app.FastDeletePendingButton.Layout.Column = [1,3];

            app.UncompletedTasksTable.CellSelectionCallback = @(src, event) showUncompletedTaskDetails(app, event);
            app.UncompletedTasksTable.CellEditCallback = @(src, event) PendingTasksTableCellEdit(app, event);

            % Completed Tasks
            app.RightPanel = uipanel(experimentalGrid, 'Title', 'Completed Tasks');
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;
            app.RightGridLayout = uigridlayout(app.RightPanel, [5, 4]);
            app.RightGridLayout.RowHeight = {100, 40, '1x', 30, 30};
            app.RightGridLayout.ColumnWidth = {'1x', '1x', '1x', '1x'};
        
            tiplabelPanel_3 = uipanel(app.RightGridLayout);
            tiplabelPanel_3.Layout.Row = 1;
            tiplabelPanel_3.Layout.Column = [1, 4];
            tiplabelPanel_3.BackgroundColor = [0.95 0.95 0.95];
            
            tipText = ['This table displays completed tasks, including full algorithm and benchmark configurations. ' ...
                'Click a task to view its details, plot results, rerun it, or delete it. ' ...
                'You can also add selected tasks to Statistical Analysis using "Select to SA." ' ...
                'Use the buttons below to import/export tasks as .m files for backup, sharing, or reuse.'];
            
            tipGridLayout_3 = uigridlayout(tiplabelPanel_3);
            tipGridLayout_3.RowHeight = {'1x'};
            tipGridLayout_3.ColumnWidth = {'1x'};
            tipGridLayout_3.Scrollable = 'on';

            uilabel(tipGridLayout_3, ...
                'Text', tipText, ...
                'FontSize', 10, ...
                'FontColor', [0.2 0.2 0.2], ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', [0.95 0.95 0.95]);

            app.CompletedTasksTable = uitable(app.RightGridLayout);
            app.CompletedTasksTable.Layout.Row = 3;
            app.CompletedTasksTable.Layout.Column = [1, 4];
            app.CompletedTasksTable.RowName = {};
            app.CompletedTasksTable.ColumnName = {'Task ID', 'Task Info', 'E_o(mean)', 'E_o(median)', 'E_o(SE)', 'E_bbc(mean)', 'E_bbc(median)', 'E_bbc(SE)'};
            app.CompletedTasksTable.ColumnWidth = {'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};
            app.CompletedTasksTable.Data = {};
            app.CompletedTasksTable.CellSelectionCallback = @(src, event) showCompletedTaskDetails(app, event);
            app.CompletedTasksTable.CellEditCallback = @(src, event) CompletedTasksTableCellEdit(app, event);

            app.UnionIndicatorsItem = {'E_o', 'E_bbc', 'T_r'};
            
            numIndicators = numel(app.UnionIndicatorsItem);
            app.UnionIndicatorsGridLayout = uigridlayout(app.RightGridLayout);
            app.UnionIndicatorsGridLayout.Scrollable = 'on';
            app.UnionIndicatorsGridLayout.RowHeight = { 'fit' };
            app.UnionIndicatorsGridLayout.ColumnWidth = [{'fit'}, {'1x'}, repmat({'fit'}, 1, numIndicators+1)];
            app.UnionIndicatorsGridLayout.Layout.Row = 2;
            app.UnionIndicatorsGridLayout.Layout.Column = [1,4];

            app.SelectAllCompletedTasksCheckBox = uicheckbox(app.UnionIndicatorsGridLayout, ...
                'Text', 'Select All', ...
                'FontWeight', 'bold', ...
                'Value', true, ...
                'Tooltip', 'Selecting this checkbox will select all completed tasks; deselecting will deselect all completed tasks', ...
                'ValueChangedFcn', @(src, event) selectAllCompletedTasksCallback(app, src));
            app.SelectAllCompletedTasksCheckBox.Layout.Row = 1;
            app.SelectAllCompletedTasksCheckBox.Layout.Column = 1;


            app.ShowUnionIndicatorsLabel = uilabel(app.UnionIndicatorsGridLayout, 'Text', 'Displayed Indicators:', 'Tooltip', ['Select which indicators to display in the table. All are shown by default. ' ...
                'At least one indicator must be selected.']);
            app.ShowUnionIndicatorsLabel.Layout.Row = 1;
            app.ShowUnionIndicatorsLabel.FontWeight = 'bold';
            app.ShowUnionIndicatorsLabel.Layout.Column = 3;
            
            if isprop(app, 'UnionIndicatorsCheckboxes')
                delete(app.UnionIndicatorsCheckboxes);
            end
            app.UnionIndicatorsCheckboxes = gobjects(numIndicators, 1);
            
            for i = 1:numIndicators
                indicator = app.UnionIndicatorsItem{i};
                    if strcmp(indicator, 'E_o')
                        tooltipText = 'Offline Error';
                    elseif strcmp(indicator, 'E_bbc')
                        tooltipText = 'Best Error Before Change';
                    elseif strcmp(indicator, 'T_r')
                        tooltipText = 'Run Time';
                    else
                        tooltipText = indicator;
                    end
                app.UnionIndicatorsCheckboxes(i) = uicheckbox(app.UnionIndicatorsGridLayout, ...
                    'Text', indicator, ...
                    'Value', any(strcmp(indicator, {'E_o', 'E_bbc'})), ... % default selection
                    'Tooltip', tooltipText, ...
                    'ValueChangedFcn', @(src, event) freshDisplayCompletedTasksTable(app, event));
                
                app.UnionIndicatorsCheckboxes(i).Layout.Row = 1;
                app.UnionIndicatorsCheckboxes(i).Layout.Column = i + 3;
            end

            app.ImportButton = uibutton(app.RightGridLayout, ...
                'Text', 'Import Completed Tasks from .mat', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'import.png'), ...
                'Tooltip', 'Click to import completed tasks from your saved .mat results file', ...
                'ButtonPushedFcn', @(btn, event) importCompletedResults(app));           
            app.ImportButton.Layout.Row = 4;
            app.ImportButton.Layout.Column = [1,2];

            app.ExportButton = uibutton(app.RightGridLayout, ...
                'Text', 'Export Selected Completed Tasks to .mat', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'export.png'), ...
                'Tooltip', 'Click to export selected completed tasks to a .mat file', ...
                'ButtonPushedFcn', @(btn, event) exportSelectedCompletedResults(app));     

            app.ExportButton.Layout.Row = 4;
            app.ExportButton.Layout.Column = [3,4];


            app.FastSelectSAButton = uibutton(app.RightGridLayout, ...
                'Text', 'Add Selected Completed Tasks to SA', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'select2.png'), ...
                'Tooltip', 'Add selected completed tasks to Statistical Analysis List', ...
                'ButtonPushedFcn', @(btn, event) multiSelectForSA(app));
            app.FastSelectSAButton.Layout.Row = 5;
            app.FastSelectSAButton.Layout.Column = [1,2];

            app.FastDeleteButton = uibutton(app.RightGridLayout, ...
                'Text', 'Delete Selected Completed Tasks', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [1, 0.7, 0.7], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete2.png'), ...
                'Tooltip', 'Click to delete selected completed tasks', ...
                'ButtonPushedFcn', @(btn, event) deleteSelectedCompletedTasks(app));           
            app.FastDeleteButton.Layout.Row = 5;
            app.FastDeleteButton.Layout.Column = [3,4];

            % Statistical Analysis
            app.SAPanel = uipanel(experimentalGrid, 'Title', 'Statistical Analysis (SA)');
            app.SAPanel.Layout.Row = 1;
            app.SAPanel.Layout.Column = 4;

            app.SAGridLayout = uigridlayout(app.SAPanel, [8, 6]);
            app.SAGridLayout.RowHeight = {100, 40, '1x', 40, 20, 30, 30, 30, 30};
            app.SAGridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1.5x', '0.5x'};

            tiplabelPanel_4 = uipanel(app.SAGridLayout);
            tiplabelPanel_4.Layout.Row = 1;
            tiplabelPanel_4.Layout.Column = [1, 6];
            tiplabelPanel_4.BackgroundColor = [0.95 0.95 0.95];
            
            tipText = ['This table displays tasks selected for statistical analysis. ' ...
           'All tasks must have identical problem parameters and run numbers. ' ...
           'Once matched, you can perform statistical tests, generate box plots for key metrics, ' ...
           'and compare offline error progression over time.'];
            
            tipGridLayout_4 = uigridlayout(tiplabelPanel_4);
            tipGridLayout_4.RowHeight = {'1x'};
            tipGridLayout_4.ColumnWidth = {'1x'};
            tipGridLayout_4.Scrollable = 'on';

            uilabel(tipGridLayout_4, ...
                'Text', tipText, ...
                'FontSize', 10, ...                   
                'FontColor', [0.2 0.2 0.2], ...       
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'WordWrap', 'on', ...                 
                'BackgroundColor', [0.95 0.95 0.95]); 

            app.SelectAllSATasksCheckBox = uicheckbox(app.SAGridLayout, ...
                'Text', 'Select All', ...
                'FontWeight', 'bold', ...
                'Value', true, ...
                'Tooltip', 'Selecting this checkbox will select all SA tasks; deselecting will deselect all SA tasks', ...
                'ValueChangedFcn', @(src, event) selectAllSATasksCallback(app, src));
            app.SelectAllSATasksCheckBox.Layout.Row = 2;
            app.SelectAllSATasksCheckBox.Layout.Column = [1,3];

            app.SATasksTable = uitable(app.SAGridLayout);
            app.SATasksTable.Layout.Row = 3;
            app.SATasksTable.Layout.Column = [1, 6];
            app.SATasksTable.RowName = {};
            app.SATasksTable.ColumnName = {'Task ID', 'Task Info'};
            app.SATasksTable.ColumnWidth = {'fit','1x'};
            app.SATasksTable.Data = {};
            app.SATasksTable.CellSelectionCallback = @(src, event) showSATaskDetails(app, event);
            app.SATasksTable.CellEditCallback = @(src, event) SATasksTableCellEdit(app, event);

            app.IntersectIndicatorsItem = {'E_o', 'E_bbc', 'T_r'};

            app.ShowIntersectIndicatorsLabel = uilabel(app.SAGridLayout, 'Text', '*Tested Indicators:', 'Tooltip', ['Select which indicators to test and plot. ' ...
                'At least one indicator must be selected.']);
            app.ShowIntersectIndicatorsLabel.Layout.Row = 4;
            app.ShowIntersectIndicatorsLabel.FontWeight = 'bold';
            app.ShowIntersectIndicatorsLabel.Layout.Column = [1,2];

            numIntersectIndicators = numel(app.IntersectIndicatorsItem);
            app.IntersectIndicatorsGridLayout = uigridlayout(app.SAGridLayout);
            app.IntersectIndicatorsGridLayout.Scrollable = 'on';
            app.IntersectIndicatorsGridLayout.RowHeight = { 'fit' };
            app.IntersectIndicatorsGridLayout.ColumnWidth = [{'1x'}, repmat({'fit'}, 1, numIntersectIndicators)];
            app.IntersectIndicatorsGridLayout.Layout.Row = 4;
            app.IntersectIndicatorsGridLayout.Layout.Column = [3,6];

            if isprop(app, 'IntersectIndicatorsCheckboxes')
                delete(app.IntersectIndicatorsCheckboxes);
            end
            app.IntersectIndicatorsCheckboxes = gobjects(numIntersectIndicators, 1);
            
            for i = 1:numIntersectIndicators
                indicator = app.IntersectIndicatorsItem{i};
                if strcmp(indicator, 'E_o')
                    tooltipText = 'Offline Error';
                elseif strcmp(indicator, 'E_bbc')
                    tooltipText = 'Best Error Before Change';
                elseif strcmp(indicator, 'T_r')
                    tooltipText = 'Run Time';
                else
                    tooltipText = indicator;
                end
                app.IntersectIndicatorsCheckboxes(i) = uicheckbox(app.IntersectIndicatorsGridLayout, ...
                    'Text', indicator, ...
                    'Value', any(strcmp(indicator, {'E_o', 'E_bbc'})), ... % default selection
                    'Tooltip', tooltipText, ...
                    'ValueChangedFcn', @(src, event) forbiddenUnselectForTest(app, event));
                
                app.IntersectIndicatorsCheckboxes(i).Layout.Row = 1;
                app.IntersectIndicatorsCheckboxes(i).Layout.Column = i+1;
            end

            % Add a dropdown for statistical method selection
            app.SAMethodSelectLabel = uilabel(app.SAGridLayout, 'Text', '*Select SA Method:');
            app.SAMethodSelectLabel.Layout.Row = 5;
            app.SAMethodSelectLabel.Layout.Column = [1,3];
            app.SAMethodSelectLabel.FontWeight = 'bold';
            app.SAMethodSelectDropdown = uidropdown(app.SAGridLayout);
            app.SAMethodSelectDropdown.Layout.Row = 5;
            app.SAMethodSelectDropdown.Layout.Column = [4,6];
            app.SAMethodSelectDropdown.Items = {'Friedman test', 'Wilcoxon signed-rank test', 'Wilcoxon rank-sum test'};
            app.SAMethodSelectDropdown.Value = 'Friedman test';

            helpBtn = uibutton(app.SAGridLayout, 'Text', '', ...
                'Tooltip', 'Details of the statistical test methodology used in the analysis.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'help.png'), ...
                'ButtonPushedFcn', @(btn,event) uialert(app.UIFigure, ...
                [ 'EDOLAB supports multiple non-parametric statistical tests to compare algorithm performance based on selected metrics. Below is a summary of each supported method:' newline newline ...
                '• Friedman Test: A non-parametric test used to detect differences in performance across multiple algorithms evaluated on the same tasks.' newline ...
                 ['   - It ranks each algorithm per task and checks if the average ranks differ significantly. ' ...
                 'If the Friedman test finds significant differences (p < 0.05), the Nemenyi test performs pairwise comparisons to detect which algorithms differ from each other.'] newline ...
                 '   - Algorithms with the same letter (e.g., "a", "b") in the rank columns are not significantly different from each other at 95% confidence.' newline newline ...
                 '• Wilcoxon Signed-Rank Test: This non-parametric test is used to compare the performance of paired algorithms on selected metrics (e.g., E_o, E_bbc).' newline ...
                 '  - It is applied pairwise to determine whether one algorithm significantly outperforms another when evaluated over the same conditions (e.g., runs or benchmarks).' newline newline ...
                '• Wilcoxon Rank-Sum Test: Also known as the Mann–Whitney U test, this non-parametric test is used to compare the performance of independent algorithms across selected metrics (e.g., E_o, E_bbc).' newline ...
                 '  - The test is applied pairwise between algorithms to assess whether their performance differs significantly.' newline newline], ...
                'Overview of Statistical Analysis Methods', ...
                'Icon', 'info'));
            helpBtn.Layout.Row = 6;
            helpBtn.Layout.Column = 6;


            app.FastFilterButton = uibutton(app.SAGridLayout, ...
                'Text', 'Auto Matching', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [0.3 0.95 0.3], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'select.png'), ...
                'Tooltip', 'Auto Matching the completed tasks for Statistical Analysis', ...
                'ButtonPushedFcn', @(btn, event) quickFilterForSA(app));           
            app.FastFilterButton.Layout.Row = 2;
            app.FastFilterButton.Layout.Column = [4,6];

            app.CurrentErrorPlotButton = uibutton(app.SAGridLayout, 'Text', 'Current Error Plots', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [0.95 0.95 0.95], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'plot.png'), ...
                'Tooltip', 'Plot the current error curve for selected SA tasks.', ...
                'ButtonPushedFcn', @(btn, event) startCurrentErrorPlotWithSelectedTasks(app));
            app.CurrentErrorPlotButton.Layout.Row = 8;
            app.CurrentErrorPlotButton.Layout.Column = [1,6];


            app.SAFastRemoveButton = uibutton(app.SAGridLayout, 'Text', 'Delete Selected SA Tasks', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [1, 0.7, 0.7], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete2.png'), ...
                'Tooltip', 'Click to delete selected SA tasks', ...
                'ButtonPushedFcn', @(btn, event) deleteSelectedSATasks(app));
            app.SAFastRemoveButton.Layout.Row = 9;
            app.SAFastRemoveButton.Layout.Column = [1,6];

            app.AnalyzeButton = uibutton(app.SAGridLayout, 'Text', 'Run Statistical Test', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'analyze.png'), ...
                'Tooltip', 'Use the selected test method to perform statistical analysis on the selected tasks.', ...
                'ButtonPushedFcn', @(btn, event) startStatisticalAnalysisWithSelectedTasks(app));
            app.AnalyzeButton.Layout.Row = 6;
            app.AnalyzeButton.Layout.Column = [1,6];

            app.TrendPlotButton = uibutton(app.SAGridLayout, 'Text', 'Trend Plots', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [0.95 0.95 0.95], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'plot.png'), ...
                'Tooltip', 'Display a trend plot for the selected performance indicator to visualize performance over time.', ...
                'ButtonPushedFcn', @(btn, event) startTrendPlotWithSelectedTasks(app));
            app.TrendPlotButton.Layout.Row = 7;
            app.TrendPlotButton.Layout.Column = [1,3];
            
            app.BoxPlotButton = uibutton(app.SAGridLayout, 'Text', 'Box Plots', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [0.95 0.95 0.95], ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'boxplot.png'), ...
                'Tooltip', 'Click to generate box plots for the selected performance indicator across all selected tasks.', ...
                'ButtonPushedFcn', @(btn, event) startBoxPlotWithSelectedTasks(app));
            app.BoxPlotButton.Layout.Row = 7;
            app.BoxPlotButton.Layout.Column = [4,6];

            app.LeftPanel.FontSize = 20;
            app.LeftPanel.FontWeight = 'bold';
            app.CenterPanel.FontSize = 20;
            app.CenterPanel.FontWeight = 'bold';
            app.RightPanel.FontSize = 20;
            app.RightPanel.FontWeight = 'bold';
            app.SAPanel.FontSize = 20;
            app.SAPanel.FontWeight = 'bold';

            % Creating an Educational Tab
            app.EducationalTab = uitab(app.TabGroup, 'Title', 'Educational');
            educationalGrid = uigridlayout(app.EducationalTab, [1, 3]);
            educationalGrid.ColumnWidth = {'1.2x','2.5x','2.5x'};

            % Left - Parameter selection area
            app.EducationalLeftPanel = uipanel(educationalGrid, 'Title', 'Parameter Settings');
            app.EducationalLeftPanel.Layout.Row = 1;
            app.EducationalLeftPanel.Layout.Column = 1;
            
            app.EducationalLeftGridLayout = uigridlayout(app.EducationalLeftPanel, [6, 1]);
            app.EducationalLeftGridLayout.RowHeight = {100, 40, '3x', 40, '3x', 50};
            app.EducationalLeftGridLayout.RowSpacing = 10;

            educationalTiplabelPanel_1 = uipanel(app.EducationalLeftGridLayout);
            educationalTiplabelPanel_1.Layout.Row = 1;
            educationalTiplabelPanel_1.Layout.Column = 1;
            educationalTiplabelPanel_1.BackgroundColor = [0.95 0.95 0.95];

            tipText = ['Customize the algorithm and problem parameters for this educational demo. ' ...
                'In the educational module, the problem dimension is fixed at 2 to allow visual exploration of the search and optimization process.'];

            educationalTipGridLayout_1 = uigridlayout(educationalTiplabelPanel_1);
            educationalTipGridLayout_1.RowHeight = {'1x'};
            educationalTipGridLayout_1.ColumnWidth = {'1x'};
            educationalTipGridLayout_1.Scrollable = 'on';

            uilabel(educationalTipGridLayout_1, ...
                'Text', tipText, ...
                'FontSize', 10, ...                   
                'FontColor', [0.2 0.2 0.2], ...       
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'center', ...
                'WordWrap', 'on', ...                 
                'BackgroundColor', [0.95 0.95 0.95]);


            % Select the algorithm drop-down menu
            app.EducationalSelectGridLayout = uigridlayout(app.EducationalLeftGridLayout, [1, 2]);
            app.EducationalSelectGridLayout.RowHeight = {30};
            app.EducationalSelectGridLayout.ColumnWidth = {'1x', 150};
            app.EducationalSelectGridLayout.Layout.Row = 2;

            app.EducationalAlgorithmLabel = uilabel(app.EducationalSelectGridLayout, 'Text', 'Algorithm:');
            app.EducationalAlgorithmLabel.Layout.Row = 1;
            app.EducationalAlgorithmLabel.Layout.Column = 1;

            app.EducationalAlgorithmList = uidropdown(app.EducationalSelectGridLayout);
            app.EducationalAlgorithmList.Layout.Row = 1;
            app.EducationalAlgorithmList.Layout.Column = 2;

            app.EducationalAlgorithmParametersPanel = uipanel(app.EducationalLeftGridLayout, 'Title', 'Algorithm Parameters');
            app.EducationalAlgorithmParametersPanel.Layout.Row = 3;
            app.EducationalAlgorithmParametersPanel.Layout.Column = 1;

            % Select the benchmark drop-down menu
            app.EducationalSelectGridLayout = uigridlayout(app.EducationalLeftGridLayout, [1, 2]);
            app.EducationalSelectGridLayout.RowHeight = {30};
            app.EducationalSelectGridLayout.ColumnWidth = {'1x', 150, 30};
            app.EducationalSelectGridLayout.Layout.Row = 4;

            app.EducationalBenchmarkLabel = uilabel(app.EducationalSelectGridLayout, 'Text', 'Benchmark:');
            app.EducationalBenchmarkLabel.Layout.Row = 1;
            app.EducationalBenchmarkLabel.Layout.Column = 1;

            app.EducationalBenchmarkList = uidropdown(app.EducationalSelectGridLayout);
            app.EducationalBenchmarkList.Layout.Row = 1;
            app.EducationalBenchmarkList.Layout.Column = 2;

            helpBtn = uibutton(app.EducationalSelectGridLayout, 'Text', '', ...
                'Text', '', ...
                'Tooltip', 'View suggested benchmark settings.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'help.png'), ...
                'ButtonPushedFcn', @(btn, event) showSuggestedSettings(app));
            helpBtn.Layout.Row = 1;
            helpBtn.Layout.Column = 3;

            app.EducationalBenchmarkParametersPanel = uipanel(app.EducationalLeftGridLayout, 'Title', 'Problem Parameters');
            app.EducationalBenchmarkParametersPanel.Layout.Row = 5;
            app.EducationalBenchmarkParametersPanel.Layout.Column = 1;

            % Execute educational task button
            app.EducationalRunButton = uibutton(app.EducationalLeftGridLayout, 'Text', 'Run', ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'run.png'), ...
                'ButtonPushedFcn', @(btn, event) runEducationalTask(app));
            app.EducationalRunButton.Layout.Row = 6;
            app.EducationalRunButton.Layout.Column = 1;

            app.EducationalRightPanel = uipanel(educationalGrid, 'Title', 'Visualization');
            app.EducationalRightPanel.Layout.Row = 1;
            app.EducationalRightPanel.Layout.Column = [2,3];

            app.EducationalVisualizationGrid = uigridlayout(app.EducationalRightPanel, [2,2]);
            app.EducationalVisualizationGrid.RowHeight = {'1x', 80};
            app.EducationalVisualizationGrid.ColumnWidth = {'1x', '1x'};
            app.EducationalVisualizationGrid.RowSpacing = 15;

            app.EducationalUIAxes = uiaxes(app.EducationalVisualizationGrid);
            app.EducationalUIAxes.Layout.Row = 1;
            app.EducationalUIAxes.Layout.Column = 1;
            xlabel(app.EducationalUIAxes, 'x_1');
            ylabel(app.EducationalUIAxes, 'x_2');
            colormap(app.EducationalUIAxes, cool);
            app.DefaultInteractions_1 = app.EducationalUIAxes.Interactions;
            
            app.EducationalUIAxes2 = uiaxes(app.EducationalVisualizationGrid);
            app.EducationalUIAxes2.Layout.Row = 1;
            app.EducationalUIAxes2.Layout.Column = 2;
            xlabel(app.EducationalUIAxes2, 'Fitness Evaluation');
            ylabel(app.EducationalUIAxes2, 'Current Error');
            grid(app.EducationalUIAxes2, 'on');
            app.DefaultInteractions_2 = app.EducationalUIAxes2.Interactions;

            controlPanel = uipanel(app.EducationalVisualizationGrid);
            controlPanel.Layout.Row = 2;
            controlPanel.Layout.Column = [1,2];
            controlGrid = uigridlayout(controlPanel, [1,4]);
            controlGrid.RowHeight = {'1x', '1x'};
            controlGrid.ColumnWidth = {80, 80,'fit',50, '1x', 'fit'};

            % Play/Pause button
            app.EducationalPlayButton = uibutton(controlGrid,...
                'Text', 'Play',...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'start.png'), ...
                'Enable','off',...
                'ButtonPushedFcn', @(src,event) educationalPlayCallback(app));
            app.EducationalPlayButton.Layout.Row = [1,2];
            app.EducationalPlayButton.Layout.Column = 1;
            
            % Reset button
            app.EducationalResetButton = uibutton(controlGrid,...
                'Text', 'Reset',...
                'Enable','off',...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'reset.png'), ...
                'ButtonPushedFcn', @(src,event) educationalResetCallback(app));
            app.EducationalResetButton.Layout.Row = 1;
            app.EducationalResetButton.Layout.Column = 2;

            % Reset button
            app.EducationalResizeButton = uibutton(controlGrid,...
                'Text', 'Resize',...
                'Enable','off',...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'resize.png'), ...
                'ButtonPushedFcn', @(src,event) educationalResizeCallback(app));
            app.EducationalResizeButton.Layout.Row = 2;
            app.EducationalResizeButton.Layout.Column = 2;

            % Speed ​​selection
            app.EducationalSpeedDropdown = uidropdown(controlGrid,...
                'Items', {'1x', '2x', '5x', '10x', '20x', '50x'},...
                'Value', '10x',...
                'Enable','off',...
                'Tooltip', 'Select the playback speed for the educational visualization.', ...
                'ValueChangedFcn', @(src,event) educationalSpeedChange(app));
            app.EducationalSpeedDropdown.Layout.Row = [1,2];
            app.EducationalSpeedDropdown.Layout.Column = 3;

            % Iterate input box
            app.EducationalIterInput = uieditfield(controlGrid, 'numeric',...
                'Value', 1,...
                'Enable','off',...
                'Tooltip', 'Enter a specific iteration number to plot and visualize algorithm behavior at that iteration.',...
                'ValueChangedFcn', @(src,event) educationalIterInputCallback(app));
            app.EducationalIterInput.Layout.Row = [1,2];
            app.EducationalIterInput.Layout.Column = 4;
            
            % Progress Bar
            app.EducationalSlider = uislider(controlGrid,...
                'Enable','off',...
                'ValueChangedFcn', @(src,event) educationalSliderCallback(app,event));
            app.EducationalSlider.Layout.Row = [1,2];
            app.EducationalSlider.Layout.Column = 5;
            
            % Show current interation
            app.EducationalIterLabel = uilabel(controlGrid,...
                'Text', 'Iter: 0/NA',...
                'HorizontalAlignment', 'center');
            app.EducationalIterLabel.Layout.Row = [1,2];
            app.EducationalIterLabel.Layout.Column = 6;

            app.EducationalLeftPanel.FontSize = 20;
            app.EducationalLeftPanel.FontWeight = 'bold';
            app.EducationalRightPanel.FontSize = 20;
            app.EducationalRightPanel.FontWeight = 'bold';

            drawnow;

            % Start parallel pool
            delete(gcp('nocreate'));
            setParallelPool(app);
            app.NowPoolType = app.PoolTypeDropdown.Value;
        end

        % Code that executes after component creation
        function startupFcn(app)
            %  addpath(genpath(pwd));
            %% Add the full path of EDOLAB folder and its subfolders into work space
            nowPath = mfilename('fullpath');
            app.projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
            addpath(genpath(app.projectPath));
            
            [app.AlgorithmList.Items, app.BenchmarkList.Items]...
                = app.getAlgAndBenchName();
            
            app.AlgorithmList.Value = app.AlgorithmList.Items(1);
            app.BenchmarkList.Value = app.BenchmarkList.Items(3);
            updateExperimentalAlgParameterUI(app)
            updateExperimentalProParameterUI(app)
            app.AlgorithmList.ValueChangedFcn = @(src, event) app.updateExperimentalAlgParameterUI();
            app.BenchmarkList.ValueChangedFcn = @(src, event) app.updateExperimentalProParameterUI();

            [app.EducationalAlgorithmList.Items, app.EducationalBenchmarkList.Items]...
                = app.getAlgAndBenchName();
            app.EducationalAlgorithmList.Value = app.EducationalAlgorithmList.Items(1);
            app.EducationalBenchmarkList.Value = app.EducationalBenchmarkList.Items(3);
            updateEducationalAlgParameterUI(app)
            updateEducationalProParameterUI(app)
            app.EducationalAlgorithmList.ValueChangedFcn = @(src, event) app.updateEducationalAlgParameterUI();
            app.EducationalBenchmarkList.ValueChangedFcn = @(src, event) app.updateEducationalProParameterUI();
            
            app.SpeedMap = containers.Map(...
                {'1x','2x','5x','10x','20x','50x'},...
                [1, 2, 5, 10, 20, 50]);
            initializeTasks(app);

            app.UIFigure.CloseRequestFcn = @(src, event) UIFigureCloseRequest(app);
        end

        function updateThreadsSetting(app, event) 
            newThreads = round(event.Value);
            app.UserSettingNumberThreads = newThreads;
            app.ThreadsInput.Value = app.UserSettingNumberThreads;
            drawnow;
        end

        function maxThreads = updateThreadLimits(app)
            checkBoxValue = app.UseLogicalCheckbox.Value;
            requestedWorkers = app.LogicalProcessors;
            maxWorkersAllowed = parcluster('processes').NumWorkers;
            if checkBoxValue
                if strcmp(app.PoolTypeDropdown.Value, 'processes')
                    if requestedWorkers > maxWorkersAllowed
                        msg = sprintf([...
                            'Worker Limit Exceeded\n\n' ...
                            'You selected %d workers, but your local MATLAB settings currently allow a maximum of %d.\n' ...
                            'EDOLAB has automatically adjusted the number of workers to %d to continue.\n\n' ...
                            'If you would like to use more workers (e.g., all logical cores), you can update your local cluster profile.\n' ...
                            'To increase this limit:\n' ...
                            'Go to Home > Parallel > Manage Cluster Profiles in MATLAB.\n' ...
                            'Select the "local" profile.\n' ...
                            'Edit the NumWorkers value and save the profile.'], ...
                            requestedWorkers, maxWorkersAllowed, maxWorkersAllowed);
                        
                        selection = uiconfirm(app.UIFigure, msg, 'Worker Limit Exceeded', ...
                            'Options', {sprintf('Proceed with %d workers', maxWorkersAllowed), 'Cancel'}, ...
                            'DefaultOption', 1, 'CancelOption', 2);
                        
                        if strcmp(selection, sprintf('Proceed with %d workers', maxWorkersAllowed))
                            maxThreads = maxWorkersAllowed;
                        else
                            app.UseLogicalCheckbox.Value = false;
                            maxThreads = app.PhysicalCores;
                        end
                    else
                        maxThreads = requestedWorkers;
                    end
                elseif strcmp(app.PoolTypeDropdown.Value, 'threads')
                        uialert(app.UIFigure, ...
                            ['Enabling logical processors may increase the maximum number of threads, ' ...
                             'but some systems may not support it. If you encounter the error ' ...
                             '"parallel:pool:ThreadsPoolSizeExceedsMax", please disable the option for logical processors.'], ...
                            'Warning', 'Icon', 'warning');
                        maxThreads = app.LogicalProcessors;
                end

            else
                maxThreads = app.PhysicalCores;
            end
            app.ThreadsInput.Limits = [1, maxThreads];
            app.ThreadsInput.Value = maxThreads;
            app.UserSettingNumberThreads = maxThreads;
            app.ThreadsInput.Limits = [1, maxThreads];
            app.ThreadsInput.Tooltip = sprintf('Select the number of parallel workers (1 to %d) to use during execution. The maximum depends on your MATLAB settings and the processor mode (physical or logical).', maxThreads);

        end

        function closeSettingsWindow(app, src)
            if isvalid(src)
                delete(src);
            end
            if isprop(app, 'SettingsWindow')
                app.SettingsWindow = matlab.ui.Figure.empty;
            end
        end

        function UIFigureCloseRequest(app)
            closeApp(app);
            delete(app);
        end

        function closeApp(app)
            if isprop(app, 'Futures') && ~isempty(app.Futures)
                for i = 1:numel(app.Futures)
                    try
                        if ~strcmp(app.Futures(i).State, 'finished')
                            cancel(app.Futures(i));
                        end
                        delete(app.Futures(i));
                    catch ME
                        warning(ME.message);
                    end
                end
                app.Futures = [];
            end

            % shut down Parpool
            progressDialog = uiprogressdlg(app.UIFigure, ...
                'Title', 'Please Wait', ...
                'Message', 'Shut down Parpool', ...
                'Indeterminate', 'on');
            % Close the parallel pool to release RAM
            delete(gcp('nocreate'));
            app.NowPoolType = '';
            app.CleanRAMButton.Enable = 'off';
            close(progressDialog);
            disp('All resources have been released.');
            delete(app.UIFigure);
        end

        function [AlgorithmsList, BenchmarksList] = getAlgAndBenchName(app)
            % Get Algorithm lists
            AlgorithmsFloder = dir([app.projectPath, '\Algorithm']);
            AlgorithmsList = {};
            for i = 3:length(AlgorithmsFloder)
                if AlgorithmsFloder(i).isdir
                    AlgorithmsList{end+1} = AlgorithmsFloder(i).name;
                end
            end
            
            % Get Benchmark lists
            BenchmarksFloder = dir([app.projectPath, '\Benchmark']);
            BenchmarksList = {};
            for i = 3:length(BenchmarksFloder)
                if BenchmarksFloder(i).isdir
                    BenchmarksList{end+1} = BenchmarksFloder(i).name;
                end
            end
        end
    end

    % Methods for Experimental Module
    methods (Access = private)
        function updateExperimentalAlgParameterUI(app)
            selectedAlgorithm = app.AlgorithmList.Value;
            ConfigurableParameters = getAlgConfigurableParameters(selectedAlgorithm);
            paramNames = fieldnames(ConfigurableParameters);
        
            % Clear the old UI controls
            if isprop(app, 'ExperimentalConfigurableAlgorithmParameters') && ~isempty(app.ExperimentalConfigurableAlgorithmParameters)
                existingFields = fieldnames(app.ExperimentalConfigurableAlgorithmParameters);
                for i = 1:length(existingFields)
                    if isfield(app.ExperimentalConfigurableAlgorithmParameters, existingFields{i}) ...
                            && isvalid(app.ExperimentalConfigurableAlgorithmParameters.(existingFields{i}))
                        delete(app.ExperimentalConfigurableAlgorithmParameters.(existingFields{i}));
                    end
                end
                app.ExperimentalConfigurableAlgorithmParameters = struct();
            end
        
            % clear AlgorithmParametersPanel
            if isvalid(app.AlgorithmParametersPanel)
                delete(allchild(app.AlgorithmParametersPanel));
            end
        
            paramGrid = uigridlayout(app.AlgorithmParametersPanel, 'Scrollable', 'on');
            paramGrid.RowHeight = repmat({20}, length(paramNames), 1);
            paramGrid.ColumnWidth = {'1x', 120};
        
            for i = 1:length(paramNames)
                paramName = paramNames{i};
                paramValue = ConfigurableParameters.(paramName);
                tooltipText = paramName;
                if isfield(paramValue, 'description')
                    tooltipText = paramValue.description;
                end
                label = uilabel(paramGrid, 'Text', paramName, 'Tooltip', tooltipText);
                label.Layout.Row = i;
                label.Layout.Column = 1;
        
                if isstruct(paramValue)
                    switch paramValue.type
                        case 'integer'
                            ui = uispinner(paramGrid, ...
                                'Value', paramValue.value, ...
                                'Limits', paramValue.range, ...
                                'Step', 1);
                        case 'numeric'
                            ui = uieditfield(paramGrid, 'numeric', ...
                                'Value', paramValue.value);
                        case 'option'
                            ui = uidropdown(paramGrid, ...
                                'Items', paramValue.options, ...
                                'Value', paramValue.value);
                        case 'boolean'
                            ui = uicheckbox(paramGrid, 'Text', '', 'Value', paramValue.value);
                    end
        
                    ui.Layout.Row = i;
                    ui.Layout.Column = 2;
        
                    app.ExperimentalConfigurableAlgorithmParameters.(paramName) = ui;
                end
            end
        end

        function updateExperimentalProParameterUI(app)
            selectedBenchmark = app.BenchmarkList.Value;
            ConfigurableParameters = getProConfigurableParameters(selectedBenchmark);
            paramNames = fieldnames(ConfigurableParameters);
        
            % Clear the old UI controls
            if isprop(app, 'ExperimentalConfigurableBenchmarkParameters') && ~isempty(app.ExperimentalConfigurableBenchmarkParameters)
                existingFields = fieldnames(app.ExperimentalConfigurableBenchmarkParameters);
                for i = 1:length(existingFields)
                    if isfield(app.ExperimentalConfigurableBenchmarkParameters, existingFields{i}) ...
                            && isvalid(app.ExperimentalConfigurableBenchmarkParameters.(existingFields{i}))
                        delete(app.ExperimentalConfigurableBenchmarkParameters.(existingFields{i}));
                    end
                end
                app.ExperimentalConfigurableBenchmarkParameters = struct();
            end
            if isvalid(app.BenchmarkParametersPanel)
                delete(allchild(app.BenchmarkParametersPanel));
            end
        
            paramGrid = uigridlayout(app.BenchmarkParametersPanel, 'Scrollable', 'on');
            paramGrid.RowHeight = repmat({20}, length(paramNames), 1);
            paramGrid.ColumnWidth = {'1x', 120};
        
            for i = 1:length(paramNames)
                paramName = paramNames{i};
                paramValue = ConfigurableParameters.(paramName);
                tooltipText = paramName;
                if isfield(paramValue, 'description')
                    tooltipText = paramValue.description;
                end
                label = uilabel(paramGrid, 'Text', paramName, 'Tooltip', tooltipText);
                label.Layout.Row = i;
                label.Layout.Column = 1;
        
                if isstruct(paramValue)
                    switch paramValue.type
                        case 'integer'
                            ui = uispinner(paramGrid, ...
                                'Value', paramValue.value, ...
                                'Limits', paramValue.range, ...
                                'Step', 1);
                        case 'numeric'
                            ui = uieditfield(paramGrid, 'numeric', ...
                                'Value', paramValue.value);
                        case 'option'
                            ui = uidropdown(paramGrid, ...
                                'Items', paramValue.options, ...
                                'Value', paramValue.value);
                        case 'boolean'
                            ui = uicheckbox(paramGrid, 'Text', '', 'Value', paramValue.value);                            
                    end
        
                    ui.Layout.Row = i;
                    ui.Layout.Column = 2;
        
                    app.ExperimentalConfigurableBenchmarkParameters.(paramName) = ui;
                end
            end
        end

        function showSuggestedSettings(app)
            try
                jsonPath = fullfile(app.projectPath, 'Utility/GUI/json', 'BenchmarkParameters.json');
                raw = jsondecode(fileread(jsonPath));
                T = struct2table(raw.Table);
        
                % 创建窗口
                fig = uifigure('Name', 'Suggested Benchmark Settings', ...
                               'Position', [300 300 700 280]);
        
                % 显示表格
                uit = uitable(fig, ...
                    'Data', T, ...
                    'ColumnName', T.Properties.VariableNames, ...
                    'Position', [10 60 680 200]);
        
                % Notes 文本标签
                note1 = raw.Notes{1};
                note2 = raw.Notes{2};
        
                uilabel(fig, ...
                    'Text', note1, ...
                    'Tooltip', note1, ...
                    'Position', [10 35 680 15], ...
                    'FontAngle', 'italic', ...
                    'FontSize', 11, ...
                    'HorizontalAlignment', 'left');
        
                uilabel(fig, ...
                    'Text', note2, ...
                    'Tooltip', note2, ...
                    'Position', [10 15 680 15], ...
                    'FontAngle', 'italic', ...
                    'FontSize', 11, ...
                    'HorizontalAlignment', 'left');
        
            catch ME
                uialert(app.UIFigure, ...
                    ['Failed to load suggested settings: ' ME.message], ...
                    'Error');
            end
        end



        function addTask(app, ~)
            app.AddTaskButton.Enable = 'off';
            % Get the currently selected algorithm and problem name
            algName = app.AlgorithmList.Value;
            probName = app.BenchmarkList.Value;
            
            % Get RunNumber from RunNumberSpinner
            runNum = app.RunNumberSpinner.Value;
            
            % Get the current time string
            creationTime = datestr(now, 'yyyy-mm-dd HH:MM:SS');
            
            % Generate task summary information
            taskInfo = [algName, '_', probName, '_', creationTime];
            
            while true
                taskID = char(java.util.UUID.randomUUID());
                taskID = taskID(1:4);
            
                if ~isKey(app.Tasks, taskID)
                    break;
                end
            end

            % Encapsulate algorithm parameters and read values ​​from UI controls
            algParams = struct();
            algParamNames = fieldnames(app.ExperimentalConfigurableAlgorithmParameters);
            for i = 1:length(algParamNames)
                paramName = algParamNames{i};
                algParams.(paramName).value = app.ExperimentalConfigurableAlgorithmParameters.(paramName).Value;
            end

            % Encapsulate benchmark parameters and read values ​​from UI controls
            probParams = struct();
            probParamNames = fieldnames(app.ExperimentalConfigurableBenchmarkParameters);
            for i = 1:length(probParamNames)
                paramName = probParamNames{i};
                probParams.(paramName).value = app.ExperimentalConfigurableBenchmarkParameters.(paramName).Value;
            end
            
            
            % Create a task record structure
            newTask = struct( ...
                'TaskID', taskID, ...
                'Algorithm', algName, ...
                'Benchmark', probName, ...
                'RunNumber', runNum, ...
                'CreationTime', creationTime, ...
                'TaskInfo', taskInfo, ...
                'AlgorithmParameters', algParams, ...
                'BenchmarkParameters', probParams, ...
                'Status', 'New', ...
                'Progress', 'Not Started', ...
                'Result', struct( ...
                    'Problem', '', ... 
                    'E_bbc', struct( ...
                        'mean', '', ...
                        'median', '', ...
                        'StdErr', '', ...
                        'AllResults', []), ...  
                    'E_o', struct( ...
                        'mean', '', ...
                        'median', '', ...
                        'StdErr', '', ...
                        'AllResults', []), ...  
                    'T_r', struct( ...
                        'mean', '', ...
                        'median', '', ...
                        'StdErr', '', ...
                        'AllResults', []), ...  
                    'CurrentError', '', ...
                    'VisualizationInfo', [], ...
                    'Iteration', '' ...
                ) ...
            );

            % Check if a task with the same parameters already exists
            taskKeys = keys(app.Tasks);
            duplicateFound = false;
            for i = 1:length(taskKeys)
                existingTask = getTask(app, taskKeys{i});
                % Compare all fields except TaskID and CreationTime
                if isequal(existingTask.Algorithm, newTask.Algorithm) && ...
                   isequal(existingTask.Benchmark, newTask.Benchmark) && ...
                   isequal(existingTask.RunNumber, newTask.RunNumber) && ...
                   isequal(existingTask.AlgorithmParameters, newTask.AlgorithmParameters) && ...
                   isequal(existingTask.BenchmarkParameters, newTask.BenchmarkParameters)
                    duplicateFound = true;
                    break;
                end
            end
            % If a duplicate is found, prompt the user
            if duplicateFound
                answer = questdlg('A task with the same parameters already exists. Do you want to add a new task anyway?', ...
                    'Duplicate Task', ...
                    'Yes', 'No', 'No'); % Default to 'No'
                
                % If the user chooses 'No', return without adding the task
                if strcmp(answer, 'No')
                    app.AddTaskButton.Enable = "on";
                    return;
                end
            end

            setTask(app, taskID, newTask);
            app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
            app.AddTaskButton.Enable = "on";
        end

        function UncompletedTasks = getUncompletedTasksTable(app)
            UncompletedTasks = {};
            taskKeys = keys(app.Tasks);
        
            % Setting up table columns
            columnNames = {'Select', 'Task ID', 'Task Info', 'Status', 'Progress', 'CreationTime'};
            app.UncompletedTasksTable.ColumnName = columnNames;
            app.UncompletedTasksTable.ColumnWidth = {'fit', 'fit','1x','1x','1x', 0};
            drawnow;
        
            % Set column format and editability
            columnFormat = {'logical', '', '', '', '', ''};
            columnEditable = [true, false, false, false, false, false];
            app.UncompletedTasksTable.ColumnFormat = columnFormat;
            app.UncompletedTasksTable.ColumnEditable = columnEditable;
        
            for i = 1:length(taskKeys)
                task = getTask(app, taskKeys{i});
                if ~strcmp(task.Status, 'Completed')
                    if app.SelectAllUncompletedTasksCheckBox.Value == true
                        app.PendingTasksSelectionStates(task.TaskID) = true;
                        checkStatus = true;
                    else
                        if isKey(app.PendingTasksSelectionStates, task.TaskID)
                            checkStatus = app.PendingTasksSelectionStates(task.TaskID);
                        else
                            app.PendingTasksSelectionStates(task.TaskID) = false;
                            checkStatus = false;
                        end
                    end
        
                    row = {
                        checkStatus, ...
                        task.TaskID, ...
                        task.TaskInfo, ...
                        task.Status, ...
                        task.Progress, ...
                        task.CreationTime ...
                    };
        
                    UncompletedTasks(end+1, :) = row;
                end
            end
        
            % Sort by CreationTime
            if ~isempty(UncompletedTasks)
                creationTimes = datetime({UncompletedTasks{:, 6}});
                [~, sortedIdx] = sort(creationTimes, 'ascend');
                UncompletedTasks = UncompletedTasks(sortedIdx, 1:5);
            end
        
            app.UncompletedTasksTable.Data = UncompletedTasks;
        end
        

        function freshDisplayCompletedTasksTable(app, event)
            % Count how many checkboxes are currently selected
            numSelected = 0;
            for i = 1:numel(app.UnionIndicatorsCheckboxes)
                if app.UnionIndicatorsCheckboxes(i).Value
                    numSelected = numSelected + 1;
                end
            end
            
            % If no indicator is selected, force the checkbox that triggered this event to stay selected
            if numSelected < 1
                event.Source.Value = true;
                uialert(app.UIFigure, 'At least one indicator must be selected.', 'Selection Warnning');
                drawnow;
                return;
            end
            
            % Continue updating the completed tasks table
            getCompletedTasksTable(app);
        end

        function forbiddenUnselectForTest(app, event)
            % Count how many checkboxes are currently selected
            numSelected = 0;
            for i = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(i).Value
                    numSelected = numSelected + 1;
                end
            end
            
            % If no indicator is selected, force the checkbox that triggered this event to stay selected
            if numSelected < 1
                event.Source.Value = true;
                uialert(app.UIFigure, 'At least one indicator must be selected.', 'Selection Warnning');
                drawnow;
                return;
            end
        end


        function freshUnionIndicatorCheckboxes(app)
            if isprop(app, 'UnionIndicatorsCheckboxes')
                delete(app.UnionIndicatorsCheckboxes);
            end
            numIndicators = numel(app.UnionIndicatorsItem);
            
            app.UnionIndicatorsGridLayout.ColumnWidth = [{'fit'}, {'1x'}, repmat({'fit'}, 1, numIndicators+1)];

            app.UnionIndicatorsCheckboxes = gobjects(numIndicators, 1);
            
            for i = 1:numIndicators
                indicator = app.UnionIndicatorsItem{i};
                app.UnionIndicatorsCheckboxes(i) = uicheckbox(app.UnionIndicatorsGridLayout, ...
                    'Text', indicator, ...
                    'Tooltip', indicator, ...
                    'ValueChangedFcn', @(src, event) freshDisplayCompletedTasksTable(app, event));
                
                app.UnionIndicatorsCheckboxes(i).Layout.Row = 1;
                app.UnionIndicatorsCheckboxes(i).Layout.Column = i + 3;
            end
        end

        function freshIntersectIndicatorCheckboxes(app)
            if isprop(app, 'IntersectIndicatorsCheckboxes')
                delete(app.IntersectIndicatorsCheckboxes);
            end

            numIntersectIndicators = numel(app.IntersectIndicatorsItem);
            app.IntersectIndicatorsCheckboxes = gobjects(numIntersectIndicators, 1);

            app.IntersectIndicatorsGridLayout.ColumnWidth = [{'1x'}, repmat({'fit'}, 1, numIntersectIndicators)];

            for i = 1:numIntersectIndicators
                indicator = app.IntersectIndicatorsItem{i};
                app.IntersectIndicatorsCheckboxes(i) = uicheckbox(app.IntersectIndicatorsGridLayout, ...
                    'Text', indicator, ...
                    'Value', any(strcmp(indicator, {'E_o', 'E_bbc'})), ... % default selection (adjust as necessary)
                    'Tooltip', indicator, ...
                    'ValueChangedFcn', @(src, event) forbiddenUnselectForTest(app, event));
                
                app.IntersectIndicatorsCheckboxes(i).Layout.Row = 1;
                app.IntersectIndicatorsCheckboxes(i).Layout.Column = i+1;
            end
        end

        function CompletedTasks = getCompletedTasksTable(app)
            CompletedTasks = {};
            taskKeys = keys(app.Tasks);
            indicators = {}; 
            for i = 1:numel(app.UnionIndicatorsCheckboxes)
                if app.UnionIndicatorsCheckboxes(i).Value
                    indicators{end+1} = app.UnionIndicatorsItem{i};
                end
            end
            
            staticColumns = {'Select', 'Task ID', 'Task Info'};
            dynamicColumns = {};
            for i = 1:length(indicators)
                name = indicators{i};
                dynamicColumns{end+1} = sprintf('%s(mean)', name);
                dynamicColumns{end+1} = sprintf('%s(median)', name);
                dynamicColumns{end+1} = sprintf('%s(SE)', name);
            end
            
            allColumns = [staticColumns, dynamicColumns];
            
            numTotalCols = numel(allColumns);
            columnFormat = cell(1, numTotalCols);
            columnEditable = false(1, numTotalCols);
            columnFormat{1} = 'logical';
            columnEditable(1) = true;
            
            for i = 1:length(taskKeys)
                task = getTask(app, taskKeys{i});
                if strcmp(task.Status, 'Completed')
                    row = {};
                    if app.SelectAllCompletedTasksCheckBox.Value == true
                        app.CompletedTasksSelectionStates(task.TaskID) = true;
                        checkStatus = true;
                    else
                        if isKey(app.CompletedTasksSelectionStates, task.TaskID)
                            checkStatus = app.CompletedTasksSelectionStates(task.TaskID);
                        else
                            app.CompletedTasksSelectionStates(task.TaskID) = false;
                            checkStatus = false;
                        end
                    end
                    row{end+1} = checkStatus;
                    row{end+1} = task.TaskID;
                    row{end+1} = task.TaskInfo;
                    
                    for j = 1:length(indicators)
                        fieldName = indicators{j};
                        if isfield(task.Result, fieldName)
                            subField = task.Result.(fieldName);
                            if isfield(subField, 'mean')
                                row{end+1} = subField.mean;
                            else
                                row{end+1} = '';
                            end
                            if isfield(subField, 'median')
                                row{end+1} = subField.median;
                            else
                                row{end+1} = '';
                            end
                            if isfield(subField, 'StdErr')
                                row{end+1} = subField.StdErr;
                            else
                                row{end+1} = '';
                            end
                        else
                            row{end+1} = '';
                            row{end+1} = '';
                            row{end+1} = '';
                        end
                    end
                    
                    row{end+1} = task.CreationTime;
                    CompletedTasks(end+1, :) = row;
                end
            end
            
            if ~isempty(CompletedTasks)
                creationTimes = datetime({CompletedTasks{:, end}});  % last colum is CreationTime
                [~, sortedIdx] = sort(creationTimes, 'ascend');
                CompletedTasks = CompletedTasks(sortedIdx, :);
                CompletedTasks = CompletedTasks(:, 1:end-1);
            end
            app.CompletedTasksTable.ColumnName = allColumns;
            app.CompletedTasksTable.ColumnWidth = [repmat({'fit'}, 1, numel(staticColumns)+numel(dynamicColumns))];
            app.CompletedTasksTable.Data = CompletedTasks;
            app.CompletedTasksTable.ColumnFormat = columnFormat;
            app.CompletedTasksTable.ColumnEditable = columnEditable;
            drawnow;
        end

        
        function updateTasksTableByID(app, taskID)
            taskData = app.Tasks(taskID);
            if strcmp(taskData.Status, 'Completed')
                CompletedTasks = app.CompletedTasksTable.Data;
                for i = 1:size(CompletedTasks, 1)
                    if strcmp(CompletedTasks{i, 1}, taskID)
                        if isKey(app.Tasks, taskID)
                            CompletedTasks{i, 2} = taskData.TaskInfo;
                            CompletedTasks{i, 3} = taskData.Status;
                            CompletedTasks{i, 4} = taskData.Progress;
                            CompletedTasks{i, 5} = taskData.Result.E_o.mean;
                            CompletedTasks{i, 6} = taskData.Result.E_o.median;
                            CompletedTasks{i, 7} = taskData.Result.E_o.StdErr;
                            CompletedTasks{i, 8} = taskData.Result.E_bbc.mean;
                            CompletedTasks{i, 9} = taskData.Result.E_bbc.median;
                            CompletedTasks{i, 10} = taskData.Result.E_bbc.StdErr;
                        end
                        break;
                    end
                end
                app.CompletedTasksTable.Data = CompletedTasks;
            else
                UncompletedTasks = app.UncompletedTasksTable.Data;
                for i = 1:size(UncompletedTasks, 1)
                    if strcmp(UncompletedTasks{i, 1}, taskID)
                        if isKey(app.Tasks, taskID)
                            UncompletedTasks{i, 2} = taskData.TaskInfo;
                            UncompletedTasks{i, 3} = taskData.Status;
                            UncompletedTasks{i, 4} = taskData.Progress;
                        end
                        break;
                    end
                end
                app.UncompletedTasksTable.Data = UncompletedTasks;
            end
        end

        function showUncompletedTaskDetails(app, event)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
            
            if isempty(event.Indices) || ~isequal(size(event.Indices), [1, 2])
                return;
            end
            
            rowIndex = event.Indices(1);
            colIndex = event.Indices(2);
            if rowIndex > length(app.Tasks) || colIndex == 1
                return;
            end

            
            TaskID = app.UncompletedTasksTable.Data{rowIndex, 2};
            selectedTask = app.Tasks(TaskID);
        
            % Get table location information
            tablePos = app.UncompletedTasksTable.Position;
            rowHeight = 25;
            bubbleWidth = 250;
            bubbleHeight = 400;
            buttonWidth = 100;
            buttonHeight = 30;
            buttonPadding = 10;
        
            bubbleX = tablePos(1) + tablePos(3) - bubbleWidth;
            bubbleY = tablePos(2) + tablePos(4) - (rowIndex * rowHeight) - rowHeight - bubbleHeight - 5;
        
            % Bounds Checking
            panelPos = app.CenterPanel.Position;
            if bubbleX + bubbleWidth > panelPos(1) + panelPos(3)
                bubbleX = panelPos(1) + panelPos(3) - bubbleWidth - 10; 
            end

            if bubbleY < panelPos(2)
                bubbleY = panelPos(2) + 10;
            end
        
            % Create bubbles
            app.TaskBubble = uipanel(app.CenterPanel, ...
                'Title', 'Task Details', ...
                'Position', [bubbleX, bubbleY, bubbleWidth, bubbleHeight], ...
                'BackgroundColor', [1, 1, 0.9], ...
                'BorderType', 'line');
        
            % Partition Layout
            sectionHeight = (bubbleHeight-50) / 3;
            padding = 20;
        
            % Display algorithm information
            algorithmPanel = uipanel(app.TaskBubble, ...
                'Title', 'Algorithm Parameters', ...
                'Position', [padding, bubbleHeight - sectionHeight - 0.5*padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            algParams = fieldnames(selectedTask.AlgorithmParameters);
            paramGridAlg = uigridlayout(algorithmPanel, 'Scrollable', 'on');
            paramGridAlg.RowHeight = repmat({15}, length(algParams)+1, 1);
            paramGridAlg.ColumnWidth = {'1x'};
            label = uilabel(paramGridAlg, 'Text', ['Algorithm', ': ' ,selectedTask.Algorithm]);
                label.Layout.Row = 1;
                label.Layout.Column = 1;
            for i = 1:length(algParams)
                paramName = algParams{i};
                paramValue = selectedTask.AlgorithmParameters.(paramName).value;
            
                label = uilabel(paramGridAlg, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            % Display benchmark information
            problemPanel = uipanel(app.TaskBubble, ...
                'Title', 'Benchmark Parameters', ...
                'Position', [padding, bubbleHeight - 2*sectionHeight, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1], 'Scrollable', 'on');
        
            proParams = fieldnames(selectedTask.BenchmarkParameters);
            paramGridPro = uigridlayout(problemPanel, 'Scrollable', 'on');
            paramGridPro.RowHeight = repmat({15}, length(proParams)+1, 1);
            paramGridPro.ColumnWidth = {'1x'};
            label = uilabel(paramGridPro, 'Text', ['Benchmark', ': ' ,selectedTask.Benchmark]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;
            for i = 1:length(proParams)
                paramName = proParams{i};
                paramValue = selectedTask.BenchmarkParameters.(paramName).value;
            
                label = uilabel(paramGridPro, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            % Display RunNumber and other information
            runPanel = uipanel(app.TaskBubble, ...
                'Title', 'Run Info', ...
                'Position', [padding, bubbleHeight - 3*sectionHeight + 0.5*padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            runText = sprintf('Task ID:%s\nRun Number: %d\nCreated: %s', ...
                selectedTask.TaskID, selectedTask.RunNumber, selectedTask.CreationTime);
            uilabel(runPanel, ...
                'Text', runText, ...
                'Position', [padding, padding, bubbleWidth - 4*padding, sectionHeight - 3*padding], ...
                'HorizontalAlignment', 'left');
        
            % Add a close button
            uibutton(app.TaskBubble, 'Text', '✖', ...
                'Position', [bubbleWidth - 20, bubbleHeight - 20, 20, 20], ...
                'ButtonPushedFcn', @(~,~) delete(app.TaskBubble));

            if strcmp(app.RunButton.Text, 'Run Selected Tasks')
                uibutton(app.TaskBubble, ...
                    'Text', 'Run Single', ...
                    'Position', [(bubbleWidth/2 - buttonWidth)/2, buttonHeight-buttonPadding, buttonWidth, buttonHeight], ...
                    'BackgroundColor', [1, 0.5, 0], ... 
                    'FontColor', [1, 1, 1], ... 
                    'FontWeight', 'bold', ...
                    'Tooltip', 'Click to run this task', ... 
                    'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'singlecycle.png'), ...
                    'ButtonPushedFcn', @(~,~) runSingleTask(app, rowIndex));
            else
                uibutton(app.TaskBubble, ...
                    'Text', 'Run Single', ...
                    'Position', [(bubbleWidth/2 - buttonWidth)/2, buttonHeight-buttonPadding, buttonWidth, buttonHeight], ...
                    'Enable', 'off', ...
                    'BackgroundColor', [1, 0.5, 0], ... 
                    'FontColor', [1, 1, 1], ... 
                    'FontWeight', 'bold', ...
                    'Tooltip', 'Click to run this task', ... 
                    'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'singlecycle.png'), ...
                    'ButtonPushedFcn', @(~,~) runSingleTask(app, rowIndex));
            end

            if strcmp(app.RunButton.Text, 'Run Selected Tasks')
                uibutton(app.TaskBubble, ...
                    'Text', 'Delete Task', ...
                    'Position', [bubbleWidth/2 + (bubbleWidth/2 - buttonWidth)/2, buttonHeight-buttonPadding, buttonWidth, buttonHeight], ...  
                    'BackgroundColor', [1, 0, 0], ... 
                    'FontColor', [1, 1, 1], ... 
                    'FontWeight', 'bold', ...
                    'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete.png'), ...
                    'ButtonPushedFcn', @(~,~) deleteUncompletedTask(app, rowIndex));
            else
                uibutton(app.TaskBubble, ...
                    'Text', 'Delete Task', ...
                    'Position', [bubbleWidth/2 + (bubbleWidth/2 - buttonWidth)/2, buttonHeight-buttonPadding, buttonWidth, buttonHeight], ...  
                    'Enable', 'off', ...
                    'BackgroundColor', [1, 0, 0], ... 
                    'FontColor', [1, 1, 1], ... 
                    'FontWeight', 'bold', ...
                    'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete.png'), ...
                    'ButtonPushedFcn', @(~,~) deleteUncompletedTask(app, rowIndex));

            end

            % Force refresh of table selection status
            temp = app.UncompletedTasksTable.Data;
            app.UncompletedTasksTable.Data = [];
            app.UncompletedTasksTable.Data = temp;
            drawnow;
        end

        function selectAllUncompletedTasksCallback(app, src)
            % Remove any existing detail bubble (if present)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
        
            % Get the new value from the "Select All" checkbox.
            newValue = src.Value;
            
            % Get the current data of the Pending Tasks table.
            data = app.UncompletedTasksTable.Data;
            
            % Iterate through each row of the table
            for i = 1:size(data, 1)
                % Set the checkbox state in the first column to the new value.
                data{i, 1} = newValue;
                % Update the saved selection state using the TaskID from the second column.
                taskID = data{i, 2};
                app.PendingTasksSelectionStates(taskID) = newValue;
            end
        
            % Update the table data with the new selection state.
            app.UncompletedTasksTable.Data = data;
         end


        function selectAllCompletedTasksCallback(app, src)
            % Remove any existing detail bubble (if present)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
        
            % Get the new value from the "Select All" checkbox.
            newValue = src.Value;
            
            % Get the current data of the Completed Tasks table.
            data = app.CompletedTasksTable.Data;
            
            % Iterate through each row of the table
            for i = 1:size(data, 1)
                % Set the checkbox state in the first column to the new value.
                data{i, 1} = newValue;
                % Update the saved selection state using the TaskID from the second column.
                taskID = data{i, 2};
                app.CompletedTasksSelectionStates(taskID) = newValue;
            end
        
            % Update the table data with the new selection state.
            app.CompletedTasksTable.Data = data;
        end

        function selectAllSATasksCallback(app, src)
            % Remove any existing detail bubble (if present)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
        
            % Get the new value from the "Select All" checkbox.
            newValue = src.Value;
            
            % Get the current data of the SA Tasks table.
            data = app.SATasksTable.Data;
            
            % Iterate through each row of the table
            for i = 1:size(data, 1)
                % Set the checkbox state in the first column to the new value.
                data{i, 1} = newValue;
                % Update the saved selection state using the TaskID from the second column.
                taskID = data{i, 2};
                app.SATasksSelectionStates(taskID) = newValue;
            end
        
            % Update the table data with the new selection state.
            app.SATasksTable.Data = data;
        end

        function CompletedTasksTableCellEdit(app, event)
            % Remove the bubble for showing detail
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            if event.Indices(2) == 1
                editedRow = event.Indices(1);
                taskID = app.CompletedTasksTable.Data{editedRow, 2};
                app.CompletedTasksSelectionStates(taskID) = event.NewData;
            end

            % Check whether all checkboxes are selected
            data = app.CompletedTasksTable.Data;
            allSelected = true;
            
            % Loop through each row and check the first column
            for i = 1:size(data, 1)
                if ~data{i, 1}  % if any checkbox is not selected
                    allSelected = false;
                    break;
                end
            end
        
            % Update the global "Select All" checkbox accordingly
            app.SelectAllCompletedTasksCheckBox.Value = allSelected;
        end

        function PendingTasksTableCellEdit(app, event)
            % Remove the bubble for showing detail
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            if event.Indices(2) == 1
                editedRow = event.Indices(1);
                taskID = app.UncompletedTasksTable.Data{editedRow, 2};
                app.PendingTasksSelectionStates(taskID) = event.NewData;
            end

            % Check whether all checkboxes are selected
            data = app.UncompletedTasksTable.Data;
            allSelected = true;
            
            % Loop through each row and check the first column
            for i = 1:size(data, 1)
                if ~data{i, 1}  % if any checkbox is not selected
                    allSelected = false;
                    break;
                end
            end
        
            % Update the global "Select All" checkbox accordingly
            app.SelectAllUncompletedTasksCheckBox.Value = allSelected;
        end

        function SATasksTableCellEdit(app, event)
            % Remove the bubble for showing detail
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            if event.Indices(2) == 1
                editedRow = event.Indices(1);
                taskID = app.SATasksTable.Data{editedRow, 2};
                app.SATasksSelectionStates(taskID) = event.NewData;
            end

            % Check whether all checkboxes are selected
            data = app.SATasksTable.Data;
            allSelected = true;
            
            % Loop through each row and check the first column
            for i = 1:size(data, 1)
                if ~data{i, 1}  % if any checkbox is not selected
                    allSelected = false;
                    break;
                end
            end
        
            % Update the global "Select All" checkbox accordingly
            app.SelectAllSATasksCheckBox.Value = allSelected;
        end

        function showCompletedTaskDetails(app, event)
            % Remove the bubble for showing detail
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            if isempty(event.Indices) || ~isequal(size(event.Indices), [1, 2])
                return;
            end
            
            rowIndex = event.Indices(1);
            colIndex = event.Indices(2);
            if rowIndex > length(app.Tasks) || colIndex == 1
                return;
            end
            
            TaskID = app.CompletedTasksTable.Data{rowIndex, 2};
            selectedTask = app.Tasks(TaskID);

            tablePos = app.CompletedTasksTable.Position;
            rowHeight = 25;
            bubbleWidth = 275;
            bubbleHeight = 500;
            buttonWidth = 130;
            buttonHeight = 25;
            buttonPadding = 5;
        
            bubbleX = tablePos(1) + tablePos(3) - bubbleWidth;
            bubbleY = tablePos(2) + tablePos(4) - (rowIndex * rowHeight) - rowHeight - bubbleHeight - 5;
        
            panelPos = app.RightPanel.Position;
            if bubbleX + bubbleWidth > panelPos(1) + panelPos(3)
                bubbleX = panelPos(1) + panelPos(3) - bubbleWidth - 10;
            end

            if bubbleY < panelPos(2)
                bubbleY = panelPos(2) + 10;
            end
        
            app.TaskBubble = uipanel(app.RightPanel, ...
                'Title', 'Task Details', ...
                'Position', [bubbleX, bubbleY, bubbleWidth, bubbleHeight], ...
                'BackgroundColor', [1, 1, 0.9], ...
                'BorderType', 'line');
        
            sectionHeight = (bubbleHeight) / 4;
            padding = 20;
        
            algorithmPanel = uipanel(app.TaskBubble, ...
                'Title', 'Algorithm Parameters', ...
                'Position', [padding, bubbleHeight - sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            algParams = fieldnames(selectedTask.AlgorithmParameters);
            paramGridAlg = uigridlayout(algorithmPanel, 'Scrollable', 'on');
            paramGridAlg.RowHeight = repmat({15}, length(algParams)+1, 1);
            paramGridAlg.ColumnWidth = {'1x'};
            label = uilabel(paramGridAlg, 'Text', ['Algorithm', ': ' ,selectedTask.Algorithm]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;       
            for i = 1:length(algParams)
                paramName = algParams{i};
                paramValue = selectedTask.AlgorithmParameters.(paramName).value;
            
                label = uilabel(paramGridAlg, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            problemPanel = uipanel(app.TaskBubble, ...
                'Title', 'Benchmark Parameters', ...
                'Position', [padding, bubbleHeight - 2*sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1], 'Scrollable', 'on');
        
            proParams = fieldnames(selectedTask.BenchmarkParameters);
            paramGridPro = uigridlayout(problemPanel, 'Scrollable', 'on');
            paramGridPro.RowHeight = repmat({15}, length(proParams)+1, 1);
            paramGridPro.ColumnWidth = {'1x'};
            label = uilabel(paramGridPro, 'Text', ['Benchmark', ': ' ,selectedTask.Benchmark]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;  
            for i = 1:length(proParams)
                paramName = proParams{i};
                paramValue = selectedTask.BenchmarkParameters.(paramName).value;
                label = uilabel(paramGridPro, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            runPanel = uipanel(app.TaskBubble, ...
                'Title', 'Run Info', ...
                'Position', [padding, bubbleHeight - 3*sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            runText = sprintf('Task ID:%s\nRun Number: %d\nCreated: %s', ...
                selectedTask.TaskID, selectedTask.RunNumber, selectedTask.CreationTime);
            uilabel(runPanel, ...
                'Text', runText, ...
                'Position', [padding, padding, bubbleWidth - 4*padding, sectionHeight - 3*padding], ...
                'HorizontalAlignment', 'left');
        
            uibutton(app.TaskBubble, 'Text', '✖', ...
                'Position', [bubbleWidth - 20, bubbleHeight - 20, 20, 20], ...
                'ButtonPushedFcn', @(~,~) delete(app.TaskBubble));
        
            uibutton(app.TaskBubble, ...
                'Text', 'Plot Results', ...
                'Position', [(bubbleWidth/2 - buttonWidth)/2, 3*buttonHeight, buttonWidth, buttonHeight], ...
                'BackgroundColor', [0, 0.8, 0], ... 
                'FontColor', [1, 1, 1], ... 
                'FontWeight', 'bold', ...
                'Tooltip', 'Click to show the average of current error and offline error (E_o) over time over all runs.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'plot.png'), ...
                'ButtonPushedFcn', @(~,~) plotTaskResults(app, rowIndex));


            uibutton(app.TaskBubble, ...
                'Text', 'Save Results', ...
                'Position', [bubbleWidth/2 + (bubbleWidth/2 - buttonWidth)/2, 3*buttonHeight, buttonWidth, buttonHeight], ...
                'BackgroundColor', [0.569, 0.569, 0.569], ...
                'FontColor', [1, 1, 1], ...
                'FontWeight', 'bold', ...
                'Tooltip', 'Click to save detailed results of this task, including the algorithms used, problems, results of each run, and overall summary, stored in an Excel file.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'excel.png'), ...
                'ButtonPushedFcn', @(~,~) saveTaskResults(app, rowIndex));
        
            uibutton(app.TaskBubble, ...
                'Text', 'Select to SA', ...
                'Position', [(bubbleWidth/2 - buttonWidth)/2, 2*buttonHeight-buttonPadding, buttonWidth, buttonHeight], ...
                'BackgroundColor', [0, 0.6, 0.8], ...
                'FontColor', [1, 1, 1], ... 
                'FontWeight', 'bold', ...
                'Tooltip', 'Click to select for statistical analysis of multiple algorithms run on problem instances with the same problem parameter settings and number of runs.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'select.png'), ...
                'ButtonPushedFcn', @(~,~) selectTaskForStats(app, rowIndex));
            temp = app.CompletedTasksTable.Data;
            app.CompletedTasksTable.Data = [];
            app.CompletedTasksTable.Data = temp;
            drawnow;

            % Repending Task Button
            uibutton(app.TaskBubble, ...
                'Text', 'Move to Pending', ...
                'Position', [bubbleWidth/2 + (bubbleWidth/2 - buttonWidth)/2, 2*buttonHeight-buttonPadding, buttonWidth, buttonHeight], ...
                'BackgroundColor', [1, 0.5, 0], ...
                'FontColor', [1, 1, 1], ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'return.png'), ...
                'Tooltip', 'Move the task to the pending list for rerunning or editing.', ...
                'ButtonPushedFcn', @(~,~) rependingTask(app, rowIndex));
        
            uibutton(app.TaskBubble, ...
                'Text', 'Delete Task', ...
                'Position', [(bubbleWidth/2 - buttonWidth)/2, buttonHeight-2*buttonPadding, bubbleWidth/2 + (bubbleWidth/2 - buttonWidth)/2 - (bubbleWidth/2 - buttonWidth)/2 + buttonWidth, buttonHeight], ...
                'BackgroundColor', [1, 0, 0], ...
                'FontColor', [1, 1, 1], ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete.png'), ...
                'ButtonPushedFcn', @(~,~) deleteCompletedTask(app, rowIndex));
       
        end

        function showSATaskDetails(app, event)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble); 
            end

            if isempty(event.Indices) || ~isequal(size(event.Indices), [1, 2])
                return;
            end
            
            rowIndex = event.Indices(1);
            colIndex = event.Indices(2);
            if rowIndex > length(app.Tasks) || colIndex == 1
                return;
            end
            
            TaskID = app.SATasksTable.Data{rowIndex, 2};
            selectedTask = app.SATasks(TaskID);
        
            tablePos = app.SATasksTable.Position;
            rowHeight = 25;
            bubbleWidth = 250;
            bubbleHeight = 500;
            buttonWidth = 100;
            buttonHeight = 30;
            buttonPadding = 10;
        
            bubbleX = tablePos(1) + tablePos(3) - bubbleWidth;
            bubbleY = tablePos(2) + tablePos(4) - (rowIndex * rowHeight) - rowHeight - bubbleHeight - 5;
        
            panelPos = app.RightPanel.Position;
            if bubbleX + bubbleWidth > panelPos(1) + panelPos(3)
                bubbleX = panelPos(1) + panelPos(3) - bubbleWidth - 10; 
            end

            if bubbleY < panelPos(2)
                bubbleY = panelPos(2) + 10;
            end
        
            app.TaskBubble = uipanel(app.SAPanel, ...
                'Title', 'Task Details', ...
                'Position', [bubbleX, bubbleY, bubbleWidth, bubbleHeight], ...
                'BackgroundColor', [1, 1, 0.9], ...
                'BorderType', 'line');
        
            sectionHeight = (bubbleHeight) / 4;
            padding = 20;
        
            algorithmPanel = uipanel(app.TaskBubble, ...
                'Title', 'Algorithm Parameters', ...
                'Position', [padding, bubbleHeight - sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            algParams = fieldnames(selectedTask.AlgorithmParameters);
            paramGridAlg = uigridlayout(algorithmPanel, 'Scrollable', 'on');
            paramGridAlg.RowHeight = repmat({15}, length(algParams)+1, 1);
            paramGridAlg.ColumnWidth = {'1x'};
            label = uilabel(paramGridAlg, 'Text', ['Algorithm', ': ' ,selectedTask.Algorithm]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;
            for i = 1:length(algParams)
                paramName = algParams{i};
                paramValue = selectedTask.AlgorithmParameters.(paramName).value;
            
                label = uilabel(paramGridAlg, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            problemPanel = uipanel(app.TaskBubble, ...
                'Title', 'Benchmark Parameters', ...
                'Position', [padding, bubbleHeight - 2*sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1], 'Scrollable', 'on'); 
        
            proParams = fieldnames(selectedTask.BenchmarkParameters);
            paramGridPro = uigridlayout(problemPanel, 'Scrollable', 'on');
            paramGridPro.RowHeight = repmat({15}, length(proParams)+1, 1);
            paramGridPro.ColumnWidth = {'1x'};
            label = uilabel(paramGridPro, 'Text', ['Benchmark', ': ' ,selectedTask.Benchmark]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;
            for i = 1:length(proParams)
                paramName = proParams{i};
                paramValue = selectedTask.BenchmarkParameters.(paramName).value;
                label = uilabel(paramGridPro, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            runPanel = uipanel(app.TaskBubble, ...
                'Title', 'Run Info', ...
                'Position', [padding, bubbleHeight - 3*sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            runText = sprintf('Task ID:%s\nRun Number: %d\nCreated: %s', ...
                selectedTask.TaskID, selectedTask.RunNumber, selectedTask.CreationTime);
            uilabel(runPanel, ...
                'Text', runText, ...
                'Position', [padding, padding, bubbleWidth - 4*padding, sectionHeight - 3*padding], ...
                'HorizontalAlignment', 'left');
        
            uibutton(app.TaskBubble, 'Text', '✖', ...
                'Position', [bubbleWidth - 20, bubbleHeight - 20, 20, 20], ...
                'ButtonPushedFcn', @(~,~) delete(app.TaskBubble));
        
            uibutton(app.TaskBubble, ...
                'Text', 'Plot Results', ...
                'Position', [(bubbleWidth/2 - buttonWidth)/2, 1.5 * buttonHeight, buttonWidth, buttonHeight], ...
                'BackgroundColor', [0, 0.8, 0], ...
                'FontColor', [1, 1, 1], ... 
                'FontWeight', 'bold', ...
                'Tooltip', 'Click to show the average of current error and offline error (E_o) over time over all runs.', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'plot.png'), ...
                'ButtonPushedFcn', @(~,~) plotTaskResults(app, rowIndex));
    
            uibutton(app.TaskBubble, ...
                'Text', 'Delete', ...
                'Position', [bubbleWidth/2 + (bubbleWidth/2 - buttonWidth)/2, 1.5 * buttonHeight, buttonWidth, buttonHeight], ...
                'BackgroundColor', [1, 0, 0], ...
                'FontColor', [1, 1, 1], ...
                'FontWeight', 'bold', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'delete.png'), ...
                'ButtonPushedFcn', @(~,~) removeSATask(app, rowIndex));
       
        end

        function showSAResultsTaskDetails(app, event)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble); 
            end

            if isempty(event.Indices)  || ~all(event.Indices(:,2) == event.Indices(1,2))
                return;
            end
            
            rowIndex = event.Indices(1 ,1);
            colIndex = event.Indices(1, 2);
            if rowIndex > length(app.Tasks)
                return;
            end

             method = app.SAMethodSelectDropdown.Value;
            switch method
                case 'Wilcoxon rank-sum test'
                    TaskID = app.RankSumResultsTable.Data{1, colIndex};
                    tablePos = app.RankSumResultsTable.Position;
                    panelPos = app.RankSumResultsTable.Position;
                case 'Wilcoxon signed-rank test'
                    TaskID = app.SignedRankResultsTable.Data{1, colIndex};
                    tablePos = app.SignedRankResultsTable.Position;
                    panelPos = app.SignedRankResultsTable.Position;
                case 'Friedman test'
                    TaskID = app.FriedmanResultsTable.Data{1, colIndex};
                    tablePos = app.FriedmanResultsTable.Position;
                    panelPos = app.FriedmanResultsTable.Position;
                otherwise
                    uialert(app.UIFigure, 'Unknown statistical method selected', 'Error');
            end
            
            selectedTask = app.Tasks(TaskID);
        
            rowHeight = 25;
            bubbleWidth = 250;
            bubbleHeight = 400;
        
            bubbleX = tablePos(1) + tablePos(3) - bubbleWidth;
            bubbleY = tablePos(2) + tablePos(4) - (rowIndex * rowHeight) - rowHeight - bubbleHeight - 5;
        
            if bubbleX + bubbleWidth > panelPos(1) + panelPos(3)
                bubbleX = panelPos(1) + panelPos(3) - bubbleWidth - 10; 
            end

            if bubbleY < panelPos(2)
                bubbleY = panelPos(2) + 10;
            end
        
            app.TaskBubble = uipanel(app.SAFigure, ...
                'Title', 'Task Details', ...
                'Position', [bubbleX, bubbleY, bubbleWidth, bubbleHeight], ...
                'BackgroundColor', [1, 1, 0.9], ...
                'BorderType', 'line');

            sectionHeight = (bubbleHeight) / 3.5;
            padding = 20; 
        
            algorithmPanel = uipanel(app.TaskBubble, ...
                'Title', 'Algorithm Parameters', ...
                'Position', [padding, bubbleHeight - sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            algParams = fieldnames(selectedTask.AlgorithmParameters);
            paramGridAlg = uigridlayout(algorithmPanel, 'Scrollable', 'on');
            paramGridAlg.RowHeight = repmat({15}, length(algParams)+1, 1);
            paramGridAlg.ColumnWidth = {'1x'};
            label = uilabel(paramGridAlg, 'Text', ['Algorithm', ': ' ,selectedTask.Algorithm]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;            
            for i = 1:length(algParams)
                paramName = algParams{i};
                paramValue = selectedTask.AlgorithmParameters.(paramName).value;
                label = uilabel(paramGridAlg, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            problemPanel = uipanel(app.TaskBubble, ...
                'Title', 'Benchmark Parameters', ...
                'Position', [padding, bubbleHeight - 2*sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1], 'Scrollable', 'on');
        
            proParams = fieldnames(selectedTask.BenchmarkParameters);
            paramGridPro = uigridlayout(problemPanel, 'Scrollable', 'on');
            paramGridPro.RowHeight = repmat({15}, length(proParams)+1, 1);
            paramGridPro.ColumnWidth = {'1x'};
            label = uilabel(paramGridPro, 'Text', ['Benchmark', ': ' ,selectedTask.Benchmark]);
            label.Layout.Row = 1;
            label.Layout.Column = 1;
            for i = 1:length(proParams)
                paramName = proParams{i};
                paramValue = selectedTask.BenchmarkParameters.(paramName).value;
                label = uilabel(paramGridPro, 'Text', [paramName, ': ' ,num2str(paramValue)]);
                label.Layout.Row = i+1;
                label.Layout.Column = 1;
            end
        
            runPanel = uipanel(app.TaskBubble, ...
                'Title', 'Run Info', ...
                'Position', [padding, bubbleHeight - 3*sectionHeight - padding, bubbleWidth - 2*padding, sectionHeight - padding], ...
                'BackgroundColor', [1, 1, 1]);
        
            runText = sprintf('Task ID:%s\nRun Number: %d\nCreated: %s', ...
                selectedTask.TaskID, selectedTask.RunNumber, selectedTask.CreationTime);
            uilabel(runPanel, ...
                'Text', runText, ...
                'Position', [padding, padding, bubbleWidth - 4*padding, sectionHeight - 3*padding], ...
                'HorizontalAlignment', 'left');
        
            uibutton(app.TaskBubble, 'Text', '✖', ...
                'Position', [bubbleWidth - 20, bubbleHeight - 20, 20, 20], ...
                'ButtonPushedFcn', @(~,~) delete(app.TaskBubble));

        end

        function multiSelectForSA(app)
            completedData = app.CompletedTasksTable.Data;
            if isempty(completedData)
                uialert(app.UIFigure, ...
                    'No completed tasks available for selection.', ...
                    'No Data', ...
                    'Icon', 'warning', ...
                    'Modal', true);
                return;
            end
            
            selectedTaskIDs = {};
            for i = 1:size(completedData, 1)
                isChecked = completedData{i, 1};
                if islogical(isChecked) && isChecked
                    selectedTaskIDs{end+1} = completedData{i, 2};
                end
            end

            if isempty(selectedTaskIDs)
                uialert(app.UIFigure, ...
                    'Please select at least one completed task to add to Statistical Analysis List.', ...
                    'No Selection', ...
                    'Icon', 'warning', ...
                    'Modal', true);
                return;
            end

            baseTask = getTask(app, selectedTaskIDs{1});
            inconsistent = false;
            sameAlgParms = false;

            for i = 2:length(selectedTaskIDs)
                task = getTask(app, selectedTaskIDs{i});
                if ~isequal(task.Benchmark, baseTask.Benchmark) || ...
                   ~isequal(task.RunNumber, baseTask.RunNumber) || ...
                   ~isequal(task.BenchmarkParameters, baseTask.BenchmarkParameters)
                    inconsistent = true;
                    break;
                end
                if isequal(task.Algorithm, baseTask.Algorithm) && ...
                   isequal(task.AlgorithmParameters, baseTask.AlgorithmParameters)
                    sameAlgParms = true;
                end
            end

            if inconsistent
                uialert(app.UIFigure, ...
                    'Selected tasks do not match in Benchmark settings. Cannot proceed.', ...
                    'Inconsistent Tasks', ...
                    'Icon', 'error', ...
                    'Modal', true);
                return;
            end

            existingSATaskKeys = keys(app.SATasks);
            if ~isempty(existingSATaskKeys)
                refTask = getTask(app, existingSATaskKeys{1});
                if ~isequal(refTask.Benchmark, baseTask.Benchmark) || ...
                   ~isequal(refTask.RunNumber, baseTask.RunNumber) || ...
                   ~isequal(refTask.BenchmarkParameters, baseTask.BenchmarkParameters)
                    uialert(app.UIFigure, ...
                        'Selected tasks do not match the Benchmark settings of the existing Statistical Analysis List.', ...
                        'Mismatch with Existing List', ...
                        'Icon', 'error', ...
                        'Modal', true);
                    return;
                end
            end

            if sameAlgParms
                answer = questdlg(['Some selected tasks are from the same algorithm settings. ' ...
                                  'Statistical analysis may be meaningless. Do you still want to continue?'], ...
                                  'Redundant Tasks Detected', ...
                                  'Proceed', 'Cancel', 'Cancel');
                if strcmp(answer, 'Cancel') || isempty(answer)
                    return;
                end
            end

            addedCount = 0;
            for i = 1:length(selectedTaskIDs)
                taskID = selectedTaskIDs{i};
                if ~isKey(app.SATasks, taskID)
                    app.SATasks(taskID) = getTask(app, taskID);
                    addedCount = addedCount + 1;
                end
            end

            app.SATasksTable.Data = getSATasksTable(app);
            updateIntersectIndicatorsList(app);
            uialert(app.UIFigure, ...
                sprintf('%d task(s) successfully added to Statistical Analysis List.', addedCount), ...
                'Selection Added', ...
                'Icon', 'success', ...
                'Modal', true);
        end

        function quickFilterForSA(app)
            SATaskKeys = keys(app.SATasks);
            if isempty(SATaskKeys)
                % Show alert when no tasks are available
                uialert(app.UIFigure, ...
                    'You must first select at least one task for the statistical analysis list before using quick filtering.', ...
                    'Selection Required', ...
                    'Icon', 'warning', ...
                    'Modal', true);
                return;
            end
            beforeQuickFilterNumber = length(SATaskKeys);
            existingTask = getTask(app, SATaskKeys{1});
            TaskKeys = keys(app.Tasks);
            for i = 1:length(TaskKeys)
                task = getTask(app, TaskKeys{i});
                if strcmp(task.Status, 'Completed') && ~isKey(app.SATasks, TaskKeys{i})
                    if (isequal(existingTask.Benchmark, task.Benchmark) && ...
                       isequal(existingTask.RunNumber, task.RunNumber) && ...
                       isequal(existingTask.BenchmarkParameters, task.BenchmarkParameters))
                        app.SATasks(TaskKeys{i}) = task;
                    end
                end
            end
            app.SATasksTable.Data = getSATasksTable(app);
            SATaskKeys = keys(app.SATasks);
            afterQuickFilterNumber = length(SATaskKeys);
            increaseNumber = afterQuickFilterNumber - beforeQuickFilterNumber;
            % Show success message with added count
            if increaseNumber > 0
                pluralS = '';
                if increaseNumber > 1
                    pluralS = 's';
                end
                message = sprintf('Successfully added %d matching task%s to statistical analysis.', ...
                                increaseNumber, pluralS);
            else
                message = 'No additional matching tasks found.';
            end
            updateIntersectIndicatorsList(app);
            
            uialert(app.UIFigure, ...
                   message, ...
                   'Filter Complete', ...
                   'Icon', 'success', ...
                   'Modal', true);

        end

        function selectTaskForStats(app, rowIndex)
            TaskID = app.CompletedTasksTable.Data{rowIndex, 2};
            selectedTask = app.Tasks(TaskID);
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
            drawnow
            if isKey(app.SATasks, TaskID)
                uialert(app.UIFigure, 'A task with the same ID already exists in the archive and cannot be added.', 'Warning', ...
                    'Icon', 'warning');
                return;
            else
                taskKeys = keys(app.SATasks);
                matchFlag = true;
                for i = 1:length(taskKeys)
                    existingTask = app.SATasks(taskKeys{i});
                    % Compare Benchmark fields
                    if ~(isequal(existingTask.Benchmark, selectedTask.Benchmark) && ...
                       isequal(existingTask.RunNumber, selectedTask.RunNumber) && ...
                       isequal(existingTask.BenchmarkParameters, selectedTask.BenchmarkParameters))
                        matchFlag = false;
                        break;
                    end
                end
                if ~matchFlag
                    uialert(app.UIFigure, 'The test benchmark does not match the selected task instances, making statistical analysis impossible. Please check the newly added test case or the selected test cases.', ...
                        'Error', ...
                        'Icon', 'error');
                    return;
                end
               
                duplicateFound = false;
                for i = 1:length(taskKeys)
                    existingTask = app.SATasks(taskKeys{i});
                    % Compare all fields except TaskID and CreationTime
                    if isequal(existingTask.Algorithm, selectedTask.Algorithm) && ...
                       isequal(existingTask.Benchmark, selectedTask.Benchmark) && ...
                       isequal(existingTask.RunNumber, selectedTask.RunNumber) && ...
                       isequal(existingTask.AlgorithmParameters, selectedTask.AlgorithmParameters) && ...
                       isequal(existingTask.BenchmarkParameters, selectedTask.BenchmarkParameters)
                        duplicateFound = true;
                        break;
                    end
                end
                % If a duplicate is found, prompt the user
                if duplicateFound
                    answer = questdlg('A task with the same parameters already exists. Do you want to add the task to SA anyway?', ...
                        'Duplicate Task', ...
                        'Yes', 'No', 'No'); % Default to 'No'
                    
                    % If the user chooses 'No', return without adding the task
                    if strcmp(answer, 'No')
                        app.AddTaskButton.Enable = "on";
                        return;
                    end
                end
                app.SATasks(TaskID) = selectedTask;
                app.SATasksTable.Data = getSATasksTable(app);
                updateIntersectIndicatorsList(app);
            end
        end

        function SATasks = getSATasksTable(app)
            SATasks = {};
            taskKeys = keys(app.SATasks);
            
            % Set table columns (include CreationTime as a hidden column for sorting)
            columnNames = {'Select', 'Task ID', 'Task Info', 'CreationTime'};
            app.SATasksTable.ColumnName = columnNames;
            app.SATasksTable.ColumnWidth = {'fit', 'fit', '1x', 0};  % Hide CreationTime column
            drawnow;
            
            % Set column formats and editable properties
            columnFormat = {'logical', '', '', ''};
            columnEditable = [true, false, false, false];
            app.SATasksTable.ColumnFormat = columnFormat;
            app.SATasksTable.ColumnEditable = columnEditable;
            
            for i = 1:length(taskKeys)
                task = app.SATasks(taskKeys{i});
                % Determine checkbox status based on a global "Select All" checkbox if active
                if app.SelectAllSATasksCheckBox.Value == true
                    app.SATasksSelectionStates(task.TaskID) = true;
                    checkStatus = true;
                else
                    if isKey(app.SATasksSelectionStates, task.TaskID)
                        checkStatus = app.SATasksSelectionStates(task.TaskID);
                    else
                        app.SATasksSelectionStates(task.TaskID) = false;
                        checkStatus = false;
                    end
                end
                
                row = { ...
                    checkStatus, ...       % Checkbox (Select)
                    task.TaskID, ...       % Task ID
                    task.TaskInfo, ...     % Task Info
                    task.CreationTime ...  % CreationTime (for sorting, hidden later)
                };
                
                SATasks(end+1, :) = row;
            end
            
            % Sort by CreationTime (column 4) in ascending order and then remove that column from display
            if ~isempty(SATasks)
                creationTimes = datetime({SATasks{:, 4}});
                [~, sortedIdx] = sort(creationTimes, 'ascend');
                SATasks = SATasks(sortedIdx, :);
                SATasks = SATasks(:, 1:3);  % Remove the hidden CreationTime column
            end
            
            app.SATasksTable.Data = SATasks;
        end

        function removeSATask(app, rowIndex)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
            if rowIndex > size(app.SATasksTable.Data, 1)
                return;
            end
            rowData = app.SATasksTable.Data(rowIndex, :);
            taskIDtoRemove = rowData{2};
            if isKey(app.SATasks, taskIDtoRemove)
                remove(app.SATasks, taskIDtoRemove);
            else
                uialert(app.UIFigure, 'Invalid Task ID!', 'Warning', ...
                       'Icon', 'warning');
                return;
            end
            if isKey(app.SATasksSelectionStates, taskIDtoRemove)
                remove(app.SATasksSelectionStates, taskIDtoRemove);
            end
            app.SATasksTable.Data = getSATasksTable(app);
            updateIntersectIndicatorsList(app);
            drawnow
        end

        function deleteSelectedSATasks(app)
            answer = questdlg(['Are you sure you want to delete the selected tasks for statistical analysis? ' ...
                               'This action cannot be undone.'], ...
                               'Confirm Deletion', ...
                               'Delete', 'Cancel', 'Cancel');
            
            if isempty(answer) || strcmp(answer, 'Cancel')
                return;
            end
            
            tableData = app.SATasksTable.Data;
            deletedCount = 0;
            
            % Remove any displayed task detail bubble
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
            
            % Loop through each row in the SATasks table
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox state
                taskID = tableData{i, 2};     % Task ID
                
                if islogical(isChecked) && isChecked
                    % Remove the task from the SATasks map if it exists
                    if isKey(app.SATasks, taskID)
                        remove(app.SATasks, taskID);
                    end
                    
                    % Remove the selection state from SATasksSelectionStates (if applicable)
                    if isKey(app.SATasksSelectionStates, taskID)
                        remove(app.SATasksSelectionStates, taskID);
                    end
                    
                    deletedCount = deletedCount + 1;
                end
            end
            
            % Refresh the SATasks table and update intersect indicators
            app.SATasksTable.Data = getSATasksTable(app);
            updateIntersectIndicatorsList(app);
            drawnow;
            
            if deletedCount > 0
                uialert(app.UIFigure, ...
                        sprintf('Selected tasks for statistical analysis (%d) have been deleted.', deletedCount), ...
                        'Deletion Successful', ...
                        'Icon', 'info', ...
                        'Modal', true);
            else
                uialert(app.UIFigure, ...
                        'No tasks were selected for deletion.', ...
                        'No Tasks Deleted', ...
                        'Icon', 'warning', ...
                        'Modal', true);
            end
        end

        function deleteUncompletedTask(app, rowIndex)
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
            if rowIndex > size(app.UncompletedTasksTable.Data, 1)
                return;
            end
            rowData = app.UncompletedTasksTable.Data(rowIndex, :);
            taskIDtoRemove = rowData{2};
            removeTask(app, taskIDtoRemove);
            app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
            if isKey(app.PendingTasksSelectionStates, taskIDtoRemove)
                remove(app.PendingTasksSelectionStates, taskIDtoRemove);
            end
            drawnow
        end

        function deleteCompletedTask(app, rowIndex)
            if rowIndex > size(app.CompletedTasksTable.Data, 1)
                return;
            end
            rowData = app.CompletedTasksTable.Data(rowIndex, :);
            taskIDtoRemove = rowData{2};
            
            answer = questdlg('This task has already been completed. Are you sure you want to delete it? Deleted tasks cannot be recovered.', ...
                'Delete Completed Task', ...
                'Delete', 'Cancel', 'Cancel'); 
            
            
            if isempty(answer) || strcmp(answer, 'Cancel')
                return;
            end
            removeTask(app, taskIDtoRemove);
            getCompletedTasksTable(app);
            if isKey(app.SATasks, taskIDtoRemove)
                remove(app.SATasks, taskIDtoRemove);
                app.SATasksTable.Data = getSATasksTable(app);
            end
            app.SATasksTable.Data = getSATasksTable(app);
            if isKey(app.CompletedTasksSelectionStates, taskIDtoRemove)
                remove(app.CompletedTasksSelectionStates, taskIDtoRemove);
            end
           
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end
            updateUnionIndicatorsList(app);
            updateIntersectIndicatorsList(app);
            drawnow
        end

        function deleteSelectedPendingTasks(app)
        answer = questdlg(['Are you sure you want to delete the selected pending tasks?' ...
                           ' This action cannot be undone.'], ...
                           'Delete Pending Tasks', ...
                           'Delete', 'Cancel', 'Cancel');
            
            if isempty(answer) || strcmp(answer, 'Cancel')
                return;
            end
            
            tableData = app.UncompletedTasksTable.Data;
            deletedCount = 0;
                    
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                taskID = tableData{i, 2};     % Task ID
        
                if islogical(isChecked) && isChecked
                    % Remove from task pool
                    if isKey(app.Tasks, taskID)
                        removeTask(app, taskID);
                    end
        
                    % Remove from Statistical Analysis tasks
                    if isKey(app.SATasks, taskID)
                        remove(app.SATasks, taskID);
                    end
        
                    % Remove selection state
                    if isKey(app.PendingTasksSelectionStates, taskID)
                        remove(app.PendingTasksSelectionStates, taskID);
                    end
        
                    deletedCount = deletedCount + 1;
                end
            end
            
            app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
            app.SATasksTable.Data = getSATasksTable(app);
            
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            updateIntersectIndicatorsList(app);
            
            drawnow;
            
            if deletedCount > 0
                uialert(app.UIFigure, ...
                        sprintf('Selected pending tasks (%d) have been deleted.', deletedCount), ...
                        'Deletion Complete', ...
                        'Icon', 'info', ...
                        'Modal', true);
            else
                uialert(app.UIFigure, ...
                        'No pending tasks were found for deletion.', ...
                        'No Tasks Deleted', ...
                        'Icon', 'warning', ...
                        'Modal', true);
            end
        end

        function deleteSelectedCompletedTasks(app)
            answer = questdlg('These tasks have already been completed. Are you sure you want to delete them? Deleted tasks cannot be recovered. It is strongly recommended that you save them first.', ...
                            'Delete Completed Tasks', ...
                            'Delete', 'Cancel', 'Cancel');
            
            if isempty(answer) || strcmp(answer, 'Cancel')
                return;
            end
            
            tableData = app.CompletedTasksTable.Data;
            deletedCount = 0;
                    
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                taskID = tableData{i, 2};     % Task ID
        
                if islogical(isChecked) && isChecked
                    % Remove from task pool
                    if isKey(app.Tasks, taskID)
                        removeTask(app, taskID);
                    end
        
                    % Remove from Statistical Analysis tasks
                    if isKey(app.SATasks, taskID)
                        remove(app.SATasks, taskID);
                    end
        
                    % Remove selection state
                    if isKey(app.CompletedTasksSelectionStates, taskID)
                        remove(app.CompletedTasksSelectionStates, taskID);
                    end
        
                    deletedCount = deletedCount + 1;
                end
            end
            
            getCompletedTasksTable(app);
            app.SATasksTable.Data = getSATasksTable(app);
            
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            updateUnionIndicatorsList(app);
            updateIntersectIndicatorsList(app);
            
            drawnow;
            
            if deletedCount > 0
                uialert(app.UIFigure, ...
                        sprintf('Selected completed tasks (%d) have been deleted.', deletedCount), ...
                        'Deletion Complete', ...
                        'Icon', 'info', ...
                        'Modal', true);
            else
                uialert(app.UIFigure, ...
                        'No completed tasks were found for deletion.', ...
                        'No Tasks Deleted', ...
                        'Icon', 'warning', ...
                        'Modal', true);
            end
            
        end

        function updateUnionIndicatorsList(app)

            oldSelected = {}; 
            for i = 1:numel(app.UnionIndicatorsCheckboxes)
                if app.UnionIndicatorsCheckboxes(i).Value
                    oldSelected{end+1} = app.UnionIndicatorsItem{i};
                end
            end

            indicators = getResultFieldUnion(app);
            if isempty(indicators)
                indicators = {'E_o', 'E_bbc', 'T_r'};
            end
            app.UnionIndicatorsItem = indicators;
            freshUnionIndicatorCheckboxes(app);
        
            if isempty(oldSelected)
                newSelected = indicators;
            else
                newSelected = intersect(oldSelected, indicators);
                if isempty(newSelected)
                    newSelected = indicators;
                end
            end
            % Update the checkboxes' states based on the new selection.
            for i = 1:numel(app.UnionIndicatorsCheckboxes)
                if any(strcmp(app.UnionIndicatorsItem{i}, newSelected))
                    app.UnionIndicatorsCheckboxes(i).Value = true;
                else
                    app.UnionIndicatorsCheckboxes(i).Value = false;
                end
            end
        end

        function updateIntersectIndicatorsList(app)
            oldSelected = {}; 
            for i = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(i).Value
                    oldSelected{end+1} = app.IntersectIndicatorsItem{i};
                end
            end
            indicators = getResultFieldIntersect(app);
            if isempty(indicators)
                indicators = {'E_o', 'E_bbc', 'T_r'};
            end
            app.IntersectIndicatorsItem = indicators;
            freshIntersectIndicatorCheckboxes(app);
        
            if isempty(oldSelected)
                newSelected = indicators;
            else
                newSelected = intersect(oldSelected, indicators);
                if isempty(newSelected)
                    newSelected = indicators;
                end
            end
            % Update the checkboxes' states based on the new selection.
            for i = 1:numel(app.IntersectIndicatorsCheckboxes)
                if any(strcmp(app.IntersectIndicatorsItem{i}, newSelected))
                    app.IntersectIndicatorsCheckboxes(i).Value = true;
                else
                    app.IntersectIndicatorsCheckboxes(i).Value = false;
                end
            end
        end


        function runSingleTask(app, rowIndex)
            if rowIndex > size(app.UncompletedTasksTable.Data, 1)
                return;
            end
            rowData = app.UncompletedTasksTable.Data(rowIndex, :);
            taskIDtoRun = rowData{2};
            
            try
                pool = setParallelPool(app);
                app.RunButton.Text = 'Stop Tasks';
                app.RunButton.BackgroundColor = [1 0 0]; % red
                app.AddTaskButton.Enable = 'off'; % Disable add button
                app.AlgorithmList.Enable = 'off'; % Disable algorithm selection
                app.BenchmarkList.Enable = 'off'; % Disable benchmark selection
                app.RunNumberSpinner.Enable = 'off'; % Disable run count adjustment
                app.FastDeletePendingButton.Enable = 'off'; % Disable batch delete
                app.ThreadsInput.Enable = 'off'; % Disable thread adjustment
                app.CleanRAMButton.Enable = 'off'; % Disable thread pool shutdown
                app.UseLogicalCheckbox.Enable = 'off'; % Disable thread limit adjustment
                app.PoolTypeDropdown.Enable = 'off';
                app.RunButton.ButtonPushedFcn = @(~,~) stopTasks(app);
                app.RunButton.Tooltip = 'Click to stop the running tasks';
                app.RunButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'stop.png');

                task = app.Tasks(taskIDtoRun);
                task.Status = 'Queued';
                task.Progress = 'Ready for Run';
                app.Tasks(taskIDtoRun) = task;
                getCompletedTasksTable(app);
                app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
                if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble) && isvalid(app.TaskBubble)
                    delete(app.TaskBubble);
                end
                drawnow;
                % Create a DataQueue to receive progress updates for parallel tasks
                progressQueue = parallel.pool.DataQueue;
                afterEach(progressQueue, @(data) updateProgress(app, data));
                app.NumberRunningTasks = app.NumberRunningTasks + 1;
                newFuture = parfeval(pool, @GUIMode.executeTask, 0, task, task.TaskID, progressQueue);
                app.Futures = [app.Futures, newFuture];

            catch ME
                handleTaskError(app, ME);
                cleanupExperimental(app);
            end
        end
        
        function exportSelectedCompletedResults(app)
            if size(app.CompletedTasksTable.Data, 1) == 0
                uialert(app.UIFigure, 'No completed tasks available!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end

            progressDialog = uiprogressdlg(app.UIFigure, ...
                    'Title', 'Please Wait', ...
                    'Message', 'Exporting selected results...', ...
                    'Indeterminate', 'on');
        
            CompletedTasks = app.CompletedTasksTable.Data;
            savedTasks = struct([]);
            taskCounter = 0;
        
            for i = 1:size(CompletedTasks, 1)
                isChecked = CompletedTasks{i, 1};  % Checkbox status
                taskID = CompletedTasks{i, 2};     % Task ID
        
                if islogical(isChecked) && isChecked
                    if isKey(app.Tasks, taskID)
                        task = app.Tasks(taskID);
                        taskCounter = taskCounter + 1;
                        fields = fieldnames(task);
                        for j = 1:numel(fields)
                            savedTasks(taskCounter).(fields{j}) = task.(fields{j});
                        end
                    end
                end
            end
        
            if taskCounter == 0
                uialert(app.UIFigure, 'No tasks selected for export.', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
        
            resultsDir = fullfile(app.projectPath, 'Results', 'BatchRecords');
            if ~exist(resultsDir, 'dir')
                mkdir(resultsDir);
            end
        
            timestamp = datestr(now, 'yyyymmddTHHMMSS');
            defaultFileName = ['CompletedTasks_' timestamp '.mat'];
            filePath = fullfile(resultsDir, defaultFileName);
        
            try
                save(filePath, 'savedTasks', '-v7.3');
                uialert(app.UIFigure, ...
                    "Selected tasks exported successfully to '/Results/BatchRecords/'. " + ...
                    "Files are named like: CompletedTasks_YYYYMMDDTHHMMSS.mat", ...
                    'Export Complete', 'Icon', 'success');
                close(progressDialog);
            catch ME
                close(progressDialog);
                uialert(app.UIFigure, ['Export failed: ', ME.message], 'Error');
            end
        end


        function importCompletedResults(app)
            % Select .MAT file
            [file, path] = uigetfile('*.mat', 'Import Completed Tasks', fullfile(app.projectPath, 'Results', 'BatchRecords'));
        
            % If the user cancels the selection, exit
            if isequal(file, 0)
                return;
            end

            progressDialog = uiprogressdlg(app.UIFigure, ...
                'Title', 'Please Wait', ...
                'Message', 'Importing results from .mat...', ...
                'Indeterminate', 'on');
        
            filePath = fullfile(path, file);
        
            try
                loadedData = load(filePath);
                
                if ~isfield(loadedData, 'savedTasks')
                    uialert(app.UIFigure, 'Invalid file: No tasks found.', 'Error', 'Icon', 'error');
                    return;
                end
        
                % Parsing the data
                savedTasks = loadedData.savedTasks;
                numImported = 0; % Count the number of tasks that were successfully imported
                numSkipped = 0;  % Count the number of skipped tasks
                
                % Traverse the imported tasks and store them in app.Tasks
                for i = 1:numel(savedTasks)
                    taskID = savedTasks(i).TaskID;
                    
                    if isKey(app.Tasks, taskID)
                        numSkipped = numSkipped + 1;
                        continue;
                    end
                    
                    app.Tasks(taskID) = savedTasks(i);
                    numImported = numImported + 1;
                end
        
                getCompletedTasksTable(app);
                updateUnionIndicatorsList(app);
        
                if numImported > 0
                    successMsg = sprintf('Successfully imported %d tasks.', numImported);
                else
                    successMsg = 'No new tasks were imported. All tasks already exist.';
                end
        
                if numSkipped > 0
                    successMsg = sprintf('%s\nSkipped %d duplicate tasks.', successMsg, numSkipped);
                end
                close(progressDialog)
        
                uialert(app.UIFigure, successMsg, 'Import Results', 'Icon', 'success');
        
            catch ME
                close(progressDialog)
                uialert(app.UIFigure, ['Import failed: ', ME.message], 'Error', 'Icon', 'error');
            end
        end

        function runWilcoxonRankSum(app)

            tableData = app.SATasksTable.Data;
            taskIDs = {};
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                if islogical(isChecked) && isChecked
                    % Task ID is in the second column.
                    taskIDs{end+1} = tableData{i, 2};
                end
            end

            numTasks = length(taskIDs);
            
            if numTasks < 2
                uialert(app.UIFigure, 'There are not enough tasks for statistical analysis!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
            
            indicators = {}; 
            for ii = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(ii).Value
                    indicators{end+1} = app.IntersectIndicatorsItem{ii};
                end
            end
            numIndicators = length(indicators);
            alpha = 0.05;
            results = cell(numIndicators * 4 + 1, numTasks);
            total_wtl = zeros(numTasks, 3);

            for task = 1:numTasks
                results{1, task} = taskIDs{task};
            end
            % Statistical analysis was performed on each indicator
            for ind = 1:numIndicators
                indicator = indicators{ind};
                
                % Initializes the w/t/l counter of the current indicator
                wtl = zeros(numTasks, 3);
                
                % Get the mean and standard error
                for task = 1:numTasks
                    taskID = taskIDs{task};
                    meanVal = app.SATasks(taskID).Result.(indicator).mean;
                    seVal = app.SATasks(taskID).Result.(indicator).StdErr;
                    medianVal = app.SATasks(taskID).Result.(indicator).median;
                    results{(ind-1)*4 + 2, task} = sprintf('%.4f ± %.4f', meanVal, seVal);
                    results{(ind-1)*4 + 3, task} = sprintf('%.4f', medianVal);
                end
                
                % Wilcoxon rank-sum test and statistics w/t/l
                for task1 = 1:numTasks
                    taskID1 = taskIDs{task1};
                    for task2 = task1+1:numTasks
                        taskID2 = taskIDs{task2};
                        data1 = app.SATasks(taskID1).Result.(indicator).AllResults;
                        data2 = app.SATasks(taskID2).Result.(indicator).AllResults;
                        [p, ~] = ranksum(data1, data2);
                        if p < alpha
                            if median(data1) < median(data2)
                                wtl(task1, 1) = wtl(task1, 1) + 1;
                                wtl(task2, 3) = wtl(task2, 3) + 1;
                                total_wtl(task1, 1) = total_wtl(task1, 1) + 1;
                                total_wtl(task2, 3) = total_wtl(task2, 3) + 1;
                            elseif median(data1) > median(data2)
                                wtl(task1, 3) = wtl(task1, 3) + 1;
                                wtl(task2, 1) = wtl(task2, 1) + 1;
                                total_wtl(task1, 3) = total_wtl(task1, 3) + 1;
                                total_wtl(task2, 1) = total_wtl(task2, 1) + 1;
                            else
                                wtl(task1, 2) = wtl(task1, 2) + 1;
                                wtl(task2, 2) = wtl(task2, 2) + 1;
                                total_wtl(task1, 2) = total_wtl(task1, 2) + 1;
                                total_wtl(task2, 2) = total_wtl(task2, 2) + 1;
                            end
                        else
                            wtl(task1, 2) = wtl(task1, 2) + 1;
                            wtl(task2, 2) = wtl(task2, 2) + 1;
                            total_wtl(task1, 2) = total_wtl(task1, 2) + 1;
                            total_wtl(task2, 2) = total_wtl(task2, 2) + 1;
                        end
                    end
                end
                
                for task = 1:numTasks
                    results{(ind-1)*4 + 4, task} = sprintf('%d/%d/%d', wtl(task,1), wtl(task,2), wtl(task,3));
                    results{(ind-1)*4 + 5, task} = sprintf('%d', wtl(task,1) - wtl(task,3));
                end
            end
            
            % for task = 1:numTasks
            %     w = total_wtl(task, 1);
            %     l = total_wtl(task, 3);
            %     results{end, task} = sprintf('%d', w - l);
            % end
            
            rowNames = {};
            for ind = 1:numIndicators
                rowNames = [rowNames, {sprintf('%s Mean ± SE', indicators{ind})}, {sprintf('%s Median', indicators{ind})}, {sprintf('%s w/t/l', indicators{ind})}, {sprintf('%s w-l', indicators{ind})}];
            end
            % rowNames = [{'Task ID'}, rowNames, {'Total w - l'}];
            rowNames = [{'Task ID'}, rowNames];
            
            colNames = cell(1, numTasks);
            for task = 1:numTasks
                colNames{task} = sprintf(app.SATasks(taskIDs{task}).Algorithm);
            end

            totalDiff = total_wtl(:,1) - total_wtl(:,3);
            [~, sortIdx] = sort(totalDiff, 'descend');
            results = results(:, sortIdx);
            colNames = colNames(sortIdx);

            % TEMP
            % desiredOrder = {'ACFPSO', 'mPSO', 'SPSO_AP_AD', 'AMPPSO', 'mDE', ...
            %     'ImQSO', 'psfNBC', 'DPCPSO', 'APCPSO'};
            % 
            % [~, sortIdx] = ismember(desiredOrder, colNames);
            % results = results(:, sortIdx);
            % colNames = colNames(sortIdx);


            app.SAResults = results;
            app.SARowNames = rowNames;
            app.SAColNames = colNames;
            
            app.SAFigure = uifigure('Name', 'Wilcoxon rank-sum test results', 'Position', [100, 100, 800, 600]);
            gl = uigridlayout(app.SAFigure, [3,1]);
            gl.RowHeight = {'fit', '1x', 50};

            topPanel = uipanel(gl, 'Title', 'Benchmark and Experiment Settings');
            topPanel.Layout.Row = 1;
            topPanel.Layout.Column = 1;
            topGL = uigridlayout(topPanel, [1, 2]);
            topGL.ColumnWidth = {'1x', 50};
            topGL.RowHeight = {'fit'};
            
            firstTaskID = taskIDs{1};
            if isfield(app.SATasks(firstTaskID), 'Benchmark')
                benchmark = app.SATasks(firstTaskID).Benchmark;
            else
                benchmark = 'Unknown';
            end
            benchParamsStr = GUIMode.getParamString(app.SATasks(firstTaskID).BenchmarkParameters, '');
            labelText = sprintf('Benchmark: %s\nParameters: %s\nRun Number: %d', benchmark, benchParamsStr, app.SATasks(firstTaskID).RunNumber);
            benchmarkLabel = uilabel(topGL, 'Text', labelText, 'HorizontalAlignment','left', 'Tooltip', labelText);
            benchmarkLabel.Layout.Row = 1;
            benchmarkLabel.Layout.Column = 1;
            
            % help button
            helpBtn = uibutton(topGL, 'Text', '', ...
                'Tooltip', 'Show SA test methodology and results information', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'help.png'), ...
                'ButtonPushedFcn', @(btn,event) uialert(app.SAFigure, ...
                ['Statistical Analysis Overview' newline newline ...
                 '• Wilcoxon Rank-Sum Test: Also known as the Mann–Whitney U test, this non-parametric test is used to compare the performance of independent algorithms across selected metrics (e.g., E_o, E_bbc).' newline ...
                 '  - The test is applied pairwise between algorithms to assess whether their performance differs significantly.' newline newline ...
                 '• Results Format:' newline ...
                 '  - For each performance metric, the table displays:' newline ...
                 '     • Mean ± Standard Error' newline ...
                 '     • Median value' newline ...
                 '     • Win/Tie/Loss counts ("w/t/l")' newline ...
                 '       - These reflect the number of statistically significant wins (w), ties (t), and losses (l) for each algorithm in all pairwise comparisons.' newline ...
                 '     • w – l: The win–loss difference is also shown per metric as a simple score indicating relative performance.' newline ...
                 '       - Higher values suggest stronger performance against other algorithms.' newline newline ...
                 'The results are shown in the table below and can be exported to Excel for further analysis.'], ...
                'Methodology and Results Information', ...
                'Icon', 'info'));
            helpBtn.Layout.Row = 1;
            helpBtn.Layout.Column = 2;
            
            midPanel = uipanel(gl, 'Title', 'Statistical Comparison Results');
            midPanel.Layout.Row = 2;
            midPanel.Layout.Column = 1;
            midGL = uigridlayout(midPanel, [1, 1]);
            midGL.ColumnWidth = {'1x'};
            midGL.RowHeight = {'1x'};
            
            app.RankSumResultsTable = uitable(midGL, 'Data', results, ...
                          'RowName', rowNames, ...
                          'ColumnName', colNames);
            app.RankSumResultsTable.Layout.Row = 1;
            app.RankSumResultsTable.Layout.Column = 1;
            app.RankSumResultsTable.CellSelectionCallback = @(src, event) showSAResultsTaskDetails(app, event);
            
            exportBtn = uibutton(gl, 'Text', 'Export to Excel', ...
                                 'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'export.png'), ...
                                 'ButtonPushedFcn', @(btn, event) exportWilcoxonSAResults(app));
            exportBtn.Layout.Row = 3;
            exportBtn.Layout.Column = 1;
            
            app.RankSumResultsTable.ColumnWidth = 'auto';
        end

        function runWilcoxonSignedRank(app)
            tableData = app.SATasksTable.Data;
            taskIDs = {};
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                if islogical(isChecked) && isChecked
                    % Task ID is in the second column.
                    taskIDs{end+1} = tableData{i, 2};
                end
            end

            numTasks = length(taskIDs);
            
            if numTasks < 2
                uialert(app.UIFigure, 'There are not enough tasks for statistical analysis!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
            
            % indicators = {'E_o', 'E_bbc'};
            indicators = {}; 
            for ii = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(ii).Value
                    indicators{end+1} = app.IntersectIndicatorsItem{ii};
                end
            end
            numIndicators = length(indicators);
            alpha = 0.05;
            
            results = cell(numIndicators * 4 + 1, numTasks);
            
            total_wtl = zeros(numTasks, 3);

            for task = 1:numTasks
                results{1, task} = taskIDs{task};
            end
            for ind = 1:numIndicators
                indicator = indicators{ind};
                
                wtl = zeros(numTasks, 3);
                
                for task = 1:numTasks
                    taskID = taskIDs{task};
                    meanVal = app.SATasks(taskID).Result.(indicator).mean;
                    seVal = app.SATasks(taskID).Result.(indicator).StdErr;
                    medianVal = app.SATasks(taskID).Result.(indicator).median;
                    results{(ind-1)*4 + 2, task} = sprintf('%.4f ± %.4f', meanVal, seVal);
                    results{(ind-1)*4 + 3, task} = sprintf('%.4f', medianVal);
                end
                
                for task1 = 1:numTasks
                    taskID1 = taskIDs{task1};
                    for task2 = task1+1:numTasks
                        taskID2 = taskIDs{task2};
                        data1 = app.SATasks(taskID1).Result.(indicator).AllResults;
                        data2 = app.SATasks(taskID2).Result.(indicator).AllResults;
                        [p, ~] = signrank(data1, data2);
                        if p < alpha
                            if median(data1) < median(data2)
                                wtl(task1, 1) = wtl(task1, 1) + 1;
                                wtl(task2, 3) = wtl(task2, 3) + 1;
                                total_wtl(task1, 1) = total_wtl(task1, 1) + 1;
                                total_wtl(task2, 3) = total_wtl(task2, 3) + 1;
                            elseif median(data1) > median(data2)
                                wtl(task1, 3) = wtl(task1, 3) + 1;
                                wtl(task2, 1) = wtl(task2, 1) + 1;
                                total_wtl(task1, 3) = total_wtl(task1, 3) + 1;
                                total_wtl(task2, 1) = total_wtl(task2, 1) + 1;
                            else
                                wtl(task1, 2) = wtl(task1, 2) + 1;
                                wtl(task2, 2) = wtl(task2, 2) + 1;
                                total_wtl(task1, 2) = total_wtl(task1, 2) + 1;
                                total_wtl(task2, 2) = total_wtl(task2, 2) + 1;
                            end
                        else
                            wtl(task1, 2) = wtl(task1, 2) + 1;
                            wtl(task2, 2) = wtl(task2, 2) + 1;
                            total_wtl(task1, 2) = total_wtl(task1, 2) + 1;
                            total_wtl(task2, 2) = total_wtl(task2, 2) + 1;
                        end
                    end
                end
                
                for task = 1:numTasks
                    results{(ind-1)*4 + 4, task} = sprintf('%d/%d/%d', wtl(task,1), wtl(task,2), wtl(task,3));
                    results{(ind-1)*4 + 5, task} = sprintf('%d', wtl(task,1) - wtl(task,3));
                end
            end
            
            % for task = 1:numTasks
            %     w = total_wtl(task, 1);
            %     l = total_wtl(task, 3);
            %     results{end, task} = sprintf('%d', w - l);
            % end
            
            rowNames = {};
            for ind = 1:numIndicators
                rowNames = [rowNames, {sprintf('%s Mean ± SE', indicators{ind})}, {sprintf('%s Median', indicators{ind})}, {sprintf('%s w/t/l', indicators{ind})}, {sprintf('%s w-l', indicators{ind})}];
            end
            % rowNames = [{'Task ID'}, rowNames, {'Total w - l'}];
            rowNames = [{'Task ID'}, rowNames];
            
            colNames = cell(1, numTasks);
            for task = 1:numTasks
                colNames{task} = sprintf(app.SATasks(taskIDs{task}).Algorithm);
            end

            totalDiff = total_wtl(:,1) - total_wtl(:,3);
            [~, sortIdx] = sort(totalDiff, 'descend');
            results = results(:, sortIdx);
            colNames = colNames(sortIdx);

            % TEMP
            % desiredOrder = {'ACFPSO', 'mPSO', 'SPSO_AP_AD', 'AMPPSO', 'mDE', ...
            %     'ImQSO', 'psfNBC', 'DPCPSO', 'APCPSO'};
            % 
            % [~, sortIdx] = ismember(desiredOrder, colNames);
            % results = results(:, sortIdx);
            % colNames = colNames(sortIdx);

            app.SAResults = results;
            app.SARowNames = rowNames;
            app.SAColNames = colNames;
            
            app.SAFigure = uifigure('Name', 'Wilcoxon signed-rank test results', 'Position', [100, 100, 800, 600]);
            gl = uigridlayout(app.SAFigure, [3,1]);
            gl.RowHeight = {'fit', '1x', 50};

            topPanel = uipanel(gl, 'Title', 'Benchmark and Experiment Settings');
            topPanel.Layout.Row = 1;
            topPanel.Layout.Column = 1;
            topGL = uigridlayout(topPanel, [1, 2]);
            topGL.ColumnWidth = {'1x', 50};
            topGL.RowHeight = {'fit'};
            
            firstTaskID = taskIDs{1};
            if isfield(app.SATasks(firstTaskID), 'Benchmark')
                benchmark = app.SATasks(firstTaskID).Benchmark;
            else
                benchmark = 'Unknown';
            end
            benchParamsStr = GUIMode.getParamString(app.SATasks(firstTaskID).BenchmarkParameters, '');
            labelText = sprintf('Benchmark: %s\nParameters: %s\nRun Number: %d', benchmark, benchParamsStr, app.SATasks(firstTaskID).RunNumber);
            benchmarkLabel = uilabel(topGL, 'Text', labelText, 'HorizontalAlignment','left', 'Tooltip', labelText);
            benchmarkLabel.Layout.Row = 1;
            benchmarkLabel.Layout.Column = 1;
            
            % help button
            helpBtn = uibutton(topGL, 'Text', '', ...
                'Tooltip', 'Show SA test methodology and results information', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'help.png'), ...
                'ButtonPushedFcn', @(btn,event) uialert(app.SAFigure, ...
                ['Statistical Analysis Overview' newline newline ...
                 '• Wilcoxon Signed-Rank Test: This non-parametric test is used to compare the performance of paired algorithms on selected metrics (e.g., E_o, E_bbc).' newline ...
                 '  - It is applied pairwise to determine whether one algorithm significantly outperforms another when evaluated over the same conditions (e.g., runs or benchmarks).' newline newline ...
                 '• Results Format:' newline ...
                 '  - For each performance metric, the table displays:' newline ...
                 '     • Mean ± Standard Error' newline ...
                 '     • Median value' newline ...
                 '     • Win/Tie/Loss counts ("w/t/l")' newline ...
                 '       - These reflect the number of statistically significant wins (w), ties (t), and losses (l) for each algorithm in all pairwise comparisons.' newline ...
                 '     • w – l: The win–loss difference is shown per metric as a summary score indicating relative performance.' newline ...
                 '       - Higher values suggest stronger performance compared to others under paired testing.' newline newline ...
                 'Note: Win–loss scores are reported separately for each metric and are not aggregated, as each represents a distinct statistical comparison.' newline newline ...
                 'The results are displayed in the table below and can be exported to Excel for further analysis.'], ...
                'Methodology and Results Information', ...
                'Icon', 'info'));

            helpBtn.Layout.Row = 1;
            helpBtn.Layout.Column = 2;
            
            midPanel = uipanel(gl, 'Title', 'Statistical Comparison Results');
            midPanel.Layout.Row = 2;
            midPanel.Layout.Column = 1;
            midGL = uigridlayout(midPanel, [1, 1]);
            midGL.ColumnWidth = {'1x'};
            midGL.RowHeight = {'1x'};

            app.SignedRankResultsTable = uitable(midGL, 'Data', results, ...
                          'RowName', rowNames, ...
                          'ColumnName', colNames);
            app.SignedRankResultsTable.Layout.Row = 1;
            app.SignedRankResultsTable.Layout.Column = 1;
            app.SignedRankResultsTable.CellSelectionCallback = @(src, event) showSAResultsTaskDetails(app, event);
            
            exportBtn = uibutton(gl, 'Text', 'Export to Excel', ...
                                 'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'export.png'), ...
                                 'ButtonPushedFcn', @(btn, event) exportWilcoxonSAResults(app));
            exportBtn.Layout.Row = 3;
            exportBtn.Layout.Column = 1;
            
            app.SignedRankResultsTable.ColumnWidth = 'auto';
        end

        function runFriedmanTest(app)
            tableData = app.SATasksTable.Data;
            taskIDs = {};
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                if islogical(isChecked) && isChecked
                    % Task ID is in the second column.
                    taskIDs{end+1} = tableData{i, 2};
                end
            end

            numTasks = length(taskIDs);
            
            if numTasks < 2
                uialert(app.UIFigure, 'There are not enough tasks for statistical analysis!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
            
            indicators = {}; 
            for ii = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(ii).Value
                    indicators{end+1} = app.IntersectIndicatorsItem{ii};
                end
            end
            numIndicators = length(indicators);
            alpha = 0.05;
            
            results = cell(numIndicators*3 + 1, numTasks);
            results(1, :) = taskIDs;
            
            % Store the average ranking of all indicators for overall sorting
            allAvgRanks = zeros(numIndicators, numTasks);
            
            for ind = 1:numIndicators
                indicator = indicators{ind};
                
                % Collect data for all tasks (in matrix form, each column corresponds to a task)
                dataMatrix = [];
                for task = 1:numTasks
                    taskID = taskIDs{task};
                    data = app.SATasks(taskID).Result.(indicator).AllResults;
                    dataMatrix = [dataMatrix, data(:)];
                end
                
                % Run Friedman test
                [p, ~, stats] = friedman(dataMatrix, 1, 'off');
                avgRanks = stats.meanranks;
                allAvgRanks(ind, :) = avgRanks;
                
                % Fill in the mean and standard error
                for task = 1:numTasks
                    taskID = taskIDs{task};
                    meanVal = app.SATasks(taskID).Result.(indicator).mean;
                    stdVal = app.SATasks(taskID).Result.(indicator).StdErr;
                    medianVal = app.SATasks(taskID).Result.(indicator).median;
                    results{3*(ind-1)+2, task} = sprintf('%.4f ± %.4f', meanVal, stdVal);
                    results{3*(ind-1)+3, task} = sprintf('%.4f', medianVal);
                end
                
                % Conduct post-hoc testing and generate grouping labels (if p is significant)
                if p < alpha
                    % Calculate Nemenyi critical difference
                    k = numTasks;
                    N = size(dataMatrix, 1);
                    q = getNemenyiCriticalValue(app, k, alpha);
                    CD = q * sqrt(k*(k+1)/(6*N));
                    
                    % Generate grouping letters
                    groups = getNemenyiGroups(avgRanks, CD);
                else
                    groups = repmat({''}, 1, numTasks);
                end
                
                % Fill in ranking and grouping information
                for task = 1:numTasks
                    rankStr = sprintf('%.2f', avgRanks(task));
                    if ~isempty(groups{task})
                        rankStr = [rankStr ' ' groups{task}];
                    end
                    results{3*(ind-1)+4, task} = rankStr;
                end
            end
            
            % Calculate total average ranking
            totalAvgRanks = mean(allAvgRanks, 1);
            % for task = 1:numTasks
            %     results{end, task} = sprintf('%.2f', totalAvgRanks(task));
            % end
            
            % Based on the overall ranking to sort the task
            [~, sortIdx] = sort(totalAvgRanks);
            results = results(:, sortIdx);
            
            % Build column name (algorithm name)
            colNames = cell(1, numTasks);
            for task = 1:numTasks
                taskID = taskIDs{sortIdx(task)};
                colNames{task} = app.SATasks(taskID).Algorithm;
            end
            
            % Build row name
            rowNames = {'Task ID'};
            for ind = 1:numIndicators
                rowNames = [rowNames, ...
                    sprintf('%s Mean ± SE', indicators{ind}), ...
                    sprintf('%s Median', indicators{ind}), ...
                    sprintf('%s Rank', indicators{ind})];
            end
            % rowNames = [rowNames, 'Total Rank'];

            % TEMP
            % desiredOrder = {'ACFPSO', 'mPSO', 'SPSO_AP_AD', 'AMPPSO', 'mDE', ...
            %     'ImQSO', 'psfNBC', 'DPCPSO', 'APCPSO'};
            % 
            % [~, sortIdx] = ismember(desiredOrder, colNames);
            % results = results(:, sortIdx);
            % colNames = colNames(sortIdx);

            app.SAResults = results;
            app.SARowNames = rowNames;
            app.SAColNames = colNames;
            
            app.SAFigure = uifigure('Name', 'Friedman test results', 'Position', [100, 100, 800, 600]);
            gl = uigridlayout(app.SAFigure, [3,1]);
            gl.RowHeight = {'fit', '1x', 50};

            topPanel = uipanel(gl, 'Title', 'Benchmark and Experiment Settings');
            topPanel.Layout.Row = 1;
            topPanel.Layout.Column = 1;
            topGL = uigridlayout(topPanel, [1, 2]);
            topGL.ColumnWidth = {'1x', 50};
            topGL.RowHeight = {'fit'};
            
            firstTaskID = taskIDs{1};
            if isfield(app.SATasks(firstTaskID), 'Benchmark')
                benchmark = app.SATasks(firstTaskID).Benchmark;
            else
                benchmark = 'Unknown';
            end
            benchParamsStr = GUIMode.getParamString(app.SATasks(firstTaskID).BenchmarkParameters, '');
            labelText = sprintf('Benchmark: %s\nParameters: %s\nRun Number: %d', benchmark, benchParamsStr, app.SATasks(firstTaskID).RunNumber);
            benchmarkLabel = uilabel(topGL, 'Text', labelText, 'HorizontalAlignment','left', 'Tooltip', labelText);
            benchmarkLabel.Layout.Row = 1;
            benchmarkLabel.Layout.Column = 1;
            
            % help button
            helpBtn = uibutton(topGL, 'Text', '', ...
                'Tooltip', 'Show SA test methodology and results information', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'help.png'), ...
                'ButtonPushedFcn', @(btn,event) uialert(app.SAFigure, ...
                ['• Statistical Analysis Overview ' newline newline ...
                 '• Friedman Test: A non-parametric test used to detect differences in performance across multiple algorithms evaluated on the same tasks.' newline ...
                 '   - It ranks each algorithm per task and checks if the average ranks differ significantly.' newline newline ...
                 '• Post-hoc Nemenyi Test: If the Friedman test finds significant differences (p < 0.05), the Nemenyi test performs pairwise comparisons to detect which algorithms differ from each other.' newline ...
                 '   - Algorithms with the same letter (e.g., "a", "b") in the rank columns are not significantly different from each other at 95% confidence.' newline newline ...
                 '• Results Table Columns:' newline ...
                 '   - E_o Mean ± SE: Mean and Standard Error of offline error.' newline ...
                 '   - E_o Median: Median of offline error.' newline ...
                 '   - E_o Rank: Average rank of the algorithm across tasks for E_o, with statistical grouping (a, b, ...).' newline ...
                 '   - E_bbc Mean ± SE: Same as above, but for the error before best change.' newline ...
                 '   - Total Rank: Average of ranks across all metrics—lower is better.' newline newline ...
                 '• Interpretation Tip:' newline ...
                 '   - Algorithms in the same group (e.g., both labeled "a") perform similarly.' newline ...
                 '   - Lower ranks indicate better performance.' newline newline ...
                 '•  You can export these results to Excel for further custom analysis.'], ...
                'Methodology and Results Information', ...
                'Icon', 'info'));
            helpBtn.Layout.Row = 1;
            helpBtn.Layout.Column = 2;
            
            midPanel = uipanel(gl, 'Title', 'Statistical Comparison Results');
            midPanel.Layout.Row = 2;
            midPanel.Layout.Column = 1;
            midGL = uigridlayout(midPanel, [1, 2]);
            midGL.ColumnWidth = {'1x'};
            midGL.RowHeight = {'1x'};

            app.FriedmanResultsTable = uitable(midGL, 'Data', results, ...
                'RowName', rowNames, 'ColumnName', colNames);
            app.FriedmanResultsTable.Layout.Row = 1;
            app.FriedmanResultsTable.Layout.Column = 1;
            app.FriedmanResultsTable.CellSelectionCallback = @(src, event) showSAResultsTaskDetails(app, event);
            
            % export button
            exportBtn = uibutton(gl, 'Text', 'Export to Excel', ...
                'Icon', fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'export.png'), ...
                'ButtonPushedFcn', @(btn,event) exportFriedmanResults(app));
            exportBtn.Layout.Row = 3;
            exportBtn.Layout.Column = 1;
            
            app.FriedmanResultsTable.ColumnWidth = 'auto';

            % Auxiliary function: Get Nemenyi critical value
            function q = getNemenyiCriticalValue(app, k, alpha)
                if alpha ~= 0.05
                    uialert(app.UIFigure, 'Please set alpha to 0.05', 'Error');
                    return
                end
                % qalpha array (alpha=0.05)
                qalpha = [0.000, 1.960, 2.344, 2.569, 2.728, 2.850, 2.948, 3.031, 3.102, 3.164, ...
                          3.219, 3.268, 3.313, 3.354, 3.391, 3.426, 3.458, 3.489, 3.517, 3.544, ...
                          3.569, 3.593, 3.616, 3.637, 3.658, 3.678, 3.696, 3.714, 3.732, 3.749, ...
                          3.765, 3.780, 3.795, 3.810, 3.824, 3.837, 3.850, 3.863, 3.876, 3.888, ...
                          3.899, 3.911, 3.922, 3.933, 3.943, 3.954, 3.964, 3.973, 3.983, 3.992, ...
                          4.001, 4.009, 4.017, 4.025, 4.032, 4.040, 4.046];
                
                % Verify the range of k
                if k < 2 || k > length(qalpha)
                    uialert(app.UIFigure, 'Nemenyi critical value not available', 'Error');
                    return
                end
                
                % Return the corresponding q value
                q = qalpha(k);
            end
            
            % Auxiliary function: Generate Nemenyi grouping letters
            function groups = getNemenyiGroups(avgRanks, CD)
                [sortedRanks, sortIndex] = sort(avgRanks);
                n = length(sortedRanks);
                groups = repmat({''}, 1, n);
                
                currentGroup = 1;
                groupLetters = repmat({'a'}, 1, n);
                
                % Forward scan: Determine basic grouping
                for i = 2:n
                    if (sortedRanks(i) - sortedRanks(currentGroup)) > CD
                        currentGroup = i;
                        groupLetters{i} = char('a' + currentGroup - 1);
                    else
                        groupLetters{i} = groupLetters{currentGroup};
                    end
                end
                
                % Backpropagation: Ensuring that subsequent tasks have no significant differences with the previous shared group
                for i = n-1:-1:1
                    for j = i+1:n
                        if (sortedRanks(j) - sortedRanks(i)) <= CD
                            groupLetters{i} = unique([groupLetters{i}, groupLetters{j}]);
                        end
                    end
                end
                
                % Convert to single-letter representation
                [~, ~, ic] = unique(groupLetters);
                finalLetters = arrayfun(@(x) char('a' + x - 1), ic, 'UniformOutput', false);
                groups(sortIndex) = finalLetters;
            end
        end
       
        function startTrendPlotWithSelectedTasks(app)
           tableData = app.SATasksTable.Data;
            taskKeys = {};
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                if islogical(isChecked) && isChecked
                    % Task ID is in the second column.
                    taskKeys{end+1} = tableData{i, 2};
                end
            end
            numTasks = length(taskKeys);
            if numTasks < 1
                uialert(app.UIFigure, 'There are not enough tasks for plot!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end

            indicators = {}; 
            for ii = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(ii).Value
                    indicators{end+1} = app.IntersectIndicatorsItem{ii};
                end
            end
            numIndicators = length(indicators);
            % answer = questdlg('If the number of fitness evaluations is large, plotting the results may take a long time. The process cannot be paused or canceled once started. Do you want to proceed with plotting?', ...
            %     'Plot Task Results', ...
            %     'Confirm', 'Cancel', 'Cancel');
            % 
            % if isempty(answer) || strcmp(answer, 'Cancel')
            %     return;
            % end
            
            commonParams = getCommonAlgParametersInTasks(app, taskKeys);
            commonParams = cellfun(@(x) ['Parameters:', x], commonParams, 'UniformOutput', false);
            if iscell(commonParams)
                commonParams = [{'Algorithm'}, commonParams(:)'];
            else
                commonParams = {'Algorithm'};
            end

            [selectedParam, isOK] = listdlg(...
            'Name', 'Selection',...
            'PromptString', 'Your selection will determine which parameter is used for the legends in the E_o plot:',...
            'SelectionMode', 'single',...
            'ListString', commonParams,...
            'ListSize', [450 200], ...
            'OKString', 'Confirm Selection',...
            'CancelString', 'Cancel');
            if ~isOK || isempty(selectedParam)
                return; 
            end

            poolFlag = true;
            pool = gcp('nocreate'); % Get current parallel pool
            if isempty(pool) % No pool exists, start a new one
                poolFlag = false;
                progressDialog = uiprogressdlg(app.UIFigure, ...
                    'Title', 'Please Wait', ...
                    'Message', sprintf('Starting %s pool with %d workers...', app.PoolTypeDropdown.Value, app.PhysicalCores), ...
                    'Indeterminate', 'on');
                try
                    pool = parpool(app.PoolTypeDropdown.Value, app.UserSettingNumberThreads);
                catch
                    close(progressDialog);
                    uialert(app.UIFigure, ...
                        sprintf('Failed to start the %s pool with the specified configuration. A default pool has been started instead.', app.PoolTypeDropdown.Value), ...
                        'Warning', 'Icon', 'warning');
                    progressDialog = uiprogressdlg(app.UIFigure, ...
                        'Title', 'Please Wait', ...
                        'Message', sprintf('Starting %s pool with default workers...', app.PoolTypeDropdown.Value), ...
                        'Indeterminate', 'on');
                    pool = parpool(app.PoolTypeDropdown.Value);
                    app.ThreadsInput.Value = pool.NumWorkers;
                    app.UserSettingNumberThreads = app.ThreadsInput.Value;
                end
                app.NowPoolType = app.PoolTypeDropdown.Value;
                close(progressDialog);
            end

            selectedX = commonParams{selectedParam};
            if ~strcmp(selectedX, 'Algorithm')
                fieldNameParam = extractAfter(selectedX, length('Parameters:'));
            else
                fieldNameParam = selectedX;
            end
            groupLabels = cell(length(taskKeys), 1);
            sortBase = cell(length(taskKeys), 1);
            for i = 1:length(taskKeys)
                taskID = taskKeys{i};
                taskData = app.SATasks(taskID);
                if strcmp(selectedX, 'Algorithm')
                    groupLabels{i} = taskData.Algorithm;
                else
                    if isfield(taskData.AlgorithmParameters, fieldNameParam)
                        paramVal = taskData.AlgorithmParameters.(fieldNameParam).value;
                        if isnumeric(paramVal)
                            sortBase{i} = paramVal;
                            groupLabels{i} = num2str(paramVal);
                        else
                            sortBase{i} = char(paramVal);
                            groupLabels{i} = char(paramVal);
                        end
                    else
                        sortBase{i} = 'Unknown';
                        groupLabels{i} = 'Unknown';
                    end
                end
            end

            if ~strcmp(selectedX, 'Algorithm')
                if isnumeric(sortBase{1})
                    numericArray = cell2mat(sortBase);
                    [~, sortIdx] = sort(numericArray);
                else
                    [~, sortIdx] = sort(sortBase);
                end
                taskKeys = taskKeys(sortIdx);
                groupLabels = groupLabels(sortIdx);
            end

            groupLabelsWithoutTaskID = groupLabels;
            groupLabelsWithTaskID = groupLabels;
            for i = 1:length(taskKeys)
                taskID = taskKeys{i};
                if ~strcmp(selectedX, 'Algorithm')
                    groupLabelsWithTaskID{i} = sprintf('%s:%s (%s)', fieldNameParam, groupLabels{i}, taskID);
                else
                    groupLabelsWithTaskID{i} = sprintf('%s (%s)', groupLabels{i}, taskID);
                end
                indices = find(strcmp(groupLabels, groupLabels{i}));
                if numel(indices) > 1
                    if ~strcmp(selectedX, 'Algorithm')
                        groupLabelsWithoutTaskID{i} = sprintf('%s:%s (%s)', fieldNameParam, groupLabels{i}, taskID);
                    else
                        groupLabelsWithoutTaskID{i} = sprintf('%s (%s)', groupLabels{i}, taskID);
                    end
                else
                    if ~strcmp(selectedX, 'Algorithm')
                        groupLabelsWithoutTaskID{i} = sprintf('%s:%s', fieldNameParam, groupLabels{i});
                    end
                end
            end

            noTrendIndicator = {};
            for ii = 1:numIndicators
                if strcmp(indicators{ii}, 'E_o')
                    plotMultiTaskOfflineError(app, pool, taskKeys, groupLabelsWithTaskID, groupLabelsWithoutTaskID);
                elseif strcmp(indicators{ii}, 'E_bbc')
                    plotMultiTaskBestErrorBeforeChange(app, pool, taskKeys, groupLabelsWithTaskID, groupLabelsWithoutTaskID);
                % elseif strcmp(indicators{ii}, 'T_r')
                %     continue;
                else
                    % User define Plot
                    if isfield(app.SATasks(taskKeys{1}).Result.(indicators{ii}), 'trend')
                        plotMultiTaskIndicatorTrend(app, taskKeys, indicators{ii}, groupLabelsWithTaskID, groupLabelsWithoutTaskID);
                    else
                        noTrendIndicator{end+1} = indicators{ii};
                    end
                end
                pause(1);
            end
            if ~isempty(noTrendIndicator)
                msg = sprintf('The following indicators have no trend data and cannot be plotted:\n\n%s', ...
                    strjoin(noTrendIndicator, '\n'));
                uialert(app.UIFigure, msg, 'Missing Trend Data', 'Icon', 'warning');
            end

            if ~poolFlag
                delete(gcp('nocreate')); % Close the parallel pool to release RAM
                app.NowPoolType = '';
                app.CleanRAMButton.Enable = 'off';
            end
        end

        function startBoxPlotWithSelectedTasks(app)
            tableData = app.SATasksTable.Data;
            taskKeys = {};
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                if islogical(isChecked) && isChecked
                    % Task ID is in the second column.
                    taskKeys{end+1} = tableData{i, 2};
                end
            end
            numTasks = length(taskKeys);
            if numTasks < 1
                uialert(app.UIFigure, 'There are not enough tasks for plot!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
            plotMetricBoxplotsWithNotch(app, taskKeys);
        end

        function startCurrentErrorPlotWithSelectedTasks(app)
            tableData = app.SATasksTable.Data;
            taskKeys = {};
            for i = 1:size(tableData, 1)
                isChecked = tableData{i, 1};  % Checkbox status
                if islogical(isChecked) && isChecked
                    % Task ID is in the second column.
                    taskKeys{end+1} = tableData{i, 2};
                end
            end
            numTasks = length(taskKeys);
            if numTasks < 1
                uialert(app.UIFigure, 'There are not enough tasks for plot!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end

            indicators = {}; 
            for ii = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(ii).Value
                    indicators{end+1} = app.IntersectIndicatorsItem{ii};
                end
            end
            numIndicators = length(indicators);
            % answer = questdlg('If the number of fitness evaluations is large, plotting the results may take a long time. The process cannot be paused or canceled once started. Do you want to proceed with plotting?', ...
            %     'Plot Task Results', ...
            %     'Confirm', 'Cancel', 'Cancel');
            % 
            % if isempty(answer) || strcmp(answer, 'Cancel')
            %     return;
            % end
            
            commonParams = getCommonAlgParametersInTasks(app, taskKeys);
            commonParams = cellfun(@(x) ['Parameters:', x], commonParams, 'UniformOutput', false);
            if iscell(commonParams)
                commonParams = [{'Algorithm'}, commonParams(:)'];
            else
                commonParams = {'Algorithm'};
            end

            [selectedParam, isOK] = listdlg(...
            'Name', 'Selection',...
            'PromptString', 'Your selection will determine which parameter is used for the legends in the E_o plot:',...
            'SelectionMode', 'single',...
            'ListString', commonParams,...
            'ListSize', [450 200], ...
            'OKString', 'Confirm Selection',...
            'CancelString', 'Cancel');
            if ~isOK || isempty(selectedParam)
                return; 
            end

            selectedX = commonParams{selectedParam};
            if ~strcmp(selectedX, 'Algorithm')
                fieldNameParam = extractAfter(selectedX, length('Parameters:'));
            else
                fieldNameParam = selectedX;
            end
            groupLabels = cell(length(taskKeys), 1);
            sortBase = cell(length(taskKeys), 1);
            for i = 1:length(taskKeys)
                taskID = taskKeys{i};
                taskData = app.SATasks(taskID);
                if strcmp(selectedX, 'Algorithm')
                    groupLabels{i} = taskData.Algorithm;
                else
                    if isfield(taskData.AlgorithmParameters, fieldNameParam)
                        paramVal = taskData.AlgorithmParameters.(fieldNameParam).value;
                        if isnumeric(paramVal)
                            sortBase{i} = paramVal;
                            groupLabels{i} = num2str(paramVal);
                        else
                            sortBase{i} = char(paramVal);
                            groupLabels{i} = char(paramVal);
                        end
                    else
                        sortBase{i} = 'Unknown';
                        groupLabels{i} = 'Unknown';
                    end
                end
            end

            if ~strcmp(selectedX, 'Algorithm')
                if isnumeric(sortBase{1})
                    numericArray = cell2mat(sortBase);
                    [~, sortIdx] = sort(numericArray);
                else
                    [~, sortIdx] = sort(sortBase);
                end
                taskKeys = taskKeys(sortIdx);
                groupLabels = groupLabels(sortIdx);
            end

            groupLabelsWithoutTaskID = groupLabels;
            groupLabelsWithTaskID = groupLabels;
            for i = 1:length(taskKeys)
                taskID = taskKeys{i};
                if ~strcmp(selectedX, 'Algorithm')
                    groupLabelsWithTaskID{i} = sprintf('%s:%s (%s)', fieldNameParam, groupLabels{i}, taskID);
                else
                    groupLabelsWithTaskID{i} = sprintf('%s (%s)', groupLabels{i}, taskID);
                end
                indices = find(strcmp(groupLabels, groupLabels{i}));
                if numel(indices) > 1
                    if ~strcmp(selectedX, 'Algorithm')
                        groupLabelsWithoutTaskID{i} = sprintf('%s:%s (%s)', fieldNameParam, groupLabels{i}, taskID);
                    else
                        groupLabelsWithoutTaskID{i} = sprintf('%s (%s)', groupLabels{i}, taskID);
                    end
                else
                    if ~strcmp(selectedX, 'Algorithm')
                        groupLabelsWithoutTaskID{i} = sprintf('%s:%s', fieldNameParam, groupLabels{i});
                    end
                end
            end

            plotMultiTaskCurrentErrorTrend(app, taskKeys, groupLabelsWithTaskID, groupLabelsWithoutTaskID);
        end

        function plotMultiTaskCurrentErrorTrend(app, selectedTaskIDs, groupLabelsWithTaskID, groupLabelsWithoutTaskID)
            % Number of tasks
            numTasks = numel(selectedTaskIDs);
            avgError  = cell(numTasks,1);
        
            % 1. Compute average CurrentError (across 31 runs) for each task
            for i = 1:numTasks
                td = app.SATasks(selectedTaskIDs{i});
                % assume CurrentError is [numEvals × runNumber]
                if isfield(td.Result, 'CurrentError')
                    CE = td.Result.CurrentError;
                    avgError{i} = mean(CE, 1);  
                else
                    avgError{i} = [];
                end
            end
        
            % 2. Create figure & axes with identical styling
            try
                fig = figure('Name',       'Trend of Current Error Over Evaluations', ...
                             'NumberTitle','off', ...
                             'Position',   [100 100 1000 600], ...
                             'Color',      'w', ...
                             'DefaultTextFontName','Times New Roman', ...
                             'DefaultAxesFontName','Times New Roman');
                ax = axes('Parent',fig); 
                hold(ax,'on');
        
                % 3. Colors & line‐styles
                baseC = lines(9);
                C     = baseC(mod(0:numTasks-1,size(baseC,1))+1, :);
                Ls    = {'-','--',':','-.'};
                lw    = 2.0;
        
                % 4. Plot each
                for k = 1:numTasks
                    y = avgError{k};
                    if isempty(y), continue; end
                    x = 1:numel(y);
                    plot(ax, x, y, ...
                         'Color',      C(k,:), ...
                         'LineStyle',  Ls{mod(k-1,4)+1}, ...
                         'LineWidth',  lw, ...
                         'DisplayName',groupLabelsWithoutTaskID{k});
                end
        
                % 5. Axes formatting
                set(ax, 'YScale','log', ...
                        'FontSize',14, ...
                        'FontWeight','bold', ...
                        'LineWidth',1.5);
                xlabel(ax, 'Function Evaluations', ...
                       'FontSize',16, ...
                       'FontWeight','bold', ...
                       'Interpreter','latex');
                ylabel(ax, 'Average Current Error', ...
                       'FontSize',16, ...
                       'FontWeight','bold', ...
                       'Interpreter','latex');
                title(ax, 'Trend of Current Error Over Evaluations', ...
                      'FontSize',16, ...
                      'FontWeight','bold', ...
                      'Interpreter','latex');
                box(ax,'on');
        
                % 6. Outside legend
                lg = legend(ax, 'Location','bestoutside', ...
                               'FontSize',14, ...
                               'NumColumns',ceil(numTasks/20), ...
                               'EdgeColor','none', ...
                               'Box','off', ...
                               'Interpreter','none');
        
                % 7. “Show TaskID” checkbox
                % uicontrol('Parent', fig, ...
                %           'Style','checkbox', ...
                %           'String','Show TaskID', ...
                %           'Units','normalized', ...
                %           'Position',[0.00,0.95,0.10,0.05], ...
                %           'FontSize',10, ...
                %           'Tooltip','Toggle TaskID in Legend', ...
                %           'Callback', @(src,~) toggleID(src));
        
                hold(ax,'off');
            catch ME
                errordlg(sprintf('Error: %s', ME.message), 'Plot Error');
            end
        
            % Nested callback: swap between with/without TaskID
            function toggleID(src)
                linesObj = findobj(ax,'Type','Line');
                linesObj = flipud(linesObj);
                if get(src,'Value')
                    newLabels = groupLabelsWithTaskID;
                else
                    newLabels = groupLabelsWithoutTaskID;
                end
                for ii = 1:min(numel(linesObj),numel(newLabels))
                    set(linesObj(ii),'DisplayName',newLabels{ii});
                end
                legend(ax,'off');
                legend(ax, 'Location','bestoutside', ...
                           'FontSize',11, ...
                           'NumColumns',ceil(numTasks/20), ...
                           'EdgeColor','none', ...
                           'Box','off', ...
                           'Interpreter','none');
                legend(ax,'show');
            end
        end


        function startStatisticalAnalysisWithSelectedTasks(app)
            taskKeys = keys(app.SATasks);
            numTasks = length(taskKeys);
            if numTasks < 2
                uialert(app.UIFigure, 'There are not enough tasks for statistical analysis!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
            method = app.SAMethodSelectDropdown.Value;  % Get the selected method
            switch method
                case 'Wilcoxon rank-sum test'
                    runWilcoxonRankSum(app);
                case 'Wilcoxon signed-rank test'
                    runWilcoxonSignedRank(app);
                case 'Friedman test'
                    runFriedmanTest(app);
                otherwise
                    uialert(app.UIFigure, 'Unknown statistical method selected', 'Error');
            end
        end

        function exportWilcoxonSAResults(app)
            method = app.SAMethodSelectDropdown.Value;
            if ~strcmp(method, 'Wilcoxon rank-sum test') && ~strcmp(method, 'Wilcoxon signed-rank test')
                uialert(app.UIFigure, 'Error SA Test Method!', 'Warning', ...
                        'Icon', 'warning');
                return;
            end
            if ~isprop(app, 'SAResults') || isempty(app.SAResults)
                uialert(app.SAFigure, 'No statistical analysis results to export.', 'Error', ...
                    'Icon', 'error');
                return;
            end
        
            resultsDir = fullfile(app.projectPath, 'Results', 'StatisticalAnalysis');
            if ~exist(resultsDir, 'dir')
                mkdir(resultsDir);
            end
            
            % Create a default file name with a timestamp
            timestamp = datestr(now, 'yyyymmddTHHMMSS');
            if strcmp(method, 'Wilcoxon rank-sum test')
                fileLabel = 'WilcoxonRankSumTest';
            elseif strcmp(method, 'Wilcoxon signed-rank test')
                fileLabel = 'WilcoxonSignedRankTest';
            end
            defaultFileName = ['SA_' fileLabel '_' timestamp '.xlsx'];
            filePath = fullfile(resultsDir, defaultFileName);
            numTasks = size(app.SAResults,2);
            paramRow = cell(1, numTasks);
            for i = 1:numTasks
                taskID = app.SAResults{1, i};
                params = app.SATasks(taskID).AlgorithmParameters;
                paramRow{i} = GUIMode.getParamString(params, '');
            end
        
            updatedResults = [paramRow; app.SAResults(2:end, :)];
            updatedRowNames = [{'Algorithm Parameters'}; app.SARowNames(2:end).'];

            problemParamRow = cell(1, numTasks);
            runNumberRow    = cell(1, numTasks);
            for i = 1:numTasks
                if i == 1
                    taskID = app.SAResults{1, i};
                    probParams = app.SATasks(taskID).BenchmarkParameters;
                    problemParamRow{i} = GUIMode.getParamString(probParams, '');
                    
                    runNum = app.SATasks(taskID).RunNumber;
                    runNumberRow{i} = num2str(runNum);
                else
                    problemParamRow{i} = '';
                    runNumberRow{i} = '';
                end
            end
            updatedResults = [updatedResults; problemParamRow; runNumberRow];
            updatedRowNames = [updatedRowNames; {'Benchmark Parameters'}; {'Run Number'}];

            try
                T = cell2table(updatedResults, 'VariableNames', makeUniqueNames(app.SAColNames), 'RowNames', updatedRowNames);
                writetable(T, filePath, 'WriteRowNames', true);
                uialert(app.SAFigure, ...
                    "Results exported successfully to '/Results/StatisticalAnalysis/'. " + ...
                    "Files are named using the format: SA_[Analysis Method]_YYYYMMDDTHHMMSS.xlsx", ...
                    'Success', 'Icon', 'success');
            catch ME
                uialert(app.SAFigure, sprintf('Error exporting results: %s', ME.message), 'Error', 'Icon', 'error');
            end

            function uniqueNames = makeUniqueNames(names)
                uniqueNames = names;
                counts = containers.Map;
                for n = 1:length(names)
                    name = names{n};
                    if isKey(counts, name)
                        counts(name) = counts(name) + 1;
                        uniqueNames{n} = sprintf('%s(%d)', name, counts(name));
                    else
                        counts(name) = 1;
                    end
                end
            end
        end

        function exportFriedmanResults(app)
            if ~isprop(app, 'SAResults') || isempty(app.SAResults)
                uialert(app.SAFigure, 'No Friedman test results to export.', 'Error', ...
                        'Icon', 'error');
                return;
            end
        
            resultsDir = fullfile(app.projectPath, 'Results', 'StatisticalAnalysis');
            if ~exist(resultsDir, 'dir')
                mkdir(resultsDir);
            end
            
            timestamp = datestr(now, 'yyyymmddTHHMMSS');
            defaultFileName = ['SA_FriedmanTest_' timestamp '.xlsx'];
            filePath = fullfile(resultsDir, defaultFileName);
        
            numTasks = size(app.SAResults,2);
            paramRow = cell(1, numTasks);
            for i = 1:numTasks
                taskID = app.SAResults{1, i};
                params = app.SATasks(taskID).AlgorithmParameters;
                paramRow{i} = GUIMode.getParamString(params, '');
            end
        
            updatedResults = [paramRow; app.SAResults(2:end, :)];
            updatedRowNames = [{'Algorithm Parameters'}; app.SARowNames(2:end).'];

            problemParamRow = cell(1, numTasks);
            runNumberRow    = cell(1, numTasks);
            for i = 1:numTasks
                if i == 1
                    taskID = app.SAResults{1, i};
                    probParams = app.SATasks(taskID).BenchmarkParameters;
                    problemParamRow{i} = GUIMode.getParamString(probParams, '');
                    
                    runNum = app.SATasks(taskID).RunNumber;
                    runNumberRow{i} = num2str(runNum);
                else
                    problemParamRow{i} = '';
                    runNumberRow{i} = '';
                end
            end
            updatedResults = [updatedResults; problemParamRow; runNumberRow];
            updatedRowNames = [updatedRowNames; {'Benchmark Parameters'}; {'Run Number'}];
        
            try
                T = cell2table(updatedResults, ...
                    'VariableNames', makeUniqueNames(app.SAColNames), ...
                    'RowNames', updatedRowNames);
                writetable(T, filePath, 'WriteRowNames', true);
                
                uialert(app.SAFigure, ...
                    "Results exported successfully to '/Results/StatisticalAnalysis/'. " + ...
                    "Files are named using the format: SA_[Analysis Method]_YYYYMMDDTHHMMSS.xlsx", ...
                    'Success', 'Icon', 'success');
            catch ME
                uialert(app.SAFigure, ...
                    sprintf('Export failed:\n%s', ME.message), ...
                    'Export Error', 'Icon', 'error');
            end
        
            function uniqueNames = makeUniqueNames(names)
                uniqueNames = names;
                counts = containers.Map;
                for n = 1:length(names)
                    name = names{n};
                    if isKey(counts, name)
                        counts(name) = counts(name) + 1;
                        uniqueNames{n} = sprintf('%s(%d)', name, counts(name));
                    else
                        counts(name) = 1;
                    end
                end
            end
        end


        function rependingTask(app, rowIndex)
            if rowIndex > size(app.CompletedTasksTable.Data, 1)
                return;
            end
            rowData = app.CompletedTasksTable.Data(rowIndex, :);
            taskIDtoRerun = rowData{2};
            
            
            answer = questdlg('This task has already been completed. Are you sure to repending it?', ...
                'Repending Completed Task', ...
                'Repending', 'Cancel', 'Cancel'); 
        
            
            if isempty(answer) || strcmp(answer, 'Cancel')
                return;
            end

            try
                task = app.Tasks(taskIDtoRerun);
                task.Status = 'Repending';
                task.Progress = 'Repending for Run';
                app.Tasks(taskIDtoRerun) = task;
                getCompletedTasksTable(app);
                app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
                if isKey(app.SATasks, taskIDtoRerun)
                    remove(app.SATasks, taskIDtoRerun);
                    app.SATasksTable.Data = getSATasksTable(app);
                end
                if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble) && isvalid(app.TaskBubble)
                    delete(app.TaskBubble);
                end
                drawnow;

            catch ME
                handleTaskError(app, ME);
                cleanupExperimental(app);
            end
        end

        function plotTaskResults(app, rowIndex)
            if rowIndex > size(app.CompletedTasksTable.Data, 1)
                return;
            end
            % answer = questdlg('If the number of fitness evaluations is large, plotting the results may take a long time. The process cannot be paused or canceled once started. Do you want to proceed with plotting?', ...
            %     'Plot Task Results', ...
            %     'Confirm', 'Cancel', 'Cancel');
            % 
            % if isempty(answer) || strcmp(answer, 'Cancel')
            %     return;
            % end
            
            progressDialog = uiprogressdlg(app.UIFigure, 'Title', 'Please Wait', ...
                'Message', 'Plotting data...', 'Indeterminate', 'on');

            rowData = app.CompletedTasksTable.Data(rowIndex, :);
            taskIDtoPlot = rowData{2};
            task = app.Tasks(taskIDtoPlot);
            OutputPlot(task.Result.CurrentError,task.RunNumber,task.Result.E_o,task.Result.E_bbc,task.Algorithm);
            close(progressDialog);
        end


        function saveTaskResults(app, rowIndex)
            if rowIndex > size(app.CompletedTasksTable.Data, 1)
                return;
            end
            progressDialog = uiprogressdlg(app.UIFigure, 'Title', 'Please Wait', ...
                'Message', 'Saving Detailed Result...', 'Indeterminate', 'on');

            rowData = app.CompletedTasksTable.Data(rowIndex, :);
            taskIDtoSave = rowData{2};
            task = app.Tasks(taskIDtoSave);
            OutputDetailResultsToExcel( ...
                task.Algorithm, ...
                task.AlgorithmParameters, ...
                task.Benchmark, ...
                task.BenchmarkParameters, ...
                task.Result, ...
                [app.projectPath, '/Results/TaskDetailResults']);
            close(progressDialog);
            uialert(app.UIFigure, ...
                "Tasks exported successfully to '/Results/TaskDetailResults/'. " + ...
                "Files are named using the format: [Algorithm]_[Problem]_YYYYMMDDTHHMMSS.xlsx", ...
                'Success', 'Icon', 'success');
        end

        function plotMultiTaskOfflineError(app, pool, selectedTaskIDs, groupLabelsWithTaskID, groupLabelsWithoutTaskID)

            numTasks = length(selectedTaskIDs);
            currentErrors = cell(numTasks, 1);
            runNumbers = zeros(numTasks, 1);
            totalFE = 0;
            for i = 1:numTasks
                taskID = selectedTaskIDs{i};
                taskData = app.SATasks(taskID);
                currentErrors{i} = taskData.Result.CurrentError;
                runNumbers(i) = taskData.RunNumber;
                totalFE = totalFE + size(currentErrors{i}, 2);
            end
            processedFE = zeros(numTasks, 1);

            mainPos = app.UIFigure.Position;
            dlgWidth = 400;
            dlgHeight = 150;
            centerX = mainPos(1) + (mainPos(3) - dlgWidth) / 2;
            centerY = mainPos(2) + (mainPos(4) - dlgHeight) / 2;
            
            dlg = uifigure('Name','E_o Progress', ...
                'WindowStyle','modal', ...
                'Position',[centerX centerY dlgWidth dlgHeight], ...
                'Resize','off', ...
                'CloseRequestFcn', @(src, event) cancelCallback());
            
            uilabel(dlg, ...
                'Text', sprintf('Using %s pool with %d workers to process plotting tasks...', ...
                app.PoolTypeDropdown.Value, app.PhysicalCores), ...
                'Position', [20 100 360 30], ...
                'FontSize', 12);


           progressLabel = uilabel(dlg, ...
                'Text', '0%', ...
                'Position', [20 70 360 30], ...
                'FontSize', 12);
            
            progressBG = uipanel(dlg, ...
                'Position',[20 60 360 20], ...
                'BackgroundColor',[0.8 0.8 0.8], ...
                'BorderType', 'none');
            
            progressFill = uipanel(progressBG, ...
                'Position',[0 0 1 20], ...
                'BackgroundColor',[0.2 0.7 0.2]);  % 绿色
            
            uibutton(dlg, 'Text', 'Cancel', ...
                'Position', [150 15 100 30], ...
                'ButtonPushedFcn', @(src,event) cancelCallback());


            dQueue = parallel.pool.DataQueue;
            afterEach(dQueue, @(data) updatePlotEoProgress(data));
            futures = parallel.FevalFuture.empty(0, numTasks);
            for i = 1:numTasks
                futures(i) = parfeval(pool, @GUIMode.computeOfflineError, 2, currentErrors{i}, runNumbers(i), i, dQueue);
            end
            offlineErrors = cell(numTasks, 1);

            function plotEo()
                try
                    % Create figure window
                    fig = figure('Name', 'Comparison of E_o Over Time Across Tasks', ...
                        'NumberTitle', 'off', ...
                        'Position', [100 100 1000 600], ...
                        'Color', 'w', ...
                        'DefaultTextFontName', 'Times New Roman', ...
                        'DefaultAxesFontName', 'Times New Roman');
                    
                    ax = axes('Parent', fig);
                    hold(ax, 'on');

                    natureColors = lines(9);
                    % Repeat colors if there are more tasks than colors
                    numColors = size(natureColors, 1);
                    colors = natureColors(mod(0:length(selectedTaskIDs)-1, numColors) + 1, :);
                    
                    lineStyles = {'-', '--', ':', '-.'};      % Keep 4 basic line styles
                    lineWidth = 2.0;                          % Keep bolder line width
                    
                    % Get maximum evaluation count
                    maxEvals = max(cellfun(@(id) size(app.SATasks(id).Result.CurrentError, 2), selectedTaskIDs));
                    
                    displayName = groupLabelsWithoutTaskID;
                    
                    % Plot each curve
                    for taskIdx = 1:length(selectedTaskIDs)
                        
                        % Plot line without markers
                        plot(ax, 1:length(offlineErrors{taskIdx}), offlineErrors{taskIdx}, ...
                            'Color', colors(taskIdx, :), ...
                            'LineStyle', lineStyles{mod(taskIdx-1, 4)+1}, ...
                            'LineWidth', lineWidth, ...
                            'DisplayName', displayName{taskIdx});
                    end
                    
                    % Formatting
                    set(ax, 'YScale', 'log', ...
                        'FontSize', 14, ...
                        'FontWeight', 'bold', ...
                        'LineWidth', 1.5);
                    
                    xlabel(ax, 'Fitness Evaluations', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    ylabel(ax, '$E_{o}$', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    title(ax, 'Comparison of $E_{o}$ Over Time Across Tasks', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    
                    box(ax, 'on');
                    
                    % Enhanced legend
                    legend(ax, 'Location', 'bestoutside', ...
                        'FontSize', 14, ...
                        'NumColumns', ceil(length(selectedTaskIDs)/20), ...
                        'EdgeColor', 'none', ...
                        'Box', 'off', ...
                        'Interpreter', 'none');
                    
                    % Axis limits
                    xlim(ax, [1 maxEvals]);
                    yRange = ylim(ax);
                    ylim(ax, [yRange(1)*0.7, yRange(2)*1.3]); % Wider margins
                    
                    % Add reference lines
                    plot(ax, [1 maxEvals], [yRange(1) yRange(1)], ':', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
                    plot(ax, [1 maxEvals], [yRange(2) yRange(2)], ':', 'Color', [0.5 0.5 0.5], 'LineWidth', 0.8, 'HandleVisibility', 'off');
                    
                    % uicontrol('Parent', fig, 'Style', 'checkbox', ...
                    %         'String', 'Show TaskID', 'Units', 'normalized', ...
                    %         'Position', [0.00, 0.95, 0.10, 0.05], 'Value', 0, ...
                    %         'Tooltip', 'Show TaskID', ...
                    %         'Callback', @(src, event) toggleTaskID(src));
    
                catch ME
                    errordlg(sprintf('Error: %s', ME.message), 'Plot Error');
                end
    
                function toggleTaskID(src)
                    lines = findobj(ax, 'Type', 'Line');
                    lines = flipud(lines);
                    if get(src, 'Value') == 1
                        newLabels = groupLabelsWithTaskID;
                    else
                        newLabels = groupLabelsWithoutTaskID;
                    end
                    for l = 1:min(length(lines), length(newLabels))
                        set(lines(l), 'DisplayName', newLabels{l});
                    end
                    legend(ax, 'off');
                    legend(ax, 'Location', 'bestoutside', ...
                        'FontSize', 11, ...
                        'NumColumns', ceil(length(selectedTaskIDs)/20), ...
                        'EdgeColor', 'none', ...
                        'Box', 'off', ...
                        'Interpreter', 'none');
                    legend(ax, 'show');
                end
            end

            function cancelCallback()
               % Cancel all pending futures.
               if  ~isempty(futures)
                    try
                        for idx = 1:length(futures)
                           cancel(futures(idx));
                        end
                    catch
                        if isvalid(dlg)
                            delete(dlg);
                            drawnow;
                        end    
                    end
               end
               
               % Close the progress dialog
               if isvalid(dlg)
                   delete(dlg);
                   drawnow;
               end
            end

            function updatePlotEoProgress(data)
                index = data.taskIdx;
                currentFE = data.DoneFE;
                processedFE(index) = currentFE;
                progressFraction = sum(processedFE) / totalFE;
                totalWidth = progressBG.Position(3);
                newWidth = progressFraction * totalWidth;
                progressFill.Position(3) = newWidth;
                progressLabel.Text = sprintf(' %.1f%%', progressFraction * 100);
                if strcmp('Completed', data.Status)
                    offlineErrors{index} = data.offlineError;
                end

                if progressFraction >= 1
                    delete(dlg);
                    drawnow;
                    pause(0.05);
                    plotEo();
                end

                drawnow;
            end
        end

        function plotMultiTaskIndicatorTrend(app, selectedTaskIDs, indicator, groupLabelsWithTaskID, groupLabelsWithoutTaskID)
            numTasks = length(selectedTaskIDs);
            trendData = cell(numTasks, 1);
            totalEnvs = 0;
            for i = 1:numTasks
                taskID = selectedTaskIDs{i};
                taskData = app.SATasks(taskID);
                trendData{i} = mean(taskData.Result.(indicator).trend);
            end
            if strcmp('FE based', app.SATasks(selectedTaskIDs{i}).Result.(indicator).type)
                plotIndicatorTrend(indicator, 'Fitness Evaluations');
            elseif strcmp('Environment based', app.SATasks(selectedTaskIDs{i}).Result.(indicator).type)
                plotIndicatorTrend(indicator, 'Environment Number');
            end

            function plotIndicatorTrend(indicator, type)
                try
                    fig = figure('Name', ...
                        sprintf('Trend of %s Over %s', indicator, type), ...
                        'NumberTitle', 'off', 'Position', [100 100 1000 600], 'Color', 'w', ...
                        'DefaultTextFontName', 'Times New Roman', ...
                        'DefaultAxesFontName', 'Times New Roman');
                    ax = axes('Parent', fig); hold(ax, 'on');
                    natureColors = lines(9);
                    numColors = size(natureColors, 1);
                    colors = natureColors(mod(0:length(selectedTaskIDs)-1, numColors) + 1, :);
                    lineStyles = {'-', '--', ':', '-.'};
                    lineWidth = 2.0;
                    displayName = groupLabelsWithoutTaskID;
                    for taskIdx = 1:length(selectedTaskIDs)
                        plot(ax, 1:length(trendData{taskIdx}), trendData{taskIdx}, ...
                            'Color', colors(taskIdx, :), ...
                            'LineStyle', lineStyles{mod(taskIdx-1, 4)+1}, ...
                            'LineWidth', lineWidth, ...
                            'DisplayName', displayName{taskIdx});
                    end
                    set(ax, 'YScale', 'log', 'FontSize', 12, 'FontWeight', 'bold', 'LineWidth', 1.5);
                    xlabel(ax, type, 'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    ylabel(ax, indicator, 'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    title(ax, sprintf('Trend of %s Over %s', indicator, type), 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    box(ax, 'on');
                    legend(ax, 'Location', 'bestoutside', 'FontSize', 11, ...
                        'NumColumns', ceil(length(selectedTaskIDs)/20), 'EdgeColor', 'none', 'Box', 'off', 'Interpreter', 'none');
        
                    % uicontrol('Parent', fig, 'Style', 'checkbox', 'String', 'Show TaskID', ...
                    %     'Units', 'normalized', 'Position', [0.00, 0.95, 0.10, 0.05], 'Value', 0, ...
                    %     'Tooltip', 'Show TaskID', 'Callback', @(src, event) toggleTaskID(src));
                catch ME
                    errordlg(sprintf('Error: %s', ME.message), 'Plot Error');
                end

                 function toggleTaskID(src)
                    lines = findobj(ax, 'Type', 'Line');
                    lines = flipud(lines);
                    newLabels = groupLabelsWithoutTaskID;
                    if get(src, 'Value') == 1
                        newLabels = groupLabelsWithTaskID;
                    end
                    for l = 1:min(length(lines), length(newLabels))
                        set(lines(l), 'DisplayName', newLabels{l});
                    end
                    legend(ax, 'off');
                    legend(ax, 'Location', 'bestoutside', 'FontSize', 11, ...
                        'NumColumns', ceil(length(selectedTaskIDs)/20), 'EdgeColor', 'none', 'Box', 'off', 'Interpreter', 'none');
                    legend(ax, 'show');
                 end
            end
        end

        function plotMultiTaskBestErrorBeforeChange(app, pool, selectedTaskIDs, groupLabelsWithTaskID, groupLabelsWithoutTaskID)
            numTasks = length(selectedTaskIDs);
            currentErrors = cell(numTasks, 1);
            runNumbers = zeros(numTasks, 1);
            changeFrequency = zeros(numTasks, 1);
            totalEnvs = 0;
            for i = 1:numTasks
                taskID = selectedTaskIDs{i};
                taskData = app.SATasks(taskID);
                currentErrors{i} = taskData.Result.CurrentError;
                changeFrequency(i) = taskData.BenchmarkParameters.ChangeFrequency.value;
                numFE = size(currentErrors{i}, 2);
                envIndices = changeFrequency(i):changeFrequency(i):numFE;
                if envIndices(end) ~= numFE
                    envIndices = [envIndices, numFE];
                end
                totalEnvs = totalEnvs + length(envIndices);
                runNumbers(i) = taskData.RunNumber;
            end
        
            processedEnvs = zeros(numTasks, 1);

            mainPos = app.UIFigure.Position;
            dlgWidth = 400;
            dlgHeight = 150;
            centerX = mainPos(1) + (mainPos(3) - dlgWidth) / 2;
            centerY = mainPos(2) + (mainPos(4) - dlgHeight) / 2;
            
            dlg = uifigure('Name','E_bbc Progress', ...
                'WindowStyle','modal', ...
                'Position',[centerX centerY dlgWidth dlgHeight], ...
                'Resize','off', ...
                'CloseRequestFcn', @(src, event) cancelCallback());

            uilabel(dlg, 'Text', 'Processing E_bbc...', 'Position', [20 100 360 30], 'FontSize', 12);
            progressLabel = uilabel(dlg, 'Text', '0%', 'Position', [20 70 360 30], 'FontSize', 12);
            progressBG = uipanel(dlg, 'Position',[20 60 360 20], 'BackgroundColor',[0.8 0.8 0.8], 'BorderType', 'none');
            progressFill = uipanel(progressBG, 'Position',[0 0 1 20], 'BackgroundColor',[0.2 0.7 0.2]);
            uibutton(dlg, 'Text', 'Cancel', 'Position', [150 15 100 30], 'ButtonPushedFcn', @(src,event) cancelCallback());
        
            dQueue = parallel.pool.DataQueue;
            afterEach(dQueue, @(data) updatePlotEbbcProgress(data));
            futures = parallel.FevalFuture.empty(0, numTasks);
            for i = 1:numTasks
                futures(i) = parfeval(pool, @GUIMode.computeBestErrorBeforeChange, 2, currentErrors{i}, changeFrequency(i), runNumbers(i), i, dQueue);
            end
        
            bestErrorBeforeChange = cell(numTasks, 1);
        
            function cancelCallback()
                if  ~isempty(futures)
                    try
                        for idx = 1:length(futures)
                           cancel(futures(idx));
                        end
                    catch
                        if isvalid(dlg)
                            delete(dlg);
                            drawnow;
                        end    
                    end
                    if isvalid(dlg)
                        delete(dlg);
                        drawnow;
                    end
                end
            end
        
            function updatePlotEbbcProgress(data)
                index = data.taskIdx;
                currentEnv = data.DoneEnv;
                processedEnvs(index) = currentEnv;
                progressFraction = sum(processedEnvs) / totalEnvs;
                totalWidth = progressBG.Position(3);
                newWidth = progressFraction * totalWidth;
                progressFill.Position(3) = newWidth;
                progressLabel.Text = sprintf(' %.1f%%', progressFraction * 100);
                if strcmp('Completed', data.Status)
                    bestErrorBeforeChange{index} = data.bestErrorBeforeChange;
                end
                if progressFraction >= 1
                    delete(dlg);
                    drawnow;
                    pause(0.05);
                    plotBBC();
                end
                drawnow;
            end
        
            function plotBBC()
                try
                    fig = figure('Name', 'Comparison of E_{bbc} Across Environments', ...
                        'NumberTitle', 'off', 'Position', [100 100 1000 600], 'Color', 'w', ...
                        'DefaultTextFontName', 'Times New Roman', ...
                        'DefaultAxesFontName', 'Times New Roman');
                    ax = axes('Parent', fig); hold(ax, 'on');
                    natureColors = lines(9);
                    numColors = size(natureColors, 1);
                    colors = natureColors(mod(0:length(selectedTaskIDs)-1, numColors) + 1, :);
                    lineStyles = {'-', '--', ':', '-.'};
                    lineWidth = 2.0;
                    displayName = groupLabelsWithoutTaskID;
                    for taskIdx = 1:length(selectedTaskIDs)
                        plot(ax, 1:length(bestErrorBeforeChange{taskIdx}), bestErrorBeforeChange{taskIdx}, ...
                            'Color', colors(taskIdx, :), ...
                            'LineStyle', lineStyles{mod(taskIdx-1, 4)+1}, ...
                            'LineWidth', lineWidth, ...
                            'DisplayName', displayName{taskIdx});
                    end
                    set(ax, 'YScale', 'log', 'FontSize', 14, 'FontWeight', 'bold', 'LineWidth', 1.5);
                    xlabel(ax, 'Environment Number', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    ylabel(ax, '$E_{bbc}$', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    title(ax, 'Comparison of $E_{bbc}$ Over Time Across Tasks', 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    box(ax, 'on');
                    legend(ax, 'Location', 'bestoutside', 'FontSize', 14, ...
                        'NumColumns', ceil(length(selectedTaskIDs)/20), 'EdgeColor', 'none', 'Box', 'off', 'Interpreter', 'none');
        
                    % uicontrol('Parent', fig, 'Style', 'checkbox', 'String', 'Show TaskID', ...
                    %     'Units', 'normalized', 'Position', [0.00, 0.95, 0.10, 0.05], 'Value', 0, ...
                    %     'Tooltip', 'Show TaskID', 'Callback', @(src, event) toggleTaskID(src)); 
                catch ME
                    errordlg(sprintf('Error: %s', ME.message), 'Plot Error');
                end

                 function toggleTaskID(src)
                    lines = findobj(ax, 'Type', 'Line');
                    lines = flipud(lines);
                    newLabels = groupLabelsWithoutTaskID;
                    if get(src, 'Value') == 1
                        newLabels = groupLabelsWithTaskID;
                    end
                    for l = 1:min(length(lines), length(newLabels))
                        set(lines(l), 'DisplayName', newLabels{l});
                    end
                    legend(ax, 'off');
                    legend(ax, 'Location', 'bestoutside', 'FontSize', 11, ...
                        'NumColumns', ceil(length(selectedTaskIDs)/20), 'EdgeColor', 'none', 'Box', 'off', 'Interpreter', 'none');
                    legend(ax, 'show');
                 end

            end
        end

        function plotMetricBoxplotsWithNotch(app, selectedTaskIDs)
            % Create a progress dialog in English
            progressDialog = uiprogressdlg(app.UIFigure, 'Title', 'Generating Boxplots', ...
                'Message', 'Processing data...', 'Indeterminate', 'on');
            
            indicators = {}; 
            for ii = 1:numel(app.IntersectIndicatorsCheckboxes)
                if app.IntersectIndicatorsCheckboxes(ii).Value
                    indicators{end+1} = app.IntersectIndicatorsItem{ii};
                end
            end
            if isempty(indicators)
                error('No indicators selected');
            end

            commonParams = getCommonAlgParametersInTasks(app, selectedTaskIDs);
            commonParams = cellfun(@(x) ['Parameters:', x], commonParams, 'UniformOutput', false);
            if iscell(commonParams)
                commonParams = [{'Algorithm'}, commonParams(:)'];
            else
                commonParams = {'Algorithm'};
            end

            [selectedParam, isOK] = listdlg(...
            'Name', 'Selection',...
            'PromptString', 'Your selection will determine which parameter is used for the x-axis in the boxplot:',...
            'SelectionMode', 'single',...
            'ListString', commonParams,...
            'ListSize', [450 200], ...
            'OKString', 'Confirm Selection',...
            'CancelString', 'Cancel');
            if ~isOK || isempty(selectedParam)
                close(progressDialog);
                return; 
            end
            selectedX = commonParams{selectedParam};
            if ~strcmp(selectedX, 'Algorithm')
                fieldNameParam = extractAfter(selectedX, length('Parameters:'));
            else
                fieldNameParam = selectedX;
            end            
            groupLabels = cell(length(selectedTaskIDs), 1);
            for i = 1:length(selectedTaskIDs)
                taskID = selectedTaskIDs{i};
                taskData = app.SATasks(taskID);
                if strcmp(selectedX, 'Algorithm')
                    groupLabels{i} = taskData.Algorithm;
                else
                    if isfield(taskData.AlgorithmParameters, fieldNameParam)
                        paramVal = taskData.AlgorithmParameters.(fieldNameParam).value;
                        if isnumeric(paramVal)
                            groupLabels{i} = num2str(paramVal);
                        else
                            groupLabels{i} = char(paramVal);
                        end
                    else
                        groupLabels{i} = 'Unknown';
                    end
                end
            end

            groupLabelsWithoutTaskID = groupLabels;
            groupLabelsWithTaskID = groupLabels;
            for i = 1:length(selectedTaskIDs)
                taskID = selectedTaskIDs{i};
                groupLabelsWithTaskID{i} = sprintf('%s (%s)', groupLabels{i}, taskID);
                indices = find(strcmp(groupLabels, groupLabels{i}));
                if numel(indices) > 1
                    groupLabelsWithoutTaskID{i} = sprintf('%s (%s)', groupLabels{i}, taskID);
                end
            end

            groupLabelsMapWithoutTaskID = containers.Map();
            groupLabelsMapWithTaskID = containers.Map();
            for i = 1:length(selectedTaskIDs)
                groupLabelsMapWithoutTaskID(selectedTaskIDs{i}) = groupLabelsWithoutTaskID{i};
                groupLabelsMapWithTaskID(selectedTaskIDs{i}) = groupLabelsWithTaskID{i};
            end
            try
                for idx = 1:length(indicators)
                    indicator = indicators{idx};
                    medians.(indicator) = zeros(length(selectedTaskIDs), 1);
                    % --- Collect indicator data and calculate medians ---
                    for taskIdx = 1:length(selectedTaskIDs)
                       taskID = selectedTaskIDs{taskIdx};
                       taskData = app.SATasks(taskID);
                       allresults = taskData.Result.(indicator).AllResults; % Results from multiple runs
                       medians.(indicator)(taskIdx) = median(allresults);
                    end
                    % Sort tasks based on indicator medians
                    [~, sortedIdx] = sort(medians.(indicator));
                    sortedTaskIDs = selectedTaskIDs(sortedIdx);
                    % Reorganize indicator data based on sorted tasks, using selected parameter for grouping
                    all = [];
                    groupsWithoutTaskID = {};
                    groupsWithTaskID = {};
                    for taskIdx = 1:length(sortedTaskIDs)
                        taskID = sortedTaskIDs{taskIdx};
                        taskData = app.SATasks(taskID);
                        allresults = taskData.Result.(indicator).AllResults;
                        all = [all; allresults']; % Ensure it's a column vector
                        groupValWithoutTaskID = groupLabelsMapWithoutTaskID(taskID);
                        groupsWithoutTaskID = [groupsWithoutTaskID; repmat({groupValWithoutTaskID}, length(allresults), 1)];
                        groupValWithTaskID = groupLabelsMapWithTaskID(taskID);
                        groupsWithTaskID = [groupsWithTaskID; repmat({groupValWithTaskID}, length(allresults), 1)];
                    end
                    % --- Create boxplot for indicator ---
                    fig = figure('Name', sprintf('%s Comparison', indicator), ...
                        'NumberTitle', 'off', ...
                        'Position', [100 100 1000 600], ...
                        'Color', 'w', ...
                        'DefaultTextFontName', 'Times New Roman', ...
                        'DefaultAxesFontName', 'Times New Roman');
                    
                    ax = axes('Parent', fig);
                    boxplot(ax, all, groupsWithoutTaskID, 'Notch', 'on');
                    title(ax, sprintf('Comparison of %s by %s', sprintf('$%s$', regexprep(indicator, '_(\w+)', '_{$1}')), sprintf('$%s$', regexprep(selectedX, '_(\w+)', '_{$1}'))), 'FontSize', 14, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    xlabel(ax, sprintf('$%s$', regexprep(selectedX, '_(\w+)', '_{$1}')), 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');
                    ylabel(ax, sprintf('$%s$', regexprep(indicator, '_(\w+)', '_{$1}')), 'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'latex');

                    set(ax, 'FontSize', 16, 'FontWeight', 'bold', 'LineWidth', 1.5);
                    if length(unique(groupsWithoutTaskID)) > 5
                        xtickangle(ax, 45);
                    end
    
                    % uicontrol('Parent', fig, 'Style', 'checkbox', ...
                    %     'String', 'Show TaskID', 'Units', 'normalized', ...
                    %     'Position', [0.00, 0.95, 0.10, 0.05], 'Value', 0, ...
                    %     'Tooltip', 'Show TaskID', ...
                    %     'Callback', @(src, event) toggleTaskID(src, ax, groupsWithTaskID, groupsWithoutTaskID));    
                end
                
            catch ME
                errordlg(sprintf('Error: %s', ME.message), 'Plot Error');
            end
            
            close(progressDialog);

            function toggleTaskID(src, boxplot, xtickWithTaskID, xtickWithoutTaskID)
                if get(src, 'Value') == 1
                    boxplot.XTickLabel = unique(xtickWithTaskID, 'stable');
                else
                    boxplot.XTickLabel = unique(xtickWithoutTaskID, 'stable');
                end
            end
        end

        function commonParams = getCommonAlgParametersInTasks(app, selectedtaskIDs)
            if isempty(selectedtaskIDs)
                commonParams = {};
                return
            end

            AlgNames = cell(length(selectedtaskIDs), 1);
            for i = 1:length(selectedtaskIDs)
                AlgNames{i} = app.Tasks(selectedtaskIDs{i}).Algorithm;
            end
            
            if ~all(strcmp(AlgNames{1}, AlgNames))
                commonParams = {};
                return
            end
        
            allParams = cell(length(selectedtaskIDs), 1);
            for i = 1:length(selectedtaskIDs)
                if isfield(app.Tasks(selectedtaskIDs{i}), 'AlgorithmParameters')
                    params = fieldnames(app.Tasks(selectedtaskIDs{i}).AlgorithmParameters);
                    allParams{i} = params(:);
                else
                    allParams{i} = {};
                end
            end
        
            if isempty(allParams)
                commonParams = {};
            else
                commonParams = allParams{1};
                for i = 2:length(allParams)
                    commonParams = intersect(commonParams, allParams{i});
                end
            end
        end

        function runSelectedUncompletedTasks(app, ~)
            try
                % Close the detail of task
                if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                    delete(app.TaskBubble);
                end
        
                drawnow;
        
                uncompletedData = app.UncompletedTasksTable.Data;
                selectedTaskIDs = {};
                for i = 1:size(uncompletedData, 1)
                    isChecked = uncompletedData{i, 1};
                    if islogical(isChecked) && isChecked
                        selectedTaskIDs{end+1} = uncompletedData{i, 2};
                    end
                end
        
                if isempty(selectedTaskIDs)
                    uialert(app.UIFigure, ...
                        'Please select at least one task to run.', ...
                        'No Task Selected', ...
                        'Icon', 'warning', ...
                        'Modal', true);
                    return;
                end
        
                uncompletedTaskList = {};
                for i = 1:length(selectedTaskIDs)
                    taskID = selectedTaskIDs{i};
                    taskData = app.Tasks(taskID);
                    if ~strcmp(taskData.Status, 'Completed')
                        taskData.Status = 'Queued';
                        taskData.Progress = 'Ready for Run';
                        app.Tasks(taskID) = taskData;
                        uncompletedTaskList{end+1} = taskData;
                    end
                end
        
                app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
                drawnow;
        
                numUncompleted = length(uncompletedTaskList);
                if numUncompleted == 0
                    uialert(app.UIFigure, 'There are no tasks to run!', 'Warning', ...
                        'Icon', 'warning');
                    return;
                end
        
                pool = setParallelPool(app);
        
                if strcmp(app.RunButton.Text, 'Run Selected Tasks')
                    app.RunButton.Text = 'Stop Tasks';
                    app.RunButton.BackgroundColor = [1 0 0];
                    app.AddTaskButton.Enable = 'off';
                    app.AlgorithmList.Enable = 'off';
                    app.BenchmarkList.Enable = 'off';
                    app.RunNumberSpinner.Enable = 'off';
                    app.FastDeletePendingButton.Enable = 'off';
                    app.ThreadsInput.Enable = 'off';
                    app.CleanRAMButton.Enable = 'off';
                    app.UseLogicalCheckbox.Enable = 'off';
                    app.PoolTypeDropdown.Enable = 'off';
                    app.RunButton.ButtonPushedFcn = @(~,~) stopTasks(app);
                    app.RunButton.Tooltip = 'Click to stop the running tasks';
                    app.RunButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'stop.png');
                end
        
                progressQueue = parallel.pool.DataQueue;
                afterEach(progressQueue, @(data) updateProgress(app, data));
        
                app.NumberRunningTasks = numUncompleted;
                disp(['Starting parallel execution of ', num2str(numUncompleted), ' tasks...']);
                app.Futures = parallel.FevalFuture.empty(0, numUncompleted);
                for i = 1:numUncompleted
                    task = uncompletedTaskList{i};
                    app.Futures(i) = parfeval(pool, @GUIMode.executeTask, 0, task, task.TaskID, progressQueue);
                end
        
            catch ME
                handleTaskError(app, ME);
                cleanupExperimental(app);
            end
        end


        function cleanupExperimental(app)
            % Close the detail of task
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble); 
            end

            app.RunButton.Text = 'Run Selected Tasks';
            app.RunButton.BackgroundColor = [0.96, 0.96, 0.96];
            app.RunButton.ButtonPushedFcn = @(~,~) runSelectedUncompletedTasks(app);
            app.RunButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'run.png');
            app.RunButton.Tooltip = 'Click to start running the above tasks in parallel';
            % Enable all controls
            app.AddTaskButton.Enable = 'on';
            app.AlgorithmList.Enable = 'on';
            app.BenchmarkList.Enable = 'on';
            app.RunNumberSpinner.Enable = 'on';
            app.FastDeletePendingButton.Enable = 'on';
            app.ThreadsInput.Enable = 'on';
            app.UseLogicalCheckbox.Enable = 'on';
            app.PoolTypeDropdown.Enable = 'on';
            pool = gcp('nocreate');
            if isempty(pool)
                app.CleanRAMButton.Enable = "off";
            else
                app.CleanRAMButton.Enable = "on";
            end
            drawnow
        end

        function cleanupEducational(app)
            % Close the detail of task
            if isprop(app, 'TaskBubble') && ~isempty(app.TaskBubble)
                delete(app.TaskBubble);
            end

            app.EducationalRunButton.Text = 'Run';
            app.EducationalRunButton.Enable = 'on';
            app.EducationalRunButton.BackgroundColor = [0.96, 0.96, 0.96]; % 默认灰色
            app.EducationalRunButton.ButtonPushedFcn = @(~,~) runEducationalTask(app); % 重新绑定运行任务回调
            app.EducationalRunButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'run.png');
            % Enable all controls
            app.EducationalAlgorithmList.Enable = 'on';
            app.EducationalBenchmarkList.Enable = 'on';
            % close(app.EducationalDialog)
            drawnow
        end

        function errorList = checkTaskError(app)
            errorList = {};
            TaskKeys = keys(app.Tasks);
            for i = 1:length(TaskKeys)
                task = getTask(app, TaskKeys{i});
                if strcmp(task.Status, 'Error')
                    errorList{end+1} = task.Progress;
                end
            end
        end

        function handleTaskError(app, ME)
            % Determine the error type based on the error identifier
            if contains(ME.identifier, 'parallel:threadpool:DisallowedMexFunction')
                % Specific error for invoking a MEX function in a thread pool
                uialert(app.UIFigure, ...
                    sprintf(['The FPs run failed because it uses MEX functions, which are not permitted in thread pools.\n\n' ...
                             'Error Identifier: %s\n\nPlease switch to process pool for proper execution.'], ME.identifier), ...
                    'Parallel Benchmark Warning', 'Icon', 'warning');
                app.PoolTypeDropdown.Value = 'threads';
                app.NowPoolType = 'threads';
                
            elseif contains(ME.identifier, 'parallel:pool:WorkerRestartFailure')
                % Error when a worker restart fails in the pool
                uialert(app.UIFigure, ...
                    sprintf('Worker restart failed.\n\nError Identifier: %s\n\nPlease check your parallel configuration.', ME.identifier), ...
                    'Worker Restart Error', 'Icon', 'error');
                
            elseif contains(ME.identifier, 'parallel:pool:Timeout')
                % Error when a task times out in the parallel pool
                uialert(app.UIFigure, ...
                    sprintf('The operation has timed out.\n\nError Identifier: %s\n\nConsider increasing timeout settings or verifying task complexity.', ME.identifier), ...
                    'Timeout Error', 'Icon', 'error');
                
            elseif contains(ME.identifier, 'parallel:pool:JobCancelled')
                % Error when a parallel job is cancelled
                uialert(app.UIFigure, ...
                    sprintf('The parallel job was cancelled.\n\nError Identifier: %s\n\nVerify that all tasks are configured to run properly.', ME.identifier), ...
                    'Job Cancellation', 'Icon', 'error');
                
            else
                % Default error handling for other cases
                uialert(app.UIFigure, ...
                    sprintf('An unexpected error occurred:\n\n%s\n\nError Identifier: %s', ME.message, ME.identifier), ...
                    'Execution Error', 'Icon', 'error');
            end
        end

        % stop all tasks
        function stopTasks(app)
            % Cancel all Future tasks
            if ~isempty(app.Futures)
                cancel(app.Futures);
            end
            taskIDs = keys(app.Tasks);
            numTasks = length(taskIDs);

            for i = 1:numTasks
                taskID = taskIDs{i};
                taskData = app.Tasks(taskID);
                % Only update tasks that are not already completed
                if ~strcmp(taskData.Status, 'Completed') && ~strcmp(taskData.Status, 'New') && ~strcmp(taskData.Status, 'Error')
                    taskData.Status = 'Cancelled';
                    taskData.Progress = 'Cancelled By User';
                    app.Tasks(taskID) = taskData;
                end
            end
            app.NumberRunningTasks = 0;
   
            app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
            drawnow;
            cleanupExperimental(app);
        end
        % Update progress callback function
        function updateProgress(app, data)
            TaskID = data.TaskID;
            TaskValue = app.Tasks(TaskID);
            if isfield(data, 'Status')
                TaskValue.Status = data.Status;
                if strcmp(data.Status, 'Error')
                    app.NumberRunningTasks = app.NumberRunningTasks - 1;
                end
            end
            
            if isfield(data, 'Progress')
                TaskValue.Progress = data.Progress;
                if contains(TaskValue.Progress, 'parallel')
                    
                end
            end
            
            if isfield(data, 'Result')
                TaskValue.Result = data.Result;
                app.Tasks(TaskID) = TaskValue;
                getCompletedTasksTable(app);
                app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
                app.SATasksTable.Data = getSATasksTable(app);
                app.NumberRunningTasks = app.NumberRunningTasks - 1;
                updateUnionIndicatorsList(app);
            else
                app.Tasks(TaskID) = TaskValue;
                app.UncompletedTasksTable.Data = getUncompletedTasksTable(app);
            end
            if (app.NumberRunningTasks == 0)
                cleanupExperimental(app);
                errorList = checkTaskError(app);
                if ~isempty(errorList)
                    for i = 1:length(errorList)
                        if strcmp(errorList{i}, 'parallel:threadpool:DisallowedMexFunction')
                            ME.identifier = 'parallel:threadpool:DisallowedMexFunction';
                            handleTaskError(app, ME);
                        end
                    end
                end
            end
            drawnow;
        end

        function ResultsFields = getResultFieldUnion(app)
            baseFields = {'Problem', 'CurrentError', 'VisualizationInfo', 'Iteration'};
            ResultsFields = {};
            taskIDs = keys(app.Tasks);
            numTasks = length(taskIDs);
            
            for idx = 1:numTasks
                taskID = taskIDs{idx};
                if isfield(app.Tasks(taskID), 'Result') && ~isempty(app.Tasks(taskID).Result)
                    resultFields = fieldnames(app.Tasks(taskID).Result);
                    currentFields = setdiff(resultFields, baseFields, 'stable');
                    for i = 1:numel(currentFields)
                        field = currentFields{i};
                        if ~ismember(field, ResultsFields)
                            ResultsFields{end+1} = field;
                        end
                    end
                end
            end
        end

        function ResultsFields = getResultFieldIntersect(app)
            baseFields = {'Problem', 'CurrentError', 'VisualizationInfo', 'Iteration'};
            taskIDs = keys(app.SATasks);
            numTasks = length(taskIDs);
            ResultsFields = {};
            
            % Initialize the intersection with the first task that has a non-empty Result.
            initFound = false;
            for idx = 1:numTasks
                taskID = taskIDs{idx};
                if isfield(app.Tasks(taskID), 'Result') && ~isempty(app.Tasks(taskID).Result)
                    resultFields = fieldnames(app.Tasks(taskID).Result);
                    currentFields = setdiff(resultFields, baseFields, 'stable'); % keep order
                    ResultsFields = currentFields;
                    initFound = true;
                    break;
                end
            end
            if ~initFound
                return;  % No tasks with a valid Result field.
            end
            
            % Intersect with subsequent tasks' Result fields
            for idx = idx+1:numTasks
                taskID = taskIDs{idx};
                if isfield(app.Tasks(taskID), 'Result') && ~isempty(app.Tasks(taskID).Result)
                    resultFields = fieldnames(app.Tasks(taskID).Result);
                    currentFields = setdiff(resultFields, baseFields, 'stable');
                    ResultsFields = intersect(ResultsFields, currentFields, 'stable');
                end
            end
        end

    end

    % Methods for Educational Module
    methods (Access = private)
        function updateEducationalAlgParameterUI(app)
            selectedAlgorithm = app.EducationalAlgorithmList.Value;
            ConfigurableParameters = getAlgConfigurableParameters(selectedAlgorithm);
            paramNames = fieldnames(ConfigurableParameters);
        
            if isprop(app, 'EducationalConfigurableAlgorithmParameters') && ~isempty(app.EducationalConfigurableAlgorithmParameters)
                existingFields = fieldnames(app.EducationalConfigurableAlgorithmParameters);
                for i = 1:length(existingFields)
                    if isfield(app.EducationalConfigurableAlgorithmParameters, existingFields{i}) ...
                            && isvalid(app.EducationalConfigurableAlgorithmParameters.(existingFields{i}))
                        delete(app.EducationalConfigurableAlgorithmParameters.(existingFields{i}));
                    end
                end
                app.EducationalConfigurableAlgorithmParameters = struct();
            end
        
            if isvalid(app.EducationalAlgorithmParametersPanel)
                delete(allchild(app.EducationalAlgorithmParametersPanel));
            end
        
            paramGrid = uigridlayout(app.EducationalAlgorithmParametersPanel, 'Scrollable', 'on');
            paramGrid.RowHeight = repmat({20}, length(paramNames), 1);
            paramGrid.ColumnWidth = {'1x', 120};
        
            for i = 1:length(paramNames)
                paramName = paramNames{i};
                paramValue = ConfigurableParameters.(paramName);
        
                tooltipText = paramName;
                if isfield(paramValue, 'description')
                    tooltipText = paramValue.description;
                end
                label = uilabel(paramGrid, 'Text', paramName, 'Tooltip', tooltipText);
                label.Layout.Row = i;
                label.Layout.Column = 1;
        
                if isstruct(paramValue)
                    switch paramValue.type
                        case 'integer'
                            ui = uispinner(paramGrid, ...
                                'Value', paramValue.value, ...
                                'Limits', paramValue.range, ...
                                'Step', 1);
                        case 'numeric'
                            ui = uieditfield(paramGrid, 'numeric', ...
                                'Value', paramValue.value);
                        case 'option'
                            ui = uidropdown(paramGrid, ...
                                'Items', paramValue.options, ...
                                'Value', paramValue.value);
                        case 'boolean'
                            ui = uicheckbox(paramGrid, 'Text', '', 'Value', paramValue.value);
                    end
        
                    ui.Layout.Row = i;
                    ui.Layout.Column = 2;
        
                    app.EducationalConfigurableAlgorithmParameters.(paramName) = ui;
                end
            end
        end

        function updateEducationalProParameterUI(app)
            selectedBenchmark = app.EducationalBenchmarkList.Value;
            ConfigurableParameters = getProConfigurableParameters(selectedBenchmark);
            paramNames = fieldnames(ConfigurableParameters);
        
            % Clear old UI controls
            if isprop(app, 'EducationalConfigurableBenchmarkParameters') && ~isempty(app.EducationalConfigurableBenchmarkParameters)
                existingFields = fieldnames(app.EducationalConfigurableBenchmarkParameters);
                for i = 1:length(existingFields)
                    if isfield(app.EducationalConfigurableBenchmarkParameters, existingFields{i}) ...
                            && isvalid(app.EducationalConfigurableBenchmarkParameters.(existingFields{i}))
                        delete(app.EducationalConfigurableBenchmarkParameters.(existingFields{i}));
                    end
                end
                app.EducationalConfigurableBenchmarkParameters = struct();
            end
            if isvalid(app.EducationalBenchmarkParametersPanel)
                delete(allchild(app.EducationalBenchmarkParametersPanel));
            end
        
            paramGrid = uigridlayout(app.EducationalBenchmarkParametersPanel, 'Scrollable', 'on');
            paramGrid.RowHeight = repmat({20}, length(paramNames), 1);
            paramGrid.ColumnWidth = {'1x', 120};
        
            for i = 1:length(paramNames)
                paramName = paramNames{i};
                paramValue = ConfigurableParameters.(paramName);
        
                tooltipText = paramName;
                if isfield(paramValue, 'description')
                    tooltipText = paramValue.description;
                end
                label = uilabel(paramGrid, 'Text', paramName, 'Tooltip', tooltipText);
                label.Layout.Row = i;
                label.Layout.Column = 1;
                if strcmp(paramName, 'Dimension')
                    ui = uispinner(paramGrid, ...
                        'Value', 2, ...
                        'Limits', [1 100], ... 
                        'Step', 1, ...
                        'Enable', 'off');
                elseif strcmp(paramName, 'EnvironmentNumber')
                    ui = uispinner(paramGrid, ...
                        'Value', 10, ...
                        'Limits', paramValue.range, ...
                        'Step', 1);
                elseif isstruct(paramValue)
                    switch paramValue.type
                        case 'integer'
                            ui = uispinner(paramGrid, ...
                                'Value', paramValue.value, ...
                                'Limits', paramValue.range, ...
                                'Step', 1);
                        case 'numeric'
                            ui = uieditfield(paramGrid, 'numeric', ...
                                'Value', paramValue.value);
                        case 'option'
                            ui = uidropdown(paramGrid, ...
                                'Items', paramValue.options, ...
                                'Value', paramValue.value);
                        case 'boolean'
                            ui = uicheckbox(paramGrid, 'Text', '', 'Value', paramValue.value);                            
                    end
                end
                ui.Layout.Row = i;
                ui.Layout.Column = 2;
               
                app.EducationalConfigurableBenchmarkParameters.(paramName) = ui;
            end
        end

        function setInitStatus(app)
            app.EducationalPlayButton.Text = 'Play';
            app.EducationalPlayButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'start.png');
            app.EducationalPlayButton.Enable = 'off';
            app.EducationalIterInput.Enable = 'off';
            app.EducationalResetButton.Enable = 'off';
            app.EducationalResizeButton.Enable = 'off';
            app.EducationalSlider.Enable = 'off';
            app.EducationalSpeedDropdown.Enable = 'off';

            app.EducationalRunButton.Text = 'Run';
            app.EducationalRunButton.Enable = "on";
            app.EducationalAlgorithmList.Enable = 'on';
            app.EducationalBenchmarkList.Enable = 'on';
        end

        function setPlayStatus(app)
            disableDefaultInteractivity(app.EducationalUIAxes);
            disableDefaultInteractivity(app.EducationalUIAxes2);
            app.EducationalUIAxes.Interactions = [];
            app.EducationalUIAxes2.Interactions = [];
            app.EducationalPlayButton.Text = 'Pause';
            app.EducationalPlayButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'stop.png');
            app.EducationalPlayButton.Enable = 'on';
            app.EducationalRunButton.Text = 'Run';
            app.EducationalRunButton.Enable = 'off';
            app.EducationalAlgorithmList.Enable = 'off';
            app.EducationalBenchmarkList.Enable = 'off';
            app.EducationalIterInput.Enable = 'off';

            app.EducationalResetButton.Enable = 'on';
            app.EducationalResizeButton.Enable = 'on';
            app.EducationalSlider.Enable = 'on';
            app.EducationalSpeedDropdown.Enable = 'on';
            drawnow;
        end

        function setUnplayStatus(app)
            enableDefaultInteractivity(app.EducationalUIAxes);
            enableDefaultInteractivity(app.EducationalUIAxes2);
            app.EducationalUIAxes.Interactions = app.DefaultInteractions_1;
            app.EducationalUIAxes2.Interactions = app.DefaultInteractions_2;
            app.EducationalUIAxes.Toolbar.Visible = 'on';
            app.EducationalPlayButton.Text = 'Play';
            app.EducationalPlayButton.Icon = fullfile(app.projectPath, 'Utility', 'GUI', 'icons', 'start.png');
            app.EducationalPlayButton.Enable = 'on';
            app.EducationalRunButton.Text = 'Run';
            app.EducationalRunButton.Enable = "on";
            app.EducationalAlgorithmList.Enable = 'on';
            app.EducationalBenchmarkList.Enable = 'on';
            app.EducationalIterInput.Enable = 'on';

            app.EducationalResetButton.Enable = 'on';
            app.EducationalSlider.Enable = 'on';
            app.EducationalSpeedDropdown.Enable = 'on';
            drawnow;
        end

        function runEducationalTask(app)
            try
                % clear exist data
                cla(app.EducationalUIAxes);
                cla(app.EducationalUIAxes2);
                app.VisualizationData = '';
                app.CurrentError = '';
                app.TotalIter = '';

                algName = app.EducationalAlgorithmList.Value;
                probName = app.EducationalBenchmarkList.Value;
                runNum = 1;
                algParams = struct();
                algParamNames = fieldnames(app.EducationalConfigurableAlgorithmParameters);
                for i = 1:length(algParamNames)
                    paramName = algParamNames{i};
                    algParams.(paramName).value = app.EducationalConfigurableAlgorithmParameters.(paramName).Value;
                end
                probParams = struct();
                probParamNames = fieldnames(app.EducationalConfigurableBenchmarkParameters);
                for i = 1:length(probParamNames)
                    paramName = probParamNames{i};
                    probParams.(paramName).value = app.EducationalConfigurableBenchmarkParameters.(paramName).Value;
                end
                pool = gcp('nocreate'); % Get current parallel pool
                if isempty(pool) % No pool exists, start a new one
                    progressDialog = uiprogressdlg(app.UIFigure, ...
                        'Title', 'Please Wait', ...
                        'Message', sprintf('Starting %s pool with %d workers...', app.PoolTypeDropdown.Value, app.UserSettingNumberThreads), ...
                        'Indeterminate', 'on');
                    try
                        pool = parpool(app.PoolTypeDropdown.Value, app.UserSettingNumberThreads);
                    catch
                        close(progressDialog);
                        uialert(app.UIFigure, ...
                            sprintf('Failed to start the %s pool with the specified configuration. A default pool has been started instead.', app.PoolTypeDropdown.Value), ...
                            'Warning', 'Icon', 'warning');
                        progressDialog = uiprogressdlg(app.UIFigure, ...
                            'Title', 'Please Wait', ...
                            'Message', sprintf('Starting %s pool with default workers...', app.PoolTypeDropdown.Value), ...
                            'Indeterminate', 'on');
                        pool = parpool(app.PoolTypeDropdown.Value);
                        app.ThreadsInput.Value = pool.NumWorkers;
                        app.UserSettingNumberThreads = app.ThreadsInput.Value;
                    end
                    app.NowPoolType = app.PoolTypeDropdown.Value;
                    close(progressDialog);
                end

                mainPos = app.UIFigure.Position;
                dlgWidth = 400;
                dlgHeight = 150;
                centerX = mainPos(1) + (mainPos(3) - dlgWidth) / 2;
                centerY = mainPos(2) + (mainPos(4) - dlgHeight) / 2;
                
                dlg = uifigure('Name','Educational Task Progress', ...
                    'WindowStyle','modal', ...
                    'Position',[centerX centerY dlgWidth dlgHeight], ...
                    'Resize','off', ...
                    'CloseRequestFcn', @(src, event) cancelCallback());
                
                uilabel(dlg, ...
                    'Text', 'Educational Task is Running...', ...
                    'Position', [20 100 360 30], ...
                    'FontSize', 12);
    
    
                progressLabel = uilabel(dlg, ...
                    'Text', '0%', ...
                    'Position', [20 70 360 30], ...
                    'FontSize', 12);
                
                progressBG = uipanel(dlg, ...
                    'Position',[20 60 360 20], ...
                    'BackgroundColor',[0.8 0.8 0.8], ...
                    'BorderType', 'none');
                
                progressFill = uipanel(progressBG, ...
                    'Position',[0 0 1 20], ...
                    'BackgroundColor',[0.2 0.7 0.2]);  % 绿色
                
                uibutton(dlg, 'Text', 'Cancel', ...
                    'Position', [150 15 100 30], ...
                    'ButtonPushedFcn', @(src,event) cancelCallback());
                
                progressQueue = parallel.pool.DataQueue;
                afterEach(progressQueue, @(data) updateEducationalProgress(app, data));
                newFuture = parfeval(pool, @GUIMode.executeEducationalTask, 0, algName, ...
                    probName, runNum, probParams, algParams, progressQueue);
                app.Futures = [app.Futures, newFuture];
                app.EducationalRunButton.Enable = 'off';
                app.EducationalAlgorithmList.Enable = 'off';
                app.EducationalBenchmarkList.Enable = 'off';
            catch ME
                handleTaskError(app, ME)
                cleanupEducational(app);
                delete(dlg);
            end

            function updateEducationalProgress(app, data)
                app.EducationalRunButton.Text = data.Status;
                % if isfield(data, 'Status') && strcmp(data.Status, 'Started')
                %     app.EducationalDialog = uiprogressdlg(app.UIFigure, 'Title', 'Please Wait', ...
                %         'Message', 'Educational Task is Running...', 'Indeterminate', 'on');
                % end
                if isfield(data, 'Progress')
                    progressFraction = str2double(erase(data.Progress, '%'))/100;
                    totalWidth = progressBG.Position(3);
                    newWidth = progressFraction * totalWidth;
                    progressFill.Position(3) = newWidth;
                    progressLabel.Text = sprintf(' %.1f%%', progressFraction * 100);
                end
    
                if isfield(data, 'Status') && strcmp(data.Status, 'Error')
                    % close(app.EducationalDialog);
                    delete(dlg);
                    if strcmp('parallel:threadpool:DisallowedMexFunction', data.Progress)
                        selection = uiconfirm(app.UIFigure, ...
                            sprintf(['The FPs run failed because it uses MEX functions, which are not permitted in thread pools.\n\n' ...
                                     'Error Identifier: %s\n\nDo you want to switch to *process pool* for proper execution?'], data.Progress), ...
                            'Parallel Benchmark Warning', ...
                            'Options', {'Confirm', 'Cancel'}, ...
                            'DefaultOption', 'Confirm', ...
                            'Icon', 'warning');
    
                        if strcmp(selection, 'Confirm')
                            if app.EducationalTryCount < 1
                                app.PoolTypeDropdown.Value = 'processes';
                                app.NowPoolType = 'processes';
                                delete(gcp('nocreate'));
                                setParallelPool(app);
                                app.EducationalTryCount = app.EducationalTryCount + 1;
                                runEducationalTask(app);
                            else
                                uialert(app.UIFigure, ...
                                   'The benchmark failed multiple times due to MEX incompatibility with thread pools. Please manually switch to *process pool* and retry.', ...
                                   'Switch Required', ...
                                   'Icon', 'warning');
                                app.EducationalTryCount = 0;
                            end
                        end      
                    end
                    cleanupEducational(app);
                end
    
                if isfield(data, 'Result')
                    delete(dlg);
                    % close(app.EducationalDialog);
                    setUnplayStatus(app);
    
                    app.VisualizationData = {data.Result.VisualizationInfo};
                    app.CurrentError = {data.Result.CurrentError};
                    app.TotalIter = data.Result.Iteration;
    
                    app.EducationalTryCount = 0;
                    app.CurrentIter = 1;
                    app.EducationalSlider.Limits = [1 app.TotalIter];
                    app.EducationalSlider.Value = 1;
    
                    app.EducationalIterInput.Limits = [1 app.TotalIter];
                    app.EducationalIterInput.Value = 1;
                    
                    educationalPlayCallback(app);
                end
            end

            function cancelCallback()
               try
                   cancel(newFuture);
               catch
                   if isvalid(dlg)
                       delete(dlg);
                       drawnow;
                   end    
               end
               if isvalid(dlg)
                   delete(dlg);
                   drawnow;
               end
               cleanupEducational(app);
               setInitStatus(app);
            end
        end

        function updateVisualization(app, refreshFlag)
            % Get current iteration data
            iter = app.CurrentIter;
            info = app.VisualizationData{1}{iter};
            
            % If there is no contour data from the last time, or if the current data is inconsistent with the last, redraw the contours
            needRedrawContour = true;
            if isprop(app, 'PreviousContourT') && isprop(app, 'PreviousContourF')
                if isequal(app.PreviousContourT, info.T) && isequal(app.PreviousContourF, info.F)
                    needRedrawContour = false;
                end
            end
        
            if needRedrawContour || refreshFlag
                cla(app.EducationalUIAxes);
                contour(app.EducationalUIAxes, info.T, info.T, info.F, 25);
                hold(app.EducationalUIAxes, 'on');

                % Plot peak points
                for ii = 1:length(info.Problem.PeakVisibility)
                    if info.Problem.PeakVisibility(ii)
                        if ii == info.Problem.OptimumID
                            % Global Optimal - Red Pentagram
                            plot(app.EducationalUIAxes, ...
                                info.Problem.PeaksPosition(ii,2), ...
                                info.Problem.PeaksPosition(ii,1), ...
                                'p', 'MarkerSize', 15, ...
                                'MarkerFaceColor', 'none', ...      
                                'MarkerEdgeColor', 'r', ...      
                                'LineWidth', 2);
                        else
                            % Normal Peak - Blue Circle
                            plot(app.EducationalUIAxes, ...
                                info.Problem.PeaksPosition(ii,2), ...
                                info.Problem.PeaksPosition(ii,1), ...
                                'o', 'MarkerSize', 15, ...
                                'MarkerFaceColor', 'none', ...    
                                'MarkerEdgeColor', 'b', ...       
                                'LineWidth', 2);
                        end
                    end
                end

                app.PreviousContourT = info.T;
                app.PreviousContourF = info.F;
            else
                delete(findall(app.EducationalUIAxes, 'Tag', 'individualMarker'));
                hold(app.EducationalUIAxes, 'on');
            end
        
            % Draw individual positions
            scatter(app.EducationalUIAxes, ...
                info.Individuals(:,2), ...
                info.Individuals(:,1), ...
                50, 'g', 'filled', 'MarkerEdgeColor', 'none', 'Tag', 'individualMarker');
            hold(app.EducationalUIAxes, 'off');
            
            % Update error curve
            semilogy(app.EducationalUIAxes2, ...
                app.CurrentError{1}(1:info.FE), ...
                'r', 'LineWidth', 1.5);
            xlim(app.EducationalUIAxes2, [0, app.EducationalConfigurableBenchmarkParameters.ChangeFrequency.Value * ...
                app.EducationalConfigurableBenchmarkParameters.EnvironmentNumber.Value]);
            
            % Update iteration tag
            app.EducationalIterLabel.Text = sprintf('Iter: %d/%d', iter, app.TotalIter);
        end

        % Progress bar callback
        function educationalSliderCallback(app, event)
            newIter = round(event.Value);
            if app.IsPlaying && newIter ~= app.CurrentIter
                educationalStopCallback(app, false);
                app.CurrentIter = newIter;
                app.EducationalIterInput.Value = newIter;
                educationalPlayCallback(app);
            else
                app.CurrentIter = newIter;
                app.EducationalSlider.Value = newIter;
                updateVisualization(app, false);
            end
        end
        
        % Reset callback
        function educationalResetCallback(app)
            if app.IsPlaying
                educationalStopCallback(app, true);
            end
            axis(app.EducationalUIAxes, 'auto');
            axis(app.EducationalUIAxes2, 'auto');
            app.CurrentIter = 1;
            app.EducationalSlider.Value = 1;
            app.EducationalIterInput.Value = 1;
            updateVisualization(app, true);
            drawnow;
            setUnplayStatus(app);
        end

        function educationalResizeCallback(app)
            if app.IsPlaying
                educationalStopCallback(app, true);
            end
            axis(app.EducationalUIAxes, 'auto');
            axis(app.EducationalUIAxes2, 'auto');
            updateVisualization(app, true);
            drawnow;
            setUnplayStatus(app);
        end

        function educationalPlayCallback(app) 
            if app.IsPlaying
                educationalStopCallback(app, true);
                return;
            end
            app.IsPlaying = true;
            setPlayStatus(app);
            progressQueue = parallel.pool.DataQueue;
            pool = gcp('nocreate'); % Get current parallel pool
            if isempty(pool) % No pool exists, start a new one
                progressDialog = uiprogressdlg(app.UIFigure, ...
                    'Title', 'Please Wait', ...
                    'Message', sprintf('Starting %s pool with %d workers...', app.PoolTypeDropdown.Value, app.UserSettingNumberThreads), ...
                    'Indeterminate', 'on');
                try
                    pool = parpool(app.PoolTypeDropdown.Value, app.UserSettingNumberThreads);
                catch
                    close(progressDialog);
                    uialert(app.UIFigure, ...
                        sprintf('Failed to start the %s pool with the specified configuration. A default pool has been started instead.', app.PoolTypeDropdown.Value), ...
                        'Warning', 'Icon', 'warning');
                    progressDialog = uiprogressdlg(app.UIFigure, ...
                        'Title', 'Please Wait', ...
                        'Message', sprintf('Starting %s pool with default workers...', app.PoolTypeDropdown.Value), ...
                        'Indeterminate', 'on');
                    pool = parpool(app.PoolTypeDropdown.Value);
                    app.ThreadsInput.Value = pool.NumWorkers;
                    app.UserSettingNumberThreads = app.ThreadsInput.Value;
                end
                app.NowPoolType = app.PoolTypeDropdown.Value;
                close(progressDialog);
            end
            afterEach(progressQueue, @(data) handleVisualizationUpdate(app, data));
            currentIter = app.CurrentIter;
            totalIter = app.TotalIter;
            currentFPS = app.SpeedMap(app.EducationalSpeedDropdown.Value);
            app.VisualizationLoop = parfeval(pool, @GUIMode.visualizationMainLoop, 0, currentIter, ...
                    totalIter, currentFPS, progressQueue);
        end

        function educationalStopCallback(app, uiFlag)            
            app.IsPlaying = false;
            if isobject(app.VisualizationLoop) && isvalid(app.VisualizationLoop)
                cancel(app.VisualizationLoop);
            end
            if (uiFlag)
                setUnplayStatus(app);
            end
        end

        function educationalSpeedChange(app)
            % If playing, restart to apply the new speed
            if app.IsPlaying
                educationalStopCallback(app, false);
                educationalPlayCallback(app);
            end
        end

        function handleVisualizationUpdate(app, data)
            switch data.Type
                case 'Update'
                    app.CurrentIter = data.Iter;
                    app.EducationalSlider.Value = data.Iter;
                    app.EducationalIterInput.Value = data.Iter;
                    updateVisualization(app, false);
                    
                case 'Finished'
                    educationalResetCallback(app);
                    uialert(app.UIFigure, 'Playback completed', 'Notification', 'Icon', 'success');
            end
        end
    end

    % For parpool
    methods (Access=private)
        function pool = setParallelPool(app)
            pool = gcp('nocreate'); % Get current parallel pool
            
            if isempty(pool) % No pool exists, start a new one
                progressDialog = uiprogressdlg(app.UIFigure, ...
                    'Title', 'Please Wait', ...
                    'Message', sprintf('Starting %s pool with %d workers...', app.PoolTypeDropdown.Value, app.UserSettingNumberThreads), ...
                    'Indeterminate', 'on');
                try
                    pool = parpool(app.PoolTypeDropdown.Value, app.UserSettingNumberThreads);
                catch
                    close(progressDialog);
                    uialert(app.UIFigure, ...
                        sprintf('Failed to start the %s pool with the specified configuration. A default pool has been started instead.', app.PoolTypeDropdown.Value), ...
                        'Warning', 'Icon', 'warning');
                    progressDialog = uiprogressdlg(app.UIFigure, ...
                        'Title', 'Please Wait', ...
                        'Message', sprintf('Starting %s pool with default workers...', app.PoolTypeDropdown.Value), ...
                        'Indeterminate', 'on');
                    pool = parpool(app.PoolTypeDropdown.Value);
                    app.ThreadsInput.Value = pool.NumWorkers;
                    app.UserSettingNumberThreads = app.ThreadsInput.Value;
                end
                app.NowPoolType = app.PoolTypeDropdown.Value;
                close(progressDialog);
            else
                currentPoolType = app.NowPoolType;
                newPoolType = app.PoolTypeDropdown.Value;
                currentWorkers = pool.NumWorkers;
                newWorkers = app.UserSettingNumberThreads;

                if (currentWorkers == newWorkers) && strcmp(currentPoolType, newPoolType)
                    return;
                else
                    % When app start
                    if isempty(currentPoolType)
                        progressDialog = uiprogressdlg(app.UIFigure, ...
                            'Title', 'Please Wait', ...
                            'Message', sprintf('Starting %s pool with %d workers...', newPoolType, newWorkers), ...
                            'Indeterminate', 'on');
                        delete(gcp('nocreate'));
                        try
                            pool = parpool(app.PoolTypeDropdown.Value, app.UserSettingNumberThreads);
                        catch
                            close(progressDialog);
                            uialert(app.UIFigure, ...
                                sprintf('Failed to start the %s pool with the specified configuration. A default pool has been started instead.', app.PoolTypeDropdown.Value), ...
                                'Warning', 'Icon', 'warning');
                            progressDialog = uiprogressdlg(app.UIFigure, ...
                                'Title', 'Please Wait', ...
                                'Message', sprintf('Starting %s pool with default workers...', app.PoolTypeDropdown.Value), ...
                                'Indeterminate', 'on');
                            pool = parpool(app.PoolTypeDropdown.Value);
                            app.ThreadsInput.Value = pool.NumWorkers;
                            app.UserSettingNumberThreads = app.ThreadsInput.Value;
                        end
                        app.NowPoolType = app.PoolTypeDropdown.Value;
                        close(progressDialog);
                        return
                    end
                    answer = uiconfirm(app.UIFigure, ...
                        sprintf('Current pool: %s pool with %d workers.\nRestart with %s pool having %d workers?', ...
                            currentPoolType, currentWorkers, newPoolType, newWorkers), ...
                        'Confirm Restart', 'Options', {'Yes', 'No'}, 'DefaultOption', 'No');
                    
                    if strcmp(answer, 'Yes')
                        progressDialog = uiprogressdlg(app.UIFigure, ...
                            'Title', 'Please Wait', ...
                            'Message', sprintf('Restarting %s pool with %d workers...', newPoolType, newWorkers), ...
                            'Indeterminate', 'on');
                        delete(gcp('nocreate'));
                        try
                            pool = parpool(app.PoolTypeDropdown.Value, app.UserSettingNumberThreads);
                        catch
                            close(progressDialog);
                            uialert(app.UIFigure, ...
                                sprintf('Failed to start the %s pool with the specified configuration. A default pool has been started instead.', app.PoolTypeDropdown.Value), ...
                                'Warning', 'Icon', 'warning');
                            progressDialog = uiprogressdlg(app.UIFigure, ...
                                'Title', 'Please Wait', ...
                                'Message', sprintf('Starting %s pool with default workers...', app.PoolTypeDropdown.Value), ...
                                'Indeterminate', 'on');
                            pool = parpool(app.PoolTypeDropdown.Value);
                            app.ThreadsInput.Value = pool.NumWorkers;
                            app.UserSettingNumberThreads = app.ThreadsInput.Value;
                        end
                        app.NowPoolType = app.PoolTypeDropdown.Value;
                        close(progressDialog);
                    else
                        app.UserSettingNumberThreads = currentWorkers;
                        app.ThreadsInput.Value = currentWorkers;
                        app.PoolTypeDropdown.Value = app.NowPoolType;
                        drawnow;
                    end
                end
            end
            app.CleanRAMButton.Enable = 'on';
        end

        function releaseRAM(app)
            answer = uiconfirm(app.UIFigure, ...
                ['Closing the parallel pool will free up system memory by shutting down background workers. ' ...
                'Restarting the pool for future tasks may take additional time. ' ...
                'Do you want to proceed?'], ...
                'Confirm Action', 'Options', {'Yes', 'No'}, 'DefaultOption', 'No');
        
            if strcmp(answer, 'Yes')
                progressDialog = uiprogressdlg(app.UIFigure, ...
                    'Title', 'Please Wait', ...
                    'Message', 'Shut down Parpool', ...
                    'Indeterminate', 'on');
                delete(gcp('nocreate')); % Close the parallel pool to release RAM
                app.NowPoolType = '';
                app.CleanRAMButton.Enable = 'off';
                close(progressDialog);
            end
        end
    end

    % Static Methods
    methods (Static)
        function executeTask(task, taskID, queue)
            try
                main_EDO = str2func(['main_', task.Algorithm]);
        
                progressInfo = struct('IsParallel', true, 'Queue', queue, 'TaskID', taskID);
                [Problem, Results, CurrentError, VisualizationInfo, Iteration] = ...
                    main_EDO(0, task.RunNumber, task.Benchmark, task.BenchmarkParameters, task.AlgorithmParameters, progressInfo);
                
                resultStruct = struct(...
                    'Problem', Problem, ...
                    'CurrentError', CurrentError, ...
                    'VisualizationInfo', {VisualizationInfo}, ...
                    'Iteration', Iteration);
                
                if exist('Results', 'var') && ~isempty(Results)
                    resultFields = fieldnames(Results);
                    for i = 1:length(resultFields)
                        fieldName = resultFields{i};
                        resultStruct.(fieldName) = Results.(fieldName);
                    end
                end

                send(queue, struct(...
                    'TaskID', taskID, ...
                    'Status', 'Completed', ...
                    'Progress', '100%', ...
                    'Result', resultStruct));

            catch ME
                send(queue, struct('TaskID', taskID, 'Status', 'Error', 'Progress', ME.identifier));
            end
        end

        function executeEducationalTask(Algorithm, Benchmark, RunNumber, BenchmarkParameters, AlgorithmParameters, queue)
             try
                main_EDO = str2func(['main_', Algorithm]);
                
                taskID = 'educational-task';
                send(queue, struct( ...
                    'TaskID', taskID, ...
                    'Status', 'Started' ...
                ));
                progressInfo = struct('IsParallel', true, 'Queue', queue, 'TaskID', taskID);
                [Problem, Results, CurrentError, VisualizationInfo, Iteration] = ...
                    main_EDO(1, RunNumber, Benchmark, BenchmarkParameters, AlgorithmParameters, progressInfo);
                

                resultStruct = struct(...
                    'Problem', Problem, ...
                    'CurrentError', CurrentError, ...
                    'VisualizationInfo', {VisualizationInfo}, ...
                    'Iteration', Iteration);
                
                if exist('Results', 'var') && ~isempty(Results)
                    resultFields = fieldnames(Results);
                    for i = 1:length(resultFields)
                        fieldName = resultFields{i};
                        resultStruct.(fieldName) = Results.(fieldName);
                    end
                end

                send(queue, struct(...
                    'TaskID', taskID, ...
                    'Status', 'Completed', ...
                    'Progress', '100%', ...
                    'Result', resultStruct));

            catch ME
                send(queue, struct('TaskID', taskID, 'Status', 'Error', 'Progress', ME.identifier));
            end
        end
        function visualizationMainLoop(currentIter, totalIter, framesPerSecond, visualizationDataQueue)
            frameInterval = 1 / framesPerSecond;
            
            while currentIter < totalIter
                tStart = tic; 
                
                send(visualizationDataQueue, struct(...
                    'Type', 'Update', ...
                    'Iter', currentIter ...
                ));
                currentIter = currentIter + 1;
                
                elapsed = toc(tStart);
                pause(max(frameInterval - elapsed, 0.001));
            end
            
            if currentIter >= totalIter
                send(visualizationDataQueue, struct('Type', 'Finished'));
            end
        end
        
        function paramStr = getParamString(paramStruct, prefix)
            if nargin < 2
                prefix = '';
            end
            paramList = {};
            fields = fieldnames(paramStruct);
            for k = 1:length(fields)
                fieldName = fields{k};
                fullFieldName = [prefix fieldName];
                fieldValue = paramStruct.(fieldName).value;
                
                if isnumeric(fieldValue)
                   if isscalar(fieldValue)
                    valueStr = sprintf('%.5f', fieldValue);
                    valueStr = regexprep(valueStr, '(\.\d*?[1-9])0+$', '$1');
                    valueStr = regexprep(valueStr, '\.0+$', '');
                    else
                        if all(fieldValue >= 32 & fieldValue <= 126)
                            valueStr = ['"' char(fieldValue) '"'];
                        else
                            values = arrayfun(@(x) sprintf('%.5f', x), fieldValue, 'Uni', 0);
                            values = cellfun(@(s) regexprep(s, '(\.\d*?[1-9])0+$', '$1'), values, 'Uni', 0);
                            valueStr = ['[' strjoin(values, ' ') ']'];
                        end
                    end
                elseif islogical(fieldValue)
                    valueStr = mat2str(fieldValue);
                elseif ischar(fieldValue) || isstring(fieldValue)
                    valueStr = char(fieldValue);
                elseif isstruct(fieldValue)
                    subFields = fieldnames(fieldValue);
                    if isscalar(subFields) && strcmp(subFields{1}, 'value')
                        if ischar(fieldValue.value) || isstring(fieldValue.value)
                            valueStr = ['"', char(fieldValue.value), '"'];
                        else
                            valueStr = sprintf('%.5f', fieldValue.value);
                            valueStr = regexprep(valueStr, '(\.\d*?[1-9])0+$', '$1');
                            valueStr = regexprep(valueStr, '\.0+$', '');
                        end
                    else
                        valueStr = getParamString(fieldValue, [fullFieldName '.']);
                    end
                elseif iscell(fieldValue)
                    cellStrs = cellfun(@(x) getParamString(x, ''), fieldValue, 'UniformOutput', false);
                    valueStr = ['{' strjoin(cellStrs, ',') '}'];
                else
                    valueStr = '[Unknown Type]';
                end
                
                paramList{end+1} = sprintf('%s=%s', fullFieldName, valueStr);
            end
            paramStr = strjoin(paramList, ', ');
        end

        function [offlineError, taskIdx] = computeOfflineError(currentError, runNumber, taskIdx, plotQueue)
            if runNumber > 1
                currentError = mean(currentError, 1);
            end
            numFE = length(currentError);
            cumulativeSum = cumsum(currentError);
            offlineError = cumulativeSum ./ (1:numFE);

            % updateIndices = unique(round(linspace(1, numFE, 10)));
            send(plotQueue, struct(...
                'Status', 'Completed', ...
                'taskIdx', taskIdx, ...
                'DoneFE', numFE, ...
                'offlineError', offlineError));
        end

        function [bestErrorBeforeChange, taskIdx] = computeBestErrorBeforeChange(currentError, changeFrequency, runNumber, taskIdx, plotQueue)
            % e_bbc is assumed to be (Run x Env) matrix
            if runNumber > 1
                currentError = mean(currentError, 1);
            end
            numFE = length(currentError);
            envIndices = changeFrequency:changeFrequency:numFE;
            if envIndices(end) ~= numFE
                envIndices = [envIndices, numFE];
            end
            errorBeforeChange = currentError(:, envIndices);

            cumSum = cumsum(errorBeforeChange);
            bestErrorBeforeChange = cumSum ./ (1:length(errorBeforeChange));
            data = struct('Status', 'Completed', 'taskIdx', taskIdx, 'DoneEnv', length(errorBeforeChange), 'bestErrorBeforeChange', bestErrorBeforeChange);
            send(plotQueue, data);
        end


        function [PhysicalCores, LogicalProcessors] = getCoreInfo()
        % getCoreInfo retrieves the number of physical cores and logical processors
        % across Windows, macOS, and Linux platforms.
        %
        %   [PhysicalCores, LogicalProcessors] = getCoreInfo() calls the appropriate
        %   system command based on the current OS and extracts CPU information.
        %
        % Note: Output formats may vary between systems. Parsing logic is based on
        % common default output structures.
        
        if ispc
            % Windows: Use 'wmic' command with CSV format
            [status, result] = system('wmic cpu get NumberOfCores,NumberOfLogicalProcessors /format:csv');
            if status ~= 0
                error('Failed to execute wmic command.');
            end
            lines = strsplit(result, '\n');
            lines = lines(~cellfun('isempty', lines));
            if numel(lines) < 2
                error('Unexpected WMIC output format.');
            end
            dataLine = strtrim(lines{end});
            parts = strsplit(dataLine, ',');
            if numel(parts) < 3
                error('Failed to parse WMIC output.');
            end
            PhysicalCores = str2double(parts{2});
            LogicalProcessors = str2double(parts{3});
        
        elseif isunix
            if ismac
                % macOS: Use 'sysctl' to get core counts
                [status, result] = system('sysctl -n hw.physicalcpu hw.logicalcpu');
                if status ~= 0
                    error('Failed to execute sysctl.');
                end
                parts = strsplit(strtrim(result));
                if numel(parts) < 2
                    error('Unexpected sysctl output format.');
                end
                PhysicalCores = str2double(parts{1});
                LogicalProcessors = str2double(parts{2});
            else
                % Linux: Use 'lscpu' and parse its output
                [status, result] = system('lscpu');
                if status ~= 0
                    error('Failed to execute lscpu.');
                end
                coresPerSocket = [];
                sockets = [];
                logicalCores = [];
                lines = strsplit(result, '\n');
                for i = 1:length(lines)
                    line = strtrim(lines{i});
                    if startsWith(line, 'Core(s) per socket:')
                        tokens = regexp(line, 'Core\(s\) per socket:\s*(\d+)', 'tokens');
                        if ~isempty(tokens)
                            coresPerSocket = str2double(tokens{1}{1});
                        end
                    elseif startsWith(line, 'Socket(s):')
                        tokens = regexp(line, 'Socket\(s\):\s*(\d+)', 'tokens');
                        if ~isempty(tokens)
                            sockets = str2double(tokens{1}{1});
                        end
                    elseif startsWith(line, 'CPU(s):')
                        tokens = regexp(line, 'CPU\(s\):\s*(\d+)', 'tokens');
                        if ~isempty(tokens)
                            logicalCores = str2double(tokens{1}{1});
                        end
                    end
                end
                if isempty(coresPerSocket) || isempty(sockets) || isempty(logicalCores)
                    error('Failed to parse lscpu output.');
                end
                PhysicalCores = coresPerSocket * sockets;
                LogicalProcessors = logicalCores;
            end
        else
            error('Unsupported operating system.');
        end
        end

    end

    % App initialization and construction
    methods (Access = public)
        function app = GUIMode
            checkMATLABVersion(app);
            createComponents(app);
            runStartupFcn(app, @startupFcn);

            % Suppress output when not assigned to a variable
            if ~nargout
                clear app
            end
        end
    end
end