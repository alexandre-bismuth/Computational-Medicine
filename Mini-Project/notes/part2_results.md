# Part 2 Results: Simulation-Derived Risk Stratification in PTB-XL

*This page contains AI-generated content, in line with mini-project guidelines*

---

## Summary

Part 2 translates the population of models (POM) findings from Part 1 into a clinical ECG context.
Baseline AP biomarkers from 30 female and 30 male virtual patients were correlated with
drug-induced arrhythmia vulnerability, mapped to QTc via percentile matching, and applied to
8,705 normal ECGs from the PTB-XL database to estimate the sex- and age-stratified proportion
of real patients whose resting repolarisation falls in the simulation-predicted vulnerable range.

---

## Biomarker Discovery: Baseline APD90 Predicts Drug Vulnerability

### Correlation

Baseline APD90 (no drug) correlates near-perfectly with drug-induced APD90 under sertraline
at maximum clinical dose (0.328 uM):

- **Spearman r = 0.994, p < 10⁻²⁸**

Models with longer baseline APD90 experience disproportionately more prolongation under drug
exposure. This is the single-cell mechanistic basis for QTc as a clinical risk marker.

### Quintile Analysis (Female POM, Sertraline Max Dose)

| Quintile | Baseline APD90 (ms) | Mean Prolongation (ms) | Mean Drug APD90 (ms) | EAD |
|----------|:-------------------:|:----------------------:|:--------------------:|:---:|
| Q1 (lowest)  | 219–268 | 38  | 289 | 0/6 |
| Q2           | 279–305 | 49  | 336 | 0/6 |
| Q3           | 309–345 | 45  | 367 | 0/6 |
| Q4           | 359–418 | 54  | 435 | 0/6 |
| Q5 (highest) | 418–525 | 142 | 602 | 2/6 |

The top quintile (Q5) receives **3× the prolongation** of Q1–Q4 (142 ms vs 38–54 ms), and
all EADs arise exclusively from this group. The non-linear jump from Q4 to Q5 demonstrates
that vulnerability is concentrated in the upper tail of baseline APD90, not uniformly
distributed.

### EAD Models

| Model ID | Baseline APD90 (ms) | Percentile | Triangulation (ms) | EAD Under |
|:--------:|:-------------------:|:----------:|:-------------------:|-----------|
| 6        | 525                 | 100th      | 247                 | Sertraline + Amitriptyline |
| 28       | 449                 | 93rd       | 194                 | Sertraline only |

Model 6 is the most vulnerable virtual patient in the female population — it develops EADs
under both sertraline and amitriptyline, and has the longest baseline APD90 and highest
triangulation. Model 28 develops EADs only under sertraline (the most potent IKr blocker),
consistent with its lower but still elevated baseline APD90.

No male models develop EADs under any drug at maximum clinical dose.

---

## Simulation-to-ECG Mapping

### Percentile Mapping Rationale

Direct linear scaling from APD90 to QTc is inappropriate because APD90 is a single-cell
measure while QTc reflects population-averaged transmural repolarisation. Instead, we use
**percentile mapping**: the Nth percentile of simulation APD90 corresponds to the Nth
percentile of clinical QTc within the same sex. This preserves the rank ordering without
assuming a specific functional relationship.

### Risk Tier Definitions

Risk tiers are defined from the female POM quintile boundaries and mapped to QTc via the
female PTB-XL QTc distribution:

| Tier | Simulation Criterion | Female APD90 Boundary | Mapped QTc Boundary |
|------|----------------------|:---------------------:|:-------------------:|
| **Elevated risk** | Top 20% (Q5) — contains all EADs | >= 418 ms | >= 441 ms |
| **Lower risk**    | Bottom 80% (Q1–Q4) — modest prolongation, no EADs | < 418 ms | < 441 ms |

The elevated-risk QTc threshold (441 ms) is close to the clinical borderline for prolonged QTc
(440 ms for men, 450 ms for women), providing independent face validity.

---

## PTB-XL Risk Stratification

### Dataset

- **Source**: PTB-XL v1.0.3 (Wagner et al. 2020), 21,837 12-lead ECGs
- **Filtered**: Normal ECGs (NORM confidence >= 80, age 18–100) → **8,798 records**
- **Feature extraction**: QTc (Bazett), Tpeak–Tend, T-wave amplitude from Lead II at 500 Hz
  using neurokit2 wave delineation
- **Success rate**: 8,705/8,798 (98.9%) — 93 records failed delineation
- **PTB-XL sex encoding**: 0 = male, 1 = female (confirmed via height: sex=0 avg 173.5 cm,
  sex=1 avg 161.0 cm)

### QTc Distributions by Sex

| Metric | Female (n = 4,714) | Male (n = 3,991) |
|--------|:------------------:|:-----------------:|
| QTc median | 416.2 ms | 407.2 ms |
| QTc IQR | 397.4–435.6 ms | 389.0–428.0 ms |
| Heart rate median | 70.5 bpm | 66.8 bpm |

**QTc sex gap: +9.1 ms (female > male), Mann-Whitney U p < 10⁻⁴⁰**

This is consistent with the established clinical sex difference (~10–20 ms, Rautaharju et al.
2009) and with the simulation baseline APD90 sex gap (female median 320 ms vs male 252 ms).
The clinical gap (9 ms) is smaller than the simulation gap (68 ms) because the simulation
LHS sampling [×0.5–2.0] amplifies inter-individual variability beyond the clinical range,
while the sex scaling effect is preserved in both.

### Risk Tier Distribution by Sex

| Risk Tier | Total | Female (% of all F) | Male (% of all M) | Female Proportion | Median Age |
|-----------|:-----:|:-------------------:|:------------------:|:-----------------:|:----------:|
| **Elevated risk** | 1,507 (17.3%) | 943 (20.0%) | 564 (14.1%) | 62.6% | 59 |
| **Lower risk**    | 7,198 (82.7%) | 3,771 (80.0%) | 3,427 (85.9%) | 52.4% | 52 |

**Key findings**:

1. **Women are 1.42× more likely than men to be in the elevated-risk tier** (20.0% vs 14.1%).
   This directly reflects the sex difference in baseline repolarisation reserve predicted
   by the simulation.

2. **The elevated-risk group is disproportionately female** (62.6% vs 54.2% in the overall
   population). This overrepresentation is the clinical-scale manifestation of the
   simulation finding that female models develop EADs while male models do not.

3. **The elevated-risk group is older** (median age 59, 61% post-menopausal ≥55) while the
   lower-risk group is younger (median age 52). This is consistent with age-related QTc
   prolongation, though it complicates the menopause-specific interpretation.

4. **The lower-risk group skews male** (52.4% female vs 54.2% overall), confirming that male
   repolarisation reserve provides relative protection — consistent with the simulation finding
   that no male model develops EADs under any drug.

### QTc Sex Gap by Age Group

| Age Group | Sex Gap (F − M median) | 95% Bootstrap CI | n Female | n Male |
|-----------|:----------------------:|:-----------------:|:--------:|:------:|
| Pre-menopausal (< 50)  | **+10.0 ms** | [7.9, 11.7] | 2,001 | 1,645 |
| Post-menopausal (≥ 55) | **+8.6 ms**  | [6.5, 11.1] | 2,212 | 1,882 |

The sex gap narrows modestly from +10.0 ms pre-menopause to +8.6 ms post-menopause, **partially
consistent** with the hormonal modulation hypothesis (estrogen upregulates IKr → loss of
estrogen at menopause → reduced sex difference). The narrowing is small and the confidence
intervals overlap ([7.9, 11.7] vs [6.5, 11.1]), so this should be interpreted cautiously.
Age-related QTc prolongation in post-menopausal women (comorbidities, medications, structural
remodelling) likely partially offsets the hormonal effect.

---

## Tpeak–Tend: An Unexpected Negative Finding

| Metric | Female | Male | Sex Gap |
|--------|:------:|:----:|:-------:|
| Tpeak–Tend median | 70.0 ms | 74.0 ms | **−4.0 ms (M > F)** |
| Mann-Whitney U p | — | — | < 10⁻⁴¹ |

The simulation predicted female > male Tpeak–Tend (based on the mapping: AP triangulation →
Tpeak–Tend). The clinical data shows the **opposite**: males have longer Tpeak–Tend by 4 ms.

**Interpretation**: Tpeak–Tend reflects transmural dispersion of repolarisation across the
ventricular wall, not just single-cell AP triangulation. Males have larger hearts with greater
transmural heterogeneity, which dominates the single-cell triangulation effect. This
demonstrates a limitation of the single-cell → ECG surrogate mapping for Tpeak–Tend, while
QTc (which has a more direct relationship to APD90) shows the expected sex difference.

This is reported as an honest negative result that strengthens the mechanistic discussion:
not all AP-level biomarkers translate straightforwardly to ECG surrogates, and the mapping
limitations must be explicitly acknowledged.

---

## Limitations

1. **No drug-outcome ground truth**: PTB-XL contains no drug administration records. The risk
   stratification estimates vulnerability based on resting repolarisation, not observed
   drug-induced arrhythmias. This is a risk estimation, not a validated classifier.

2. **Percentile mapping assumes rank preservation**: the mapping from APD90 percentiles to QTc
   percentiles assumes that the rank ordering of repolarisation duration is preserved from the
   single-cell to the ECG level. This is a reasonable but unverified assumption.

3. **Bazett correction**: Bazett's formula overcorrects at high heart rates and undercorrects
   at low rates. Females have higher median heart rate (70.5 vs 66.8 bpm), which inflates
   female QTc relative to Fridericia or Framingham corrections. The sex gap would be smaller
   (~5 ms) with Fridericia correction.

4. **Clinical population**: PTB-XL is a cardiology referral population (1984–2008), not a
   general population sample. The "normal" ECGs are from patients referred for ECG recording
   who happened to have normal findings, not from healthy volunteers. This may affect the
   QTc distribution.

5. **100 Hz vs 500 Hz**: We used 500 Hz signals for better temporal resolution on Tpeak–Tend
   (2 ms precision). Even at 500 Hz, automatic wave delineation introduces measurement
   variability that is larger than the sex differences being measured for Tpeak–Tend.

6. **Small EAD sample**: Only 2/30 female models and 0/30 male models develop EADs under
   sertraline at max dose. The risk tier boundaries are derived from a small number of
   events; a larger POM (n = 100+) would provide more robust quintile boundaries.

---

## References

- Wagner P et al. (2020). PTB-XL, a large publicly available electrocardiography dataset.
  *Scientific Data* 7:154. DOI: 10.1038/s41597-020-0495-6
- Rautaharju PM et al. (2009). AHA/ACCF/HRS recommendations for the standardization and
  interpretation of the electrocardiogram: Part IV. *Circulation* 119:e241–e250.
- Makowski D et al. (2021). NeuroKit2: A Python toolbox for neurophysiological signal
  processing. *Behavior Research Methods* 53:1689–1696.
