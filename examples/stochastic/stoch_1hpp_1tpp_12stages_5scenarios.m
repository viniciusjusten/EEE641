%% system inputs
inputs.conf.num_scenarios = 5;
inputs.conf.num_stages = 12;
inputs.conf.repeat_horizon = 5;

inputs.time_series.demand = NaN*ones(inputs.conf.num_stages, inputs.conf.num_scenarios);

inputs.time_series.demand(:,1) = .7*[
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

inputs.time_series.demand(:,2) = inputs.time_series.demand(:,1);
inputs.time_series.demand(:,3) = inputs.time_series.demand(:,1);
inputs.time_series.demand(:,4) = inputs.time_series.demand(:,1);
inputs.time_series.demand(:,5) = inputs.time_series.demand(:,1);

inputs.conf.deficit_cost = 100;

%% thermal plants inputs
inputs.thermal_plants.num_thermal_plants = 1;
inputs.thermal_plants.thermal_costs = [
    10;
];

inputs.thermal_plants.thermal_plant_min_generation = [
    0;
];


inputs.thermal_plants.thermal_plant_max_generation = [
    20e3;
];

%% hydro plants inputs
inputs.hydro_plants.num_hydro_plants = 1;

inputs.hydro_plants.production_factor = ones(1,1);

inputs.hydro_plants.initial_reservoir_volume = [
    86267;
];

inputs.hydro_plants.reservoir_min_volume = 0.35*[
    86267;
];

inputs.hydro_plants.reservoir_max_volume = 2*[
    86267;
];

inputs.hydro_plants.max_turbined_volume = [
    63e3;
];

inputs.hydro_plants.topology = {[]};

inputs.time_series.inflow = NaN*ones(inputs.conf.num_stages, ...
    inputs.hydro_plants.num_hydro_plants, inputs.conf.num_scenarios);

inputs.time_series.inflow(:,1,1) = [
    38027;
    31347;
    17969;
    26222;
    18468;
    53289;
    51240;
    54885;
    53087;
    54631;
    55304;
    58066;
];

inputs.time_series.inflow(:,1,2) = [
    39791;
    29184;
    18686;
    37726;
    15145;
    51138;
    48561;
    43195;
    52794;
    49678;
    59147;
    56658;
];

inputs.time_series.inflow(:,1,3) = [
    25732;
    18375;
    39497;
    19125;
    26445;
    43232;
    48180;
    57686;
    41638;
    40843;
    44093;
    57025;
];
    
inputs.time_series.inflow(:,1,4) = [
    19300;
    37510;
    19067;
    22374;
    17333;
    51588;
    59853;
    48224;
    50519;
    49977;
    49177;
    51365;
];

inputs.time_series.inflow(:,1,5) = [
    17661;
    29929;
    16085;
    36315;
    17126;
    51324;
    42689;
    41667;
    44079;
    48554;
    49891;
    56890;
];

%% resolve optimization
[sol,fval,exitflag,output,lambda] = hydrothermal_dispatch(inputs);

%% get results

inflow_s1 = inputs.time_series.inflow(1:12, :, 1);
inflow_s2 = inputs.time_series.inflow(1:12, :, 2);
inflow_s3 = inputs.time_series.inflow(1:12, :, 3);
inflow_s4 = inputs.time_series.inflow(1:12, :, 4);
inflow_s5 = inputs.time_series.inflow(1:12, :, 5);

vol_s1 = sol.reservoir_volume(2:13, :, 1);
vol_s2 = sol.reservoir_volume(2:13, :, 2);
vol_s3 = sol.reservoir_volume(2:13, :, 3);
vol_s4 = sol.reservoir_volume(2:13, :, 4);
vol_s5 = sol.reservoir_volume(2:13, :, 5);

turb_s1 = sol.turbined_volume(1:12, :, 1);
turb_s2 = sol.turbined_volume(1:12, :, 2);
turb_s3 = sol.turbined_volume(1:12, :, 3);
turb_s4 = sol.turbined_volume(1:12, :, 4);
turb_s5 = sol.turbined_volume(1:12, :, 5);

ver_s1 = sol.spilled_volume(1:12, :, 1);
ver_s2 = sol.spilled_volume(1:12, :, 2);
ver_s3 = sol.spilled_volume(1:12, :, 3);
ver_s4 = sol.spilled_volume(1:12, :, 4);
ver_s5 = sol.spilled_volume(1:12, :, 5);

therm_ger_s1 = sol.thermal_generation(1:12, :, 1);
therm_ger_s2 = sol.thermal_generation(1:12, :, 2);
therm_ger_s3 = sol.thermal_generation(1:12, :, 3);
therm_ger_s4 = sol.thermal_generation(1:12, :, 4);
therm_ger_s5 = sol.thermal_generation(1:12, :, 5);

defict_s1 = sol.generation_deficit(1:12, 1);
defict_s2 = sol.generation_deficit(1:12, 2);
defict_s3 = sol.generation_deficit(1:12, 3);
defict_s4 = sol.generation_deficit(1:12, 4);
defict_s5 = sol.generation_deficit(1:12, 5);

case_table = table(inflow_s1, inflow_s2, inflow_s3, inflow_s4, inflow_s5, vol_s1, vol_s2, vol_s3, vol_s4, vol_s5, turb_s1, turb_s2, turb_s3, turb_s4, turb_s5, ver_s1, ver_s2, ver_s3, ver_s4, ver_s5, therm_ger_s1, therm_ger_s2, therm_ger_s3, therm_ger_s4, therm_ger_s5, defict_s1, defict_s2, defict_s3, defict_s4, defict_s5);
writetable(case_table, "1uhe_1ute_12_est_5_cen.xlsx", "Sheet", 1);
