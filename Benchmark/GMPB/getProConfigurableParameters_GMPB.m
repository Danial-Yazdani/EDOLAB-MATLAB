function ConfigurableParameters = getProConfigurableParameters_GMPB()
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


        % AngleSeverity: Intensity of rotation angle variations (in radians)
    ConfigurableParameters.AngleSeverity = struct( ...
        'value', pi/9, ...
        'type', 'numeric', ...
        'range', [0, pi], ...
        'description', 'Intensity factor for variations in peak rotation angles (radians).');

    % TauSeverity: Intensity of temporal dependency changes
    ConfigurableParameters.TauSeverity = struct( ...
        'value', 0.2, ...
        'type', 'numeric', ...
        'range', [0, 1], ...
        'description', 'Severity of changes in time-related parameters (tau).');

    % EtaSeverity: Intensity of asymmetry modifications
    ConfigurableParameters.EtaSeverity = struct( ...
        'value', 10, ...
        'type', 'numeric', ...
        'range', [0, 50], ...
        'description', 'Magnitude of variations in peak asymmetry (eta).');
end