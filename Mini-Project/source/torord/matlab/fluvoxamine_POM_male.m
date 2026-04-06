% Fluvoxamine Population of Models — MALE ventricular model.
% Maximum clinical dose: 0.250 uM (300 mg/day; C = C_max/MW, MW = 318 g/mol).
%
% Channel block parameters (McMillan et al. 2017, Table 1):
%   IKr  (hERG/IKr)  pIC50 = 5.4202  ->  IC50 = 3.80 uM, h = 1
%   ICaL (Cav1.2)    pIC50 = 5.3098  ->  IC50 = 4.90 uM, h = 1
%   INa  (Nav1.5)    pIC50 = 4.4045  ->  IC50 = 39.4 uM, h = 1
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

% Fluvoxamine maximum dose
C = 0.250;  % uM (300 mg/day)

IC50_IKr  = 3.80;  h_IKr  = 1;
IC50_ICaL = 4.90;  h_ICaL = 1;
IC50_INa  = 39.4;  h_INa  = 1;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

%% Parameter assignment
params(1:nsmp) = param;

for i = 1:nsmp
    params(i).ICaL_Multiplier  = LHSR(i,1) * coef(C, IC50_ICaL, h_ICaL);
    params(i).INa_Multiplier   = LHSR(i,2) * coef(C, IC50_INa,  h_INa);
    params(i).INaCa_Multiplier = LHSR(i,3);
    params(i).INaK_Multiplier  = LHSR(i,4);
    params(i).IKr_Multiplier   = LHSR(i,5) * coef(C, IC50_IKr,  h_IKr);
    params(i).IKs_Multiplier   = LHSR(i,6);
    params(i).Ito_Multiplier   = LHSR(i,7);
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
title('AP — Fluvoxamine max dose, Male POM');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');

figure(2); clf
for i = 1:nsmp
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Fluvoxamine max dose, Male POM');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
