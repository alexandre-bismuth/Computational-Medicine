% Amitriptyline single-drug simulations using the ToR-ORd model.
% Clinically-anchored concentrations (total plasma, Css):
%   Start dose (75 mg/day, outpatient): 0.129 uM
%   High therapeutic (200 mg/day):      0.345 uM
%   Maximum (300 mg/day, inpatient):    0.518 uM
% Conversion: C(uM) = C(ng/mL) / MW; MW(amitriptyline) = 277 g/mol.
%
% Channel block parameters (McMillan et al. 2017, Table 1):
%   IKr  (hERG/IKr)       pIC50 = 5.4841  ->  IC50 = 3.28 uM,  h = 1
%   IKs  (KCNQ1/KCNE1)    pIC50 = 5.5627  ->  IC50 = 2.73 uM,  h = 1
%   INaL (Nav1.5, late)    pIC50 = 5.3533  ->  IC50 = 4.43 uM,  h = 1
%   ICaL (Cav1.2)          pIC50 = 4.9355  ->  IC50 = 11.6 uM,  h = 1
%   Ito  (Kv4.3/Kv1.4)    pIC50 = 5.0000  ->  IC50 = 10.0 uM,  h = 1
%   INa  (Nav1.5, fast)    pIC50 = 4.6990  ->  IC50 = 20.0 uM,  h = 1
% h = 1 (CiPA standard; McMillan et al. 2017).
% IpNa (late Na) mapped to INaL_Multiplier in ToR-ORd.

%% Parameters
clear
param.bcl   = 1000;
param.model = @model_Torord;

% Default multipliers
param.IKr_Multiplier  = 1;
param.IKs_Multiplier  = 1;
param.INaL_Multiplier = 1;
param.ICaL_Multiplier = 1;
param.Ito_Multiplier  = 1;
param.INa_Multiplier  = 1;

% Amitriptyline IC50 and Hill coefficient per channel
IC50_IKr  = 3.28;  h_IKr  = 1;
IC50_IKs  = 2.73;  h_IKs  = 1;
IC50_INaL = 4.43;  h_INaL = 1;
IC50_ICaL = 11.6;  h_ICaL = 1;
IC50_Ito  = 10.0;  h_Ito  = 1;
IC50_INa  = 20.0;  h_INa  = 1;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

% Clinically-anchored concentrations (uM)
C_start    = 0.129;  % 75 mg/day  — start dose (outpatient) - 4ms (1.4%)
C_high_ther = 0.345; % 200 mg/day — high therapeutic (inpatient) - 9ms (3.1%)
C_max      = 0.518;  % 300 mg/day — maximum (inpatient only) - only 11ms (3.7%) QT prolongation: low compared to other antidepressants 

% Control (no drug)
params(1:4) = param;

% Amitriptyline — start dose
params(2).IKr_Multiplier  = coef(C_start, IC50_IKr,  h_IKr);
params(2).IKs_Multiplier  = coef(C_start, IC50_IKs,  h_IKs);
params(2).INaL_Multiplier = coef(C_start, IC50_INaL, h_INaL);
params(2).ICaL_Multiplier = coef(C_start, IC50_ICaL, h_ICaL);
params(2).Ito_Multiplier  = coef(C_start, IC50_Ito,  h_Ito);
params(2).INa_Multiplier  = coef(C_start, IC50_INa,  h_INa);

% Amitriptyline — high therapeutic
params(3).IKr_Multiplier  = coef(C_high_ther, IC50_IKr,  h_IKr);
params(3).IKs_Multiplier  = coef(C_high_ther, IC50_IKs,  h_IKs);
params(3).INaL_Multiplier = coef(C_high_ther, IC50_INaL, h_INaL);
params(3).ICaL_Multiplier = coef(C_high_ther, IC50_ICaL, h_ICaL);
params(3).Ito_Multiplier  = coef(C_high_ther, IC50_Ito,  h_Ito);
params(3).INa_Multiplier  = coef(C_high_ther, IC50_INa,  h_INa);

% Amitriptyline — maximum dose
params(4).IKr_Multiplier  = coef(C_max, IC50_IKr,  h_IKr);
params(4).IKs_Multiplier  = coef(C_max, IC50_IKs,  h_IKs);
params(4).INaL_Multiplier = coef(C_max, IC50_INaL, h_INaL);
params(4).ICaL_Multiplier = coef(C_max, IC50_ICaL, h_ICaL);
params(4).Ito_Multiplier  = coef(C_max, IC50_Ito,  h_Ito);
params(4).INa_Multiplier  = coef(C_max, IC50_INa,  h_INa);

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
title('AP — Amitriptyline');
legend('Control', 'Start (0.129\muM)', 'High ther. (0.345\muM)', 'Max (0.518\muM)');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');
xlim([0 500]);

subplot(1,2,2);
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Amitriptyline');
legend('Control', 'Start (0.129\muM)', 'High ther. (0.345\muM)', 'Max (0.518\muM)');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
xlim([0 500]);
