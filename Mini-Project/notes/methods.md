# Methods: Sex Differences in Antidepressant-Induced Arrhythmia Risk

*This page contains AI-generated content, in line with mini-project guidelines*

---

## Drug Pharmacology

| Drug | Class | Primary block | Source |
|------|-------|---------------|--------|
| Sertraline | SSRI | IKr-dominant | https://pmc.ncbi.nlm.nih.gov/articles/PMC3484517/ |
| Amitriptyline | TCA | IKr + IKs + multi-channel | McMillan et al. 2017 |
| Desipramine | TCA | INa-dominant | McMillan et al. 2017 |

### Sertraline — Full Channel Block Parameters

| Multiplier        | Channel / Gene        | IC₅₀ (µM)   | h           |
|-------------------|-----------------------|-------------|-------------|
| IKr_Multiplier    | hERG                  | 0.70 ± 0.01 | 1.30 ± 0.02 |
| ICaL_Multiplier   | L-type Ca²⁺           | 2.60 ± 0.40 | 1.90 ± 0.50 |
| INa_Multiplier    | Nav1.5                | 6.10 ± 1.70 | 0.70 ± 0.20 |
| IK1_Multiplier    | KCNJ2 (Kir2.1)        | 10.50 ± 0.50 | 2.10 ± 0.20 |
| IKs_Multiplier    | KCNQ1/KCNE1           | 12.30 ± 1.30 | 2.50 ± 0.10 |
| IKv1.5_Multiplier | Kv1.5 (not modelled)  | 0.71 ± 0.01 | 1.29 ± 0.04 |

### Amitriptyline — Full Channel Block Parameters

pIC50 values from McMillan et al. 2017 (Table 1); IC50 = 10^(6−pIC50) μM; h = 1 (CiPA standard).

| Multiplier      | Channel / Gene  | pIC50 (log M) | IC₅₀ (µM) | h |
|-----------------|-----------------|---------------|-----------|---|
| IKr_Multiplier  | hERG/IKr        | 5.4841        | 3.28      | 1 |
| IKs_Multiplier  | KCNQ1/KCNE1     | 5.5627        | 2.73      | 1 |
| INaL_Multiplier | Nav1.5 (late)   | 5.3533        | 4.43      | 1 |
| ICaL_Multiplier | Cav1.2          | 4.9355        | 11.6      | 1 |
| Ito_Multiplier  | Kv4.3/Kv1.4     | 5.0000        | 10.0      | 1 |
| INa_Multiplier  | Nav1.5 (fast)   | 4.6990        | 20.0      | 1 |

### Desipramine — Full Channel Block Parameters

| Multiplier      | Channel / Gene  | IC₅₀ (µM) | h            | Source |
|-----------------|-----------------|-----------|--------------|--------|
| INa_Multiplier  | Nav1.5          | 1.52      | 1 (assumed)  | McMillan et al. 2017 |
| ICaL_Multiplier | Cav1.2          | 1.71      | 1 (assumed)  | McMillan et al. 2017 |
| IKr_Multiplier  | hERG/Kv11.1     | 1.39      | 1 (assumed)  | McMillan et al. 2017 |

> **Hill coefficient note**: h = 1 assumed uniformly for all desipramine channels, following CiPA-oriented practice. Experimental Hill coefficients from patch-clamp carry enough variability that using h = 1 as a default reduces systematic error (McMillan et al. 2017).

> **NOTE**: IC50 values are to be confirmed from primary patch-clamp studies before submission. Sensitivity analysis varies each IC50 by ±50%.

### Clinical Doses

| Drug          | Start Dose                                       | Therapeutic Range                                          | Maximum Dose                 |
|---------------|--------------------------------------------------|------------------------------------------------------------|------------------------------|
| Sertraline    | 50 mg/day                                        | 50–200 mg/day                                              | 200 mg/day                   |
| Amitriptyline | 75 mg/day (outpatients); 100 mg/day (inpatients) | 75–150 mg/day (outpatients); up to 200 mg/day (inpatients) | 300 mg/day (inpatients only) |
| Desipramine   | 25–50 mg/day (titrated)                          | 100–200 mg/day                                             | 300 mg/day                   |

Dosage figures are sourced from FDA-approved public drug labels (DailyMed / PrescriberPoint) and are backed by the following clinical references:

- Sertraline: [Sertraline safety and efficacy in major depression: a double-blind fixed-dose comparison with placebo](https://pubmed.ncbi.nlm.nih.gov/8573661/) by Fabre et al.
- Amitriptyline: [Amitriptyline versus placebo for major depressive disorder (Review)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11299154/pdf/CD009138.pdf) by Leucht et al.
- Desipramine: [Desipramine Plasma Concentration and Antidepressant Response](https://watermark02.silverchair.com/archpsyc_39_12_010.pdf?token=AQECAHi208BE49Ooan9kkhW_Ercy7Dm3ZL_9Cf3qfKAc485ysgAAAzUwggMxBgkqhkiG9w0BBwagggMiMIIDHgIBADCCAxcGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMAxM-y06y2FFIxM89AgEQgIIC6ANdmxM-GeWyMwnLUOYNUaE44OELdPfJB-lLEEfVU33IcjA84ByVM0OSCqDC3vAhDoSqEXvz4NpasIFCJgFparo08WaCc82YVM1RdbxwEl0Bm2tZ-57klFe_XsadlNz2hc7Rmi4N8ARHnO0Fi8nx3JtUoKb-2zd0RIp4tmVOMTrdCQOWUDoknK2e1wcT6AFGV03TqtNnrdud6LuX_iYS_S3DIDuob83zjByCWo-BxkQ2A0GbVhYe-aaq793wnsYYYlYU573E69Q02NoSNMTdZqDQYo1xU5LqmizDwjkoOTLOB8Ssc3sRCaLND856Et1ea3zDrzVulvlKxTYc6r_yh7KBnEXA9xMa3a05-vwLq5w1Dexo_UAe-n4y6vcfOKDuPQwXdXM3gvFR9p8vT1G5-HW2tKcdY4yLsxchDVmNcob4G3NYUo5pkTY3m06xPjmm36p-dbCWRclk20h11dOmoJsZ_5W1-UvOFKKpm94-JBzi19k94XcD32yTg8Ob2vJUaomnMtKncUMxeWs30Vz8TyHJq01AIxd1xLpbh4O6A9i0aYt054-DeAYV4QBBev5NpQr3-kQ1jQzJ3zat18FTNHfymDGEjzlID1LZzxuyLrrwGGLBc4eRBu8X-k5CiscdoYfgkd2LN2GfOn5n3m7DShsb5FkdWDkhfcEbqRjLysxXi-e73kQl36NchDIoVlEgxWVV837RZfFq8QfsV8n7TnUPE8DFnSNgFnnVfx7ScFZyAp6L0Q5Es7037qLVG41QFtulJy3lnzHUkNcH48pkQxbY4OSD9w_JkegyImhoybBlWvRt68cXF4SGnz37ziT4Ia4KOGg1P8XaYQfeBR6GgwhX8_MNpjSzD9O4O-8oiWVOgQdtcFQzyiB77b0sBSvFFbvmjBmbCrSYc080yF_CQ3WH86IK05Okwmn2NZoC_zlvKDU2K0_9_muoRM-yiUhvRup2-b-7henk44hkTtF9f_OyE6TsSS52Tg) by Craig Nelson et al.

- Sertraline's starting dose may be lowered to 25 mg/day for panic disorder, PTSD, and social anxiety disorder to improve tolerability before titrating up to the standard 50 mg/day.
- Amitriptyline's 300 mg/day maximum is reserved for inpatients only; outpatient doses rarely exceed 150 mg/day.
- Desipramine doses above 200 mg/day should generally be managed in a hospital setting with regular ECG monitoring, given the risk of QRS/QT interval prolongation at higher plasma levels.

### mg/day → µM Conversion

Steady-state total plasma concentration is estimated from the one-compartment oral dosing formula at steady state:

$$C_{ss}\ (\mu\text{M}) = \frac{\text{Dose (mg/day)} \times 1000}{24 \times CL/F \times MW}$$

where CL/F is apparent oral clearance (L/h) and MW is molecular weight (g/mol). Assumes extensive metaboliser phenotype, linear kinetics, and once-daily dosing at steady state.

#### Pharmacokinetic constants used

| Drug | MW (g/mol) | CL/F (L/h) | Notes |
|------|------------|------------|-------|
| Sertraline | 306.23 | 83 | Midpoint of 71–95 L/h literature range |
| Amitriptyline | 277.40 | 87 | Systemic CL with ~50% first-pass bioavailability |
| Desipramine | 266.38 | 111 | Standard CYP2D6 extensive metaboliser |

#### Resulting simulation concentrations (µM)

| Drug | Start | Therapeutic range | Maximum |
|------|-------|-------------------|---------|
| Sertraline | 0.082 | 0.082 – 0.328 | 0.328 |
| Amitriptyline | 0.129 (outpatient); 0.173 (inpatient) | 0.129 – 0.259 (outpatient); up to 0.345 (inpatient) | 0.518 |
| Desipramine | 0.035 – 0.070 | 0.141 – 0.282 | 0.423 |

#### Limitations of this conversion

- **Genetic polymorphisms**: values assume extensive metabolisers. Poor CYP2D6 metabolisers (desipramine, sertraline) or poor CYP2C19 metabolisers (sertraline, amitriptyline) can have CL/F < 33 L/h, pushing plasma concentrations into the toxic range (>1.4 µM for desipramine at 300 mg/day). Ultra-rapid metabolisers may never reach therapeutic concentrations.
- **Total vs free concentration**: these are total plasma concentrations. SSRIs and TCAs are highly protein-bound (sertraline ~98%, amitriptyline ~95%). Free (pharmacologically active) concentrations are 2–5% of the values above. Hill equation IC50 values from patch-clamp are measured against total bath concentration, so using total plasma Css is internally consistent for the simulation but does not reflect the free drug concentration at the cardiac cell membrane.

### Sex Parameterisation

Full female baseline scaling from Yang & Clancy (2017), derived from human cardiac gene expression data (Gaborit et al. 2010). Applied multiplicatively to the default ToR-ORd male parameters (baseline = 1.0):

| Current | Female scaling | Functional consequence |
|---------|----------------|------------------------|
| IKr     | ×0.82 | Reduced repolarisation reserve → longer APD90 |
| IKs     | ×0.79 | Reduced repolarisation reserve, compound effect with IKr |
| Ito     | ×0.79 | Smaller phase-1 notch, alters AP morphology |
| IK1     | ×0.87 | Slightly reduced resting K⁺ conductance |
| ICaL    | ×1.24 | Increased plateau inward current → APD prolongation |
| INaCa   | ×1.44 | Increased Ca²⁺ extrusion, raises intracellular Ca²⁺ load |
| INaK    | ×1.00 | Unchanged baseline conductance |
| INaL    | ×1.00 | Unchanged baseline conductance |

Drug block is applied multiplicatively on top of the female baseline:
`IKr_Multiplier = 0.82 × coef(C, IC50_IKr, h_IKr)` (and equivalently for each blocked channel).

> **Note on INaK and INaL**: While their conductance scaling is 1.00, their *activity* diverges between sexes due to the altered voltage and Ca²⁺ environment created by the six scaled currents — particularly relevant for amitriptyline's late-Na block.

> **Previous parameterisation**: an earlier version used IKr ×0.85 only (Rautaharju et al. QTc data). The Yang & Clancy multi-channel parameterisation supersedes this; it is more mechanistically complete and better reproduces the female AP morphology (longer APD90, larger Ca²⁺ transient) observed in experimental data.

---

## Part 1: In Silico Drug Simulation

### Core: ToR-ORd Population of Models

Extends `Class1/POM.m` with:

1. **Sex-specific channel scaling** (Yang & Clancy 2017): for female models, apply before LHS variability:

   ```matlab
   IKr_Multiplier   = LHSR(i,5) * 0.82    IKs_Multiplier  = LHSR(i,6) * 0.79
   Ito_Multiplier   = LHSR(i,7) * 0.79    IK1_Multiplier  = F_IK1 * 0.87
   ICaL_Multiplier  = LHSR(i,1) * 1.24    INaCa_Multiplier = LHSR(i,3) * 1.44
   ```

2. **Drug block via Hill equation** (existing pattern from Flecainide in POM.m):

   ```matlab
   coef = @(X, IC50, h) 1 / (1 + (X/IC50)^h);
   ```

3. **Population structure**: 30 male + 30 female models per condition, same LHS seed (`rng(42)`)
4. **Simulation protocol**: 10 beats, extract last 2 (steady-state), BCL = 1000 ms
5. **Output extraction**: APD90 + EAD detection for each model

### LHS Bounds: Biological Justification and Limitations

The LHS conductance scaling bounds [0.5, 2.0] are the standard in published cardiac POM work, taken directly from Muszkiewicz et al. 2016 (Prog Biophys Mol Biol 120:150–157). These bounds represent a 4× total span in channel conductance, motivated by human cardiac ion channel gene expression data from Gaborit et al. 2010 (J Physiol 588:1659–1675), which measured ~2–4 fold inter-individual variability in transcript levels across cardiac ion channels.

**Why the bounds are approximately realistic**:
- Gaborit et al. measured mRNA variability across human donor hearts; [0.5, 2.0] spans the observed range
- The bounds are symmetric in log space: a model at 0.5× is as far from nominal as one at 2.0×
- Using the same bounds for all 7 channels follows the convention established in Class 1 and in the published literature

**Where the bounds are liberal**:
- mRNA variability ≠ protein expression variability ≠ functional conductance variability. Each step attenuates the range, so [0.5, 2.0] likely overestimates conductance variability at the protein/channel level
- LHS samples channels independently; in practice, some combinations (e.g. IKr × 0.5 AND IKs × 0.5 simultaneously) are unlikely in real patients because channels share regulatory pathways
- In rigorous POM studies, a **calibration step** is applied post-sampling: any virtual patient whose AP biomarkers (APD90, Vpeak, Vrest, dV/dt_max) fall outside the physiologically observed human range is discarded (Muszkiewicz et al. 2016). This step was not applied here (following Class 1 convention), which means a small fraction of virtual patients at the extremes may be physiologically implausible

**Practical consequence**: The broad bounds inflate the inter-individual APD90 range in simulation (female POM spans 219–525 ms) relative to the clinical QTc range (female PTB-XL IQR 397–436 ms). This is why the simulated sex gap in APD90 (~68 ms between medians) is larger than the clinical QTc sex gap (~9 ms). Crucially, the **rank ordering and direction** of the sex difference are preserved in both; only the absolute magnitudes differ due to the LHS sampling breadth. This discrepancy is discussed explicitly in Results and is expected from the methodology.

> **Methods statement**: "Ion channel conductances were sampled using Latin hypercube sampling over the range [0.5, 2.0]× nominal, following Muszkiewicz et al. (2016) and the Class 1 convention. No calibration filter was applied; the LHS bounds therefore represent an upper bound on inter-individual conductance variability, consistent with the mRNA variability reported by Gaborit et al. (2010)."

### Experiments

| Experiment | Conditions | Models | Total sims |
|------------|------------|--------|------------|
| Baseline (no drug) | 1 × 2 sexes | 30 each | 60 |
| Sertraline dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Amitriptyline dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Desipramine dose-response | 7 conc × 2 sexes | 30 each | 420 |
| Rate dependence (sertraline only) | 3 BCL × 2 sexes × 5 conc | 30 each | 900 |
| Sensitivity analysis | 3 IC50 variants × 3 drugs × 2 sexes | 30 each | 540 |

Concentrations (single-drug): [0, 1, 2, 5, 10, 20, 50] μM
BCL for rate dependence: [600, 1000, 1200] ms (100, 60, 50 bpm — light effort / normal rest / slow rest or sleep)

**Rationale for BCL range**: IKr block exhibits reverse use-dependence — APD prolongation and EAD risk are worse at slow heart rates because IKr channels have more time to be blocked and less recovery during diastole. EADs for IKr-blocking drugs are therefore a rest and sleep phenomenon, not an exercise phenomenon. BCL = 1000 ms is the baseline used in all other simulations (direct comparison); BCL = 600 ms represents light effort or anxiety/panic (common in patients prescribed antidepressants); BCL = 1200 ms represents sleep or beta-blocker co-medication (50 bpm, both clinically prevalent in this population). This range tests the counterintuitive prediction that IKr-blocking antidepressants are more dangerous at rest than during the anxiety or exercise that often prompts their prescription.

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
|---------------------------|----------------------------|-------------------|------------|
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
|-------|--------|---------------|
| Female QTc > male QTc in PTB-XL | Testable, not circular | Expected from literature; confirms dataset is representative |
| Female QTc sex gap consistent with simulation APD90 gap | Testable consistency check | Direction and magnitude comparison; quantitative discrepancy expected and discussed |
| Sex gap narrows post-menopause | Genuinely testable prediction | This is not guaranteed by construction — requires the data to show it |
| Risk stratification rule identifies more women as vulnerable | Circular by construction | **Not claimed as validation.** Reported descriptively only. |
| Classifier has measurable accuracy | Not possible — no drug-outcome labels | Acknowledged as a limitation; MIMIC-IV proposed as the path to supervised validation |

---

## Verification, Validation & Uncertainty Quantification (VVUQ)

### Verification (is the code solving the equations correctly?)

| Check | Method | Expected result |
|-------|--------|-----------------|
| Baseline male APD90 | Run ToR-ORd with default parameters, no drug | ~270 ms (matches Tomek et al. 2019 Table 2) |
| Baseline female APD90 | Run with IKr × 0.85 | ~285–295 ms (15–25 ms longer than male) |
| Drug block at C = 0 | Confirm coef(0, IC50, h) = 1.0 for all drugs | No channel modification at zero concentration |
| Drug block at C → ∞ | Confirm coef → 0 (full block) | APD90 → extreme prolongation or EAD |
| Flecainide comparison | Run with Flecainide IC50 from Class 1 POM.m | Results consistent with Class 1 output |

### Validation (does the model match clinical reality?)

| Level | Comparison | Data source | Expected agreement |
|-------|------------|-------------|--------------------|
| V1: Baseline sex difference | Simulated APD90 sex gap (~15–25 ms) vs clinical QTc sex gap | PTB-XL normal ECGs, stratified by sex | Same direction, comparable magnitude (~10–20 ms) |
| V2: Age-dependent sex gap | Simulation predicts gap should narrow post-menopause (estrogen–IKr link) | PTB-XL QTc by sex × age group | QTc sex gap smaller in women >55 than women <50 — this is a genuine prospective test |
| V3: Drug QTc prolongation | Simulated APD90 prolongation at therapeutic/near-toxic plasma concentrations | Published clinical data and case reports for SSRI- and TCA-induced QT prolongation | Same order of magnitude |
| V4: Rate dependence direction | At faster BCL, does sex gap in EAD threshold increase or decrease? | No directly comparable clinical data — reported as a novel prediction | Hypothesis: faster rates shorten APD more in males (less triangulated AP), widening the sex gap |

### Uncertainty Quantification

| Parameter varied | Range | What to report |
|-----------------|-------|----------------|
| IC50_INa (each drug) | ±50% of nominal | Does EAD threshold shift? Does sex ranking change? |
| IC50_IKr (each drug) | ±50% of nominal | Does sex-differential EAD gap change qualitatively? |
| IKr sex multiplier | [0.75, 0.80, 0.85, 0.90, 0.95] | At what multiplier does the sex gap disappear? |
| PTB-XL QTc threshold | ±1 SD from simulation-derived value | Does the sex ratio in the above-threshold group remain >1.0? |

**Key robustness claim**: The qualitative finding — IKr-dominant antidepressants (SSRIs) produce larger sex differentials than INa-dominant antidepressants (TCAs such as desipramine) — should hold across the full parameter uncertainty range. If it does not, report that honestly as an inconclusive result (this satisfies the rubric's "unexpected/negative result" requirement).
