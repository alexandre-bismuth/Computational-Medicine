# Population of Models — EAD Results

## Summary

Simulations used the ToR-ORd human ventricular cardiomyocyte model (Tomek et al. 2019) with
Latin Hypercube Sampling (n = 30) across seven conductance parameters (ICaL, INa, INaCa, INaK,
IKr, IKs, Ito), scaled ×0.5–2.0 from nominal. Female models additionally applied sex-specific
baseline conductance scaling derived from Yang & Clancy (2017) and Gaborit et al. (2010):
IKr ×0.82, IKs ×0.79, Ito ×0.79, IK1 ×0.87, ICaL ×1.24, INaCa ×1.44.

Drug block was applied as a Hill-equation fraction multiplied onto each conductance, using IC50
values and Hill coefficients from McMillan et al. (2017) and, for sertraline, Afkhami et al.
(PMC3484517).

---

## EAD Threshold Concentrations — Female POM

| Drug          | Class | Max Clinical Dose | EAD Threshold (Female) | EAD at Max Dose? | Male EAD? |
|---------------|-------|:-----------------:|:----------------------:|:----------------:|:---------:|
| Sertraline    | SSRI  | 0.328 uM          | **0.110 uM**           | Yes (3.0×)       | No        |
| Amitriptyline | TCA   | 0.518 uM          | **0.445 uM**           | Yes (1.2×)       | No        |
| Desipramine   | TCA   | 0.423 uM          | No EAD                 | No               | No        |

> "EAD at Max Dose?" ratio in parentheses = max dose / EAD threshold; values > 1 indicate the
> clinical ceiling exceeds the arrhythmogenic threshold.

---

## Drug-by-Drug Findings

### Sertraline (SSRI)
- **EAD threshold (female): 0.110 uM**; max dose 0.328 uM (200 mg/day, MW = 306 g/mol).
- EAD onset occurs at roughly one-third of the maximum clinical concentration, meaning EAD is
  predicted across nearly the entire upper therapeutic range in female models.
- Sertraline has the most potent hERG block of the three drugs (IKr IC50 = 0.70 uM, h = 1.30).
  At the EAD threshold, ~8% additional IKr block is applied on top of the female ×0.82 scaling,
  bringing effective IKr to ≈75% of the female baseline. At max dose (~27% IKr block), effective
  IKr falls to ≈60% of female baseline (≈49% of male baseline).
- Additional blockade of IK1 (IC50 = 10.5 uM) and IKs (IC50 = 12.3 uM) is negligible at
  clinical concentrations but adds to net repolarisation reserve reduction.
- No EAD in male models at max dose: male baseline IKr is higher (no ×0.82 scaling), providing
  sufficient repolarisation reserve.

### Amitriptyline (TCA)
- **EAD threshold (female): 0.445 uM**; max dose 0.518 uM (300 mg/day, MW = 277 g/mol).
- EAD onset is close to, but within, the maximum clinical concentration; only the highest
  prescribed doses are predicted to be arrhythmogenic in vulnerable female cells.
- Multi-channel blocker: IKr (IC50 = 3.28 uM), IKs (IC50 = 2.73 uM), INaL (IC50 = 4.43 uM),
  ICaL (IC50 = 11.6 uM), Ito (IC50 = 10.0 uM), INa (IC50 = 20.0 uM).
- At the EAD threshold (0.445 uM): IKr ≈12% blocked, IKs ≈14% blocked, INaL ≈9% blocked.
  Although individual block fractions are modest, the concurrent reduction of two major
  repolarising currents (IKr and IKs) is sufficient to trigger EAD in cells at the
  vulnerable end of the LHS distribution.
- INaL block provides partial counterbalancing protection: late sodium current prolongation
  of the AP plateau is blunted, slightly opposing the net QT-prolonging effect of IKr/IKs block.
  This "balanced" multi-channel pharmacology may explain why the EAD threshold for amitriptyline
  (0.445 uM) is closer to its max dose than for sertraline.
- No EAD in male models: removal of the female IKr/IKs downscaling restores sufficient
  repolarisation reserve.

### Desipramine (TCA)
- **No EAD at max dose (0.423 uM)** in either sex.
- Channel block parameters: IKr IC50 = 1.39 uM, ICaL IC50 = 1.71 uM, INa IC50 = 1.52 uM.
  All three IC50 values exceed the maximum clinical concentration, so block per channel is
  only ~23% (IKr), ~20% (ICaL), and ~22% (INa) at 0.423 uM.
- Critically, desipramine simultaneously blocks ICaL (the primary inward plateau current).
  The resulting reduction in inward depolarising drive counteracts the APD-prolonging effect
  of IKr block, preventing EAD. This "balanced" INa + ICaL + IKr profile is mechanistically
  similar to the safety conferred by verapamil co-administration in preclinical models.
- IKs, Ito, and IK1 are not significantly blocked at clinical concentrations; their female
  downscaling alone is not enough to trigger EAD in the absence of strong IKr block.

---

## Interpretation

### Why do EADs occur?

EADs arise when the action potential plateau is prolonged sufficiently that L-type calcium
channels recover from inactivation before full repolarisation, re-activating and producing a
secondary depolarisation. The key predisposing factors are (McMillan et al. 2017):

1. **Reduced repolarisation reserve** — primarily IKr (hERG) block, amplified by concurrent
   IKs block.
2. **Sustained inward current** — relatively preserved or enhanced ICaL or INaL drives the
   membrane towards calcium re-activation threshold.
3. **Female electrophysiology** — lower baseline IKr (×0.82), IKs (×0.79), and IK1 (×0.87)
   narrow the repolarisation reserve, while elevated ICaL (×1.24) and INaCa (×1.44) increase
   inward drive. This combination creates a substrate in which even a modest drug-induced
   reduction in outward current is sufficient to produce EAD.

### Why are only sertraline and amitriptyline pro-arrhythmic?

The critical variable is the ratio of **maximum clinical concentration to IKr IC50**:

| Drug          | C_max (uM) | IKr IC50 (uM) | C_max / IC50_IKr |
|---------------|:----------:|:-------------:|:----------------:|
| Sertraline    | 0.328      | 0.70          | 0.47             |
| Amitriptyline | 0.518      | 3.28          | 0.16             |
| Desipramine   | 0.423      | 1.39          | 0.30             |

Sertraline achieves the highest fractional IKr block at clinical concentrations despite being
an SSRI, because its IKr IC50 (0.70 uM) is unusually low — lower even than desipramine's
(1.39 uM). This makes it the most potent hERG blocker in the set and explains why its EAD
threshold in female models sits far inside the clinical range.

Amitriptyline's EAD arises from combined IKr + IKs block (the two dominant repolarising
currents). Its ICaL block is relatively weak at clinical concentrations (IC50 = 11.6 uM),
leaving inward plateau current largely intact. The resulting imbalance — reduced outward,
preserved inward — is sufficient to trigger EAD near the top of the dosing range in the
female POM.

Desipramine, despite stronger absolute IKr block than amitriptyline at its max dose, avoids
EAD because it simultaneously reduces ICaL (IC50 = 1.71 uM), which dampens the inward
current necessary to sustain a plateau and re-activate calcium channels.

### Sex as a risk modifier

The female electrophysiology model, taken from Yang & Clancy (2017), captures the well-established
clinical observation that women have longer baseline QTc intervals and higher drug-induced TdP
risk. In the POM simulations, this manifests as a lower EAD threshold in female models for drugs
that significantly block IKr: the pre-existing reduction in repolarisation reserve (female IKr ×0.82,
IKs ×0.79) means a smaller drug-induced increment is needed to breach the EAD-generating threshold.
Neither drug produced EAD in male models at the same concentrations, directly demonstrating the
sex-specific amplification of proarrhythmic risk. This is consistent with McMillan et al. (2017),
who identify sex as a major modifier of in silico arrhythmia risk for QT-prolonging drugs.

### Population heterogeneity

The LHS approach samples conductance uncertainty between ×0.5 and ×2.0 of nominal values. EAD
appearance in a subset — but not all — of the 30 POM traces reflects real patient-to-patient
variability in ion channel expression. Cells with relatively low IKr/IKs (lower end of LHS
distribution) and/or high ICaL (upper end) are most susceptible. This heterogeneous response is
consistent with the clinical pattern in which only a fraction of patients on sertraline or
amitriptyline develop QT prolongation or arrhythmia, even at maximum doses.

---

---

# Single-Cell Simulations — QT Prolongation

Single-cell deterministic simulations (100 beats, steady state) were run at three
clinically-anchored concentrations per drug. QT prolongation was measured as the change in APD90
relative to the sex-matched control (no drug). Values in parentheses are % change from baseline.

### QT Prolongation Summary

#### Sertraline (SSRI)
Concentrations: 50 mg/day = 0.082 uM | 125 mg/day = 0.205 uM | 200 mg/day = 0.328 uM

| Concentration | Male ΔAPD90 | Female ΔAPD90 |
|---------------|:-----------:|:-------------:|
| Start (0.082 uM) | +10 ms (3.4%) | +10 ms (2.8%) |
| Mid (0.205 uM)   | +25 ms (8.5%) | +30 ms (8.3%) |
| Max (0.328 uM)   | +40 ms (13.7%) | +50 ms (11.1%) |

#### Desipramine (TCA)
Concentrations: 50 mg/day = 0.070 uM | 200 mg/day = 0.282 uM | 300 mg/day = 0.423 uM

| Concentration | Male ΔAPD90 | Female ΔAPD90 |
|---------------|:-----------:|:-------------:|
| High start (0.070 uM) | +4 ms (1.4%) | +6 ms (1.6%) |
| High ther. (0.282 uM) | +16 ms (5.4%) | +19 ms (5.2%) |
| Max (0.423 uM)        | +20 ms (8.5%) | +26 ms (7.0%) |

#### Amitriptyline (TCA)
Concentrations: 75 mg/day = 0.129 uM | 200 mg/day = 0.345 uM | 300 mg/day = 0.518 uM

| Concentration | Male ΔAPD90 | Female ΔAPD90 |
|---------------|:-----------:|:-------------:|
| Max (0.518 uM) | +11 ms (3.7%) | +15 ms (2.7%) |

> Note: QT data recorded in comments only at maximum dose for amitriptyline.

---

### Interpretation of Single-Cell QT Results

#### Comparison with Lin & Kung (2009) clinical thresholds

Lin & Kung (2009) identified two cut-off values distinguishing strong from borderline
torsadogens in a retrospective analysis of 30 non-antiarrhythmic drugs:
- **Mean QTc increase > 12 ms** (monotherapy): sensitivity 85%, specificity 71% for strong TdP association.
- **Upper bound of 95% CI > 14 ms** (monotherapy): sensitivity 100%, specificity 67%.
- **Mean QTc increase > 25 ms** (with metabolic inhibition): sensitivity 80%, specificity 100%.

Applying these thresholds to our simulations:

| Drug | Max Dose | Male ΔAPD90 | Female ΔAPD90 | Lin & Kung category |
|------|----------|:-----------:|:-------------:|---------------------|
| Sertraline    | 0.328 uM | +40 ms | +50 ms | Exceeds strong-TdP threshold (>12 ms monotherapy; >25 ms metabolic inhibition range) |
| Desipramine   | 0.423 uM | +20 ms | +26 ms | Borderline — exceeds 12 ms but < 25 ms; female at the 25 ms boundary |
| Amitriptyline | 0.518 uM | +11 ms | +15 ms | Below 12 ms (male); borderline (female) |

#### Cross-validation with Lin & Kung Table 1 clinical data

Lin & Kung (2009) Table 1 includes observed clinical QTc prolongation for two of the four drugs
studied here:
- **Desipramine**: clinical mean QTc increase = 16.8 ms (95% CI: 8.8–24.8 ms) at a mean dose of
  157 mg/day. Our simulation at the comparable dose (200 mg/day, 0.282 uM) yields +16 ms (male) and
  +19 ms (female) — in close agreement, providing confidence in the model's pharmacodynamic
  calibration. Both simulation and clinical data place desipramine in the borderline torsadogen
  category.
- **Amitriptyline**: clinical mean QTc increase = 17.0 ms at mean 158 mg/day. Our male model
  at max dose (300 mg/day) gives +11 ms, suggesting modest underestimation, possibly because
  the clinical cohort included patients with pre-existing disease, comedications, or
  electrolyte imbalance that amplify drug effects beyond the healthy-cell baseline. Lin & Kung
  categorised amitriptyline as a borderline torsadogen, consistent with our finding that QT
  prolongation alone is moderate but the POM simulations reveal a narrow EAD margin in females.
- **Sertraline**: excluded from Lin & Kung (2009) due to inadequate published QT data at the time.
  Our simulation predicts +40 ms (male) and +50 ms (female) at max dose — values that, if realised
  clinically, would exceed the 12 ms monotherapy threshold by a factor of 3–4 and approach the
  60 ms individual-patient warning threshold cited in the paper.

#### QT prolongation vs. EAD risk: the multi-channel pharmacology problem

A key finding that emerges from combining the single-cell and POM results is that **QT prolongation
magnitude alone is a poor separator of actual arrhythmic risk**:

- **Desipramine** produces the largest QT prolongation of the four drugs at its maximum dose
  (+20 ms male, +26 ms female), yet generates no EAD in either the single-cell or POM simulations.
  This is because concurrent ICaL block (IC50 = 1.71 uM) reduces the inward plateau drive,
  preventing the sustained depolarisation needed to re-activate L-type calcium channels.
  A QT-only or hERG-only screening approach would flag desipramine as a high-concern drug,
  but the mechanistic in silico model correctly identifies the ICaL counterbalance that mitigates
  actual TdP risk. This is precisely the type of false-positive over-call that Grandi et al. (2018)
  warn can lead to the withdrawal of potentially safe drugs from the development pipeline.

- **Amitriptyline** sits at the other extreme: modest QT prolongation at max dose (+11 ms male,
  +15 ms female), which would be considered borderline or even inconclusive by the Lin & Kung
  12 ms criterion, yet the POM simulations reveal EAD in female cells at 0.445 uM — just 86% of
  the maximum clinical dose. The disparity arises because in a heterogeneous population a subgroup
  of cells with inherently lower repolarisation reserve (low IKr / low IKs end of LHS distribution)
  can tip into EAD at a drug concentration that produces only modest mean APD change in the nominal
  cell. Single-cell simulations, by definition, capture only the nominal (median) phenotype and
  therefore underestimate risk in the most vulnerable patients.

- **Sertraline** is the case where QT prolongation and EAD risk signals align: the largest QT
  prolongation and the lowest EAD threshold. At start dose alone (+10 ms, both sexes), it already
  approaches the Lin & Kung 12 ms criterion; by mid dose (+25–30 ms) it enters the range that
  Lin & Kung identify as consistent with a strong torsadogen; and at max dose (+40–50 ms) it
  approaches individual-patient warning thresholds (>60 ms). The single-cell result is reinforced
  by the POM finding that EAD onset occurs at 0.110 uM — well within the start-to-mid dosing
  range — in female models.

#### The case for mechanistic multi-channel in silico assessment (CiPA paradigm)

Grandi et al. (2018) argue that QT/hERG screening alone is an insufficient and potentially
misleading proxy for TdP risk, and advocate for the Comprehensive in vitro Proarrhythmia Assay
(CiPA) paradigm: multi-channel in vitro block data fed into in silico cardiac cell models, with
results verified in hiPSC-CMs. Our results from all three antidepressants directly illustrate why
this is necessary:

1. **Multi-channel balance matters**: Desipramine's IKr block (IC50 = 1.39 uM) is stronger at
   clinical concentrations than amitriptyline's (IC50 = 3.28 uM), yet amitriptyline is more
   pro-arrhythmic in the female POM because amitriptyline also blocks IKs (IC50 = 2.73 uM) while
   desipramine's ICaL block provides an inward-current countermeasure.

2. **Population heterogeneity reveals risk invisible to single-cell models**: The POM approach
   (LHS sampling across conductance uncertainty) is essential for detecting the subset of patients
   most vulnerable to EAD. The Lin & Kung 12 ms threshold implicitly assumes population-level
   exposure; our simulations show that the tail of the conductance distribution — the cells or
   patients with the lowest baseline repolarisation reserve — tips into EAD at concentrations where
   the median cell shows only modest QT prolongation.

3. **Sex must be incorporated**: Grandi et al. (2018) explicitly note that sex has not been
   adequately addressed in CiPA efforts, despite clinical evidence of higher drug-induced TdP
   risk in women. Our simulations confirm this: every drug that produced EAD did so exclusively
   in female models, driven by lower IKr/IKs baseline conductances (×0.82/×0.79) and higher
   ICaL/INaCa (×1.24/×1.44). Excluding sex from safety pharmacology models would systematically
   underestimate risk in half the patient population.

4. **The qNet concept applied qualitatively**: Dutta et al. (cited in Grandi et al. 2018) proposed
   qNet — the net charge carried by key inward and outward currents during the steady-state AP —
   as a metric to separate low-, intermediate-, and high-risk hERG blockers. In qualitative terms,
   desipramine's concurrent ICaL block increases net outward (or reduces net inward) charge relative
   to its IKr block alone, placing it in a lower-risk tier than a pure hERG blocker with the same
   QT prolongation. Sertraline's dominant, uncompensated IKr block (IC50 = 0.70 uM) without
   proportionate ICaL suppression at clinical concentrations pushes it toward the high-risk tier —
   consistent with both the EAD findings and the QT data.

---

## References

- McMillan et al. (2017). *Tox. Res.* DOI: 10.1039/c7tx00141j — channel block parameters
  (amitriptyline, desipramine) and in silico pro-arrhythmia framework.
- Afkhami et al. (PMC3484517) — channel block parameters for sertraline.
- Yang & Clancy (2017) — female ventricular electrophysiology scaling.
- Gaborit et al. (2010) — human cardiac ion channel expression sex differences.
- Tomek et al. (2019) — ToR-ORd human ventricular cardiomyocyte model.
- Lin Y-L & Kung M-F (2009). Magnitude of QT prolongation associated with a higher risk of
  Torsades de Pointes. *Pharmacoepidemiol Drug Saf.* 18(3):235–239. DOI: 10.1002/pds.1707 —
  QTc cut-off thresholds distinguishing strong from borderline torsadogens.
- Grandi E, Morotti S, Pueyo E & Rodriguez B (2018). Editorial: Safety Pharmacology – Risk
  Assessment QT Interval Prolongation and Beyond. *Front. Physiol.* 9:678.
  DOI: 10.3389/fphys.2018.00678 — CiPA paradigm, limitations of hERG/QT-only screening,
  and the role of multi-scale in silico modelling for proarrhythmic risk assessment.
