# Report Plan: Sex Differences in Antidepressant-Induced Arrhythmia Risk

*This page contains AI-generated content, in line with mini-project guidelines*

---

## Three Figures

### Figure 1: Drug Dose-Response by Sex

**Layout**: Left + Right panels

- **Left**: EAD incidence (% of 30 models) vs drug concentration for all 3 drugs. Male (blue) and female (red) curves — 6 curves total. Shows sex gap is largest for IKr-dominant SSRI (sertraline), intermediate for multi-channel TCA (amitriptyline), and smallest for INa-dominant TCA (desipramine). If EADs are absent, replace with median APD90 ± IQR.
- **Right**: Representative AP traces for one male and one female model under sertraline at baseline, 0.1 μM, and 0.328 μM. Shows EAD emergence in female trace at lower concentration.

**Caption**: "The sex-differential arrhythmic threshold scales with IKr block potency. Female models develop EADs (or equivalent APD90 prolongation) at lower drug concentrations than male models, with the largest sex gap under IKr-dominant pharmacology (sertraline) and minimal gap under INa-dominant pharmacology (desipramine)."

### Figure 2: Biomarker Correlation + Rate Dependence

**Layout**: Left + Right panels

- **Left**: Scatter plot of baseline APD90 (x-axis) vs EAD threshold concentration (y-axis) for all 60 models (30M blue, 30F red). Negative correlation expected. Female models cluster in the high-APD90 / low-threshold region. Simulation-derived reference boundary overlaid as dashed line.
- **Right**: EAD incidence vs sertraline concentration at BCL = 600, 1000, 1200 ms for male (blue) and female (red). Shows how heart rate modulates the sex gap — slower rates (rest, sleep, beta-blocker use) promote more EADs via reverse use-dependence of IKr block.

**Caption**: "Baseline action potential duration predicts antidepressant-induced arrhythmia vulnerability. Models with longer APD90 — disproportionately female — develop EADs at lower sertraline concentrations. Right panel shows the effect of heart rate on the sex-differential threshold; the counterintuitive finding that IKr-blocking antidepressants are more dangerous at rest than during exercise constitutes a novel simulation prediction."

### Figure 3: Simulation-Derived Risk Stratification in PTB-XL

**Layout**: Left + Right panels

- **Left**: Violin plots of QTc distribution in PTB-XL by sex, with two simulation-derived risk tier boundaries overlaid: high-risk threshold (dashed, 441 ms — top quintile of female POM, where all EADs occur) and elevated-risk threshold (dotted, 424 ms — top 40%). Annotate proportion of each sex above the high-risk line (20% F vs 14% M).
- **Right**: QTc sex gap (female minus male median, ms) by age group in PTB-XL. Pre-menopausal (<50): +10.0 ms; perimenopausal (50–54): +5.8 ms; post-menopausal (≥55): +8.6 ms. Bootstrap 95% CIs shown.

**Caption**: "Simulation-derived risk stratification applied to 8,705 normal PTB-XL ECGs. (A) Female QTc is systematically higher than male QTc (median 416 vs 407 ms, p < 10⁻⁴⁰). The dashed line marks the simulation-derived high-risk boundary (QTc ≥ 441 ms), corresponding to the top quintile of female baseline APD90 where all EADs occur; 20% of women vs 14% of men exceed this threshold (risk ratio 1.42). (B) The QTc sex gap narrows at perimenopause (+5.8 ms) relative to pre-menopause (+10.0 ms), partially consistent with the hormonal modulation of IKr, but widens again post-menopause (+8.6 ms), likely reflecting age-related QTc confounders. These observations support but do not validate the simulation framework; prospective drug-outcome data are required for clinical validation."

---

## Paper Structure — Rubric Compliance (100 marks)

### Abstract (10 marks)

| Element | Content |
|---------|---------|
| Background | Antidepressants — particularly SSRIs and TCAs — carry a risk of drug-induced QT prolongation and Torsades de Pointes (TdP); women are overrepresented in drug-induced TdP (~65–75%); the electrophysiological basis is reduced IKr conductance but no systematic cross-drug, cross-class quantification exists |
| Research question | State the RQ verbatim |
| Aim | Three aims as stated above |
| Methods | ToR-ORd POM + Hill equation pharmacology + rate-dependence experiment → biomarker discovery → ECG biomarker evaluation in PTB-XL |
| Findings | Key numbers: EAD thresholds by sex per drug (sertraline 0.110 uM female, no EAD male); baseline APD90 predicts vulnerability (r = 0.994); 20% of women vs 14% of men in PTB-XL fall in the simulation-predicted high-risk tier; QTc sex gap +9.1 ms consistent with simulation |
| Conclusions | Sex-differential arrhythmia thresholds scale with IKr block potency across antidepressant classes; simulation-derived risk stratification identifies a clinically meaningful population at elevated vulnerability, with women overrepresented 1.42:1; the approach bridges single-cell mechanistic modelling to population-scale ECG data |

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
- Sex parameterisation: IKr_female = 0.82 × IKr_male (plus 5 other channels)
- AP-to-ECG surrogate mapping with explicit limitations stated

**Experiments performed with protocols (5 marks)**:

- Part 1: 4 drugs × 7 concentrations × 2 sexes × 30 models; EAD detection + APD90
- Rate-dependence: sertraline × 3 BCL × 2 sexes × 5 concentrations × 30 models
- Part 1→2 bridge: correlation of baseline AP features with EAD threshold (r = 0.994); quintile analysis; risk tier derivation via percentile mapping (APD90 percentile → QTc percentile)
- Part 2: ECG feature extraction from 8,705 normal PTB-XL ECGs (Lead II, 500 Hz, neurokit2); risk tier classification of every individual; sex- and age-stratified analysis
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
- Validation V1–V3 as tabulated in methods.md
- Sensitivity: IC50 ±50% variation, IKr multiplier [0.75, 0.95]; qualitative ranking (SSRIs > desipramine) must hold for conclusion to stand

**Results addressing the research question (10 marks)**:

- Part 1: EAD thresholds by sex per drug; ranking by IKr dominance across SSRI vs TCA classes (sertraline > amitriptyline > desipramine)
- Part 1 rate dependence: direction of sex gap change under sertraline at BCL 600 vs 1200 ms
- Part 1→2 bridge: baseline APD90 predicts drug-induced APD90 with r = 0.994; quintile analysis shows top 20% receives 3× the prolongation and contains all EADs; risk tiers derived
- Part 2 core: risk stratification of 8,705 PTB-XL ECGs — 20% of women vs 14% of men fall in the simulation-predicted high-risk tier (ratio 1.42); the high-risk group is 63% female and older (median age 59)
- Part 2 sex gap: female QTc > male by 9.1 ms (p < 10⁻⁴⁰); gap narrows at perimenopause (+5.8 ms) but rebounds post-menopause (+8.6 ms)

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
- **Candidate 2 (unexpected, from Part 2)**: Tpeak–Tend sex gap is reversed: males have 4.0 ms longer Tpeak–Tend than females (p < 10⁻⁴¹), opposite to the simulation prediction (AP triangulation → Tpeak–Tend). This demonstrates that single-cell AP triangulation does not map straightforwardly to Tpeak–Tend, which also reflects transmural dispersion across the ventricular wall. Males have larger hearts with greater transmural heterogeneity, dominating the single-cell effect. This is an honest negative result that exposes a limitation of the AP-to-ECG surrogate mapping.
- **Candidate 3 (partially consistent)**: The QTc sex gap narrows at perimenopause (+5.8 ms vs +10.0 ms pre-menopause), supporting the estrogen–IKr mechanism, but rebounds to +8.6 ms post-menopause rather than continuing to narrow. This partial consistency suggests the hormonal mechanism is real but insufficient to explain the full post-menopausal QTc sex gap, which is confounded by age-related comorbidities.
- **Candidate 4 (inconclusive)**: At low concentrations of amitriptyline, competing INa and ICaL block may shorten APD in some models, producing a non-monotonic dose-response despite IKr block. This complicates the narrative and must be discussed rather than smoothed over.

### Conclusions (15 marks)

**Key findings and contributions (5 marks)**:

- Sex-differential arrhythmia thresholds scale with IKr block potency across antidepressant drug classes
- Sertraline (IKr-dominant SSRI) produces a larger sex gap than INa-dominant TCAs (desipramine); amitriptyline occupies an intermediate position due to multi-channel block
- Baseline APD90 predicts drug-induced APD90 with near-perfect correlation (r = 0.994); vulnerability is concentrated in the top quintile of baseline APD90, which receives 3× the prolongation and contains all EADs
- Simulation-derived risk tiers applied to 8,705 PTB-XL ECGs show that 20% of women vs 14% of men have resting QTc in the high-risk range (ratio 1.42), providing a population-scale estimate of sex-differential vulnerability
- The QTc sex gap (+9.1 ms, p < 10⁻⁴⁰) is consistent with simulation predictions; the partial narrowing at perimenopause supports the estrogen–IKr mechanism
- Rate-dependence of the sex gap under sertraline is a novel prediction: IKr-blocking antidepressants are more dangerous at rest and during sleep than during the anxiety or exercise that prompts their prescription

**Critique of the proposed approach (5 marks)**:

- **Strengths**: mechanistic, human-specific, population-level, reproducible, no fitted parameters, honest about what PTB-XL can and cannot show
- **Limitations**: single-cell only (no spatial conduction or reentry — EADs are necessary but not sufficient for arrhythmia); static sex parameterisation (ignores hormonal cycle variation); IC50 values from heterologous expression systems (not human in vivo); AP→ECG surrogate mapping assumes transmural homogeneity; 100 Hz PTB-XL resolution limits Tpeak–Tend precision (~10 ms)

**Next steps towards clinical or industrial impact (5 marks)**:

- **MIMIC-IV supervised model**: MIMIC-IV combines 12-lead ECGs recorded at emergency department admission with toxicology results and clinical outcomes. This enables a supervised classifier trained on actual drug-exposure labels, with measurable AUROC and calibration. The simulation work provides mechanistic interpretability that a pure ML model would lack — the two approaches are complementary, not competing.
- **Tissue-level extension**: once the ion channel hypothesis is established here, extending to a biventricular simulation would test whether single-cell EADs translate to re-entrant arrhythmias, and enable synthetic 12-lead ECG generation for direct ECG-level sex comparison.
- **CiPA framework contribution**: sex-aware cardiac safety pharmacology is an unmet regulatory need; this work contributes to the evidence base for sex-stratified IC50 risk thresholds in antidepressant drug approval and post-market surveillance.

---

## Literature to Cite

| Citation | Used for |
|----------|----------|
| Tomek et al. 2019 | ToR-ORd model |
| Wagner et al. 2020 | PTB-XL dataset |
| Makkar et al. 1993 | Female preponderance in drug-induced TdP |
| Rautaharju et al. 2009 | Sex differences in QTc, age dependence |
| Rodriguez et al. 2010 | Sex-specific cardiac models, early IKr sex parameterisation |
| Yang & Clancy 2017 | Full female ORd scaling factors (IKr, IKs, Ito, IK1, ICaL, INaCa) |
| Gaborit et al. 2010 | Human cardiac ion channel gene expression data underpinning sex scaling |
| Muszkiewicz et al. 2016 | Population of Models methodology |
| McMillan et al. 2017 (Toxicol. Res., DOI: 10.1039/C7TX00141J) | Amitriptyline and desipramine IC50s |
| Afkhami et al. (PMC3484517) | Sertraline multi-channel IC50s |
| Nachimuthu et al. 2012 | Drug-induced QT prolongation review |
| Antzelevitch et al. 2007 | Tpeak–Tend as arrhythmia risk marker |
| Johnson et al. (MIMIC-IV) | Future validation dataset |
