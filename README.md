# Evolutionary Dynamic Optimization Laboratory (EDOLAB)

> A MATLAB Optimization Platform for Education and Experimentation in Dynamic Environments

**Git repository:** [Danial-Yazdani/EDOLAB-MATLAB (github.com)](https://github.com/Danial-Yazdani/EDOLAB-MATLAB)

**The current version is `v2.00`**

## Author List
* **MAI PENG**, pengmai@cug.edu.cn, School of Automation, China University of Geosciences,Wuhan, Hubei Key Laboratory of Advanced Control and Intelligent Automation for Complex Systems, and Engineering Research Center of Intelligent Technology for Geo-Exploration, Ministry of Education, China, 430074; 

* **DELARAM YAZDANI**, delaram.yazdani@yahoo.com, Liverpool Logistics, Offshore and Marine (LOOM) Research Institute, Faculty of Engineering and Technology, Liverpool John Moores University, United Kingdom, L2 2ER; 

* **DANIAL YAZDANI**, danial.yazdani@gmail.com, Business Intelligence Group, Department of Technology, WINC Australia, Australia;

* **ZENENG SHE**, 20s151103@stu.hit.edu.cn, School of Computer Science and Technology, Harbin Institute of Technology, Shenzhen, China, 518055; 

* **WENJIAN LUO**, luowenjian@hit.edu.cn, Guangdong Provincial Key Laboratory of Novel Security Intelligence Technologies, School of Computer Science and Technology, Harbin Institute of Technology and Peng Cheng Laboratory, Shenzhen, China, 518055; 

* **CHANGHE LI**, School of Artificial Intelligence, Anhui University of Science & Technology, Hefei, China, 230000; 

* **JUERGEN BRANKE**, Juergen.Branke@wbs.ac.uk, Operational Research and Management Sciences Group in Warwick Business school, University of Warwick, Coventry, United Kingdom, CV4 7AL; 

* **TRUNG THANH NGUYEN**, T.T.Nguyen@ljmu.ac.uk, The Liverpool Logistics, Offshore and Marine (LOOM) Research Institute, Faculty of Engineering and Technology, Liverpool John Moores University, Liverpool, United Kingdom, L2 2ER; 

* **AMIR H. GANDOMI**, Gandomi@uts.edu.au, Faculty of Engineering & Information Technology, University of Technology Sydney, Ultimo, Australia, 2007 and University Research and Innovation Center (EKIK), Obuda University, Budapest, Hungary, 1034; 

* **SHENGXIANG YANG**, syang@dmu.ac.uk, Institute of Artificial Intelligence (IAI), School of Computer Science and Informatics, De Montfort University, Leicester, United Kingdom, LE1 9BH; 

* **YAOCHU JIN**, yaochu.jin@uni-bielefeld.de, Faculty of Technology, Bielefeld University,
Bielefeld, Germany, 33615; 

* **XIN YAO**, xiny@sustech.edu.cn, Research Institute of Trustworthy Autonomous Systems (RITAS), and Guangdong Provincial Key Laboratory of Brain inspired Intelligent Computation, Department of Computer Science and Engineering, Southern University of Science and Technology, Shenzhen, China, 518055 and The Center of Excellence for Research in Computational Intelligence and Applications (CERCIA), School of Computer Science, University of Birmingham, Birmingham, United Kingdom, B15 2TT.

## Get Started

```bash
# clone the project
git clone https://github.com/Danial-Yazdani/EDOLAB-MATLAB
```

## Architecture Overview
Modular structure with core components:
```
├── Algorithm/             # EDOA implementations (ACFPSO, CDE, mQSO, etc.)
├── Benchmark/             # Benchmark generators (GMPB, MPB, FPs, GDBG)
├── Utility/               # Helper functions
├── Octave_compatibility/  # Octave-specific adaptations
├── GUIMode.m              # GUI entry point
└── CodeMode.m             # Script mode entry
```

## Running EDOLAB

> The current version of the GUI Mode is relatively well-developed, and we strongly recommend using it.


### GUI Mode (MATLAB R2020b+)
```matlab
% Launch graphical interface
run GUIMode.m
```

* **Experimentation module** 

**Core Features:**
- Experiment configuration management
- Batch task processing
- Real-time progress monitoring
- Statistical significance analysis
- Interactive visualizations (Trend/Box plots)

![GUI Demo](https://github.com/PengMai1998/EDOLAB-Assets/blob/main/ExperimentationModule.png?raw=true)

* **Education module** 

**Core Features:**
- Step-by-step visualization of optimization process
- Interactive control over iteration playback
- Real-time population behavior tracking
- Interactive control, freely start, stop, or jump to any iteration

![GUI Demo](https://github.com/PengMai1998/EDOLAB-Assets/blob/main/EducationModule.png?raw=true)


### Code Mode (MATLAB R2016b+/Octave)
```matlab
% Configure Algorithm & Benchmark in CodeMode.m
AlgorithmName = 'mQSO';  
BenchmarkName = 'MPB';
VisualizationOverOptimization = 0;  % 1=Education Mode

% Configure algorithm parameters in getAlgConfigurableParameters_EDO.m

function ConfigurableParameters = getAlgConfigurableParameters_mQSO()
    % PopulationSize: Number of particles in each sub-swarm.
    ConfigurableParameters.PopulationSize = struct( ...
        'value', 5, ...
        'type', 'integer', ...
        'range', [0, 100], ...
        'description', 'Number of particles in each sub-swarm.');

    % x: Inertia weight used in velocity update.
    ConfigurableParameters.x = struct( ...
        'value', 0.729843788, ...
        'type', 'numeric', ...
        'range', [0, 2], ...
        'description', 'Inertia weight used in particle velocity update.');

    % c1: Cognitive coefficient influencing personal best position attraction.
    ConfigurableParameters.c1 = struct( ...
        'value', 2.05, ...
        'type', 'numeric', ...
        'range', [0, 5], ...
        'description', 'Cognitive coefficient that scales influence of personal best.');

    % c2: Social coefficient influencing global best position attraction.
    ConfigurableParameters.c2 = struct( ...
        'value', 2.05, ...
        'type', 'numeric', ...
        'range', [0, 5], ...
        'description', 'Social coefficient that scales influence of global best.');

    % QuantumNumber: Number of quantum particles generated per iteration.
    ConfigurableParameters.QuantumNumber = struct( ...
        'value', 5, ...
        'type', 'integer', ...
        'range', [0, 100], ...
        'description', 'Number of quantum particles generated to explore space around best solution.');

    % SwarmNumber: Total number of sub-swarms in the population.
    ConfigurableParameters.SwarmNumber = struct( ...
        'value', 10, ...
        'type', 'integer', ...
        'range', [0, 100], ...
        'description', 'Number of sub-swarms.');
end

% Configure benchmark parameters in getProConfigurableParameters_Benchmark.m

function ConfigurableParameters = getProConfigurableParameters_MPB()
    % Dimension: Dimensionality of the search space
    ConfigurableParameters.Dimension = struct( ...
        'value', 5, ...
        'type', 'integer', ...
        'range', [2, 100], ...
        'description', 'Number of dimensions in the optimization problem.');

    % PeakNumber: Quantity of peaks in dynamic landscape
    ConfigurableParameters.PeakNumber = struct( ...
        'value', 10, ...
        'type', 'integer', ...
        'range', [1, 500], ...
        'description', 'Number of peaks in the dynamic environment.');

    % ChangeFrequency: Evaluations between environmental changes
    ConfigurableParameters.ChangeFrequency = struct( ...
        'value', 5000, ...
        'type', 'integer', ...
        'range', [100, 20000], ...
        'description', 'Number of function evaluations between environment changes.');

    % ShiftSeverity: Magnitude of peak position changes
    ConfigurableParameters.ShiftSeverity = struct( ...
        'value', 1, ...
        'type', 'numeric', ...
        'range', [0, 10], ...
        'description', 'Magnitude of positional shifts during environment changes.');

    
    % EnvironmentNumber: Total environmental states
    ConfigurableParameters.EnvironmentNumber = struct( ...
        'value', 100, ...
        'type', 'integer', ...
        'range', [1, 1000], ...
        'description', 'Total number of distinct environmental states.');

    % HeightSeverity: Intensity of peak height variations
    ConfigurableParameters.HeightSeverity = struct( ...
        'value', 7, ...
        'type', 'numeric', ...
        'range', [0, 20], ...
        'description', 'Intensity factor for peak height modifications.');

    % WidthSeverity: Intensity of peak width variations
    ConfigurableParameters.WidthSeverity = struct( ...
        'value', 1, ...
        'type', 'numeric', ...
        'range', [0, 6], ...
        'description', 'Intensity factor for peak width modifications.');
end

run CodeMode.m
```

## Extension

### Adding New Algorithms
1. **Create algorithm folder**  
   Under `Algorithm/`, create a new sub-folder named after your EDOA (e.g. `XYZ`).

2. **Implement the five core functions**  
   Place these files inside your new folder:
   - `main_XYZ.m`  
     Main entry point—must accept and return the standardized Problem and Output structures.
   - `SubPopulationGenerator_XYZ.m`  
     Generates or updates the algorithm’s subpopulations.
   - `IterativeComponents_XYZ.m`  
     Contains the core search/update loop for each iteration.
   - `ChangeReaction_XYZ.m`  
     Handles detection of and adaptation to environmental changes.
   - `getAlgConfigurableParameters_XYZ.m`  
     Defines all user-configurable parameters (fields: `value`, `type`, `range`, `description`).

3. **Hook into CodeMode**  
   Ensure that `CodeMode.m` can invoke `main_XYZ.m` by setting:
   ```matlab
   AlgorithmName = 'XYZ';
   ```

4. **Visualization & Output**

   * Use the `%% Visualization for education` section pattern from existing EDOAs to collect GUI data.
   * At the end of `main_XYZ.m`, assemble an `Results.Indicators` structure consistent with EDOLAB’s reporting modules.


### Adding New Benchmarks

1. **Create benchmark folder**
   Under `Benchmark/`, create a sub-folder named after your benchmark (e.g. `ABC`).

2. **Implement the three core files**
   Inside `Benchmark/ABC/` add:

   * `getProConfigurableParameters_ABC.m`
     Define `ConfigurableParameters` with fields:

     ```matlab
     ConfigurableParameters.ParamName = struct( ...
       'value', <default>, ...
       'type',  '<numeric|integer|option>', ...
       'range', [...], ...
       'description', '…' ...
     );
     ```
   * `BenchmarkGenerator_ABC.m`
     Builds the `Problem` structure (environments, dynamics) based solely on the parameters from `getProConfigurableParameters_ABC.m`.
   * `fitness_ABC.m`
     Computes the baseline fitness for each solution, conforming to EDOLAB’s input/output conventions.

3. **Automatic integration**
   Once these files are in place, your new benchmark will appear in the GUI list and can be run via `CodeMode.m`.


### Custom Performance Metrics

1. **Edit the JSON interface**
   Open `Indicators/indicators.json` and add:

   ```json
   "MyMetric": {
     "type": "FE based"          // or "Environment based" / "None"
   }
   ```

2. **Implement in `fitness.m`**
   In `fitness.m`, compute and store your metric:

   ```matlab
   % FE based (every evaluation)
   Problem.Indicators.MyMetric.trend(Problem.FE) = <your calculation>;

   % Environment based (per environment)
   Problem.Indicators.MyMetric.trend(Problem.EnvironmentCounter) = <your calculation>;

   % None (final only)
   Problem.Indicators.MyMetric.final = <your calculation>;
   ```

3. **Verify & Use**

   * In **GUI Mode**, run one task and check the Completed Tasks panlel or Statistical Analysis panel to see your new indicator.
   * In **Code Mode**, confirm `Results.Indicators.MyMetric` appears in results.


## Octave Support
1. Replace files with those in `Octave_compatibility/`
2. Install required packages:
```octave
pkg install -forge io statistics
pkg load io statistics
```
3. Compile KDTree component:
```bash
mkoctfile --mex ConstructKDTree.cpp
```


## For More Information

For more information about EDOLAB, please refer to the [paper](https://arxiv.org/abs/2308.12644) and user manual. If you need further assistance, please contact Mai Peng at [pengmai1998@gmail.com](mailto:pengmai1998@gmail.com) or Danial Yazdani at [danial.yazdani@gmail.com](mailto:danial.yazdani@gmail.com).

## MATLAB Support
<img src="https://www.mathworks.com/etc.clientlibs/mathworks/clientlibs/customer-ui/templates/common/resources/images/pic-header-mathworks-logo.20221030234646672.svg" width="35%">
<br>

* **GUI Mode** requires [MATLAB R2020b+](https://www.mathworks.com/products/new_products/release2020b.html) and the **Parallel Computing Toolbox**. Recommended [MATLAB R2024a](https://www.mathworks.com/products/new_products/release2024a.html) or later.
* **Code Mode** requires [MATLAB R2016b+](https://www.mathworks.com/help/doc-archives.html).


## License

This program is to be used under the terms of the [GNU](http://www.gnu.org/copyleft/gpl.html) General Public License

Copyright (c) 2022-present **Danial Yazdani**
