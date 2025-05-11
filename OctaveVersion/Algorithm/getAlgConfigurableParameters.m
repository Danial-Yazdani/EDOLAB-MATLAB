function ConfigurableParameters = getAlgConfigurableParameters(AlgorithmName)
    getConfigurableParameters_EDO = str2func(['getAlgConfigurableParameters_',AlgorithmName]);
    ConfigurableParameters = getConfigurableParameters_EDO();
end