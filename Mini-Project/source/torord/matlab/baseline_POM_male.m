% Baseline Population of Models — MALE ventricular model (no drug).
% Used to extract baseline biomarkers (APD90, APD30, triangulation, etc.)
% for correlation with drug-induced EAD thresholds.
%
% Male model uses default ToR-ORd parameters (no sex scaling).
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

% No drug (C = 0)
C = 0;

%% Parameter assignment
params(1:nsmp) = param;

for i = 1:nsmp
    params(i).ICaL_Multiplier  = LHSR(i,1);
    params(i).INa_Multiplier   = LHSR(i,2);
    params(i).INaCa_Multiplier = LHSR(i,3);
    params(i).INaK_Multiplier  = LHSR(i,4);
    params(i).IKr_Multiplier   = LHSR(i,5);
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
title('AP — Baseline, Male POM');
xlabel('Time (ms)');
ylabel('Membrane potential (mV)');

%% Biomarker Extraction & Export
outdir = fullfile(fileparts(mfilename('fullpath')), 'POM_results');
if ~exist(outdir, 'dir'); mkdir(outdir); end

APD90_vals = NaN(nsmp, 1);
APD30_vals = NaN(nsmp, 1);
Vpeak_vals = NaN(nsmp, 1);
Vrest_vals = NaN(nsmp, 1);
EAD_vals   = zeros(nsmp, 1);
max_repol_rate_vals = NaN(nsmp, 1);

for i = 1:nsmp
    t_all = currents{i}.time;
    V_all = currents{i}.V;

    last_beat_t = t_all(1) + param.bcl;
    idx = find(t_all >= last_beat_t, 1, 'first');
    V = V_all(idx:end)';
    t = t_all(idx:end)';

    Vrest = V(end);
    Vpeak = max(V);
    Vpeak_vals(i) = Vpeak;
    Vrest_vals(i) = Vrest;

    [~, peak_idx] = max(V);

    V90 = Vrest + 0.1 * (Vpeak - Vrest);
    up90 = find(V(1:peak_idx) > V90, 1, 'first');
    dn90 = find(V(peak_idx:end) < V90, 1, 'first') + peak_idx - 1;
    if ~isempty(up90) && ~isempty(dn90)
        APD90_vals(i) = t(dn90) - t(up90);
    end

    V30 = Vrest + 0.7 * (Vpeak - Vrest);
    up30 = find(V(1:peak_idx) > V30, 1, 'first');
    dn30 = find(V(peak_idx:end) < V30, 1, 'first') + peak_idx - 1;
    if ~isempty(up30) && ~isempty(dn30)
        APD30_vals(i) = t(dn30) - t(up30);
    end

    for j = peak_idx+1:length(V)
        if V(j) > V(j-1) + 2 && V(j) > -40
            EAD_vals(i) = 1;
            break;
        end
    end

    dVdt = diff(V) ./ diff(t);
    max_repol_rate_vals(i) = min(dVdt(peak_idx:end));
end

T = table((1:nsmp)', LHSR(:,1), LHSR(:,2), LHSR(:,3), LHSR(:,4), ...
    LHSR(:,5), LHSR(:,6), LHSR(:,7), repmat(C, nsmp, 1), ...
    APD90_vals, APD30_vals, APD90_vals - APD30_vals, ...
    Vpeak_vals, Vrest_vals, EAD_vals, max_repol_rate_vals, ...
    'VariableNames', {'model_id', 'LHS_ICaL', 'LHS_INa', 'LHS_INaCa', ...
    'LHS_INaK', 'LHS_IKr', 'LHS_IKs', 'LHS_Ito', 'concentration_uM', ...
    'APD90', 'APD30', 'triangulation', 'Vpeak', 'Vrest', 'EAD', 'max_repol_rate'});

writetable(T, fullfile(outdir, 'baseline_male.csv'));
fprintf('Saved POM_results/baseline_male.csv\n');
