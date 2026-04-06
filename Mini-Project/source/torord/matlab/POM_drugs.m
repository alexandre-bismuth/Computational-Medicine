%Generation of a population of models

%% Setting parameters
clear 
% param is the default model parametrization here
param.bcl = 1000;
param.model = @model_Torord;

%populations
npar = 7;                        % number of parameters (a b c d)
nsmp = 30;                      % number of samples
LHS = lhsdesign(nsmp,npar);       % generate normalised sampling (in [0,1])
lb = 0.5;              % lower scaling bounds (each one can be different)
ub = 2;              % upper scaling bounds (each one can be different)

LHSR = rescale(LHS,lb,ub); %Rescale

% Add Flecainide 10uM
IC50_INa = 6.677; 
IC50_IKr = 0.692; 
h_INa = 1.9;
h_IKr = 0.8;
coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

% Here, we make an array of parameter structures
params(1:length(LHSR)) = param; % These are initially all the default parametrisation


% And then each is assigned a different  current Multiplier
for iParam = 1:length(LHSR)
    params(iParam).ICaL_Multiplier = LHSR(iParam,1); 
    params(iParam).INa_Multiplier = LHSR(iParam,2) * coef(10, IC50_INa, h_INa);
    params(iParam).INaCa_Multiplier = LHSR(iParam,3);
    params(iParam).INaK_Multiplier = LHSR(iParam,4);
    params(iParam).IKr_Multiplier = LHSR(iParam,5) * coef(10, IC50_IKr, h_IKr);
    params(iParam).IKs_Multiplier = LHSR(iParam,6);
    params(iParam).ITo_Multiplier = LHSR(iParam,7);
end


options = [];
beats = 10;
ignoreFirst = beats - 2;

%% Simulation and output extraction

% Now, the structure of parameters is used to run multiple models in a
% parallel-for loop.
for i = 1:length(params) 
    X0 = getStartingState('Torord_endo');
    [time{i}, X{i}] = modelRunner(X0, options, params(i), beats, ignoreFirst);
    currents{i} = getCurrentsStructure(time{i}, X{i}, params(i), 0);
end


%% Plotting APs

figure(1); clf
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.V);
    hold off
end

title('AP');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');


figure(2); clf
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.Cai);
    hold off
end

title('Calcium Transient');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
