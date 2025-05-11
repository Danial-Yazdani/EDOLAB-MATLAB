%*********************************EDOLAB ver 2.00*********************************
%
%Authors: Mai Peng and Danial Yazdani
% e-mails: pengmai1998 AT gmail DOT com
%          danial DOT yazdani AT gmail DOT com
%Last Edited: September 22, 2024
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
pkg load statistics;
pkg load io;

nowPath = mfilename('fullpath');
projectPath = nowPath(1:max(strfind(nowPath,'\'))-1);
addpath(genpath(projectPath));
%% ********Selecting Algorithm & Benchmark********
AlgorithmName = 'ACFPSO';    %Please input the name of algorithm (EADO) you want to run here (names are case sensitive).
%  The list of algorithms (EADOs) and some of their details can be found in Table 1 of the EDOLAB's paper.
%  The current version of EDOLAB includes the following algorithms (EADOs):
%  'ACFPSO' , 'AMPDE' , 'AMPPSO' , 'AmQSO' , 'AMSO' , 'CDE' , 'CESO', 'CPSO' , 'CPSOR'
%  'DSPSO' , 'DynDE' , 'DynPopDE' , 'FTMPSO' , 'HmSO' ,  'IDSPSO' , 'ImQSO' , 'mCMAES'
%  'mDE' , 'mjDE' , 'mPSO' , 'mQSO' , 'psfNBC' , 'RPSO' , 'SPSO_AP_AD' ,
%  'TMIPSO', 'DPCPSO', 'APCPSO'
BenchmarkName = 'FPs';     %Please input the name of benchmark you want to use here (names are case sensitive).
%  The current version of EDOLAB includes the following benchmark generators: 'MPB' , 'GDBG' , 'GMPB' , 'FPs'

% Run the mkoctfile command automatically if BenchmarkName is 'FPs'
if strcmp(BenchmarkName, 'FPs')
    % Define the Kdtree folder path and the cpp file
    kdtree_dir = fullfile(projectPath, 'Utility', 'Kdtree');
    cpp_file = fullfile(kdtree_dir, 'ConstructKDTree.cpp');
    output_file = fullfile(kdtree_dir, 'ConstructKDTree.mex');

    % Check if the output file exists; if not, run mkoctfile to compile
    if exist(output_file, 'file') == 0
        disp('Compiling ConstructKDTree.cpp...');
        system(['mkoctfile -v --mex "', cpp_file, '" -output "', output_file, '"']);
        disp('Compilation complete!');
    else
        disp('ConstructKDTree.mex already exists. Skipping compilation.');
    end
else
    disp('Benchmark is not FPs. Skipping mkoctfile compilation.');
end
%% Get the algorithm and benchmark lists
AlgorithmsFloder = dir([projectPath, '/Algorithm']);
AlgorithmsList = repmat({''}, length(AlgorithmsFloder)-2, 1);
for i = 3:length(AlgorithmsFloder)
    AlgorithmsList{i-2,1} = AlgorithmsFloder(i).name;  % <-- notice { }
end

BenchmarksFloder = dir([projectPath, '/Benchmark']);
BenchmarksList = repmat({''}, length(BenchmarksFloder)-5, 1);  % <-- use {''} not ""

BenchmarksCount = 0;
for i = 3:length(BenchmarksFloder)
    if isempty(strfind(BenchmarksFloder(i).name,'.m'))
        BenchmarksCount = BenchmarksCount + 1;
        BenchmarksList{BenchmarksCount,1} = BenchmarksFloder(i).name;  % <-- notice { }
    end
end
if(~ismember(AlgorithmName,AlgorithmsList))
    error("No Such Algorithm in EDOLAB");
elseif(~ismember(BenchmarkName,BenchmarksList))
    error("No Such Benchmark in EDOLAB");
end
%% ********Algorithm parameters, Benchmark parameters and Run number********
% To modify configuration parameters, please edit:
% - Algorithm settings: getAlgConfigurableParameters_[EDO].m in the selected algorithm folder
% - Problem settings: getProConfigurableParameters_[Benchmark].m in the selected problem folder
ConfigurableAlgParameters = getAlgConfigurableParameters(AlgorithmName);
ConfigurableProParameters = getProConfigurableParameters(BenchmarkName);
Dimension                      = ConfigurableProParameters.Dimension.value;
RunNumber                      = 1;   %It should be set to 31 in Experimentation module, and must be set to 2 for using Education module.
%% ********Figures and Outputs********
GeneratingExcelFile            = 1;   %Set to 1 (only for using the Experimentation module) to save the output statistics in an Excel file (in the Results folder), 0 otherwise.
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
    ConfigurableProParameters.Dimension.value                  = 2;
    RunNumber                                                  = 1;
    GeneratingExcelFile                                        = 0;
    OutputFig                                                  = 0;
end
%% Running the chosen algorithm (EDOA) on the chosen benchmark
main_EDO = str2func(['main_',AlgorithmName]);
ProgressInfo = struct('IsParallel', false);
[Problem,Results,CurrentError,VisualizationInfo,Iteration] = main_EDO(VisualizationOverOptimization, RunNumber, BenchmarkName, ConfigurableProParameters, ConfigurableAlgParameters, ProgressInfo);
%% Output
close;clc;
fields = fieldnames(Results);
for i = 1:numel(fields)
    name = fields{i};
    info = Results.(name);
    if isfield(info, 'mean') && isfield(info, 'median') && isfield(info, 'StdErr')
        disp([name, ' ==> Mean = ', num2str(info.mean), ', Median = ', num2str(info.median), ', Standard Error = ', num2str(info.StdErr)]);
    end
end

% Generating an Excel file containing output statistics (only for the Experimentation module)
if GeneratingExcelFile==1
    OutputDetailResultsToExcel(AlgorithmName, ConfigurableAlgParameters, BenchmarkName, ConfigurableProParameters, Results, [projectPath,'\Results\TaskDetailResults']);
end
% Generating an output figure containing offline error and current error plots (only for the Experimentation module)
if OutputFig==1
    OutputPlot(CurrentError,RunNumber,Results.E_o,Results.E_bbc,AlgorithmName);
end
% Generating over-time figures for Education module
if (VisualizationOverOptimization==1)
    OutputEducationalFigures(Iteration,ConfigurableProParameters.PeakNumber.value,VisualizationInfo,CurrentError,Problem);
end
