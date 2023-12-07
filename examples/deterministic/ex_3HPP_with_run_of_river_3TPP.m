%% system inputs
inputs.conf.num_scenarios = 1;
inputs.conf.num_stages = 12;
inputs.conf.repeat_horizon = 5;

inputs.time_series.demand = NaN*ones(inputs.conf.num_stages, inputs.conf.num_scenarios);

inputs.time_series.demand(:,1) = [
    67475.83;
    63843.27;
    63576.78;
    63575.11;
    64450.51;
    65240.57;
    67445.95;
    67690.31;
    67829.72;
    73142.18;
    71937.69;
    69176.68;
];

inputs.conf.deficit_cost = 20;

%% thermal plants inputs
inputs.thermal_plants.num_thermal_plants = 3;
inputs.thermal_plants.thermal_costs = [
    8;
    10;
    12;
];

inputs.thermal_plants.thermal_plant_min_generation = [
    0;
    0;
    0;
];


inputs.thermal_plants.thermal_plant_max_generation = [
    5000;
    10000;
    15000;
];

%% hydro plants inputs
inputs.hydro_plants.num_hydro_plants = 3;

inputs.hydro_plants.production_factor = [
    1;
    1;
    1;
];

inputs.hydro_plants.initial_reservoir_volume = [
    86267;
    10726;
    0;
];

inputs.hydro_plants.reservoir_min_volume = .35 * [
    86267;
    10726;
    0;
];

inputs.hydro_plants.reservoir_max_volume = 2 * [
    86267;
    10726;
    0;
];

inputs.hydro_plants.max_turbined_volume = [
    63e3;    
    19e3;
    12.5e3;
];

inputs.hydro_plants.topology = {[], [], [1, 2]};

inputs.time_series.inflow = NaN*ones(inputs.conf.num_stages, ...
    inputs.hydro_plants.num_hydro_plants, inputs.conf.num_scenarios);

inputs.time_series.inflow(:,1,1) = [
    30865;
    24592;
    17724;
    16857;
    16140;
    25475;
    40228;
    45430;
    41746;
    45982;
    66045;
    52370;
];

inputs.time_series.inflow(:,2,1) = [
    3027;
    4973;
    6408;
    4711;
    11470;
    15629;
    10395;
    5793;
    7316;
    6603;
    9479;
    6650;
];

inputs.time_series.inflow(:,3,1) = [
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
    0;
];

%% resolve optimization
sol = hydrothermal_dispatch(inputs);

%% get results
reservoir_volume_opt = sol.reservoir_volume;
turbined_volume_opt = sol.turbined_volume;
spilled_volume_opt = sol.spilled_volume;
thermal_generation_opt = sol.thermal_generation;
generation_deficit = sol.generation_deficit;

hydro_generation = turbined_volume_opt .* inputs.hydro_plants.production_factor';
total_generation = horzcat(hydro_generation, thermal_generation_opt);

%% plots
figure(1);
bar(total_generation(1:12, :, 1), 'stacked');
title("Generation");
legend("UHE1", "UHE2", "UHE3", "UTE1", "UTE2", "UTE3");

figure(2);
area(reservoir_volume_opt(2:13, :, 1));
legend("UHE1", "UHE2", "UHE3");
title("Reservoir Volume");

figure(3);
area(turbined_volume_opt(1:12, :, 1));
legend("UHE1", "UHE2", "UHE3");
title("Turbined Volume");

figure(4);
area(spilled_volume_opt(1:12, :, 1));
legend("UHE1", "UHE2", "UHE3");
title("Spilled Volume");

figure(5)
area(inputs.time_series.inflow(:,:,1));
legend("UHE1", "UHE2", "UHE3");
title("Inflow Volume");
