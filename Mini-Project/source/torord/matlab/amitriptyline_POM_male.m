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
title('Action Potential — Male population of models for a maximum therapeutic dose of Amitriptyline');
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

    % EAD detection: scan only after V first drops below 0 mV (past plateau),
    % then flag any rise > 5 mV above running minimum while above -40 mV
    scan_start = 0;
    for j = peak_idx+1:length(V)
        if V(j) < 0
            scan_start = j;
            break;
        end
    end
    if scan_start > 0
        Vmin_so_far = V(scan_start);
        for j = scan_start+1:length(V)
            if V(j) < Vmin_so_far
                Vmin_so_far = V(j);
            elseif V(j) > Vmin_so_far + 5 && Vmin_so_far > -40
                EAD_vals(i) = 1;
                break;
            end
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

writetable(T, fullfile(outdir, 'amitriptyline_male.csv'));
fprintf('Saved POM_results/amitriptyline_male.csv\n');
