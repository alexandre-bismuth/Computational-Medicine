# Mini-Project Plan: Sex Differences in Antidepressant-Induced Arrhythmia Risk

*This page contains AI-generated content, in line with mini-project guidelines*

## Research Question

> **"How do electrophysiological cardiac sex differences affect vulnerability to arrhythmias induced by antidepressants, and can simulation-derived repolarisation biomarkers identify at-risk individuals from resting ECG data?"**

### Three Aims

1. **Quantify sex-differential arrhythmic thresholds** for sertraline, amitriptyline, and desipramine using population-based ventricular cell models, and characterise how the ion channel blocking profile (IKr- vs INa-dominant) determines the magnitude of the sex gap
2. **Identify baseline AP features that predict individual drug vulnerability** and map these to ECG-measurable repolarisation markers, using simulation to derive sex-stratified reference ranges
3. **Evaluate the predicted sex differences in repolarisation** against PTB-XL clinical ECG data and quantify robustness to pharmacological parameter uncertainty

---

## Hypothesis

Women's lower baseline IKr conductance (~15%) reduces repolarisation reserve, making them more vulnerable to IKr-blocking antidepressants. This vulnerability is detectable from resting AP features (APD90, triangulation) which have measurable ECG surrogates (QTc, Tpeak–Tend). The sex gap in these surrogates should be observable in population-scale clinical ECG data and should narrow post-menopause, consistent with the hormonal modulation of IKr.

---

## Two-Part Structure

### Part 1: In Silico Drug Simulation (MATLAB)

Simulate the effect of three antidepressants (sertraline, amitriptyline, desipramine) on sex-stratified populations of ventricular cell models. Identify which baseline electrophysiological features predict who develops arrhythmias, and at what drug concentration.

### Part 2: ECG Biomarker Evaluation in Clinical Data (Python + PTB-XL)

Translate simulation-derived AP biomarkers to ECG-measurable surrogates. Apply simulation-derived reference ranges to ~21,000 real ECGs from PTB-XL to test whether the predicted sex differences in repolarisation reserve are consistent with clinical observations. This is a **consistency check**, not a validated clinical classifier: there is no drug-outcome ground truth in PTB-XL, and results are presented as hypothesis-supporting or -contradicting evidence, not as diagnostic performance.

---

## File Structure

```
Mini-Project/
├── notes/
│   ├── plan.md                ← This file (overview, timeline, risks)
│   ├── methods.md             ← Drug parameters, simulation protocols, VVUQ
│   ├── report_plan.md         ← Figures, paper structure, rubric compliance
│   └── context.md             ← Course instructions
├── source/torord/matlab/
│   ├── {drug}_single_male.m   ← Single-cell male simulations (3 drugs)
│   ├── {drug}_single_female.m ← Single-cell female simulations (3 drugs)
│   ├── {drug}_POM_male.m      ← Population of Models, male, max dose (3 drugs)
│   └── {drug}_POM_female.m    ← Population of Models, female, max dose (3 drugs)
├── results/                   ← .mat and .csv output files
├── figures/                   ← Publication-quality figures
└── paper/
    └── report.tex             ← 4-page conference paper
```

---

## Timeline (7 working days)

| Day | Date  | Tasks |
|-----|-------|-------|
| 1   | Apr 4 | Confirm IC50 values from primary sources for all 3 antidepressants; implement `POM_drugs.m` (sex-specific IKr + 3 drugs + rate dependence parameter) |
| 2   | Apr 5 | Run all dose-response simulations (3 drugs × 2 sexes × 7 conc); run rate-dependence (sertraline × 3 BCL) |
| 3   | Apr 6 | Implement and run `biomarker_analysis.m`; implement `ptbxl_features.py` |
| 4   | Apr 7 | Run PTB-XL extraction + distributional analysis; run sensitivity analysis |
| 5   | Apr 8 | Generate all 3 figures; write Methods |
| 6   | Apr 9 | Write Introduction + Results & Discussion + Abstract + Conclusions |
| 7   | Apr 10–14 | Revise, rubric audit, polish figures, proofread |

---

## Key Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| IC50 values poorly documented for SSRIs/TCAs in patch-clamp literature | Sensitivity analysis covers ±50%; report findings as conditional on parameter values |
| No EADs observed in simulation | Use APD90 prolongation as primary outcome; explicitly state this is not a failure |
| Rate-dependence result is null (no BCL effect) | Report as negative result — absence of rate-dependence is itself informative |
| PTB-XL QTc/TpTe extraction noisy at 100 Hz | Use large sample; report median/IQR; acknowledge 100 Hz resolution as limitation; use records500/ if Tpeak–Tend is unresolvable |
| Post-menopausal QTc gap does not narrow in PTB-XL | Report as a negative result contradicting the estrogen–IKr mechanism; acknowledge as genuine scientific uncertainty |
| Paper exceeds 4 pages | Strict word budget; figures take ~1.5 pages; VVUQ table in Methods not Results |
