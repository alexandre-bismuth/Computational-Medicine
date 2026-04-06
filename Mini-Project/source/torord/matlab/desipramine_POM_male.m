% Desipramine Population of Models — MALE ventricular model.
% Maximum clinical dose: 0.423 uM (300 mg/day; C = C_max/MW, MW = 266 g/mol).
%
% Channel block parameters (McMillan et al. 2017):
%   INa  (Nav1.5)       IC50 = 1.52 uM, h = 1 (assumed; CiPA practice)
%   ICaL (Cav1.2)       IC50 = 1.71 uM, h = 1 (assumed)
%   IKr  (hERG/Kv11.1)  IC50 = 1.39 uM, h = 1 (assumed)
% h = 1 assumed uniformly; reduces systematic error from patch-clamp
% variability (McMillan et al. 2017).
%
% Note: all IC50 values exceed the max clinical concentration (0.423 uM),
% so block per channel is ~20-23% at maximum dose. This is the expected
% result for an INa-dominant drug at therapeutic plasma levels.
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

% Desipramine maximum dose
C = 0.423;  % uM (300 mg/day)
% No EAD

IC50_INa  = 1.52;  h_INa  = 1;
IC50_ICaL = 1.71;  h_ICaL = 1;
IC50_IKr  = 1.39;  h_IKr  = 1;

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
title('AP — Desipramine max dose, Male POM');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');

figure(2); clf
for i = 1:nsmp
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Desipramine max dose, Male POM');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
