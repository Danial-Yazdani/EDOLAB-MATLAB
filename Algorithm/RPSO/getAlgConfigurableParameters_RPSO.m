function ConfigurableParameters = getAlgConfigurableParameters_RPSO()
    % PopulationSize: Number of particles in each sub-swarm.
    ConfigurableParameters.PopulationSize = struct( ...
        'value', 5, ...
        'type', 'integer', ...
        'range', [0, 1000], ...
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

    % RandomizingPercentage: Proportion of particles randomly reinitialized whenever the environment changes.
    ConfigurableParameters.RandomizingPercentage = struct( ...
        'value', 0.5, ...
        'type', 'numeric', ...
        'range', [0, 1], ...
        'description', ['Percentage of particles randomly reinitialized when the environment changes, ' ...
        'helping to diversify the search and prevent premature convergence after environmental shifts.']);
    
end
