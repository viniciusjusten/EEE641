%% system inputs
inputs.conf.num_scenarios = 2;
inputs.conf.num_stages = 2;
inputs.conf.repeat_horizon = 1;

inputs.conf.probability = [.5, .5];

inputs.time_series.demand = NaN*ones(inputs.conf.num_stages, inputs.conf.num_scenarios);

% cenário 1
inputs.time_series.demand(:,1) = [
    100;
    200;
];
% cenário 2
inputs.time_series.demand(:,2) = [
    100;
    200;
];

inputs.conf.deficit_cost = 1000;

%% thermal plants inputs
inputs.thermal_plants.num_thermal_plants = 1;
inputs.thermal_plants.thermal_costs = [
    150;
];

inputs.thermal_plants.thermal_plant_min_generation = [
    0;
];


inputs.thermal_plants.thermal_plant_max_generation = [
    200;
];

%% hydro plants inputs
inputs.hydro_plants.num_hydro_plants = 1;

inputs.hydro_plants.production_factor = ones(1,1);

inputs.hydro_plants.initial_reservoir_volume = [
    100;
];

inputs.hydro_plants.reservoir_min_volume = [
    100;
];

inputs.hydro_plants.reservoir_max_volume = [
    500;
];

inputs.hydro_plants.max_turbined_volume = [
    200;
];

inputs.hydro_plants.topology = {[]};

inputs.time_series.inflow = NaN*ones(inputs.conf.num_stages, ...
    inputs.hydro_plants.num_hydro_plants, inputs.conf.num_scenarios);

% cenario 1
inputs.time_series.inflow(:,1,1) = [
    120;
    95;
];
% cenario 2
inputs.time_series.inflow(:,1,2) = [
    120;
    85;
];

%% resolve optimization
[sol,fval,exitflag,output,lambda] = hydrothermal_dispatch(inputs);

%% get results
reservoir_volume_opt = sol.reservoir_volume;
turbined_volume_opt = sol.turbined_volume;
spilled_volume_opt = sol.spilled_volume;
thermal_generation_opt = sol.thermal_generation;
generation_deficit_opt = sol.generation_deficit;

save("1hpp_1tpp_prob_igual", "reservoir_volume_opt", "turbined_volume_opt", "spilled_volume_opt", ...
"thermal_generation_opt", "generation_deficit_opt", "lambda");
