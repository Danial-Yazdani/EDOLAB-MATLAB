# Evolutionary Dynamic Optimization Laboratory (EDOLAB)

> A MATLAB Optimization Platform for Education and Experimentation in Dynamic Environments

**Git repository:** [EDOLAB-platform/EDOLAB-MATLAB (github.com)](https://github.com/EDOLAB-platform/EDOLAB-MATLAB)

**The current version is `v1.00`**

## Author List
* **MAI PENG**, pengmai@cug.edu.cn, School of Automation, China University of Geosciences,Wuhan, Hubei Key Laboratory of Advanced Control and Intelligent Automation for Complex Systems, and Engineering Research Center of Intelligent Technology for Geo-Exploration, Ministry of
Education, China, 430074; 

* **ZENENG SHE**, 20s151103@stu.hit.edu.cn, School of Computer Science and Technology, Harbin Institute of Technology, Shenzhen, China, 518055; 

* **DELARAM YAZDANI**, delaram.yazdani@yahoo.com, Department of Computer Engineering, Mashhad Branch, Azad University, Mashhad, Iran; 

* **DANIAL YAZDANI**, danial.yazdani@gmail.com, Faculty of Engineering & Information Technology, University of Technology Sydney, Ultimo, Australia, 2007; 

* **WENJIAN LUO**, luowenjian@hit.edu.cn, Guangdong Provincial Key Laboratory of Novel Security Intelligence Technologies, School of Computer Science and Technology, Harbin Institute of Technology and Peng Cheng Laboratory, Shenzhen, China, 518055; 

* **CHANGHE LI**, changhe.lw@gmail.com, School of Automation, China University of Geosciences, Wuhan, Hubei Key Laboratory of Advanced Control and Intelligent Automation for Complex Systems, and Engineering Research Center of Intelligent Technology for Geo-Exploration, Ministry of Education, China, 430074; 

* **JUERGEN BRANKE**, Juergen.Branke@wbs.ac.uk, Operational Research and Management Sciences Group in Warwick Business school, University of Warwick, Coventry, United Kingdom, CV4 7AL; 

* **TRUNG THANH NGUYEN**, T.T.Nguyen@ljmu.ac.uk, The Liverpool Logistics, Offshore and Marine (LOOM) Research Institute, Faculty of Engineering and Technology, Liverpool John Moores University, Liverpool, United Kingdom, L2 2ER; 

* **AMIR H. GANDOMI**, Gandomi@uts.edu.au, Faculty of Engineering & Information Technology, University of Technology Sydney, Ultimo, Australia, 2007 and University Research and Innovation Center (EKIK), Obuda University, Budapest, Hungary, 1034; 

* **YAOCHU JIN**, yaochu.jin@uni-bielefeld.de, Faculty of Technology, Bielefeld University,
Bielefeld, Germany, 33615; 

* **XIN YAO**, xiny@sustech.edu.cn, Research Institute of Trustworthy Autonomous Systems (RITAS), and Guangdong Provincial Key Laboratory of Brain inspired Intelligent Computation, Department of Computer Science and Engineering, Southern University of Science and Technology, Shenzhen, China, 518055 and The Center of Excellence for Research in Computational Intelligence and Applications (CERCIA), School of Computer Science, University of Birmingham, Birmingham, United Kingdom, B15 2TT.

## Get Started

```bash
# clone the project
git clone https://github.com/EDOLAB-platform/EDOLAB-MATLAB
```

## Using EDOLAB via GUI

* **Experimentation module** 

  * Executing **GUI.MLAPP or RunWithGUI.m** in the root directory of EDOLAB
  * Select **Experiment tab**
  * Select an **algorithm** & **benchmark**
  * Set the parameters [*Dimension, Number of promising regions, Change Frequency, Shift Severity, Number of Environment, Run Number*]
  * Run the instance

  ![EDOLAB-Experiment](https://github.com/PengMai1998/EDOLAB-Assets/blob/main/EDOLAB-Experiment.png?raw=true)

* **Education module** 

  * Executing **GUI.MLAPP or RunWithGUI.m** in the root directory of EDOLAB

  * Select **Educational tab**

  * Select an **algorithm** & **benchmark**

  * Set the parameters [*Number of promising regions, Change Frequency, Shift Severity, Number of Environment*] 

    > *Please note that the education module is used for educational display, so the **dimension fixed as 2***

  * Run the instance

  ![EDOLAB-Experiment](https://github.com/PengMai1998/EDOLAB-Assets/blob/main/EDOLAB-Educational.png?raw=true)



## Using EDOLAB without GUI

* Open **RunWithoutGUI.m** in the root directory of EDOLAB

* Set ***AlgorithmName*** and ***BenchmarkName***

  > ```matlab
  > %% ********Selecting Algorithm & Benchmark********
  > AlgorithmName = 'psfNBC';    %Please input the name of algorithm (EADO) you want to run here (names are case sensitive).
  > %  The list of algorithms (EADOs) and some of their details can be found in Table 1 of the EDOLAB's paper.
  > %  The current version of EDOLAB includes the following algorithms (EADOs):
  > %  'ACFPSO', 'AMPDE', 'AMPPSO', 'AmQSO', 'AMSO', 'CDE', 'CESO', 'CPSO', 'CPSOR' 
  > %  'DSPSO', 'DynDE', 'DynPopDE', 'FTMPSO', 'HmSO',  'IDSPSO', 'ImQSO' 
  > %  'mCMAES', 'mDE', 'mjDE', 'mQSO' , 'SPSO_AD_AP', 'psfNBC', 'RPSO', 'TMIPSO'
  > BenchmarkName = 'GMPB';     %Please input the name of benchmark you want to use here (names are case sensitive).
  > %  The current version of EDOLAB includes the following benchmark generators: 'MPB' , 'GMPB' , 'FPs'
  > ```

* Set ***Benchmark Parameters*** 
  > ```matlab
  > %% ********Benchmark parameters and Run number********
  > PeakNumber                     = 10;  %The default value is 10
  > ChangeFrequency                = 5000;%The default value is 5000
  > Dimension                      = 5;   %The default value is 5. It must be set to 2 for using Education module
  > ShiftSeverity                  = 1;   %The default value is 1
  > EnvironmentNumber              = 100;  %The default value is 100
  > RunNumber                      = 31;   %It should be set to 31
  > ```
  _The algorithm parameters need to be set in the user-defined algorithm directory_
  
* Set ***VisualizationOverOptimization***
  
  > ```matlab
  > % For experimention module
  > VisualizationOverOptimization = 0
  > % For education module
  > VisualizationOverOptimization = 1
  > ```

_If VisualizationOverOptimization == 0, the experimentation module is activated, users can configure outputs bellow_
* Set ***OutputFigure***
  > ```matlab
  > % No need for plot
  > OutputFigure = 0
  > % Requires offline and current error plots as visualized outputs of the experiment
  > OutputFigure = 1
  > ```
  
* Set ***GeneratingExcelFile***
  > ```matlab
  > % No need for excel output
  > GeneratingExcelFile = 0
  > % Requires an excel file containing output statistics and results
  > GeneratingExcelFile = 1
  > ```

  ![EDOLAB-Experiment](https://github.com/PengMai1998/EDOLAB-Assets/blob/main/EDOLAB-ExcelResults.png?raw=true)

## Extension
* **Adding a benchmark generator**

  Assume that the user intends to add a new benchmark called ABC
  > * Users need to create a new sub-folder in the Benchmark folder and name it ABC
  >
  > * Two functions named **_fitness_ABC.m_** and _**BenchmarkGenerator_ABC.m**_ are then needed to be added into the ABC sub-folder.
  >
  >   > users need to define and initialize all the parameters of the new benchmark in a structure named Problem in *BenchmarkGenerator_ABC.m*
  >   >
  >   > the environmental parameters of all the environments need to be generated in *BenchmarkGenerator_ABC.m*
  >   >
  >   > *fitness_ABC.m* will contain the code of ABC’s baseline function
  >
  >   ![EDOLAB-AddProblem](https://github.com/PengMai1998/EDOLAB-Assets/blob/main/EDOLAB-AddProblem.jpg?raw=true)

* **Adding a performance indicator**

  > * Users need to add the code that collects the required information in fitness.m and store it in Problem structure.
  > * the code for calculating the performance indicator needs to be added in section %% Performance indicator calculation of the main function of EDOA.
  > * the results of the newly added performance indicator must be added to the outputs in section %% Output preparation at the
  >   bottom of the main function of EDOA.

* **Adding an EDOA**

  > * A sub-folder, which must be named similarly to the EDOA, needs to be created inside the Algorithm folder. Then, the functions of the new EDOA need to be added to this sub-folder.
  > * To run the new EDOA, it must be invoked by RunWithoutGUI.m. Thus, the user needs to consider the inputs and outputs of the main function of the EDOA when it is invoked by RunWithoutGUI.m.
  > * In the main function of the new EDOA, first, BenchmarkGenerator.m needs to be called for generating the problem instance.
  > * The code that generates and collects the information related to the education module needs to be added to the main loop of EDOA. This part of the code can be found in section %% Visualization for education module of the main function of EDOAs.
  > * Use fitness.m for evaluating fitness of solutions.
  > * To make the newly added EDOA accessible via EDOLAB, its main function file must be named as main_EDOA.m.

## For More Information

For more information about EDOLAB, please refer to the [paper](https://arxiv.org/abs/2308.12644). If you need further assistance, please contact Mai Peng at [pengmai@cug.edu.cn](mailto:pengmai@cug.edu.cn) or Danial Yazdani at [danial.yazdani@gmail.com](mailto:danial.yazdani@gmail.com).

## MATLAB Support
<img src="https://www.mathworks.com/etc.clientlibs/mathworks/clientlibs/customer-ui/templates/common/resources/images/pic-header-mathworks-logo.20221030234646672.svg" width="35%">
<br>

* Requires [Statistics and Machine Learning Toolbox](https://www.mathworks.com/help/stats/).
* **EDOLAB via GUI** requires [MATLAB R2020b+](https://www.mathworks.com/products/new_products/release2020b.html).
* **EDOLAB without GUI** requires [MATLAB R2016b+](https://www.mathworks.com/help/doc-archives.html).


## License

This program is to be used under the terms of the [GNU](http://www.gnu.org/copyleft/gpl.html) General Public License

Copyright (c) 2022-present **Danial Yazdani**
