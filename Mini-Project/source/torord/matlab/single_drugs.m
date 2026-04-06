% A script showing a common-case use of the model's functions when multiple
% simulations are to be run. In this case, we plot simulation outputs for 5
% different multipliers of IKr (corresponding to 80, 90, 100, 110, and 120
% percent availability).
%% Setting parameters
clear 
% param is the default model parametrization here
param.bcl = 1000;
param.model = @model_Torord;

% We add default values and the hill coefficient calculations
param.INa_Multiplier = 1;
param.IKr_Multiplier = 1;

IC50_INa = 6.677; 
IC50_IKr = 0.692; 
h_INa = 1.9;
h_IKr = 0.8;
coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

% Control
params(1:3) = param;

% Flecainide 1uM
params(2).INa_Multiplier = coef(1, IC50_INa, h_INa);
params(2).IKr_Multiplier = coef(1, IC50_IKr, h_IKr);

% Flecainide 10uM
params(3).INa_Multiplier = coef(10, IC50_INa, h_INa);
params(3).IKr_Multiplier = coef(10, IC50_IKr, h_IKr);

options = [];
beats = 100;
ignoreFirst = beats - 1;

%% Simulation and output extraction

% Now, the structure of parameters is used to run multiple models in a
% parallel-for loop.
parfor i = 1:length(params) 
    X0 = getStartingState('Torord_endo');
    [time{i}, X{i}] = modelRunner(X0, options, params(i), beats, ignoreFirst);
    currents{i} = getCurrentsStructure(time{i}, X{i}, params(i), 0);
end


%% Plotting APs
figure(1); clf
subplot(1,2,1); 
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.V);
    hold off
end

title('AP');
legend('Control', 'Flecainide 1uM', 'Flecainide 10uM');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');
xlim([0 500]);

subplot(1,2,2);
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.Cai);
    hold off
end

title('Calcium Transience');
legend('Control', 'Flecainide 1uM', 'Flecainide 10uM');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
xlim([0 500]);