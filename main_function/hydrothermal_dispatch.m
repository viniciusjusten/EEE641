function [sol,fval,exitflag,output,lambda] = hydrothermal_dispatch(inputs)
    %% system inputs
    num_scenarios = inputs.conf.num_scenarios;
    num_stages = inputs.conf.num_stages;
    
    if ~isfield(inputs.conf, "probability")
        probability = ones(num_scenarios)/num_scenarios;
    else
        probability = inputs.conf.probability;
    end
    
    repeat_horizon = inputs.conf.repeat_horizon;

    demand = inputs.time_series.demand;

    deficit_cost = inputs.conf.deficit_cost;

    %% thermal plants inputs
    num_thermal_plants = inputs.thermal_plants.num_thermal_plants;
    thermal_costs = inputs.thermal_plants.thermal_costs;

    thermal_plant_min_generation = inputs.thermal_plants.thermal_plant_min_generation;

    thermal_plant_max_generation = inputs.thermal_plants.thermal_plant_max_generation;

    %% hydro plants inputs
    num_hydro_plants = inputs.hydro_plants.num_hydro_plants;

    production_factor = inputs.hydro_plants.production_factor;

    initial_reservoir_volume = inputs.hydro_plants.initial_reservoir_volume;

    reservoir_min_volume = inputs.hydro_plants.reservoir_min_volume;

    reservoir_max_volume = inputs.hydro_plants.reservoir_max_volume;

    max_turbined_volume = inputs.hydro_plants.max_turbined_volume;
    
    topology = inputs.hydro_plants.topology;

    inflow = inputs.time_series.inflow;
    
    %% repeat horizon
    num_stages = repeat_horizon * num_stages;
    inflow = repmat(inflow, repeat_horizon, 1);
    demand = repmat(demand, repeat_horizon, 1);

    %% variables definition
    thermal_generation = optimvar("thermal_generation", num_stages, num_thermal_plants, num_scenarios);
    reservoir_volume = optimvar("reservoir_volume", num_stages+1, num_hydro_plants, num_scenarios);
    turbined_volume = optimvar("turbined_volume", num_stages, num_hydro_plants, num_scenarios);
    spilled_volume = optimvar("spilled_volume", num_stages, num_hydro_plants, num_scenarios);
    generation_deficit = optimvar("generation_deficit", num_stages, num_scenarios);

    for thermal = 1:num_thermal_plants
        thermal_generation(:, thermal, :).LowerBound = thermal_plant_min_generation(thermal);
        thermal_generation(:, thermal, :).UpperBound = thermal_plant_max_generation(thermal);
    end

    for hydro = 1:num_hydro_plants
        reservoir_volume(1, hydro, :).LowerBound = initial_reservoir_volume(hydro);
        reservoir_volume(1, hydro, :).UpperBound = initial_reservoir_volume(hydro);

        reservoir_volume(2:num_stages+1, hydro, :).LowerBound = reservoir_min_volume(hydro);
        reservoir_volume(2:num_stages+1, hydro, :).UpperBound = reservoir_max_volume(hydro);

        turbined_volume(:, hydro, :).LowerBound = 0.0;
        turbined_volume(:, hydro, :).UpperBound = max_turbined_volume(hydro);

        spilled_volume(:, hydro, :).LowerBound = 0.0;
    end

    generation_deficit(:,:).LowerBound = 0.0;

    %% constraints definition
    load_balance = optimconstr(num_stages, num_scenarios);
    reservoir_balance = optimconstr(num_stages, num_hydro_plants, num_scenarios);

    for scenario = 1:num_scenarios
        for stage = 1:num_stages
            load_balance(stage, scenario) = dot(production_factor, turbined_volume(stage, :, scenario)) +...
                sum(thermal_generation(stage, :, scenario)) == demand(stage, scenario) - generation_deficit(stage, scenario);
            for hydro = 1:num_hydro_plants
                if isempty(topology{hydro})
                    cascade_inflows = 0;
                else
                    cascade_inflows = sum(spilled_volume(stage, topology{hydro}, scenario)) + ...
                        sum(turbined_volume(stage, topology{hydro}, scenario));
                end
                reservoir_balance(stage+1, hydro, scenario) = reservoir_volume(stage+1, hydro, scenario) == reservoir_volume(stage, hydro, scenario) + ...
                    + inflow(stage, hydro, scenario) - (spilled_volume(stage, hydro, scenario) + turbined_volume(stage, hydro, scenario)) ...
                    + cascade_inflows;
            end
        end
    end
    
    % non antecipativity constraints
    if num_scenarios > 1
        non_antecipativity_turbined = optimconstr(num_hydro_plants, num_scenarios-1);
        non_antecipativity_spilled = optimconstr(num_hydro_plants, num_scenarios-1);
        for scenario = 2:num_scenarios
            for hydro = 1:num_hydro_plants
                non_antecipativity_turbined(hydro, scenario-1) = turbined_volume(1, hydro, scenario - 1) == turbined_volume(1, hydro, scenario);
                non_antecipativity_spilled(hydro, scenario-1) = spilled_volume(1, hydro, scenario - 1) == spilled_volume(1, hydro, scenario);
            end
        end
    end

    %% objective function definition
    objective_function = optimexpr(num_scenarios);

    for scenario = 1:num_scenarios
        objective_function(scenario) = probability(scenario) * (deficit_cost * sum(generation_deficit(:, scenario)) + sum(thermal_generation(:, :, scenario) * thermal_costs));
    end

    %% assign problem and solve
    prob = optimproblem;
    prob.Constraints.load_balance = load_balance;
    prob.Constraints.reservoir_balance = reservoir_balance;
    if num_scenarios > 1
        prob.Constraints.non_antecipativity_turbined = non_antecipativity_turbined;
        prob.Constraints.non_antecipativity_spilled = non_antecipativity_spilled;
    end
    prob.Objective = sum(objective_function);
    [sol,fval,exitflag,output,lambda] = solve(prob);
    show(prob)
end
