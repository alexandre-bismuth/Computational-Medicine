% Fluvoxamine single-drug simulations using the ToR-ORd model.
% Clinically-anchored concentrations (total plasma, Css):
%   Start dose (50 mg/day, at bedtime): 0.042 uM
%   Low therapeutic (100 mg/day):       0.083 uM
%   High therapeutic (300 mg/day):      0.250 uM
% Conversion: C(uM) = C(ng/mL) / MW; MW(fluvoxamine) = 318 g/mol.
%
% Channel block parameters (McMillan et al. 2017, Table 1):
%   IKr  (hERG/IKr)  pIC50 = 5.4202  ->  IC50 = 3.80 uM, h = 1
%   ICaL (Cav1.2)    pIC50 = 5.3098  ->  IC50 = 4.90 uM, h = 1
%   INa  (Nav1.5)    pIC50 = 4.4045  ->  IC50 = 39.4 uM, h = 1
% h = 1 (CiPA standard; McMillan et al. 2017).

%% Parameters
clear
param.bcl   = 1000;
param.model = @model_Torord;

% Default multipliers
param.IKr_Multiplier  = 1;
param.ICaL_Multiplier = 1;
param.INa_Multiplier  = 1;

% Fluvoxamine IC50 and Hill coefficient per channel
IC50_IKr  = 3.80;  h_IKr  = 1;
IC50_ICaL = 4.90;  h_ICaL = 1;
IC50_INa  = 39.4;  h_INa  = 1;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

% Clinically-anchored concentrations (uM)
C_start    = 0.042;  % 50 mg/day  — start dose (at bedtime)
C_low_ther = 0.083;  % 100 mg/day — low therapeutic
C_high_ther = 0.250; % 300 mg/day — high therapeutic (maximum) - 6ms (2.0%) QT prolongation for max dose: negligible compared to other antidepressants

% Control (no drug)
params(1:4) = param;

% Fluvoxamine — start dose
params(2).IKr_Multiplier  = coef(C_start, IC50_IKr,  h_IKr);
params(2).ICaL_Multiplier = coef(C_start, IC50_ICaL, h_ICaL);
params(2).INa_Multiplier  = coef(C_start, IC50_INa,  h_INa);

% Fluvoxamine — low therapeutic
params(3).IKr_Multiplier  = coef(C_low_ther, IC50_IKr,  h_IKr);
params(3).ICaL_Multiplier = coef(C_low_ther, IC50_ICaL, h_ICaL);
params(3).INa_Multiplier  = coef(C_low_ther, IC50_INa,  h_INa);

% Fluvoxamine — high therapeutic (maximum dose)
params(4).IKr_Multiplier  = coef(C_high_ther, IC50_IKr,  h_IKr);
params(4).ICaL_Multiplier = coef(C_high_ther, IC50_ICaL, h_ICaL);
params(4).INa_Multiplier  = coef(C_high_ther, IC50_INa,  h_INa);

options     = [];
beats       = 100;
ignoreFirst = beats - 1;

%% Simulation
parfor i = 1:length(params)
    X0 = getStartingState('Torord_endo');
    [time{i}, X{i}]     = modelRunner(X0, options, params(i), beats, ignoreFirst);
    currents{i}         = getCurrentsStructure(time{i}, X{i}, params(i), 0);
end

%% Plots
figure(1); clf

subplot(1,2,1);
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.V);
end
title('AP — Fluvoxamine');
legend('Control', 'Start (0.042\muM)', 'Low ther. (0.083\muM)', 'High ther. (0.250\muM)');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');
xlim([0 500]);

subplot(1,2,2);
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Fluvoxamine');
legend('Control', 'Start (0.042\muM)', 'Low ther. (0.083\muM)', 'High ther. (0.250\muM)');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
xlim([0 500]);
