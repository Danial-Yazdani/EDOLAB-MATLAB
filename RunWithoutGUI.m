%*********************************EDOLAB ver 1.00*********************************
%
%Authors: Mai Peng and Danial Yazdani
% e-mails: pengmai1998 AT gmail DOT com
%          danial DOT yazdani AT gmail DOT com
%Last Edited: July 11, 2023
%
% ------------
% Reference:
% ------------
%
%  Title: "Evolutionary Dynamic Optimization Laboratory: A MATLAB Optimization
%  Platform for Education and Experimentation in Dynamic Environments"
%  Note: reference information will be completed after acceptance of the paper
%
% ------------
% Notification:
% ------------
% 
%  This function is used to run EDOLAB without GUI
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*********************************************************************************
clear all;close all;clc;
%% Add the full path of EDOLAB folder and its subfolders into MATLAB's work space
nowPath = mfilename('fullpath');
projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
addpath(genpath(projectPath));
%% ********Selecting Algorithm & Benchmark********
AlgorithmName = 'SPSO_AP_AD';    %Please input the name of algorithm (EADO) you want to run here (names are case sensitive).
%  The list of algorithms (EADOs) and some of their details can be found in Table 1 of the EDOLAB's paper.
%  The current version of EDOLAB includes the following algorithms (EADOs):
%  'ACFPSO' , 'AMPDE' , 'AMPPSO' , 'AmQSO' , 'AMSO' , 'CDE' , 'CESO', 'CPSO' , 'CPSOR' 
%  'DSPSO' , 'DynDE' , 'DynPopDE' , 'FTMPSO' , 'HmSO' ,  'IDSPSO' , 'ImQSO' , 'mCMAES'
%  'mDE' , 'mjDE' , 'mPSO' , 'mQSO' , 'psfNBC' , 'RPSO' , 'SPSO_AP_AD' , 'TMIPSO' 
BenchmarkName = 'GMPB';     %Please input the name of benchmark you want to use here (names are case sensitive).
%  The current version of EDOLAB includes the following benchmark generators: 'MPB' , 'GMPB' , 'FPs'
%% Get the algorithm and benchmark lists
AlgorithmsFloder = dir([projectPath,'\Algorithm']);
AlgorithmsList = repmat("",length(AlgorithmsFloder)-2,1);
for i = 3:length(AlgorithmsFloder)
    AlgorithmsList(i-2,1) = AlgorithmsFloder(i).name;
end
BenchmarksFloder = dir([projectPath,'\Benchmark']);
BenchmarksList = repmat("",length(BenchmarksFloder)-5,1);
BenchmarksCount = 0;
for i = 3:length(BenchmarksFloder)
    if(isempty(strfind(BenchmarksFloder(i).name,'.m')))
        BenchmarksCount = BenchmarksCount + 1;
        BenchmarksList(BenchmarksCount,1) = BenchmarksFloder(i).name;
    end
end
if(~ismember(AlgorithmName,AlgorithmsList))
    error("No Such Algorithm in EDOLAB");
elseif(~ismember(BenchmarkName,BenchmarksList))
    error("No Such Benchmark in EDOLAB");
end
%% ********Benchmark parameters and Run number********
PeakNumber                     = 10;  %The default value is 10
ChangeFrequency                = 5000;%The default value is 5000
Dimension                      = 5;   %The default value is 5. It must be set to 2 for using Education module
ShiftSeverity                  = 1;   %The default value is 1
EnvironmentNumber              = 100;  %The default value is 100
RunNumber                      = 31;   %It should be set to 31 in Experimentation module, and must be set to 2 for using Education module.
%% ********Figures and Outputs********
GeneratingExcelFile            = 0;   %Set to 1 (only for using the Experimentation module) to save the output statistics in an Excel file (in the Results folder), 0 otherwise. 
OutputFig                      = 1;   %Set to 1 (only for using the Experimentation module) to draw offline error over time and current error plot, 0 otherwise.
VisualizationOverOptimization  = 0;   %Set to 1 for using the Education module, 0 otherwise. This must be set to 0 if the user intends to use the Experimentation module.
%If VisualizationOverOptimization is set to 1, it means that EDOLAB enters its Education module. 
%To enter the Education module, RunNumber must be set to 1, Dimension must be set to 2, and no excel file or output figure is generated. 
%If the user does not intend to use the Education module, she or he must set VisualizationOverOptimization to 0. 
%EDOLAB changes the aforementioned parameters based on the requirements of the Education module if VisualizationOverOptimization is set to 1.
if VisualizationOverOptimization==1%Forcing the right values for the following parameters when using the Education module.  
    if Dimension~=2 || RunNumber~=1 || GeneratingExcelFile~=0 || OutputFig~= 0
       warning('By setting VisualizationOverOptimization to 1, you have chosen to use the Education module of EDOLAB; therefore, run number and dimension are set to 1 and 2, respectively. The output figure and Excel file are disabled.');      
    end
    Dimension                  = 2;   
    RunNumber                  = 1;   
    GeneratingExcelFile        = 0;   
    OutputFig                  = 0;   
end
%% Running the chosen algorithm (EDOA) on the chosen benchmark
main_EDO = str2func(['main_',AlgorithmName]);
[Problem,E_bbc,E_o,CurrentError,VisualizationInfo,Iteration] = main_EDO(VisualizationOverOptimization,PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,RunNumber,BenchmarkName);
%% Output
close;clc;
disp(['Offline error ==> ', ' Mean = ', num2str(E_o.mean), ', Median = ', num2str(E_o.median), ', Standard Error = ', num2str(E_o.StdErr)]);
disp(['Average error before change ==> ', ' Mean = ', num2str(E_bbc.mean), ', Median = ', num2str(E_bbc.median), ', Standard Error = ', num2str(E_bbc.StdErr)]);
% Generating an Excel file containing output statistics (only for the Experimentation module)
if GeneratingExcelFile==1
    OutputExcel(AlgorithmName,BenchmarkName,ChangeFrequency,Dimension,PeakNumber,ShiftSeverity,RunNumber,EnvironmentNumber,E_o,E_bbc,[projectPath,'\Results']);
end
% Generating an output figure containing offline error and current error plots (only for the Experimentation module)
if OutputFig==1
    OutputPlot(CurrentError,RunNumber,E_o,E_bbc,AlgorithmName);
end
% Generating over-time figures for Education module
if (VisualizationOverOptimization==1)
    OutputEducationalFigures(Iteration,PeakNumber,VisualizationInfo,CurrentError,Problem);
end