%% EnvironmentVisualization
function [result] = EnvironmentVisualization(X,Problem)
   fitness_Benchmark = str2func(['fitness_',Problem.BenchmarkName]);
   [SolutionNumber,~] = size(X);
   result = NaN(SolutionNumber,1);
   for jj=1 : SolutionNumber
       [result(jj),~] = fitness_Benchmark(X(jj,:),Problem);
   end
end