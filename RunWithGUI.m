%*********************************EDOLAB ver 1.00*********************************
%
%Author: Zeneng She
%Last Edited: November 9, 2022
% e-mail: shezeneng AT qq DOT com
%
% ------------
% Reference:
% ------------
%
%  Title: "Evolutionary Dynamic Optimization Laboratory: A MATLAB Optimization
%  Platform for Education and Experimentation in Dynamic Environments"
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
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*********************************************************************************
classdef RunWithGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Figure                         matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        experiment                     matlab.ui.container.Tab
        GridLayout4                    matlab.ui.container.GridLayout
        UITable                        matlab.ui.control.Table
        OutputSettingsPanel            matlab.ui.container.Panel
        GridLayout6                    matlab.ui.container.GridLayout
        GeneratingofflineerrorandcurrenterrorplotsCheckBox  matlab.ui.control.CheckBox
        SavingoutputstatisticsinanExcelfileCheckBox  matlab.ui.control.CheckBox
        ParametersPanel                matlab.ui.container.Panel
        GridLayout5                    matlab.ui.container.GridLayout
        NumberofpromisingregionsSpinner_2  matlab.ui.control.Spinner
        NumberofpromisingregionsSpinnerLabel  matlab.ui.control.Label
        ChangeFrequencySpinner_2       matlab.ui.control.Spinner
        ChangeFrequencyLabel_2         matlab.ui.control.Label
        ShiftSeveritySpinner_2         matlab.ui.control.Spinner
        ShiftSeverityLabel_2           matlab.ui.control.Label
        NumberofEnvironmentsSpinner_2  matlab.ui.control.Spinner
        NumberofEnvironmentsSpinner_2Label  matlab.ui.control.Label
        DimensionSpinner_2             matlab.ui.control.Spinner
        DimensionSpinnerLabel          matlab.ui.control.Label
        AlgorithmList_2                matlab.ui.control.DropDown
        AlgorithmLabel                 matlab.ui.control.Label
        ProblemList_2                  matlab.ui.control.DropDown
        BenchmarkProblemLabel_2        matlab.ui.control.Label
        RunNumberSpinnerLabel          matlab.ui.control.Label
        RunNumberSpinner               matlab.ui.control.Spinner
        RunButton_2                    matlab.ui.control.Button
        educational                    matlab.ui.container.Tab
        GridLayout                     matlab.ui.container.GridLayout
        ViewPanel                      matlab.ui.container.Panel
        GridLayout3                    matlab.ui.container.GridLayout
        GridLayout7                    matlab.ui.container.GridLayout
        CurrentEnvironmentTextAreaLabel  matlab.ui.control.Label
        CurrentEnvironmentTextArea     matlab.ui.control.TextArea
        StopButton                     matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        RunButton                      matlab.ui.control.Button
        ParametersPanel_2              matlab.ui.container.Panel
        GridLayout2                    matlab.ui.container.GridLayout
        Dimension2Label                matlab.ui.control.Label
        NumberofpromisingregionsSpinner  matlab.ui.control.Spinner
        NumberofpromisingregionsSpinner_2Label  matlab.ui.control.Label
        ChangeFrequencySpinner         matlab.ui.control.Spinner
        ChangeFrequencyLabel           matlab.ui.control.Label
        ShiftSeveritySpinner           matlab.ui.control.Spinner
        ShiftSeverityLabel             matlab.ui.control.Label
        NumberofEnvironmentsSpinner    matlab.ui.control.Spinner
        NumberofEnvironmentsSpinnerLabel  matlab.ui.control.Label
        AlgorithmLabel_2               matlab.ui.control.Label
        AlgorithmList                  matlab.ui.control.DropDown
        ProblemList                    matlab.ui.control.DropDown
        BenchmarkProblemLabel          matlab.ui.control.Label
    end

    
    properties (Access = private)
        PeakNumber
        ChangeFrequency
        ShiftSeverity
        EnvironmentNumber
        AlgorithmName
        BenchmarkName
        
        
        % control different modules
        RunNumber
        VisualizationOverOptimization
        Dimension
        
        % output selection
        ErrorPlot
        SaveExcel
        
        % Educational
        VisualizationInfo
        Iteration
        CurrentError
        E_o % offline error
        P_o % offline performance
        E_bbc % average error before change
        Problem
        
        % Experimental
        VisualizationInfo2
        Iteration2
        CurrentError2
        E_o2 % offline error
        P_o2% offline performance
        E_bbc2 % average error before change
        Problem2
        
        StopFlag = false; % control the movie
        projectPath % Description
    end
    
    methods (Access = private)
        
        function isLegal(app)
            if app.PeakNumber <= 0 || ...
                    app.ChangeFrequency <= 0 || ...
                    app.ShiftSeverity <=0 || ...
                    app.EnvironmentNumber <= 0 || ...
                    app.RunNumber <= 0 || ...
                    app.Dimension <=0
            throwEmptyMappingDialog;
            end
        end
        
        function drawPosition(app)
            
            app.StopFlag = false;
            
            for ij =1 : app.Iteration
                if app.StopFlag == true
                    return;
                end
                
                app.CurrentEnvironmentTextArea.Value = num2str(app.VisualizationInfo{ij}.CurrentEnvironment);
                
                contour(app.UIAxes,app.VisualizationInfo{ij}.T, ...
                    app.VisualizationInfo{ij}.T, ...
                    app.VisualizationInfo{ij}.F, ...
                    25);
                colormap(app.UIAxes, cool);
                xlabel(app.UIAxes, 'x_1');
                ylabel(app.UIAxes, 'x_2');
                grid(app.UIAxes, 'on');
                
                
                hold(app.UIAxes, 'on');
                for ii=1 : app.PeakNumber
                    if app.VisualizationInfo{ij}.Problem.PeakVisibility(ii)==1
                        if ii == app.VisualizationInfo{ij}.Problem.OptimumID
                            plot(app.UIAxes, ...
                                app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,2), ...
                                app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,1), ...
                                'p', ...
                                'markersize', 15, ...
                                'markerfacecolor', 'none', ...
                                'MarkerEdgeColor', 'k', ...
                                'LineWidth',1.5);
                        else
                            plot(app.UIAxes, ...
                                app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,2), ...
                                app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,1), ...
                                'o', ...
                                'markersize', 15, ...
                                'markerfacecolor', 'none', ...
                                'MarkerEdgeColor', 'k', ...
                                'LineWidth', 1.5);
                        end
                    end
                end
                
                for ii=1 : app.VisualizationInfo{ij}.IndividualNumber
                    plot(app.UIAxes, ...
                        app.VisualizationInfo{ij}.Individuals(ii,2), ...
                        app.VisualizationInfo{ij}.Individuals(ii,1), ...
                        'o', ...
                        'markersize', 7, ...
                        'markerfacecolor', 'g', ...
                        'MarkerEdgeColor', 'none');
                end
                hold(app.UIAxes, 'off');
                
                semilogy(app.UIAxes2, ...
                    app.CurrentError(1:app.VisualizationInfo{ij}.FE), ...
                    'r', ...
                    'DisplayName', 'Current Error');
                xlabel(app.UIAxes2, 'Fitness Evaluation');
                ylabel(app.UIAxes2, 'Current Error');
                xlim(app.UIAxes2, [0 app.Problem.MaxEvals]);
                ylim(app.UIAxes2, [0 1000]);
                legend(app.UIAxes2);
                grid(app.UIAxes2, 'on');
                
                drawnow;
            end
            app.StopFlag = true;
        end
        
        
        function drawOneGeneration(app)
            cla(app.UIAxes);
            ij = app.ProgressSlider.Value;
            contour(app.UIAxes, ...
                app.VisualizationInfo{ij}.T, ...
                app.VisualizationInfo{ij}.T, ...
                app.VisualizationInfo{ij}.F, ...
                25);
            colormap(app.UIAxes, cool);
            xlabel(app.UIAxes, 'x_1');
            ylabel(app.UIAxes, 'x_2');
            grid(app.UIAxes, 'on');
            hold(app.UIAxes, 'on');
            
            for ii=1 : app.PeakNumber
                if app.VisualizationInfo{ij}.Problem.PeakVisibility(ii)==1
                    if ii == app.VisualizationInfo{ij}.Problem.OptimumID
                        plot(app.UIAxes, ...
                            app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,2), ...
                            app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,1), ...
                            'p', ...
                            'markersize', 15, ...
                            'markerfacecolor', 'none', ...
                            'MarkerEdgeColor', 'k', ...
                            'LineWidth', 1.5);
                    else
                        plot(app.UIAxes, ...
                            app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,2), ...
                            app.VisualizationInfo{ij}.Problem.PeaksPosition(ii,1), ...
                            'o', ...
                            'markersize', 15, ...
                            'markerfacecolor', 'none', ...
                            'MarkerEdgeColor', 'k', ...
                            'LineWidth', 1.5);
                    end
                end
            end
            
            for ii=1 : app.VisualizationInfo{ij}.IndividualNumber
                plot(app.UIAxes, ...
                    app.VisualizationInfo{ij}.Individuals(ii,2), ...
                    app.VisualizationInfo{ij}.Individuals(ii,1), ...
                    'o', ...
                    'markersize', 7, ...
                    'markerfacecolor', 'g', ...
                    'MarkerEdgeColor', 'none');
            end
            hold(app.UIAxes, 'off');
            drawnow;
            
        end
        
        function outputInExperiment(app)
            % Output the parameters
            t = ["", "Offline Error", "Average Error Before Change"];
            for i = 1:app.RunNumber
                t = [t; "Run #"+ i, app.E_o2.AllResults(i), app.E_bbc2.AllResults(i)];
            end
            temp = ["Average", app.E_o2.mean, app.E_bbc2.mean;
                "Median", app.E_o2.median, app.E_bbc2.median;
                "Standard Error", app.E_o2.StdErr, app.E_bbc2.StdErr;];
            t = cat(1, t, temp);
            app.UITable.Data = t;
            app.UITable.FontSize = 12;
            
            % Outputing to excel
            if app.SaveExcel == 1
                app.toExcel;
            end
            
            % draw in the offline Error and Current Error
            if app.ErrorPlot == 1
                app.toPlot;
            end
            
        end
        
        
        function [AlgorithmsList, BenchmarksList] = getAlgAndBenchName(app)
            
            % Get Algorithm lists
            AlgorithmsFloder = dir([app.projectPath, '\Algorithm']);
            AlgorithmsList = repmat("", length(AlgorithmsFloder)-2, 1);
            for i = 3:length(AlgorithmsFloder)
                AlgorithmsList(i-2,1) = AlgorithmsFloder(i).name;
            end
            % Get Benchmark lists
            BenchmarksFloder = dir([app.projectPath,'\Benchmark']);
            BenchmarksList = repmat("", length(BenchmarksFloder)-5,1);
            BenchmarksCount = 0;
            for i = 3:length(BenchmarksFloder)
                if(isempty(strfind(BenchmarksFloder(i).name,'.m')))
                    BenchmarksCount = BenchmarksCount + 1;
                    BenchmarksList(BenchmarksCount,1) = BenchmarksFloder(i).name;
                end
            end
        end
        
        
        function toExcel(app)
            OutputExcel(app.AlgorithmName, ...
                    app.BenchmarkName, ...
                    app.ChangeFrequency,...
                    app.Dimension, ...
                    app.PeakNumber, ...
                    app.ShiftSeverity,...
                    app.RunNumber, ...
                    app.EnvironmentNumber, ...
                    app.E_o2, ...
                    app.E_bbc2, ...
                    [app.projectPath, '\Results']);
        end
        
        function toPlot(app)
            OutputPlot(app.CurrentError2, ...
                    app.RunNumber, ...
                    app.E_o2, ...
                    app.E_bbc2, ...
                    app.AlgorithmName);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %  addpath(genpath(pwd));
            %% Add the full path of EDOLAB folder and its subfolders into work space
            nowPath = mfilename('fullpath');
            app.projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
            addpath(genpath(app.projectPath));
            
            [app.AlgorithmList.Items, app.ProblemList.Items]...
                = app.getAlgAndBenchName();
            app.AlgorithmList_2.Items = app.AlgorithmList.Items;
            app.ProblemList_2.Items = app.ProblemList.Items;
            
            app.AlgorithmList.Value = app.AlgorithmList.Items(1);
            app.AlgorithmList_2.Value = app.AlgorithmList_2.Items(1);
            app.ProblemList.Value = app.ProblemList.Items(1);
            app.ProblemList_2.Value = app.ProblemList_2.Items(1);
            
            app.UITable.Data = "The progress of execution will be " + ...
                "shown in the command window and you can press " + ...
                "''Ctrl + c'' to stop running.";
            app.UITable.FontSize = 14;
            app.UITable.ColumnWidth = '1x';
            s = uistyle("FontWeight", 'bold');
            addStyle(app.UITable, s, 'row', 1);
            addStyle(app.UITable, s, 'column', 1);
            
            xlabel(app.UIAxes, 'x_1');
            ylabel(app.UIAxes, 'x_2');
            grid(app.UIAxes, 'on');
            
            xlabel(app.UIAxes2,'Fitness Evaluation');
            ylabel(app.UIAxes2,'Current Error');
            grid(app.UIAxes2, 'on');
            
            
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            % get the parameters for run
            app.AlgorithmName = app.AlgorithmList.Value;
            app.BenchmarkName = app.ProblemList.Value;
            
            app.Dimension = 2;
            app.PeakNumber = app.NumberofpromisingregionsSpinner.Value;
            app.ChangeFrequency = app.ChangeFrequencySpinner.Value;
            app.ShiftSeverity = app.ShiftSeveritySpinner.Value;
            app.EnvironmentNumber = app.NumberofEnvironmentsSpinner.Value;
            
            app.RunNumber = 1;
            app.VisualizationOverOptimization = 1;
            
            % gurantee the parameters is positive
            try
                app.isLegal();
            catch ME
                uialert(app.Figure, ...
                    'Paremeters are not set correct!', ...
                    'Error', ...
                    'Icon', 'error', ...
                    'CloseFcn', 'uiresume(app.Figure)')
                uiwait(app.Figure)
            end
            
            d = uiprogressdlg(app.Figure, ...
                "Title", 'Preparing', ...
                "Indeterminate", "on");
            
            %% Optimization
            main_EDO = str2func(['main_', app.AlgorithmName]);
            [app.Problem, ...
                app.E_bbc, ...
                app.E_o, ...
                app.CurrentError, ...
                app.VisualizationInfo, ...
                app.Iteration] ...
                = main_EDO(app.VisualizationOverOptimization, ...
                app.PeakNumber,...
                app.ChangeFrequency, ...
                app.Dimension, ...
                app.ShiftSeverity,...
                app.EnvironmentNumber, ...
                app.RunNumber, ...
                app.BenchmarkName);
            
            close(d);
            
            %% Output
            app.drawPosition();
            
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            app.StopFlag = true;
        end

        % Value changed function: 
        % GeneratingofflineerrorandcurrenterrorplotsCheckBox
        function GeneratingofflineerrorandcurrenterrorplotsCheckBoxValueChanged(app, event)
            value = app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.Value;
            app.ErrorPlot = value;
        end

        % Button pushed function: RunButton_2
        function RunButton_2Pushed(app, event)
            app.Figure.Pointer = 'watch';
            pause(1);
            
            app.AlgorithmName = app.AlgorithmList_2.Value;
            app.BenchmarkName = app.ProblemList_2.Value;
            
            app.Dimension = app.DimensionSpinner_2.Value;
            app.PeakNumber = app.NumberofpromisingregionsSpinner_2.Value;
            app.ChangeFrequency = app.ChangeFrequencySpinner_2.Value;
            app.ShiftSeverity = app.ShiftSeveritySpinner_2.Value;
            app.EnvironmentNumber = app.NumberofEnvironmentsSpinner_2.Value;
            
            app.RunNumber = app.RunNumberSpinner.Value;
            app.ErrorPlot = app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.Value;
            app.VisualizationOverOptimization = 0;
            
            app.UITable.Data = "The progress of execution will be " + ...
                "shown in the command window and you can press " + ...
                "''Ctrl + c'' to stop running.";
            app.UITable.FontSize = 14;
            pause(1);
            
            % gurantee the parameters is positive
            try
                
                app.isLegal();
                
            catch ME
                uialert(app.Figure, ...
                    'Paremeters are not set correct!', ...
                    'Error', ...
                    'Icon', 'error', ...
                    'CloseFcn', 'uiresume(app.Figure)')
                uiwait(app.Figure)
            end
            
            %% Optimization
            main_EDO = str2func(['main_',app.AlgorithmName]);
            [app.Problem2, ...
                app.E_bbc2, ...
                app.E_o2, ...
                app.CurrentError2, ...
                app.VisualizationInfo2, ...
                app.Iteration2] ...
                = main_EDO(app.VisualizationOverOptimization, ...
                app.PeakNumber,...
                app.ChangeFrequency, ...
                app.Dimension, ...
                app.ShiftSeverity,...
                app.EnvironmentNumber, ...
                app.RunNumber, ...
                app.BenchmarkName);
            
            %% Output
            app.outputInExperiment();
            app.Figure.Pointer = 'arrow';
            
            delete(gcp('nocreate'));
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.StopFlag = true;
        end

        % Value changed function: 
        % SavingoutputstatisticsinanExcelfileCheckBox
        function SavingoutputstatisticsinanExcelfileCheckBoxValueChanged(app, event)
            value = app.SavingoutputstatisticsinanExcelfileCheckBox.Value;
            app.SaveExcel = value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Figure and hide until all components are created
            app.Figure = uifigure('Visible', 'off');
            app.Figure.Position = [100 100 1200 650];
            app.Figure.Name = 'EDOLAB';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.Figure);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Position = [0 0 1200 650];

            % Create experiment
            app.experiment = uitab(app.TabGroup);
            app.experiment.Title = 'Experimental';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.experiment);
            app.GridLayout4.ColumnWidth = {'fit', 'fit', 'fit', 'fit', 'fit', '1x', 84, '2x', 84, '1x', 'fit'};
            app.GridLayout4.RowHeight = {'fit', 'fit', 35, 'fit', 'fit', '1x'};

            % Create UITable
            app.UITable = uitable(app.GridLayout4);
            app.UITable.ColumnName = '';
            app.UITable.ColumnWidth = {'1x'};
            app.UITable.RowName = {};
            app.UITable.Layout.Row = 6;
            app.UITable.Layout.Column = [5 10];

            % Create OutputSettingsPanel
            app.OutputSettingsPanel = uipanel(app.GridLayout4);
            app.OutputSettingsPanel.Title = 'Output Settings';
            app.OutputSettingsPanel.Layout.Row = [2 4];
            app.OutputSettingsPanel.Layout.Column = 5;
            app.OutputSettingsPanel.FontWeight = 'bold';
            app.OutputSettingsPanel.FontSize = 20;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.OutputSettingsPanel);
            app.GridLayout6.ColumnWidth = {'fit', 'fit', 'fit'};
            app.GridLayout6.RowHeight = {22};
            app.GridLayout6.RowSpacing = 13.9500007629395;
            app.GridLayout6.Padding = [10 13.9500007629395 10 13.9500007629395];

            % Create GeneratingofflineerrorandcurrenterrorplotsCheckBox
            app.GeneratingofflineerrorandcurrenterrorplotsCheckBox = uicheckbox(app.GridLayout6);
            app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.ValueChangedFcn = createCallbackFcn(app, @GeneratingofflineerrorandcurrenterrorplotsCheckBoxValueChanged, true);
            app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.Text = 'Generating offline error and current error plots';
            app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.WordWrap = 'on';
            app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.Layout.Row = 1;
            app.GeneratingofflineerrorandcurrenterrorplotsCheckBox.Layout.Column = 1;

            % Create SavingoutputstatisticsinanExcelfileCheckBox
            app.SavingoutputstatisticsinanExcelfileCheckBox = uicheckbox(app.GridLayout6);
            app.SavingoutputstatisticsinanExcelfileCheckBox.ValueChangedFcn = createCallbackFcn(app, @SavingoutputstatisticsinanExcelfileCheckBoxValueChanged, true);
            app.SavingoutputstatisticsinanExcelfileCheckBox.Text = 'Saving output statistics in an Excel file';
            app.SavingoutputstatisticsinanExcelfileCheckBox.Layout.Row = 1;
            app.SavingoutputstatisticsinanExcelfileCheckBox.Layout.Column = 3;

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.GridLayout4);
            app.ParametersPanel.Title = 'Parameters';
            app.ParametersPanel.Layout.Row = [2 6];
            app.ParametersPanel.Layout.Column = [2 3];
            app.ParametersPanel.FontWeight = 'bold';
            app.ParametersPanel.FontSize = 20;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.ParametersPanel);
            app.GridLayout5.ColumnWidth = {'fit'};
            app.GridLayout5.RowHeight = {22, 30, 22, 30, 30, 30, 22, 30, 22, 30, 22, 30, 22, 30, 30, 30};
            app.GridLayout5.RowSpacing = 5.39999944513494;
            app.GridLayout5.Padding = [10 5.39999944513494 10 5.39999944513494];

            % Create NumberofpromisingregionsSpinner_2
            app.NumberofpromisingregionsSpinner_2 = uispinner(app.GridLayout5);
            app.NumberofpromisingregionsSpinner_2.Limits = [0 Inf];
            app.NumberofpromisingregionsSpinner_2.ValueDisplayFormat = '%.0f';
            app.NumberofpromisingregionsSpinner_2.Layout.Row = 8;
            app.NumberofpromisingregionsSpinner_2.Layout.Column = 1;
            app.NumberofpromisingregionsSpinner_2.Value = 10;

            % Create NumberofpromisingregionsSpinnerLabel
            app.NumberofpromisingregionsSpinnerLabel = uilabel(app.GridLayout5);
            app.NumberofpromisingregionsSpinnerLabel.Layout.Row = 7;
            app.NumberofpromisingregionsSpinnerLabel.Layout.Column = 1;
            app.NumberofpromisingregionsSpinnerLabel.Text = 'Number of promising regions';

            % Create ChangeFrequencySpinner_2
            app.ChangeFrequencySpinner_2 = uispinner(app.GridLayout5);
            app.ChangeFrequencySpinner_2.Limits = [0 Inf];
            app.ChangeFrequencySpinner_2.ValueDisplayFormat = '%.0f';
            app.ChangeFrequencySpinner_2.Layout.Row = 10;
            app.ChangeFrequencySpinner_2.Layout.Column = 1;
            app.ChangeFrequencySpinner_2.Value = 5000;

            % Create ChangeFrequencyLabel_2
            app.ChangeFrequencyLabel_2 = uilabel(app.GridLayout5);
            app.ChangeFrequencyLabel_2.Layout.Row = 9;
            app.ChangeFrequencyLabel_2.Layout.Column = 1;
            app.ChangeFrequencyLabel_2.Text = {'Change Frequency'; ''};

            % Create ShiftSeveritySpinner_2
            app.ShiftSeveritySpinner_2 = uispinner(app.GridLayout5);
            app.ShiftSeveritySpinner_2.Limits = [0 Inf];
            app.ShiftSeveritySpinner_2.ValueDisplayFormat = '%.0f';
            app.ShiftSeveritySpinner_2.Layout.Row = 12;
            app.ShiftSeveritySpinner_2.Layout.Column = 1;
            app.ShiftSeveritySpinner_2.Value = 1;

            % Create ShiftSeverityLabel_2
            app.ShiftSeverityLabel_2 = uilabel(app.GridLayout5);
            app.ShiftSeverityLabel_2.Layout.Row = 11;
            app.ShiftSeverityLabel_2.Layout.Column = 1;
            app.ShiftSeverityLabel_2.Text = 'Shift Severity';

            % Create NumberofEnvironmentsSpinner_2
            app.NumberofEnvironmentsSpinner_2 = uispinner(app.GridLayout5);
            app.NumberofEnvironmentsSpinner_2.Limits = [0 Inf];
            app.NumberofEnvironmentsSpinner_2.ValueDisplayFormat = '%.0f';
            app.NumberofEnvironmentsSpinner_2.Layout.Row = 14;
            app.NumberofEnvironmentsSpinner_2.Layout.Column = 1;
            app.NumberofEnvironmentsSpinner_2.Value = 10;

            % Create NumberofEnvironmentsSpinner_2Label
            app.NumberofEnvironmentsSpinner_2Label = uilabel(app.GridLayout5);
            app.NumberofEnvironmentsSpinner_2Label.Layout.Row = 13;
            app.NumberofEnvironmentsSpinner_2Label.Layout.Column = 1;
            app.NumberofEnvironmentsSpinner_2Label.Text = {'Number of Environments'; ''};

            % Create DimensionSpinner_2
            app.DimensionSpinner_2 = uispinner(app.GridLayout5);
            app.DimensionSpinner_2.Limits = [0 Inf];
            app.DimensionSpinner_2.ValueDisplayFormat = '%.0f';
            app.DimensionSpinner_2.Layout.Row = 6;
            app.DimensionSpinner_2.Layout.Column = 1;
            app.DimensionSpinner_2.Value = 2;

            % Create DimensionSpinnerLabel
            app.DimensionSpinnerLabel = uilabel(app.GridLayout5);
            app.DimensionSpinnerLabel.Layout.Row = 5;
            app.DimensionSpinnerLabel.Layout.Column = 1;
            app.DimensionSpinnerLabel.Text = {'Dimension'; ''};

            % Create AlgorithmList_2
            app.AlgorithmList_2 = uidropdown(app.GridLayout5);
            app.AlgorithmList_2.Items = {};
            app.AlgorithmList_2.Layout.Row = 2;
            app.AlgorithmList_2.Layout.Column = 1;
            app.AlgorithmList_2.Value = {};

            % Create AlgorithmLabel
            app.AlgorithmLabel = uilabel(app.GridLayout5);
            app.AlgorithmLabel.Layout.Row = 1;
            app.AlgorithmLabel.Layout.Column = 1;
            app.AlgorithmLabel.Text = {'Algorithm'; ''};

            % Create ProblemList_2
            app.ProblemList_2 = uidropdown(app.GridLayout5);
            app.ProblemList_2.Items = {};
            app.ProblemList_2.Layout.Row = 4;
            app.ProblemList_2.Layout.Column = 1;
            app.ProblemList_2.Value = {};

            % Create BenchmarkProblemLabel_2
            app.BenchmarkProblemLabel_2 = uilabel(app.GridLayout5);
            app.BenchmarkProblemLabel_2.Layout.Row = 3;
            app.BenchmarkProblemLabel_2.Layout.Column = 1;
            app.BenchmarkProblemLabel_2.Text = 'Benchmark Problem';

            % Create RunNumberSpinnerLabel
            app.RunNumberSpinnerLabel = uilabel(app.GridLayout5);
            app.RunNumberSpinnerLabel.Layout.Row = 15;
            app.RunNumberSpinnerLabel.Layout.Column = 1;
            app.RunNumberSpinnerLabel.Text = {'RunNumber'; ''};

            % Create RunNumberSpinner
            app.RunNumberSpinner = uispinner(app.GridLayout5);
            app.RunNumberSpinner.Limits = [1 Inf];
            app.RunNumberSpinner.Layout.Row = 16;
            app.RunNumberSpinner.Layout.Column = 1;
            app.RunNumberSpinner.Value = 1;

            % Create RunButton_2
            app.RunButton_2 = uibutton(app.GridLayout4, 'push');
            app.RunButton_2.ButtonPushedFcn = createCallbackFcn(app, @RunButton_2Pushed, true);
            app.RunButton_2.BusyAction = 'cancel';
            app.RunButton_2.Interruptible = 'off';
            app.RunButton_2.Layout.Row = 3;
            app.RunButton_2.Layout.Column = 8;
            app.RunButton_2.Text = 'RUN';

            % Create educational
            app.educational = uitab(app.TabGroup);
            app.educational.Title = 'Educational';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.educational);
            app.GridLayout.ColumnWidth = {'fit', 'fit', 'fit', 'fit', '1x'};
            app.GridLayout.RowHeight = {'fit', '1x', 'fit', 22, 'fit'};
            app.GridLayout.RowSpacing = 5.41666666666667;
            app.GridLayout.Padding = [10 5.41666666666667 10 5.41666666666667];

            % Create ViewPanel
            app.ViewPanel = uipanel(app.GridLayout);
            app.ViewPanel.Layout.Row = [1 4];
            app.ViewPanel.Layout.Column = 5;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ViewPanel);
            app.GridLayout3.ColumnWidth = {'fit', '1x', 'fit', 'fit', '1x', 'fit'};
            app.GridLayout3.RowHeight = {'fit', '1x', 'fit'};
            app.GridLayout3.RowSpacing = 6.59750671386719;
            app.GridLayout3.Padding = [10 6.59750671386719 10 6.59750671386719];

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout3);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', 'fit'};
            app.GridLayout7.RowHeight = {22};
            app.GridLayout7.Layout.Row = 3;
            app.GridLayout7.Layout.Column = 2;

            % Create CurrentEnvironmentTextAreaLabel
            app.CurrentEnvironmentTextAreaLabel = uilabel(app.GridLayout7);
            app.CurrentEnvironmentTextAreaLabel.HorizontalAlignment = 'center';
            app.CurrentEnvironmentTextAreaLabel.Layout.Row = 1;
            app.CurrentEnvironmentTextAreaLabel.Layout.Column = 1;
            app.CurrentEnvironmentTextAreaLabel.Text = 'Current Environment';

            % Create CurrentEnvironmentTextArea
            app.CurrentEnvironmentTextArea = uitextarea(app.GridLayout7);
            app.CurrentEnvironmentTextArea.Layout.Row = 1;
            app.CurrentEnvironmentTextArea.Layout.Column = 2;

            % Create StopButton
            app.StopButton = uibutton(app.GridLayout7, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Layout.Row = 1;
            app.StopButton.Layout.Column = 3;
            app.StopButton.Text = 'STOP';

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout3);
            title(app.UIAxes, 'Position')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes.Layout.Row = 2;
            app.UIAxes.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout3);
            title(app.UIAxes2, 'Curent Error')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes2.Layout.Row = 2;
            app.UIAxes2.Layout.Column = [3 5];

            % Create RunButton
            app.RunButton = uibutton(app.GridLayout, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Layout.Row = 3;
            app.RunButton.Layout.Column = [2 3];
            app.RunButton.Text = 'RUN';

            % Create ParametersPanel_2
            app.ParametersPanel_2 = uipanel(app.GridLayout);
            app.ParametersPanel_2.Title = 'Parameters';
            app.ParametersPanel_2.Layout.Row = 2;
            app.ParametersPanel_2.Layout.Column = [2 3];
            app.ParametersPanel_2.FontWeight = 'bold';
            app.ParametersPanel_2.FontSize = 20;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.ParametersPanel_2);
            app.GridLayout2.ColumnWidth = {'fit'};
            app.GridLayout2.RowHeight = {22, 30, 22, 30, 22, 30, 22, 30, 22, 30, 22, 30, 22};
            app.GridLayout2.RowSpacing = 4.83999938964844;
            app.GridLayout2.Padding = [10 4.83999938964844 10 4.83999938964844];

            % Create Dimension2Label
            app.Dimension2Label = uilabel(app.GridLayout2);
            app.Dimension2Label.Layout.Row = 13;
            app.Dimension2Label.Layout.Column = 1;
            app.Dimension2Label.Text = 'Dimension = 2';

            % Create NumberofpromisingregionsSpinner
            app.NumberofpromisingregionsSpinner = uispinner(app.GridLayout2);
            app.NumberofpromisingregionsSpinner.Limits = [0 Inf];
            app.NumberofpromisingregionsSpinner.ValueDisplayFormat = '%.0f';
            app.NumberofpromisingregionsSpinner.Tooltip = {''};
            app.NumberofpromisingregionsSpinner.Layout.Row = 6;
            app.NumberofpromisingregionsSpinner.Layout.Column = 1;
            app.NumberofpromisingregionsSpinner.Value = 10;

            % Create NumberofpromisingregionsSpinner_2Label
            app.NumberofpromisingregionsSpinner_2Label = uilabel(app.GridLayout2);
            app.NumberofpromisingregionsSpinner_2Label.Layout.Row = 5;
            app.NumberofpromisingregionsSpinner_2Label.Layout.Column = 1;
            app.NumberofpromisingregionsSpinner_2Label.Text = 'Number of promising regions';

            % Create ChangeFrequencySpinner
            app.ChangeFrequencySpinner = uispinner(app.GridLayout2);
            app.ChangeFrequencySpinner.Limits = [0 Inf];
            app.ChangeFrequencySpinner.ValueDisplayFormat = '%.0f';
            app.ChangeFrequencySpinner.Layout.Row = 8;
            app.ChangeFrequencySpinner.Layout.Column = 1;
            app.ChangeFrequencySpinner.Value = 5000;

            % Create ChangeFrequencyLabel
            app.ChangeFrequencyLabel = uilabel(app.GridLayout2);
            app.ChangeFrequencyLabel.Layout.Row = 7;
            app.ChangeFrequencyLabel.Layout.Column = 1;
            app.ChangeFrequencyLabel.Text = {'Change Frequency'; ''};

            % Create ShiftSeveritySpinner
            app.ShiftSeveritySpinner = uispinner(app.GridLayout2);
            app.ShiftSeveritySpinner.Limits = [0 Inf];
            app.ShiftSeveritySpinner.ValueDisplayFormat = '%.0f';
            app.ShiftSeveritySpinner.Layout.Row = 10;
            app.ShiftSeveritySpinner.Layout.Column = 1;
            app.ShiftSeveritySpinner.Value = 1;

            % Create ShiftSeverityLabel
            app.ShiftSeverityLabel = uilabel(app.GridLayout2);
            app.ShiftSeverityLabel.Layout.Row = 9;
            app.ShiftSeverityLabel.Layout.Column = 1;
            app.ShiftSeverityLabel.Text = 'Shift Severity';

            % Create NumberofEnvironmentsSpinner
            app.NumberofEnvironmentsSpinner = uispinner(app.GridLayout2);
            app.NumberofEnvironmentsSpinner.Limits = [0 Inf];
            app.NumberofEnvironmentsSpinner.ValueDisplayFormat = '%.0f';
            app.NumberofEnvironmentsSpinner.Layout.Row = 12;
            app.NumberofEnvironmentsSpinner.Layout.Column = 1;
            app.NumberofEnvironmentsSpinner.Value = 10;

            % Create NumberofEnvironmentsSpinnerLabel
            app.NumberofEnvironmentsSpinnerLabel = uilabel(app.GridLayout2);
            app.NumberofEnvironmentsSpinnerLabel.Layout.Row = 11;
            app.NumberofEnvironmentsSpinnerLabel.Layout.Column = 1;
            app.NumberofEnvironmentsSpinnerLabel.Text = 'Number of Environments';

            % Create AlgorithmLabel_2
            app.AlgorithmLabel_2 = uilabel(app.GridLayout2);
            app.AlgorithmLabel_2.Layout.Row = 1;
            app.AlgorithmLabel_2.Layout.Column = 1;
            app.AlgorithmLabel_2.Text = {'Algorithm'; ''};

            % Create AlgorithmList
            app.AlgorithmList = uidropdown(app.GridLayout2);
            app.AlgorithmList.Items = {};
            app.AlgorithmList.Layout.Row = 2;
            app.AlgorithmList.Layout.Column = 1;
            app.AlgorithmList.Value = {};

            % Create ProblemList
            app.ProblemList = uidropdown(app.GridLayout2);
            app.ProblemList.Items = {};
            app.ProblemList.Layout.Row = 4;
            app.ProblemList.Layout.Column = 1;
            app.ProblemList.Value = {};

            % Create BenchmarkProblemLabel
            app.BenchmarkProblemLabel = uilabel(app.GridLayout2);
            app.BenchmarkProblemLabel.Layout.Row = 3;
            app.BenchmarkProblemLabel.Layout.Column = 1;
            app.BenchmarkProblemLabel.Text = 'Benchmark Problem';

            % Show the figure after all components are created
            app.Figure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = RunWithGUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Figure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Figure)
        end
    end
end