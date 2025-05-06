%% BenchmarkGenerator
function Problem = BenchmarkGenerator(BenchmarkName, ConfigurableParameters)
    BenchmarkGenerator_Benchmark = str2func(['BenchmarkGenerator_',BenchmarkName]);
    Problem = BenchmarkGenerator_Benchmark(BenchmarkName, ConfigurableParameters);
end