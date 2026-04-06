# Mini-Project Plan: Sex Differences in Antidepressant-Induced Arrhythmia Risk

*This page contains AI-generated content, in line with mini-project guidelines*

## Research Question

> **"How do electrophysiological cardiac sex differences affect vulnerability to arrhythmias induced by antidepressants, and can simulation-derived repolarisation biomarkers identify at-risk individuals from resting ECG data?"**

### Three Aims

1. **Quantify sex-differential arrhythmic thresholds** for sertraline, fluvoxamine, amitriptyline, and desipramine using population-based ventricular cell models, and characterise how the ion channel blocking profile (IKr- vs INa-dominant) determines the magnitude of the sex gap
2. **Identify baseline AP features that predict individual drug vulnerability** and map these to ECG-measurable repolarisation markers, using simulation to derive sex-stratified reference ranges
3. **Evaluate the predicted sex differences in repolarisation** against PTB-XL clinical ECG data and quantify robustness to pharmacological parameter uncertainty

---

## Hypothesis

Women's lower baseline IKr conductance (~15%) reduces repolarisation reserve, making them more vulnerable to IKr-blocking antidepressants. This vulnerability is detectable from resting AP features (APD90, triangulation) which have measurable ECG surrogates (QTc, Tpeak–Tend). The sex gap in these surrogates should be observable in population-scale clinical ECG data and should narrow post-menopause, consistent with the hormonal modulation of IKr.

---

## Two-Part Structure

### Part 1: In Silico Drug Simulation (MATLAB)

Simulate the effect of four antidepressants on sex-stratified populations of ventricular cell models. Identify which baseline electrophysiological features predict who develops arrhythmias, and at what drug concentration.

### Part 2: ECG Biomarker Evaluation in Clinical Data (Python + PTB-XL)

Translate simulation-derived AP biomarkers to ECG-measurable surrogates. Apply simulation-derived reference ranges to ~21,000 real ECGs from PTB-XL to test whether the predicted sex differences in repolarisation reserve are consistent with clinical observations. This is a **consistency check**, not a validated clinical classifier: there is no drug-outcome ground truth in PTB-XL, and results are presented as hypothesis-supporting or -contradicting evidence, not as diagnostic performance.

---

## Drug Pharmacology

| Drug | Class | Primary block | Source |
|---|---|---|---|
| Sertraline | SSRI | IKr-dominant | https://pmc.ncbi.nlm.nih.gov/articles/PMC3484517/ |
| Fluvoxamine | SSRI | IKr + ICaL | McMillan et al. 2017 |
| Amitriptyline | TCA | IKr + IKs + multi-channel | McMillan et al. 2017 |
| Desipramine | TCA | INa-dominant | McMillan et al. 2017 |

#### Sertraline — Full Channel Block Parameters

| Multiplier       | Channel / Gene       | IC₅₀ (µM)    | h             |
|------------------|----------------------|---------------|---------------|
| IKr_Multiplier   | hERG                 | 0.70 ± 0.01   | 1.30 ± 0.02   |
| ICaL_Multiplier  | L-type Ca²⁺          | 2.60 ± 0.40   | 1.90 ± 0.50   |
| INa_Multiplier   | Nav1.5               | 6.10 ± 1.70   | 0.70 ± 0.20   |
| IK1_Multiplier   | KCNJ2 (Kir2.1)       | 10.50 ± 0.50  | 2.10 ± 0.20   |
| IKs_Multiplier   | KCNQ1/KCNE1          | 12.30 ± 1.30  | 2.50 ± 0.10   |
| IKv1.5_Multiplier| Kv1.5 (not modelled) | 0.71 ± 0.01   | 1.29 ± 0.04   |

#### Fluvoxamine — Full Channel Block Parameters

pIC50 values from McMillan et al. 2017 (Table 1); IC50 = 10^(6−pIC50) μM; h = 1 (CiPA standard).

| Multiplier      | Channel / Gene | pIC50 (log M) | IC₅₀ (µM) | h |
|-----------------|----------------|---------------|-----------|---|
| IKr_Multiplier  | hERG/IKr       | 5.4202        | 3.80      | 1 |
| ICaL_Multiplier | Cav1.2         | 5.3098        | 4.90      | 1 |
| INa_Multiplier  | Nav1.5         | 4.4045        | 39.4      | 1 |

#### Amitriptyline — Full Channel Block Parameters

pIC50 values from McMillan et al. 2017 (Table 1); IC50 = 10^(6−pIC50) μM; h = 1 (CiPA standard).

| Multiplier      | Channel / Gene  | pIC50 (log M) | IC₅₀ (µM) | h |
|-----------------|-----------------|---------------|-----------|---|
| IKr_Multiplier  | hERG/IKr        | 5.4841        | 3.28      | 1 |
| IKs_Multiplier  | KCNQ1/KCNE1     | 5.5627        | 2.73      | 1 |
| IpNa_Multiplier | Nav1.5 (late)   | 5.3533        | 4.43      | 1 |
| ICaL_Multiplier | Cav1.2          | 4.9355        | 11.6      | 1 |
| Ito_Multiplier  | Kv4.3/Kv1.4     | 5.0000        | 10.0      | 1 |
| INa_Multiplier  | Nav1.5 (fast)   | 4.6990        | 20.0      | 1 |

#### Desipramine — Full Channel Block Parameters

| Multiplier      | Channel / Gene  | IC₅₀ (µM) | h          | Source |
|-----------------|-----------------|-----------|------------|--------|
| INa_Multiplier  | Nav1.5          | 1.52      | 1 (assumed)| McMillan et al. 2017 |
| ICaL_Multiplier | Cav1.2          | 1.71      | 1 (assumed)| McMillan et al. 2017 |
| IKr_Multiplier  | hERG/Kv11.1     | 1.39      | 1 (assumed)| McMillan et al. 2017 |

> **Hill coefficient note**: h = 1 assumed uniformly for all desipramine channels, following CiPA-oriented practice. Experimental Hill coefficients from patch-clamp carry enough variability that using h = 1 as a default reduces systematic error (McMillan et al. 2017).

> **NOTE**: IC50 values are to be confirmed from primary patch-clamp studies before submission. Sensitivity analysis varies each IC50 by ±50%.

### Clinical Doses

| Drug          | Start Dose                                      | Therapeutic Range                                         | Maximum Dose                  |
|---------------|-------------------------------------------------|-----------------------------------------------------------|-------------------------------|
| Sertraline    | 50 mg/day                                       | 50–200 mg/day                                             | 200 mg/day                    |
| Fluvoxamine   | 50 mg/day (at bedtime)                          | 100–300 mg/day                                            | 300 mg/day                    |
| Amitriptyline | 75 mg/day (outpatients); 100 mg/day (inpatients)| 75–150 mg/day (outpatients); up to 200 mg/day (inpatients)| 300 mg/day (inpatients only)  |
| Desipramine   | 25–50 mg/day (titrated)                         | 100–200 mg/day                                            | 300 mg/day                    |

All dosage figures are sourced from FDA-approved public drug labels (DailyMed / PrescriberPoint).

- Sertraline's starting dose may be lowered to 25 mg/day for panic disorder, PTSD, and social anxiety disorder to improve tolerability before titrating up to the standard 50 mg/day.
- Fluvoxamine doses above 100 mg/day should be divided into two doses; if unequal, the larger dose is given at bedtime.
- Amitriptyline's 300 mg/day maximum is reserved for inpatients only; outpatient doses rarely exceed 150 mg/day.
- Desipramine doses above 200 mg/day should generally be managed in a hospital setting with regular ECG monitoring, given the risk of QRS/QT interval prolongation at higher plasma levels.

### mg/day → µM Conversion

Steady-state total plasma concentration is estimated from the one-compartment oral dosing formula at steady state:

$$C_{ss}\ (\mu\text{M}) = \frac{\text{Dose (mg/day)} \times 1000}{24 \times CL/F \times MW}$$

where CL/F is apparent oral clearance (L/h) and MW is molecular weight (g/mol). Assumes extensive metaboliser phenotype, linear kinetics, and once-daily dosing at steady state.

#### Pharmacokinetic constants used

| Drug | MW (g/mol) | CL/F (L/h) | Notes |
|---|---|---|---|
| Sertraline | 306.23 | 83 | Midpoint of 71–95 L/h literature range |
| Fluvoxamine | 318.33 | 157 | Healthy young adults at low doses; CL/F decreases at high doses (autoinhibition of CYP1A2/2C19) |
| Amitriptyline | 277.40 | 87 | Systemic CL with ~50% first-pass bioavailability |
| Desipramine | 266.38 | 111 | Standard CYP2D6 extensive metaboliser |

#### Resulting simulation concentrations (µM)

| Drug | Start | Therapeutic range | Maximum |
|---|---|---|---|
| Sertraline | 0.082 | 0.082 – 0.328 | 0.328 |
| Fluvoxamine | 0.042 | 0.083 – 0.250 | 0.250 |
| Amitriptyline | 0.129 (outpatient); 0.173 (inpatient) | 0.129 – 0.259 (outpatient); up to 0.345 (inpatient) | 0.518 |
| Desipramine | 0.035 – 0.070 | 0.141 – 0.282 | 0.423 |

#### Limitations of this conversion

- **Fluvoxamine non-linear kinetics**: fluvoxamine inhibits its own metabolism (CYP1A2/2C19 autoinhibition), so CL/F falls as dose increases. The 0.250 µM maximum using CL/F = 157 L/h is therefore a likely **underestimate** at 300 mg/day; the true concentration may be substantially higher.
- **Genetic polymorphisms**: values assume extensive metabolisers. Poor CYP2D6 metabolisers (desipramine, sertraline) or poor CYP2C19 metabolisers (sertraline, amitriptyline) can have CL/F < 33 L/h, pushing plasma concentrations into the toxic range (>1.4 µM for desipramine at 300 mg/day). Ultra-rapid metabolisers may never reach therapeutic concentrations.
- **Total vs free concentration**: these are total plasma concentrations. SSRIs and TCAs are highly protein-bound (sertraline ~98%, amitriptyline ~95%). Free (pharmacologically active) concentrations are 2–5% of the values above. Hill equation IC50 values from patch-clamp are measured against total bath concentration, so using total plasma Css is internally consistent for the simulation but does not reflect the free drug concentration at the cardiac cell membrane.

### Sex Parameterisation

Full female baseline scaling from Yang & Clancy (2017), derived from human cardiac gene expression data (Gaborit et al. 2010). Applied multiplicatively to the default ToR-ORd male parameters (baseline = 1.0):

| Current | Female scaling | Functional consequence |
|---|---|---|
| IKr | ×0.82 | Reduced repolarisation reserve → longer APD90 |
| IKs | ×0.79 | Reduced repolarisation reserve, compound effect with IKr |
| Ito | ×0.79 | Smaller phase-1 notch, alters AP morphology |
| IK1 | ×0.87 | Slightly reduced resting K⁺ conductance |
| ICaL | ×1.24 | Increased plateau inward current → APD prolongation |
| INaCa | ×1.44 | Increased Ca²⁺ extrusion, raises intracellular Ca²⁺ load |
| INaK | ×1.00 | Unchanged baseline conductance |
| INaL | ×1.00 | Unchanged baseline conductance |

Drug block is applied multiplicatively on top of the female baseline:
`IKr_Multiplier = 0.82 × coef(C, IC50_IKr, h_IKr)` (and equivalently for each blocked channel).

> **Note on INaK and INaL**: While their conductance scaling is 1.00, their *activity* diverges between sexes due to the altered voltage and Ca²⁺ environment created by the six scaled currents — particularly relevant for amitriptyline's late-Na block.

> **Previous parameterisation**: an earlier version used IKr ×0.85 only (Rautaharju et al. QTc data). The Yang & Clancy multi-channel parameterisation supersedes this; it is more mechanistically complete and better reproduces the female AP morphology (longer APD90, larger Ca²⁺ transient) observed in experimental data.

---

## Part 1: In Silico Drug Simulation

### Core: ToR-ORd Population of Models

Extends `Class1/POM.m` with:

1. **Sex-specific channel scaling** (Yang & Clancy 2017): for female models, apply before LHS variability:
   ```
   IKr_Multiplier  = LHSR(i,5) * 0.82    IKs_Multiplier  = LHSR(i,6) * 0.79
   Ito_Multiplier  = LHSR(i,7) * 0.79    IK1_Multiplier  = LHSR(i,?) * 0.87
   ICaL_Multiplier = LHSR(i,1) * 1.24    INaCa_Multiplier = 1.44
   ```
2. **Drug block via Hill equation** (existing pattern from Flecainide in POM.m):
   ```matlab
   coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);
   ```
3. **Population structure**: 30 male + 30 female models per condition, same LHS seed (`rng(42)`)
4. **Simulation protocol**: 10 beats, extract last 2 (steady-state), BCL = 1000 ms
5. **Output extraction**: APD90 + EAD detection for each model

### Experiments

| Experiment | Conditions | Models | Total sims |
|---|---|---|---|
| Baseline (no drug) | 1 × 2 sexes | 30 each | 60 |
| Sertraline dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Fluvoxamine dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Amitriptyline dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Desipramine dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Rate dependence (fluvoxamine only) | 3 BCL × 2 sexes × 5 conc | 30 each | 900 |
| Sensitivity analysis | 3 IC50 variants × 4 drugs × 2 sexes | 30 each | 720 |

Concentrations (single-drug): [0, 1, 2, 5, 10, 20, 50] μM  
BCL for rate dependence: [600, 800, 1000] ms (100, 75, 60 bpm — tachycardia to rest)

**Rationale for rate-dependence experiment**: Antidepressants are used chronically by patients who may experience elevated heart rates during exercise, panic attacks, or anxiety episodes — all common in the population prescribed these drugs. QT interval shortens at fast heart rates (rate adaptation); whether this compresses or widens the sex gap in EAD threshold under IKr-dominant pharmacology is not known a priori and constitutes a testable prediction. Fluvoxamine is chosen as the IKr-dominant SSRI (IKr IC50 = 3.80 μM, minimal INa confound), where rate-dependent effects on repolarisation reserve should be maximal.

### APD90 Computation

```
Vrest = V(end);  Vpeak = max(V);
V90 = Vrest + 0.1 * (Vpeak - Vrest);   % ≈ -75 mV
APD90 = time at V90 crossing (descending) − time of upstroke
```

### EAD Detection

After the AP peak, scan for any secondary depolarisation during repolarisation:
```
EAD = true if V(j) > V(j-1) + 2 mV  AND  V(j) > -40 mV  (after peak)
```

### Part 1 Key Output: Biomarker Discovery

For each of the 60 baseline (no-drug) models (30M + 30F), record:
- Baseline APD90
- Baseline APD50
- AP triangulation = APD90 − APD30 (flatter repolarisation = more vulnerable)
- Maximum repolarisation rate (dV/dt during phase 3)
- Resting membrane potential

Then correlate these baseline features with each model's **EAD threshold concentration** (the lowest drug concentration at which it develops an EAD). This reveals which resting electrophysiological features predict drug vulnerability.

**If no EADs are observed** at any tested concentration: report APD90 prolongation as the primary outcome and present the lowest-APD90-prolongation concentration by sex as a surrogate vulnerability threshold. This is not a failure — many published drug simulation studies report APD90 rather than EAD incidence. Acknowledge explicitly.

Expected findings:
- Longer baseline APD90 → lower EAD threshold (more vulnerable)
- Greater AP triangulation → lower EAD threshold
- These features are more prevalent in female models (due to lower IKr)

---

## Part 2: ECG Biomarker Evaluation in Clinical Data

### Step 1: Simulation → ECG Feature Mapping

Translate AP-level biomarkers to ECG-measurable surrogates:

| AP biomarker (simulation) | ECG surrogate (measurable) | Mapping rationale | Limitation |
|---|---|---|---|
| APD90 | QTc interval | APD90 is the cellular basis of QT duration | QT reflects population-averaged transmural AP, not a single cell |
| AP triangulation (APD90 − APD30) | Tpeak–Tend interval | Triangulated repolarisation → wider Tpeak–Tend | Tpeak–Tend also reflects transmural dispersion; single-cell triangulation is a proxy only |
| Repolarisation rate (dV/dt phase 3) | T-wave amplitude | Faster repolarisation → taller, sharper T-wave | T-wave amplitude depends on lead orientation and thorax geometry |

These mappings are **mechanistic hypotheses**, not derivations. The limitations column is reported explicitly in Methods.

### Step 2: Simulation-Derived Reference Ranges

From Part 1 correlation analysis, identify the baseline APD90 and triangulation values that separate models with EAD threshold ≤ 5 μM from those with EAD threshold > 5 μM. These AP boundaries translate to ECG reference thresholds (QTc, Tpeak–Tend) via the mappings above.

Present as: "Models in the upper quartile of APD90 (above X ms) develop EADs at concentrations that correspond to reported therapeutic or near-toxic plasma levels. The ECG surrogate of this quartile boundary is QTc > Y ms."

This is **not a classifier**. It is a simulation-derived reference range used to test whether the predicted sex difference in repolarisation features is consistent with clinical data.

### Step 3: Apply to PTB-XL

1. Load `ptbxl_database.csv`, filter normal ECGs (NORM confidence ≥ 80)
2. Load ECG signals via `wfdb` (records100/, 100 Hz)
3. For each ECG, extract from lead II:
   - QTc (Bazett: QTc = QT / √RR)
   - Tpeak–Tend interval
   - T-wave amplitude
4. Report the distribution of these features stratified by:
   - **Sex** (0=female, 1=male): test whether female QTc and Tpeak–Tend are shifted toward the simulation-predicted vulnerable region
   - **Age group** (pre-menopausal <50, post-menopausal ≥55): test whether the sex gap narrows post-menopause

### Part 2 — What This Can and Cannot Show

| Claim | Status | Justification |
|---|---|---|
| Female QTc > male QTc in PTB-XL | Testable, not circular | Expected from literature; confirms dataset is representative |
| Female QTc sex gap consistent with simulation APD90 gap | Testable consistency check | Direction and magnitude comparison; quantitative discrepancy expected and discussed |
| Sex gap narrows post-menopause | Genuinely testable prediction | This is not guaranteed by construction — requires the data to show it |
| Risk stratification rule identifies more women as vulnerable | Circular by construction | **Not claimed as validation.** Reported descriptively only. |
| Classifier has measurable accuracy | Not possible — no drug-outcome labels | Acknowledged as a limitation; MIMIC-IV proposed as the path to supervised validation |

---

## Verification, Validation & Uncertainty Quantification (VVUQ)

### Verification (is the code solving the equations correctly?)

| Check | Method | Expected result |
|---|---|---|
| Baseline male APD90 | Run ToR-ORd with default parameters, no drug | ~270 ms (matches Tomek et al. 2019 Table 2) |
| Baseline female APD90 | Run with IKr × 0.85 | ~285–295 ms (15–25 ms longer than male) |
| Drug block at C = 0 | Confirm coef(0, IC50, h) = 1.0 for all drugs | No channel modification at zero concentration |
| Drug block at C → ∞ | Confirm coef → 0 (full block) | APD90 → extreme prolongation or EAD |
| Flecainide comparison | Run with Flecainide IC50 from Class 1 POM.m | Results consistent with Class 1 output |

### Validation (does the model match clinical reality?)

| Level | Comparison | Data source | Expected agreement |
|---|---|---|---|
| V1: Baseline sex difference | Simulated APD90 sex gap (~15–25 ms) vs clinical QTc sex gap | PTB-XL normal ECGs, stratified by sex | Same direction, comparable magnitude (~10–20 ms) |
| V2: Age-dependent sex gap | Simulation predicts gap should narrow post-menopause (estrogen–IKr link) | PTB-XL QTc by sex × age group | QTc sex gap smaller in women >55 than women <50 — this is a genuine prospective test |
| V3: Drug QTc prolongation | Simulated APD90 prolongation at therapeutic/near-toxic plasma concentrations | Published clinical data and case reports for SSRI- and TCA-induced QT prolongation | Same order of magnitude |
| V4: Rate dependence direction | At faster BCL, does sex gap in EAD threshold increase or decrease? | No directly comparable clinical data — reported as a novel prediction | Hypothesis: faster rates shorten APD more in males (less triangulated AP), widening the sex gap |

### Uncertainty Quantification

| Parameter varied | Range | What to report |
|---|---|---|
| IC50_INa (each drug) | ±50% of nominal | Does EAD threshold shift? Does sex ranking change? |
| IC50_IKr (each drug) | ±50% of nominal | Does sex-differential EAD gap change qualitatively? |
| IKr sex multiplier | [0.75, 0.80, 0.85, 0.90, 0.95] | At what multiplier does the sex gap disappear? |
| PTB-XL QTc threshold | ±1 SD from simulation-derived value | Does the sex ratio in the above-threshold group remain >1.0? |

**Key robustness claim**: The qualitative finding — IKr-dominant antidepressants (SSRIs) produce larger sex differentials than INa-dominant antidepressants (TCAs such as desipramine) — should hold across the full parameter uncertainty range. If it does not, report that honestly as an inconclusive result (this satisfies the rubric's "unexpected/negative result" requirement).

---

## Three Figures

### Figure 1: Drug Dose-Response by Sex

**Layout**: Left + Right panels

- **Left**: EAD incidence (% of 30 models) vs drug concentration for all 4 drugs. Male (blue) and female (red) curves — 8 curves total. Shows sex gap is largest for IKr-dominant SSRIs (sertraline, fluvoxamine), intermediate for multi-channel TCA (amitriptyline), and smallest for INa-dominant desipramine. If EADs are absent, replace with median APD90 ± IQR.
- **Right**: Representative AP traces for one male and one female model under fluvoxamine at baseline, 5 μM, and 10 μM. Shows EAD emergence in female trace at lower concentration.

**Caption**: "The sex-differential arrhythmic threshold scales with IKr block potency. Female models develop EADs (or equivalent APD90 prolongation) at lower drug concentrations than male models, with the largest sex gap under IKr-dominant pharmacology (SSRIs: sertraline, fluvoxamine) and minimal gap under INa-dominant pharmacology (desipramine)."

### Figure 2: Biomarker Correlation + Rate Dependence

**Layout**: Left + Right panels

- **Left**: Scatter plot of baseline APD90 (x-axis) vs EAD threshold concentration (y-axis) for all 60 models (30M blue, 30F red). Negative correlation expected. Female models cluster in the high-APD90 / low-threshold region. Simulation-derived reference boundary overlaid as dashed line.
- **Right**: EAD incidence vs fluvoxamine concentration at BCL = 600, 800, 1000 ms for male (blue) and female (red). Shows whether elevated heart rate (e.g. during exercise or a panic episode) modulates the sex gap — the genuinely unpredictable result of this study.

**Caption**: "Baseline action potential duration predicts antidepressant-induced arrhythmia vulnerability. Models with longer APD90 — disproportionately female — develop EADs at lower fluvoxamine concentrations. Right panel shows the effect of heart rate on the sex-differential threshold; the direction and magnitude of this interaction constitutes a novel simulation prediction."

### Figure 3: PTB-XL Consistency Check

**Layout**: Left + Right panels

- **Left**: Violin plots of QTc distribution in PTB-XL by sex, with simulation-derived reference boundary marked. Report proportion above boundary by sex. Women expected to have higher median QTc and greater proportion above threshold.
- **Right**: QTc sex gap (female minus male median, ms) by age group in PTB-XL. Pre-menopausal (<50), perimenopausal (50–55), post-menopausal (>55). Expected: sex gap narrows with age.

**Caption**: "Clinical ECG data from PTB-XL are consistent with simulation-derived predictions. Female QTc is systematically higher than male QTc, with a greater proportion of women exceeding the simulation-derived repolarisation boundary. The sex gap in QTc narrows post-menopause, consistent with the hormonal modulation of IKr. These observations support but do not validate the simulation framework; prospective drug-outcome data are required for clinical validation."

---

## Paper Structure — Rubric Compliance (100 marks)

### Abstract (10 marks)

| Element | Content |
|---|---|
| Background | Antidepressants — particularly SSRIs and TCAs — carry a risk of drug-induced QT prolongation and Torsades de Pointes (TdP); women are overrepresented in drug-induced TdP (~65–75%); the electrophysiological basis is reduced IKr conductance but no systematic cross-drug, cross-class quantification exists |
| Research question | State the RQ verbatim |
| Aim | Three aims as stated above |
| Methods | ToR-ORd POM + Hill equation pharmacology + rate-dependence experiment → biomarker discovery → ECG biomarker evaluation in PTB-XL |
| Findings | Key numbers: EAD thresholds by sex per drug, direction of rate-dependence effect, consistency with PTB-XL QTc distributions |
| Conclusions | Sex-differential arrhythmia thresholds scale with IKr block potency across antidepressant classes; SSRIs show larger sex gaps than INa-dominant TCAs; simulation-derived repolarisation biomarkers are consistent with clinical ECG data; rate dependence modulates the sex gap in a direction that has clinical implications for exercise and anxiety co-exposure |

### Introduction (15 marks)

**Medical relevance + sex differences (5 marks)**:
- Antidepressants are among the most prescribed drug classes globally; cardiac arrhythmias are a recognised risk, particularly with TCAs in overdose and with SSRIs at therapeutic doses
- Women have ~15% lower IKr → longer QTc → less repolarisation reserve
- 65–75% of drug-induced TdP cases are female (Makkar et al. 1993)
- Patients prescribed antidepressants frequently experience anxiety, panic attacks, or participate in exercise — all of which elevate heart rate; the interaction between tachycardia and IKr block is clinically unexplored
- Gap: no systematic computational study compares sex-differential risk across SSRI and TCA mechanisms, nor examines the rate-dependence of the sex gap

**Motivation for computational methods (5 marks)**:
- Clinical studies cannot control dose, isolate channel mechanisms, or ethically administer drugs at arrhythmogenic concentrations
- ToR-ORd: state-of-the-art human ventricular cell model (Tomek et al. 2019)
- Population of Models: captures inter-individual variability via LHS
- Hill equation: validated pharmacodynamic framework (used in Class 1 for Flecainide)
- Single-cell approach is appropriate for studying ion channel mechanisms; tissue-level effects are a known limitation, not an omission

**Clear aim with literature context (5 marks)**:
- Prior work: Rodriguez et al. (sex-specific cardiac models), Muszkiewicz et al. (POM methodology), existing single-drug antidepressant simulation studies
- Gap: no cross-class mechanistic comparison of sex-differential arrhythmia risk for antidepressants; no examination of rate dependence
- State three aims explicitly

### Methods (25 marks)

**Datasets, models, algorithms, software (5 marks)**:
- ToR-ORd model (Tomek et al. 2019), endocardial cell type
- PTB-XL (Wagner et al. 2020, Nature Scientific Data, 21,837 12-lead ECGs)
- MATLAB R2024a, Python 3.x, wfdb, neurokit2, scipy
- Population: LHS, 30 samples, 7 parameters, bounds [0.5, 2.0]
- No ML classifier used; ECG analysis is distributional, not predictive

**Foundations of the model and its derivation (5 marks)**:
- ToR-ORd: Hodgkin-Huxley formalism, conservation of charge
- Key equation: IKr = GKr × √([K+]o/5.4) × xr × rkr × (V − EK)
- Hill equation: coef = 1/(1+(C/IC50)^h) — from receptor occupancy theory
- Sex parameterisation: IKr_female = 0.85 × IKr_male
- AP-to-ECG surrogate mapping with explicit limitations stated

**Experiments performed with protocols (5 marks)**:
- Part 1: 4 drugs × 7 concentrations × 2 sexes × 30 models; EAD detection + APD90
- Rate-dependence: fluvoxamine × 3 BCL × 2 sexes × 5 concentrations × 30 models
- Part 1→2 bridge: correlation of baseline AP features with EAD threshold; reference boundary derivation
- Part 2: ECG feature extraction from PTB-XL lead II; distributional analysis by sex and age group
- Sensitivity: IC50 ±50%, IKr sex multiplier [0.75, 0.85, 0.95]

**Open science and reproducibility (5 marks)**:
- Fixed rng seed (42)
- All IC50 values with explicit citations
- PTB-XL is public (DOI: 10.13026/x3p0-ij36)
- All simulation thresholds derived transparently from first principles — no fitted or tuned parameters
- Code available in project repository

**At least one rejected approach with justification (5 marks)**:

- **Rejected: Tissue-level simulation for 12-lead ECG generation (MonoAlg3D)**: Generating 12-lead ECGs from ion channel data requires a biventricular mesh, heterogeneous transmural cell parameterisation, a torso conduction model, and electrode placement. Class 2 demonstrated this for simple slab geometry requiring >2h setup; a full heart+torso forward problem is infeasible in this timeframe. More importantly, the central hypothesis concerns ion channel-level sex differences — testing it requires single-cell resolution, not the forward ECG problem. The rejected approach would have obscured the mechanism in geometrical complexity.

- **Rejected: Supervised ML risk classifier**: Requires labelled ECGs with drug-exposure outcomes. PTB-XL contains no drug administration records. Training a classifier on features derived from simulation-labelled thresholds would produce a model that cannot be validated against clinical outcomes, and whose claimed accuracy would be an artefact of the threshold choice. The distributional analysis approach is scientifically honest: it reports what the data show, not a spuriously precise performance metric.

### Results & Discussion (35 marks)

**Credibility: V&V + sensitivity analysis (5 marks)**:
- Verification: baseline male APD90 matches ToR-ORd paper values (~270 ms); female APD90 is 15–25 ms longer; drug block = 0 at C = 0
- Validation V1–V3 as tabulated above
- Sensitivity: IC50 ±50% variation, IKr multiplier [0.75, 0.95]; qualitative ranking (SSRIs > desipramine) must hold for conclusion to stand

**Results addressing the research question (10 marks)**:
- Part 1: EAD thresholds (or APD90 prolongation) by sex per drug; ranking by IKr dominance across SSRI vs TCA classes
- Part 1 rate dependence: direction of sex gap change under fluvoxamine at BCL 600 vs 1000 ms
- Part 1→2 bridge: baseline APD90 and triangulation predict EAD vulnerability; reference boundary derived
- Part 2: PTB-XL QTc and Tpeak–Tend distributions by sex and age group; consistency with simulation predictions assessed

**Max 3 figures (10 marks)**:
- See Figure descriptions above
- All axes labelled with units (mV, ms, μM, %)
- Scientific claims stated in each caption, not just descriptions
- Population data: median ± IQR (not mean ± SD — distributions are not guaranteed Gaussian)

**Contextualisation with prior literature (5 marks)**:
- Compare sex difference magnitude to Rodriguez et al.
- Compare QTc sex gap to Rautaharju et al.
- Relate to Makkar et al. female TdP preponderance
- Discuss QTc and Tpeak–Tend as established arrhythmia risk markers (Antzelevitch et al.)
- Relate SSRI/TCA cardiac liability to existing clinical pharmacovigilance literature

**At least one unexpected/negative/inconclusive result (5 marks)**:
- **Candidate 1 (negative)**: Desipramine shows minimal sex differential — confirms that the female vulnerability is mechanism-specific to IKr block, not a general drug effect. This is a negative result that strengthens the mechanistic claim, and usefully differentiates TCAs by their dominant blocking profile.
- **Candidate 2 (unexpected)**: Rate dependence may reduce rather than amplify the sex gap — if fast pacing shortens APD equally in both sexes, elevated heart rate may not worsen relative female risk. Report honestly.
- **Candidate 3 (inconclusive)**: At low concentrations of amitriptyline, competing INa and ICaL block may shorten APD in some models, producing a non-monotonic dose-response despite IKr block. This complicates the narrative and must be discussed rather than smoothed over.

### Conclusions (15 marks)

**Key findings and contributions (5 marks)**:
- Sex-differential arrhythmia thresholds scale with IKr block potency across antidepressant drug classes
- SSRIs (sertraline, fluvoxamine) produce larger sex gaps than INa-dominant TCAs (desipramine); amitriptyline occupies an intermediate position due to multi-channel block
- Baseline AP features (APD90, triangulation) predict individual EAD vulnerability within a sex-stratified population
- Rate-dependence of the sex gap under fluvoxamine is a novel prediction with clinical implications for exercise- and anxiety-related tachycardia in patients on SSRIs
- Simulation predictions are directionally consistent with PTB-XL ECG data; the post-menopausal narrowing of the sex gap in QTc provides the strongest consistency test

**Critique of the proposed approach (5 marks)**:
- **Strengths**: mechanistic, human-specific, population-level, reproducible, no fitted parameters, honest about what PTB-XL can and cannot show
- **Limitations**: single-cell only (no spatial conduction or reentry — EADs are necessary but not sufficient for arrhythmia); static sex parameterisation (ignores hormonal cycle variation); IC50 values from heterologous expression systems (not human in vivo); AP→ECG surrogate mapping assumes transmural homogeneity; 100 Hz PTB-XL resolution limits Tpeak–Tend precision (~10 ms)

**Next steps towards clinical or industrial impact (5 marks)**:
- **MIMIC-IV supervised model**: MIMIC-IV combines 12-lead ECGs recorded at emergency department admission with toxicology results and clinical outcomes. This enables a supervised classifier trained on actual drug-exposure labels, with measurable AUROC and calibration. The simulation work provides mechanistic interpretability that a pure ML model would lack — the two approaches are complementary, not competing.
- **Tissue-level extension**: once the ion channel hypothesis is established here, extending to a biventricular simulation would test whether single-cell EADs translate to re-entrant arrhythmias, and enable synthetic 12-lead ECG generation for direct ECG-level sex comparison.
- **CiPA framework contribution**: sex-aware cardiac safety pharmacology is an unmet regulatory need; this work contributes to the evidence base for sex-stratified IC50 risk thresholds in antidepressant drug approval and post-market surveillance.

---

## File Structure

```
Mini-Project/
├── plan.md                    ← This file
├── context.md                 ← Course instructions
├── src/
│   ├── POM_drugs.m            ← Part 1: sex-stratified drug simulation (4 drugs + rate dependence)
│   ├── biomarker_analysis.m   ← Part 1→2: correlate baseline features with EAD threshold
│   ├── sensitivity_analysis.m ← Sensitivity: IC50 and sex multiplier variation
│   ├── compute_APD90.m        ← Helper: APD90 extraction
│   ├── detect_EAD.m           ← Helper: EAD detection
│   ├── ptbxl_features.py      ← Part 2: extract QTc, TpTe, T-amp from PTB-XL
│   └── ptbxl_analysis.py      ← Part 2: distributional analysis by sex and age group
├── results/                   ← .mat and .csv output files
├── figures/                   ← Publication-quality figures
└── paper/
    └── report.tex             ← 4-page conference paper
```

---

## Timeline (7 working days)

| Day | Date | Tasks |
|---|---|---|
| 1 | Apr 4 | Confirm IC50 values from primary sources for all 4 antidepressants; implement `POM_drugs.m` (sex-specific IKr + 4 drugs + rate dependence parameter) |
| 2 | Apr 5 | Run all dose-response simulations (4 drugs × 2 sexes × 7 conc); run rate-dependence (fluvoxamine × 3 BCL) |
| 3 | Apr 6 | Implement and run `biomarker_analysis.m`; implement `ptbxl_features.py` |
| 4 | Apr 7 | Run PTB-XL extraction + distributional analysis; run sensitivity analysis |
| 5 | Apr 8 | Generate all 3 figures; write Methods |
| 6 | Apr 9 | Write Introduction + Results & Discussion + Abstract + Conclusions |
| 7 | Apr 10–14 | Revise, rubric audit, polish figures, proofread |

---

## Key Risks and Mitigations

| Risk | Mitigation |
|---|---|
| IC50 values poorly documented for SSRIs/TCAs in patch-clamp literature | Sensitivity analysis covers ±50%; report findings as conditional on parameter values |
| No EADs observed in simulation | Use APD90 prolongation as primary outcome; explicitly state this is not a failure |
| Rate-dependence result is null (no BCL effect) | Report as negative result — absence of rate-dependence is itself informative |
| PTB-XL QTc/TpTe extraction noisy at 100 Hz | Use large sample; report median/IQR; acknowledge 100 Hz resolution as limitation; use records500/ if Tpeak–Tend is unresolvable |
| Post-menopausal QTc gap does not narrow in PTB-XL | Report as a negative result contradicting the estrogen–IKr mechanism; acknowledge as genuine scientific uncertainty |
| Paper exceeds 4 pages | Strict word budget; figures take ~1.5 pages; VVUQ table in Methods not Results |

---

## Literature to Cite

| Citation | Used for |
|---|---|
| Tomek et al. 2019 | ToR-ORd model |
| Wagner et al. 2020 | PTB-XL dataset |
| Makkar et al. 1993 | Female preponderance in drug-induced TdP |
| Rautaharju et al. 2009 | Sex differences in QTc, age dependence |
| Rodriguez et al. 2010 | Sex-specific cardiac models, early IKr sex parameterisation |
| Yang & Clancy 2017 | Full female ORd scaling factors (IKr, IKs, Ito, IK1, ICaL, INaCa) |
| Gaborit et al. 2010 | Human cardiac ion channel gene expression data underpinning sex scaling |
| Muszkiewicz et al. 2016 | Population of Models methodology |
| McMillan et al. 2017 (Toxicol. Res., DOI: 10.1039/C7TX00141J) | Fluvoxamine, amitriptyline, desipramine IC50s — see per-drug tables above |
| Afkhami et al. (PMC3484517) | Sertraline multi-channel IC50s |
| Nachimuthu et al. 2012 | Drug-induced QT prolongation review |
| Antzelevitch et al. 2007 | Tpeak–Tend as arrhythmia risk marker |
| Johnson et al. (MIMIC-IV) | Future validation dataset |
