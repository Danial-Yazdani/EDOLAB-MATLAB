%*********************************EDOLAB ver 1.00*********************************
%
%Authors: Danial Yazdani and Mai Peng
% e-mails: danial DOT yazdani AT gmail DOT com
%          pengmai1998 AT gmail DOT com
%Last Edited: November 02, 2022
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
% This function calculates the objective function value (i.e., fitness evaluation).
% In addition, this function manages the benchmark control parameters and gathers 
% the required data for generating plots and calculating performance indicators.
%
% --------
% License:
% --------
% This program is to be used under the terms of the GNU General Public License
% (http://www.gnu.org/copyleft/gpl.html).
% e-mail: danial DOT yazdani AT gmail DOT com
% Copyright notice: (c) 2023 Danial Yazdani
%*********************************************************************************
function [result,Problem] = fitness(X,Problem)
   fitness_Benchmark = str2func(['fitness_',Problem.BenchmarkName]);
   [SolutionNumber,~] = size(X);
   result = NaN(SolutionNumber,1);
   for jj=1 : SolutionNumber
       if Problem.FE >= Problem.MaxEvals || Problem.RecentChange == 1
           return;
       end
       [result(jj),Problem] = fitness_Benchmark(X(jj,:),Problem);
       Problem.FE = Problem.FE + 1;
       SolutionError = Problem.OptimumValue(Problem.Environmentcounter) - result(jj);
       if rem(Problem.FE , Problem.ChangeFrequency)~=1
           if Problem.CurrentError(Problem.FE-1)<SolutionError
               Problem.CurrentError(Problem.FE) = Problem.CurrentError(Problem.FE-1);
               Problem.CurrentPerformance(Problem.FE) = Problem.CurrentPerformance(Problem.FE-1);
           else
               Problem.CurrentError(Problem.FE) = SolutionError;
               Problem.CurrentPerformance(Problem.FE) = result(jj);
           end
       else
           Problem.CurrentError(Problem.FE) =  SolutionError;
           Problem.CurrentPerformance(Problem.FE) =  result(jj);
       end
       if rem(Problem.FE , Problem.ChangeFrequency) == (Problem.ChangeFrequency-1)
           Problem.Ebbc(Problem.Environmentcounter) = Problem.CurrentError(Problem.FE);
       end
       if ~rem(Problem.FE , Problem.ChangeFrequency) && Problem.FE < Problem.MaxEvals
           Problem.Environmentcounter = Problem.Environmentcounter+1;
           Problem.RecentChange = 1;
       end

       % Calculate your user-defined indicators here
       % 
       % Notes:
       % - If the indicator is of type 'FE based' or 'Environment based', 
       %   you must properly maintain the 'trend' field.
       %   Make sure the 'trend' array has a length consistent with the number of FEs or environments.
       % - If the indicator is of type 'None', 
       %   you must provide a scalar value for the 'final' field at the end of the evaluation.
       
       % Example:
       
       % For indicators of type 'FE based', update the indicator's trend at each fitness evaluation.
       Problem.Indicators.E_o.trend(Problem.FE) = Problem.CurrentError(Problem.FE);
       % For indicators of type 'Environment based', update the indicator's trend when the environment changes.
       if rem(Problem.FE, Problem.ChangeFrequency) == (Problem.ChangeFrequency - 1)
           Problem.Indicators.E_bbc.trend(Problem.Environmentcounter) = Problem.Ebbc(Problem.Environmentcounter);
       end
       % For indicators of type 'None', provide the final value of the indicator after the last evaluation.
   end
end