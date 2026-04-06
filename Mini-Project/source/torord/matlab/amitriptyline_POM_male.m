% Amitriptyline Population of Models — MALE ventricular model.
% Maximum clinical dose: 0.518 uM (300 mg/day inpatient; C = C_max/MW, MW = 277 g/mol).
%
% Channel block parameters (McMillan et al. 2017, Table 1):
%   IKr  (hERG/IKr)       pIC50 = 5.4841  ->  IC50 = 3.28 uM,  h = 1
%   IKs  (KCNQ1/KCNE1)    pIC50 = 5.5627  ->  IC50 = 2.73 uM,  h = 1
%   INaL (Nav1.5, late)    pIC50 = 5.3533  ->  IC50 = 4.43 uM,  h = 1  [fixed — not in LHS]
%   ICaL (Cav1.2)          pIC50 = 4.9355  ->  IC50 = 11.6 uM,  h = 1
%   Ito  (Kv4.3/Kv1.4)    pIC50 = 5.0000  ->  IC50 = 10.0 uM,  h = 1
%   INa  (Nav1.5, fast)    pIC50 = 4.6990  ->  IC50 = 20.0 uM,  h = 1
% h = 1 (CiPA standard; McMillan et al. 2017).
%
% LHS parameter columns:
%   1=ICaL  2=INa  3=INaCa  4=INaK  5=IKr  6=IKs  7=Ito

%% Setup
clear
rng(42);

param.bcl   = 1000;
param.model = @model_Torord;

npar = 7;
nsmp = 30;
LHS  = lhsdesign(nsmp, npar);
lb   = 0.5;
ub   = 2.0;
LHSR = rescale(LHS, lb, ub);

% Amitriptyline maximum dose
C = 0.518;  % uM (300 mg/day)
% No EAD

IC50_IKr  = 3.28;  h_IKr  = 1;
IC50_IKs  = 2.73;  h_IKs  = 1;
IC50_INaL = 4.43;  h_INaL = 1;
IC50_ICaL = 11.6;  h_ICaL = 1;
IC50_Ito  = 10.0;  h_Ito  = 1;
IC50_INa  = 20.0;  h_INa  = 1;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

%% Parameter assignment
params(1:nsmp) = param;

for i = 1:nsmp
    params(i).ICaL_Multiplier  = LHSR(i,1) * coef(C, IC50_ICaL, h_ICaL);
    params(i).INa_Multiplier   = LHSR(i,2) * coef(C, IC50_INa,  h_INa);
    params(i).INaCa_Multiplier = LHSR(i,3);
    params(i).INaK_Multiplier  = LHSR(i,4);
    params(i).IKr_Multiplier   = LHSR(i,5) * coef(C, IC50_IKr,  h_IKr);
    params(i).IKs_Multiplier   = LHSR(i,6) * coef(C, IC50_IKs,  h_IKs);
    params(i).Ito_Multiplier   = LHSR(i,7) * coef(C, IC50_Ito,  h_Ito);
    params(i).INaL_Multiplier  = coef(C, IC50_INaL, h_INaL);  % fixed — not in LHS
end

options     = [];
beats       = 10;
ignoreFirst = beats - 2;

%% Simulation
for i = 1:nsmp
    X0 = getStartingState('Torord_endo');
    [time{i}, X{i}]     = modelRunner(X0, options, params(i), beats, ignoreFirst);
    currents{i}         = getCurrentsStructure(time{i}, X{i}, params(i), 0);
end

%% Plots
figure(1); clf
for i = 1:nsmp
    hold on
    plot(currents{i}.time, currents{i}.V);
end
title('AP — Amitriptyline max dose, Male POM');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');

figure(2); clf
for i = 1:nsmp
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Amitriptyline max dose, Male POM');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
