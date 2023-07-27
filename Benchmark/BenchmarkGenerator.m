%% BenchmarkGenerator
function Problem = BenchmarkGenerator(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName)
    BenchmarkGenerator_Benchmark = str2func(['BenchmarkGenerator_',BenchmarkName]);
    Problem = BenchmarkGenerator_Benchmark(PeakNumber,ChangeFrequency,Dimension,ShiftSeverity,EnvironmentNumber,BenchmarkName);
end