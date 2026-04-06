% Sertraline single-drug simulations — FEMALE ventricular model.
% Female baseline scaling from Yang & Clancy (2017) / Gaborit et al. (2010):
%   IKr   × 0.82   ICaL  × 1.24   IKs   × 0.79
%   Ito   × 0.79   IK1   × 0.87   INaCa × 1.44
%   INaK  × 1.00   INaL  × 1.00
% Drug block is applied multiplicatively on top of the female baseline.
%
% Clinically-anchored concentrations (total plasma, Css):
%   Start dose (50 mg/day):          0.082 uM
%   Mid therapeutic (125 mg/day):    0.205 uM
%   High therapeutic (200 mg/day):   0.328 uM
% Conversion: C(uM) = C(ng/mL) / MW; MW(sertraline) = 306 g/mol.
%
% Channel block parameters (Afkhami et al., PMC3484517):
%   IKr  (hERG)          IC50 = 0.70 uM, h = 1.30
%   ICaL (L-type Ca2+)   IC50 = 2.60 uM, h = 1.90
%   INa  (Nav1.5)        IC50 = 6.10 uM, h = 0.70
%   IK1  (KCNJ2/Kir2.1) IC50 = 10.50 uM, h = 2.10
%   IKs  (KCNQ1/KCNE1)  IC50 = 12.30 uM, h = 2.50
%   IKv1.5 (Kv1.5)      not represented in ToR-ORd — omitted

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

% Sertraline IC50 and Hill coefficient per channel
IC50_IKr  = 0.70;  h_IKr  = 1.30;
IC50_ICaL = 2.60;  h_ICaL = 1.90;
IC50_INa  = 6.10;  h_INa  = 0.70;
IC50_IK1  = 10.50; h_IK1  = 2.10;
IC50_IKs  = 12.30; h_IKs  = 2.50;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

% Clinically-anchored concentrations (uM)
C_start = 0.082;   % 50 mg/day  — start dose % 10ms (2.8%) longer QT interval
C_mid   = 0.205;   % 125 mg/day — mid therapeutic % 30ms (8.3%) longer QT interval
C_high  = 0.328;   % 200 mg/day — high therapeutic (maximum) % 50ms (11.1%) longer QT interval

% Control (female baseline, no drug)
params(1:4) = param;

% Sertraline — start dose
params(2).IKr_Multiplier  = F_IKr  * coef(C_start, IC50_IKr,  h_IKr);
params(2).ICaL_Multiplier = F_ICaL * coef(C_start, IC50_ICaL, h_ICaL);
params(2).INa_Multiplier  =          coef(C_start, IC50_INa,  h_INa);
params(2).IK1_Multiplier  = F_IK1  * coef(C_start, IC50_IK1,  h_IK1);
params(2).IKs_Multiplier  = F_IKs  * coef(C_start, IC50_IKs,  h_IKs);

% Sertraline — mid therapeutic
params(3).IKr_Multiplier  = F_IKr  * coef(C_mid, IC50_IKr,  h_IKr);
params(3).ICaL_Multiplier = F_ICaL * coef(C_mid, IC50_ICaL, h_ICaL);
params(3).INa_Multiplier  =          coef(C_mid, IC50_INa,  h_INa);
params(3).IK1_Multiplier  = F_IK1  * coef(C_mid, IC50_IK1,  h_IK1);
params(3).IKs_Multiplier  = F_IKs  * coef(C_mid, IC50_IKs,  h_IKs);

% Sertraline — high therapeutic (maximum dose)
params(4).IKr_Multiplier  = F_IKr  * coef(C_high, IC50_IKr,  h_IKr);
params(4).ICaL_Multiplier = F_ICaL * coef(C_high, IC50_ICaL, h_ICaL);
params(4).INa_Multiplier  =          coef(C_high, IC50_INa,  h_INa);
params(4).IK1_Multiplier  = F_IK1  * coef(C_high, IC50_IK1,  h_IK1);
params(4).IKs_Multiplier  = F_IKs  * coef(C_high, IC50_IKs,  h_IKs);

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
title('AP — Sertraline (Female)');
legend('Female control', 'Start (0.082\muM)', 'Mid (0.205\muM)', 'High (0.328\muM)');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');
xlim([0 500]);

subplot(1,2,2);
for i = 1:length(params)
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Sertraline (Female)');
legend('Female control', 'Start (0.082\muM)', 'Mid (0.205\muM)', 'High (0.328\muM)');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
xlim([0 500]);
