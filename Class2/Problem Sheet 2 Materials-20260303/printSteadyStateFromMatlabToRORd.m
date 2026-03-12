% This is a simple script which runs the control endocardial model for 500
% beats and saves the steady state variables in a .txt file to be copied into the MonoAlg3D .ini file

%% Setting parameters
clear 

% Param is the structure of model parameters that the user may wish to
% change compared to default simulation. The full list is given in the
% function ORdRunner, and it mainly includes cell type, current
% multipliers, extracellular ionic concentrations, or fraction of NCX and ICaL
% localisation in junctional subspace.
param.bcl = 1000; % basic cycle length in ms
param.model = @model_Torord; % which model is to be used - right now, use @model_Torord. In general, any model with the same format of inputs/outputs as @model_Torord may be simulated, which is useful when current formulations are changed within the model code, etc.
param.verbose = true; % printing numbers of beats simulated.
%% Uncomment relevant drug block
% param.INa_Multiplier = 0.75;
% param.IKr_Multiplier = 0.75;
% param.ICaL_Multiplier = 0.75;

options = []; % parameters for ode15s - usually empty
% Make sure the model has reached steady state - are the resting membrane potential, action potential peak, and action potential duration stable? Inspect the outputted plot.
beats = 500; % number of beats
ignoreFirst = beats - 10; % this many beats at the start of the simulations are ignored when extracting the structure of simulation outputs (i.e., beats - 1 keeps the last beat).

X0 = getStartingState('Torord_endo'); % starting state - can be also Torord_mid or Torord_epi for midmyocardial or epicardial cells respectively.

%% Simulation and extraction of outputs

% The structure param and other variables are passed to modelRunner, which is
% an interface between user and the simulation code itself (which is in
% model_Torord.m). The modelRunner unpacks the structure of parameters given by
% the users, sets undefined parameters to default, and sends all that to
% @model_Torord.

% time, X are cell arrays corresponding to stored beats (if 1 beat is
% simulated, this is 1-by-1 cell still), giving time vectors and state
% variable values at corresponding time points.
[time, X] = modelRunner(X0, options, param, beats, ignoreFirst);

% A structure of currents is computed from the state variables (see the
% function code for a list of properties extracted - also, hitting Tab
% following typing 'currents.' lists all the fields of the structure). Some
% state variables are also stored in a named way (time, V, Cai, Cass) so
% that the user can do most of necessary plotting simply via accessing the
% structure currents as shown below. 
currents = getCurrentsStructure(time, X, param, 0);

%% Create endocardial steady state text file to be copied to MonoAlg3D
% Change file name for each simulation
lastX = X{10, 1}(end, :);
file_name = 'endocardialSteadyState_control.txt';
fileID = fopen(file_name, 'w');
fprintf(fileID, 'v_endo = %e\n', lastX(1));
fprintf(fileID, 'nai_endo = %e\n', lastX(2));
fprintf(fileID, 'nass_endo = %e\n', lastX(3));
fprintf(fileID, 'ki_endo = %e\n', lastX(4));
fprintf(fileID, 'kss_endo = %e\n', lastX(5));
fprintf(fileID, 'cai_endo = %e\n', lastX(6));
fprintf(fileID, 'cass_endo = %e\n', lastX(7));
fprintf(fileID, 'cansr_endo = %e\n', lastX(8));
fprintf(fileID, 'cajsr_endo = %e\n', lastX(9));
fprintf(fileID, 'm_endo = %e\n', lastX(10));
fprintf(fileID, 'hp_endo = %e\n', lastX(11));
fprintf(fileID, 'h_endo = %e\n', lastX(12));
fprintf(fileID, 'j_endo = %e\n', lastX(13));
fprintf(fileID, 'jp_endo = %e\n', lastX(14));
fprintf(fileID, 'mL_endo = %e\n', lastX(15));
fprintf(fileID, 'hL_endo = %e\n', lastX(16));
fprintf(fileID, 'hLp_endo = %e\n', lastX(17));
fprintf(fileID, 'a_endo = %e\n', lastX(18));
fprintf(fileID, 'iF_endo = %e\n', lastX(19));
fprintf(fileID, 'iS_endo = %e\n', lastX(20));
fprintf(fileID, 'ap_endo = %e\n', lastX(21));
fprintf(fileID, 'iFp_endo = %e\n', lastX(22));
fprintf(fileID, 'iSp_endo = %e\n', lastX(23));
fprintf(fileID, 'd_endo = %e\n', lastX(24));
fprintf(fileID, 'ff_endo = %e\n', lastX(25));
fprintf(fileID, 'fs_endo = %e\n', lastX(26));
fprintf(fileID, 'fcaf_endo = %e\n', lastX(27));
fprintf(fileID, 'fcas_endo = %e\n', lastX(28));
fprintf(fileID, 'jca_endo = %e\n', lastX(29));
fprintf(fileID, 'nca_endo = %e\n', lastX(30));
fprintf(fileID, 'nca_i_endo = %e\n', lastX(31));
fprintf(fileID, 'ffp_endo = %e\n', lastX(32));
fprintf(fileID, 'fcafp_endo = %e\n', lastX(33));
fprintf(fileID, 'xs1_endo = %e\n', lastX(34));
fprintf(fileID, 'xs2_endo = %e\n', lastX(35));
fprintf(fileID, 'Jrel_np_endo = %e\n', lastX(36));
fprintf(fileID, 'CaMKt_endo = %e\n', lastX(37));
fprintf(fileID, 'ikr_c0_endo = %e\n', lastX(38));
fprintf(fileID, 'ikr_c1_endo = %e\n', lastX(39));
fprintf(fileID, 'ikr_c2_endo = %e\n', lastX(40));
fprintf(fileID, 'ikr_o_endo = %e\n', lastX(41));
fprintf(fileID, 'ikr_i_endo = %e\n', lastX(42));
fprintf(fileID, 'Jrel_p_endo = %e\n', lastX(43));
fclose(fileID);
	
%% Plotting membrane potential and calcium transient
figure(1);
plot(currents.time, currents.V);
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');
xlim([0 10000]);
% 
% figure(2);
% plot(currents.time, currents.Cai);
% xlabel('Time (ms)');
% ylabel('Ca_i (mM)');
% xlim([0 500]);