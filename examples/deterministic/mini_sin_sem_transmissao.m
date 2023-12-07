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

inputs.conf.deficit_cost = 100;

%% thermal plants inputs
inputs.thermal_plants.num_thermal_plants = 4;
inputs.thermal_plants.thermal_costs = [
    12;
    8;
    20;
    10;
];

inputs.thermal_plants.thermal_plant_min_generation = [
    0;
    0;
    0;
    0;
];


inputs.thermal_plants.thermal_plant_max_generation = [
    7.4e3; % UTE NE
    4e3; % UTE N
    20e3; % UTE SE
    4.5e3; % UTE S
];

%% hydro plants inputs
inputs.hydro_plants.num_hydro_plants = 8;

inputs.hydro_plants.production_factor = ones(8,1);

inputs.hydro_plants.initial_reservoir_volume = [
    0;
    0;
    0;
    0;
    20332;
    10726;
    86267;
    9854;
];

inputs.hydro_plants.reservoir_min_volume = 0.35*[
    0;
    0;
    0;
    0;
    20332;
    10726;
    86267;
    9854;
];

inputs.hydro_plants.reservoir_max_volume = 2*[
    0;
    0;
    0;
    0;
    20332;
    10726;
    86267;
    9854;
];

inputs.hydro_plants.max_turbined_volume = [
    12.5e3; % eolica NE
    350; % eolica N
    30; % eolica SE
    2e3; % eolica S
    11e3; % hidro NE 
    19e3; % hidro N 
    63e3; % hidro SE 
    17e3; % hidro S 
];

inputs.hydro_plants.topology = {[], [], [], [], [], [], [], []};

inputs.time_series.inflow = NaN*ones(inputs.conf.num_stages, ...
    inputs.hydro_plants.num_hydro_plants, inputs.conf.num_scenarios);

% eólica NE
inputs.time_series.inflow(:,1,1) = [
    4297.3;
    5322.4;
    5931.5;
    6300.8;
    6685.5;
    5546.4;
    6178.6;
    4338.9;
    5052.9;
    2907.9;
    2879.1;
    3131.4;
];

% eólica N
inputs.time_series.inflow(:,2,1) = [
    47.0;
    94.0;
    109.4;
    145.0;
    168.7;
    142.3;
    161.1;
    91.6;
    119.4;
    81.7;
    69.8;
    57.3;
];

% eólica SE
inputs.time_series.inflow(:,3,1) = [
    2.3;
    4.2;
    4.7;
    5.0;
    7.4;
    9.6;
    9.3;
    6.5;
    13.5;
    5.6;
    3.6;
    4.2;
];

% eólica S
inputs.time_series.inflow(:,4,1) = [
    635.9;
    612.0;
    746.3;
    774.4;
    812.6;
    715.1;
    845.3;
    666.8;
    646.1;
    421.4;
    604.4;
    507.5;
];

% hídrica NE
inputs.time_series.inflow(:,5,1) = [
    2454;
    1727;
    1486;
    1334;
    1273;
    1412;
    3794;
    8717;
    5168;
    3647;
    6224;
    6413;
];

% hídrica N
inputs.time_series.inflow(:,6,1) = [
    14254;
    6203;
    3493;
    2280;
    1583;
    1476;
    3294;
    9534;
    12172;
    14902;
    22438;
    25662;
];

% hídrica SE
inputs.time_series.inflow(:,7,1) = [
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

% hídrica S
inputs.time_series.inflow(:,8,1) = [
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

%% resolve optimization
[sol,fval,exitflag,output,lambda] = hydrothermal_dispatch(inputs);

%% get results
reservoir_volume_opt = sol.reservoir_volume;
turbined_volume_opt = sol.turbined_volume;
spilled_volume_opt = sol.spilled_volume;
thermal_generation_opt = sol.thermal_generation;
generation_deficit_opt = sol.generation_deficit;

hydro_generation = turbined_volume_opt(1:inputs.conf.num_stages, :, 1) .* inputs.hydro_plants.production_factor';
total_generation = horzcat(hydro_generation, thermal_generation_opt(1:inputs.conf.num_stages, :, 1), generation_deficit_opt(1:inputs.conf.num_stages, 1));

total_cost = thermal_generation_opt(1:inputs.conf.num_stages, :, 1) * inputs.thermal_plants.thermal_costs + ...
    generation_deficit_opt(1:inputs.conf.num_stages, 1) * inputs.conf.deficit_cost;
%% plots
dates = datetime(2018, 05, 01):calmonths(1):datetime(2019, 04, 01);

figure(1);
area(dates, hydro_generation(1:inputs.conf.num_stages, 1:4, 1));
title("Geração Eólica");
legend("NE", "N", "SE", "S");

figure(2);
area(dates, hydro_generation(1:inputs.conf.num_stages, 5:8, 1));
title("Geração Hidrelétrica");
legend("NE", "N", "SE", "S");

figure(3);
area(dates, thermal_generation_opt(1:inputs.conf.num_stages, :, 1));
title("Geração Térmica");
legend("NE", "N", "SE", "S");

figure(4);
area(dates, reservoir_volume_opt(1:inputs.conf.num_stages,5:8,1));
legend("NE", "N", "SE", "S");
title("Energia Armazenada");

figure(5);
area(dates, turbined_volume_opt(1:inputs.conf.num_stages,1:4,1));
legend("NE", "N", "SE", "S");
title("Energia Eólica Turbinada");

figure(6);
area(dates, turbined_volume_opt(1:inputs.conf.num_stages,5:8,1));
legend("NE", "N", "SE", "S");
title("Energia Hidrelétrica Turbinada");

figure(7);
area(dates, spilled_volume_opt(1:inputs.conf.num_stages,1:4,1));
legend("NE", "N", "SE", "S");
title("Energia Eólica Vertida");

figure(8);
area(dates, spilled_volume_opt(1:inputs.conf.num_stages,5:8,1));
legend("NE", "N", "SE", "S");
title("Energia Hidrelétrica Vertida");

figure(9)
area(dates, inputs.time_series.inflow(1:inputs.conf.num_stages,1:4,1));
legend("NE", "N", "SE", "S");
title("Energia Eólica Afluente");

figure(10)
area(dates, inputs.time_series.inflow(1:inputs.conf.num_stages,5:8,1));
legend("NE", "N", "SE", "S");
title("Energia Hidrelétrica Afluente");

figure(11);
bar(dates, total_cost);
title("Generation Cost");

figure(12);
bar(dates, -lambda.Constraints.load_balance(1:inputs.conf.num_stages,1));
title("Custo Marginal");
