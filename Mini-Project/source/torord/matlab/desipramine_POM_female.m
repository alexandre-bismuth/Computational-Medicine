% Desipramine Population of Models — FEMALE ventricular model.
% Maximum clinical dose: 0.423 uM (300 mg/day; C = C_max/MW, MW = 266 g/mol).
%
% Female baseline scaling (Yang & Clancy 2017; Gaborit et al. 2010):
%   IKr ×0.82  IKs ×0.79  Ito ×0.79  IK1 ×0.87  ICaL ×1.24  INaCa ×1.44
% Applied multiplicatively to LHS variability and drug block.
%
% Channel block parameters (McMillan et al. 2017):
%   INa  (Nav1.5)       IC50 = 1.52 uM, h = 1 (assumed; CiPA practice)
%   ICaL (Cav1.2)       IC50 = 1.71 uM, h = 1 (assumed)
%   IKr  (hERG/Kv11.1)  IC50 = 1.39 uM, h = 1 (assumed)
%
% Note: IKs, Ito, and IK1 are not drug-blocked by desipramine; female
% scaling is applied to these channels without drug block.
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

% Female baseline scaling factors
F_IKr   = 0.82;
F_IKs   = 0.79;
F_Ito   = 0.79;
F_IK1   = 0.87;
F_ICaL  = 1.24;
F_INaCa = 1.44;

% Desipramine maximum dose
C = 0.423;  % uM (300 mg/day)

IC50_INa  = 1.52;  h_INa  = 1;
IC50_ICaL = 1.71;  h_ICaL = 1;
IC50_IKr  = 1.39;  h_IKr  = 1;

coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);

%% Parameter assignment
params(1:nsmp) = param;

for i = 1:nsmp
    params(i).ICaL_Multiplier  = LHSR(i,1) * F_ICaL  * coef(C, IC50_ICaL, h_ICaL);
    params(i).INa_Multiplier   = LHSR(i,2)            * coef(C, IC50_INa,  h_INa);
    params(i).INaCa_Multiplier = LHSR(i,3) * F_INaCa;
    params(i).INaK_Multiplier  = LHSR(i,4);
    params(i).IKr_Multiplier   = LHSR(i,5) * F_IKr   * coef(C, IC50_IKr,  h_IKr);
    params(i).IKs_Multiplier   = LHSR(i,6) * F_IKs;   % female scaling; not drug-blocked
    params(i).Ito_Multiplier   = LHSR(i,7) * F_Ito;   % female scaling; not drug-blocked
    params(i).IK1_Multiplier   = F_IK1;                % female scaling; not drug-blocked
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
title('AP — Desipramine max dose, Female POM');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');

figure(2); clf
for i = 1:nsmp
    hold on
    plot(currents{i}.time, currents{i}.Cai);
end
title('Calcium Transient — Desipramine max dose, Female POM');
xlabel('Time (ms)');
ylabel('Ca_i (mM)');
