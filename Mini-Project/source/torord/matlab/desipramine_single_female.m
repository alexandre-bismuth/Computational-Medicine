% Desipramine single-drug simulations — FEMALE ventricular model.
% Female baseline scaling from Yang & Clancy (2017) / Gaborit et al. (2010):
%   IKr   × 0.82   ICaL  × 1.24   IKs   × 0.79
%   Ito   × 0.79   IK1   × 0.87   INaCa × 1.44
%   INaK  × 1.00   INaL  × 1.00
% Drug block is applied multiplicatively on top of the female baseline.
%
% Clinically-anchored concentrations (total plasma, Css):
%   High start dose (50 mg/day):      0.070 uM
%   High therapeutic (200 mg/day):    0.282 uM
%   Maximum (300 mg/day):             0.423 uM
% Conversion: C(uM) = C(ng/mL) / MW; MW(desipramine) = 266 g/mol.
%
% Channel block parameters (McMillan et al. 2017):
%   INa  (Nav1.5)       IC50 = 1.52 uM, h = 1 (assumed; CiPA practice)
%   ICaL (Cav1.2)       IC50 = 1.71 uM, h = 1 (assumed)
%   IKr  (hERG/Kv11.1)  IC50 = 1.39 uM, h = 1 (assumed)
% h = 1 assumed uniformly; experimental Hill coefficients from patch-clamp
% carry sufficient variability that h = 1 reduces systematic error
% (McMillan et al. 2017).

%% Parameters
clear
param.bcl   = 1000;
param.model = @model_Torord;

% Female baseline scaling factors (Yang & Clancy 2017; Gaborit et al. 2010)
F_IKr   = 0.82;
F_IKs   = 0.79;
F_Ito   = 0.79;
F_IK1   = 0.87;
F_ICaL  = 1.24;
F_INaCa = 1.44;

% Female baseline (no drug)
param.IKr_Multiplier   = F_IKr;
param.IKs_Multiplier   = F_IKs;
param.Ito_Multiplier   = F_Ito;
param.IK1_Multiplier   = F_IK1;
param.ICaL_Multiplier  = F_ICaL;
param.INaCa_Multiplier = F_INaCa;
param.INa_Multiplier   = 1;

% Desipramine IC50 and Hill coefficient per channel
IC50_INa  = 1.52;  h_INa  = 1;
IC50_ICaL = 1.71;  h_ICaL = 1;
IC50_IKr  = 1.39;  h_IKr  = 1;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

% Clinically-anchored concentrations (uM)
C_high_start = 0.070;  % 50 mg/day  — high start dose - 6ms (1.6%) QT prolongation
C_high_ther  = 0.282;  % 200 mg/day — high therapeutic - 19ms (5.2%) QT prolongation
C_max        = 0.423;  % 300 mg/day — maximum dose - 26ms (7.0%) QT prolongation

% Control (female baseline, no drug)
params(1:4) = param;

% Desipramine — high start dose
params(2).INa_Multiplier  =           coef(C_high_start, IC50_INa,  h_INa);
params(2).ICaL_Multiplier = F_ICaL * coef(C_high_start, IC50_ICaL, h_ICaL);
params(2).IKr_Multiplier  = F_IKr  * coef(C_high_start, IC50_IKr,  h_IKr);

% Desipramine — high therapeutic
params(3).INa_Multiplier  =           coef(C_high_ther, IC50_INa,  h_INa);
params(3).ICaL_Multiplier = F_ICaL * coef(C_high_ther, IC50_ICaL, h_ICaL);
params(3).IKr_Multiplier  = F_IKr  * coef(C_high_ther, IC50_IKr,  h_IKr);

% Desipramine — maximum dose
params(4).INa_Multiplier  =           coef(C_max, IC50_INa,  h_INa);
params(4).ICaL_Multiplier = F_ICaL * coef(C_max, IC50_ICaL, h_ICaL);
params(4).IKr_Multiplier  = F_IKr  * coef(C_max, IC50_IKr,  h_IKr);

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
title('AP — Desipramine (Female)');
legend('Female control', 'High start (0.070\muM)', 'High ther. (0.282\muM)', 'Max (0.423\muM)');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');
xlim([0 500]);

subplot(1,2,2);
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Desipramine (Female)');
legend('Female control', 'High start (0.070\muM)', 'High ther. (0.282\muM)', 'Max (0.423\muM)');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
xlim([0 500]);
