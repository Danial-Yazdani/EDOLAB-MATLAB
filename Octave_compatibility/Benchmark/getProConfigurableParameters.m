function ConfigurableParameters = getProConfigurableParameters(BenchmarkName)
    getConfigurableParameters_Benchmark = str2func(['getProConfigurableParameters_',BenchmarkName]);
    ConfigurableParameters = getConfigurableParameters_Benchmark();
end