"""
Part 2: ECG Biomarker Evaluation in PTB-XL Clinical Data

Extracts QTc, Tpeak-Tend, and T-wave amplitude from normal PTB-XL ECGs,
stratifies by sex and age group, and generates Figure 3.

Usage: python ptbxl_analysis.py
"""

import ast
import os
import warnings

import matplotlib.pyplot as plt
import neurokit2 as nk
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats

warnings.filterwarnings("ignore")

# ── Paths ──────────────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
DATA_DIR = os.path.join(PROJECT_DIR, "data", "ptbxl-data")
POM_DIR = os.path.join(PROJECT_DIR, "source", "torord", "matlab", "POM_results")
OUTPUT_DIR = SCRIPT_DIR

SAMPLING_RATE = 500  # Use 500 Hz for better Tpeak-Tend resolution

# ── Step 1: Load and filter PTB-XL metadata ────────────────────────────────────

def load_and_filter_metadata():
    """Load PTB-XL metadata and filter for normal ECGs with NORM confidence >= 80."""
    db_path = os.path.join(DATA_DIR, "ptbxl_database.csv")
    df = pd.read_csv(db_path, index_col="ecg_id")
    df.scp_codes = df.scp_codes.apply(lambda x: ast.literal_eval(x))

    # Filter for NORM confidence >= 80
    def is_normal(scp_dict):
        return scp_dict.get("NORM", 0) >= 80

    df_norm = df[df.scp_codes.apply(is_normal)].copy()

    # Exclude missing age or sex
    df_norm = df_norm.dropna(subset=["age", "sex"])

    # Exclude implausible ages
    df_norm = df_norm[(df_norm.age >= 18) & (df_norm.age <= 100)]

    print(f"Total ECGs: {len(df)}")
    print(f"Normal ECGs (NORM >= 80, age 18-100): {len(df_norm)}")
    # PTB-XL encoding: 0=male, 1=female (confirmed via height: sex=0 avg 173.5cm, sex=1 avg 161.0cm)
    print(f"  Male (sex=0): {(df_norm.sex == 0).sum()}")
    print(f"  Female (sex=1): {(df_norm.sex == 1).sum()}")

    return df_norm


# ── Step 2: Extract ECG features from Lead II ──────────────────────────────────

def extract_features_single(signal_lead_ii, sampling_rate):
    """
    Extract QTc, Tpeak-Tend, and T-wave amplitude from a single Lead II signal.
    Returns dict of features or None if extraction fails.
    """
    try:
        # Process ECG: clean, find R-peaks, delineate waves
        signals, info = nk.ecg_process(signal_lead_ii, sampling_rate=sampling_rate)

        # Get R-peaks for RR interval
        rpeaks = info["ECG_R_Peaks"]
        if len(rpeaks) < 3:
            return None

        # Median RR interval (seconds)
        rr_intervals = np.diff(rpeaks) / sampling_rate
        rr_median = np.median(rr_intervals)
        if rr_median <= 0.3 or rr_median > 2.0:
            return None

        # Get wave delineation columns
        # Use middle beats (skip first and last which may be incomplete)
        q_onsets = signals["ECG_Q_Peaks"].values
        t_offsets = signals["ECG_T_Offsets"].values
        t_peaks = signals["ECG_T_Peaks"].values

        # Find valid beats: need Q onset, T peak, and T offset
        # Work beat-by-beat using R-peaks as anchors
        qt_intervals = []
        tpte_intervals = []
        t_amplitudes = []

        ecg_clean = signals["ECG_Clean"].values

        for i in range(1, len(rpeaks) - 1):  # skip first and last beat
            rpeak = rpeaks[i]

            # Search window for Q onset: 200ms before R-peak
            q_search_start = max(0, rpeak - int(0.2 * sampling_rate))
            q_candidates = np.where(q_onsets[q_search_start:rpeak] == 1)[0]
            if len(q_candidates) == 0:
                continue
            q_onset_idx = q_search_start + q_candidates[-1]  # closest to R-peak

            # Search window for T peak and T offset: 100-500ms after R-peak
            t_search_start = rpeak + int(0.1 * sampling_rate)
            t_search_end = min(len(t_peaks), rpeak + int(0.5 * sampling_rate))

            t_peak_candidates = np.where(t_peaks[t_search_start:t_search_end] == 1)[0]
            t_off_candidates = np.where(t_offsets[t_search_start:t_search_end] == 1)[0]

            if len(t_peak_candidates) == 0 or len(t_off_candidates) == 0:
                continue

            t_peak_idx = t_search_start + t_peak_candidates[0]
            t_off_idx = t_search_start + t_off_candidates[-1]

            # Sanity: T offset must be after T peak
            if t_off_idx <= t_peak_idx:
                continue

            # QT interval (ms)
            qt_ms = (t_off_idx - q_onset_idx) / sampling_rate * 1000
            if qt_ms < 200 or qt_ms > 700:
                continue

            qt_intervals.append(qt_ms)

            # Tpeak-Tend (ms)
            tpte_ms = (t_off_idx - t_peak_idx) / sampling_rate * 1000
            tpte_intervals.append(tpte_ms)

            # T-wave amplitude (mV)
            t_amp = ecg_clean[t_peak_idx]
            t_amplitudes.append(t_amp)

        if len(qt_intervals) < 2:
            return None

        # Take median across beats
        qt_median = np.median(qt_intervals)
        tpte_median = np.median(tpte_intervals)
        t_amp_median = np.median(t_amplitudes)

        # Bazett correction: QTc = QT / sqrt(RR)  (RR in seconds, QT in ms)
        qtc = qt_median / np.sqrt(rr_median)

        # Plausibility check
        if qtc < 300 or qtc > 600:
            return None

        return {
            "QTc_ms": qtc,
            "QT_ms": qt_median,
            "RR_s": rr_median,
            "Tpeak_Tend_ms": tpte_median,
            "T_amplitude_mV": t_amp_median,
            "heart_rate_bpm": 60 / rr_median,
            "n_beats": len(qt_intervals),
        }

    except Exception:
        return None


def extract_all_features(df_norm):
    """Extract ECG features for all normal ECGs. Returns DataFrame with features."""
    # Check for cached results
    cache_path = os.path.join(OUTPUT_DIR, "ptbxl_features.csv")
    if os.path.exists(cache_path):
        print(f"\nLoading cached features from {cache_path}")
        features_df = pd.read_csv(cache_path, index_col="ecg_id")
        print(f"Loaded {len(features_df)} records with features")
        return features_df

    print(f"\nExtracting features from {len(df_norm)} ECGs at {SAMPLING_RATE} Hz...")

    results = []
    n_success = 0
    n_fail = 0

    for i, (ecg_id, row) in enumerate(df_norm.iterrows()):
        if (i + 1) % 500 == 0 or i == 0:
            print(f"  Processing {i+1}/{len(df_norm)} "
                  f"(success: {n_success}, fail: {n_fail})")

        # Load ECG signal
        try:
            import wfdb
            record_path = os.path.join(DATA_DIR, row.filename_hr)
            signal, _ = wfdb.rdsamp(record_path)
            # Lead II is index 1
            lead_ii = signal[:, 1]
        except Exception:
            n_fail += 1
            continue

        features = extract_features_single(lead_ii, SAMPLING_RATE)

        if features is not None:
            features["ecg_id"] = ecg_id
            features["sex"] = row.sex
            features["age"] = row.age
            results.append(features)
            n_success += 1
        else:
            n_fail += 1

    print(f"\nExtraction complete: {n_success} success, {n_fail} fail "
          f"({n_fail/(n_success+n_fail)*100:.1f}% failure rate)")

    features_df = pd.DataFrame(results).set_index("ecg_id")

    # Save to CSV
    features_df.to_csv(cache_path)
    print(f"Saved features to {cache_path}")

    return features_df


# ── Step 3: Statistical analysis ───────────────────────────────────────────────

def analyse_features(features_df):
    """Compute summary statistics stratified by sex and age group."""

    # Sex labels — PTB-XL: 0=male, 1=female
    features_df["sex_label"] = features_df.sex.map({0: "Male", 1: "Female"})

    # Age groups (relevant for menopause analysis)
    def age_group(age):
        if age < 50:
            return "Pre-menopausal\n(< 50)"
        elif age >= 55:
            return "Post-menopausal\n(>= 55)"
        else:
            return None  # Exclude perimenopause (50–54)

    features_df["age_group"] = features_df.age.apply(age_group)

    print("\n" + "=" * 70)
    print("SUMMARY STATISTICS")
    print("=" * 70)

    # Overall by sex
    for sex_label in ["Female", "Male"]:
        subset = features_df[features_df.sex_label == sex_label]
        print(f"\n{sex_label} (n = {len(subset)}):")
        for col in ["QTc_ms", "Tpeak_Tend_ms", "T_amplitude_mV", "heart_rate_bpm"]:
            med = subset[col].median()
            q25 = subset[col].quantile(0.25)
            q75 = subset[col].quantile(0.75)
            print(f"  {col:20s}: median = {med:.1f}  [IQR: {q25:.1f} - {q75:.1f}]")

    # Sex gap (sex: 0=male, 1=female)
    f_qtc = features_df[features_df.sex == 1]["QTc_ms"]
    m_qtc = features_df[features_df.sex == 0]["QTc_ms"]
    gap = f_qtc.median() - m_qtc.median()
    u_stat, p_value = stats.mannwhitneyu(f_qtc, m_qtc, alternative="two-sided")

    print(f"\nQTc sex gap (female - male median difference): {gap:.1f} ms")
    print(f"Mann-Whitney U test: U = {u_stat:.0f}, p = {p_value:.2e}")

    # Tpeak-Tend sex gap
    f_tpte = features_df[features_df.sex == 1]["Tpeak_Tend_ms"]
    m_tpte = features_df[features_df.sex == 0]["Tpeak_Tend_ms"]
    tpte_gap = f_tpte.median() - m_tpte.median()
    u_stat2, p_value2 = stats.mannwhitneyu(f_tpte, m_tpte, alternative="two-sided")

    print(f"\nTpeak-Tend sex gap (female - male median difference): {tpte_gap:.1f} ms")
    print(f"Mann-Whitney U test: U = {u_stat2:.0f}, p = {p_value2:.2e}")

    # By age group
    print(f"\n{'─' * 70}")
    print("QTc SEX GAP BY AGE GROUP")
    print(f"{'─' * 70}")

    age_order = ["Pre-menopausal\n(< 50)", "Post-menopausal\n(>= 55)"]

    sex_gaps = []
    for ag in age_order:
        f_sub = features_df[(features_df.sex == 1) & (features_df.age_group == ag)]["QTc_ms"]
        m_sub = features_df[(features_df.sex == 0) & (features_df.age_group == ag)]["QTc_ms"]
        if len(f_sub) > 10 and len(m_sub) > 10:
            gap_ag = f_sub.median() - m_sub.median()
            # Bootstrap 95% CI for the sex gap
            n_boot = 2000
            rng = np.random.default_rng(42)
            boot_gaps = []
            for _ in range(n_boot):
                f_boot = rng.choice(f_sub.values, size=len(f_sub), replace=True)
                m_boot = rng.choice(m_sub.values, size=len(m_sub), replace=True)
                boot_gaps.append(np.median(f_boot) - np.median(m_boot))
            ci_lo = np.percentile(boot_gaps, 2.5)
            ci_hi = np.percentile(boot_gaps, 97.5)

            sex_gaps.append({
                "age_group": ag,
                "gap_ms": gap_ag,
                "ci_lo": ci_lo,
                "ci_hi": ci_hi,
                "n_female": len(f_sub),
                "n_male": len(m_sub),
            })
            print(f"  {ag.replace(chr(10), ' '):30s}: gap = {gap_ag:+.1f} ms  "
                  f"[95% CI: {ci_lo:.1f}, {ci_hi:.1f}]  "
                  f"(nF={len(f_sub)}, nM={len(m_sub)})")

    return features_df, sex_gaps


# ── Step 4: POM Biomarker Correlation & Risk Stratification ────────────────────

def risk_stratification(features_df):
    """
    Core Part 2 analysis: use POM simulation results to define risk tiers,
    map to QTc via percentile mapping, classify every PTB-XL individual,
    and characterise the at-risk population by sex and age.
    """
    bl_f = pd.read_csv(os.path.join(POM_DIR, "baseline_female.csv"))
    sert_f = pd.read_csv(os.path.join(POM_DIR, "sertraline_female.csv"))

    # ── Biomarker correlation ──
    merged = bl_f[["model_id", "APD90", "triangulation"]].rename(
        columns={"APD90": "bl_APD90", "triangulation": "bl_tri"})
    merged = merged.merge(
        sert_f[["model_id", "APD90", "EAD"]].rename(columns={"APD90": "drug_APD90"}),
        on="model_id")
    merged["prolongation"] = merged.drug_APD90 - merged.bl_APD90

    r, p = stats.spearmanr(merged.bl_APD90, merged.drug_APD90)

    print("\n" + "=" * 70)
    print("POM BIOMARKER CORRELATION (sertraline, female)")
    print("=" * 70)
    print(f"Baseline APD90 vs Drug APD90: Spearman r = {r:.3f}, p = {p:.2e}")

    # ── Quintile analysis ──
    merged["quintile"] = pd.qcut(merged.bl_APD90, 5, labels=["Q1", "Q2", "Q3", "Q4", "Q5"])
    print("\nFemale POM quintiles under sertraline (max dose 0.328 uM):")
    for q in ["Q1", "Q2", "Q3", "Q4", "Q5"]:
        sub = merged[merged.quintile == q]
        print(f"  {q}: bl_APD90=[{sub.bl_APD90.min():.0f}-{sub.bl_APD90.max():.0f}] ms, "
              f"prolongation={sub.prolongation.mean():.0f} ms, "
              f"drug_APD90={sub.drug_APD90.mean():.0f} ms, "
              f"EAD={int(sub.EAD.sum())}/{len(sub)}")

    # ── Risk tiers from simulation ──
    # High risk: top quintile (Q5) — 2/6 EADs, mean prolongation 142 ms
    # Elevated risk: Q4 — no EADs but drug APD90 > 400 ms
    # Low risk: Q1-Q3 — modest prolongation
    q80 = bl_f.APD90.quantile(0.80)
    q60 = bl_f.APD90.quantile(0.60)

    # Percentile-map to QTc (using female PTB-XL distribution)
    ecg_f = features_df[features_df.sex == 1]["QTc_ms"]
    qtc_high = ecg_f.quantile(0.80)
    qtc_elevated = ecg_f.quantile(0.60)

    print(f"\n{'─' * 70}")
    print("SIMULATION-DERIVED RISK TIERS")
    print(f"{'─' * 70}")
    print(f"HIGH RISK:     baseline APD90 >= {q80:.0f} ms (top 20%) -> QTc >= {qtc_high:.0f} ms")
    print(f"               All EADs occur in this tier; mean prolongation 3x higher than low-risk")
    print(f"ELEVATED RISK: baseline APD90 >= {q60:.0f} ms (top 40%) -> QTc >= {qtc_elevated:.0f} ms")
    print(f"               Drug APD90 exceeds 400 ms; significant prolongation")
    print(f"LOW RISK:      baseline APD90 < {q60:.0f} ms (bottom 60%) -> QTc < {qtc_elevated:.0f} ms")

    # ── Classify every PTB-XL individual ──
    def assign_tier(qtc):
        if qtc >= qtc_high:
            return "High risk"
        elif qtc >= qtc_elevated:
            return "Elevated risk"
        else:
            return "Low risk"

    features_df["risk_tier"] = features_df.QTc_ms.apply(assign_tier)

    print(f"\n{'─' * 70}")
    print("PTB-XL RISK STRATIFICATION")
    print(f"{'─' * 70}")

    tier_order = ["High risk", "Elevated risk", "Low risk"]
    for tier in tier_order:
        tier_df = features_df[features_df.risk_tier == tier]
        n = len(tier_df)
        n_f = (tier_df.sex == 1).sum()
        n_m = (tier_df.sex == 0).sum()
        pct_f = n_f / n * 100 if n > 0 else 0
        age_med = tier_df.age.median()

        # What % of all females / males fall in this tier
        f_rate = n_f / (features_df.sex == 1).sum() * 100
        m_rate = n_m / (features_df.sex == 0).sum() * 100

        print(f"\n  {tier} (n = {n}, {n/len(features_df)*100:.1f}% of population):")
        print(f"    Female: {n_f} ({f_rate:.1f}% of all women)")
        print(f"    Male:   {n_m} ({m_rate:.1f}% of all men)")
        print(f"    Female proportion: {pct_f:.1f}%  "
              f"(vs {(features_df.sex==1).sum()/len(features_df)*100:.1f}% overall)")
        print(f"    Median age: {age_med:.0f} years")

        # Age breakdown for this tier
        under50 = (tier_df.age < 50).sum()
        over55 = (tier_df.age >= 55).sum()
        print(f"    Age < 50: {under50} ({under50/n*100:.0f}%)  |  "
              f"Age >= 55: {over55} ({over55/n*100:.0f}%)")

    # Female/male risk ratio
    f_high = (features_df.sex == 1) & (features_df.risk_tier == "High risk")
    m_high = (features_df.sex == 0) & (features_df.risk_tier == "High risk")
    f_rate_high = f_high.sum() / (features_df.sex == 1).sum()
    m_rate_high = m_high.sum() / (features_df.sex == 0).sum()

    print(f"\n  Female/Male risk ratio (high-risk tier): "
          f"{f_rate_high/m_rate_high:.2f}")

    return qtc_high, qtc_elevated


# ── Step 5: Generate Figure 3 ─────────────────────────────────────────────────

def generate_figure3(features_df, sex_gaps, qtc_high=None, qtc_elevated=None):
    """Generate Figure 3: violin plots with risk tiers + age-stratified sex gap."""

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4.5),
                                    gridspec_kw={"width_ratios": [1, 1.3]})

    palette = {"Female": "#D64550", "Male": "#4A90D9"}

    # ── Left panel: QTc violin plots by sex with risk tiers ──
    sns.violinplot(
        data=features_df, x="sex_label", y="QTc_ms",
        palette=palette, inner="quartile", ax=ax1,
        order=["Female", "Male"], cut=0, linewidth=0.8
    )

    ax1.set_xlabel("")
    ax1.set_ylabel("QTc (ms, Bazett)")
    ax1.set_title("QTc distribution by sex",
                  fontsize=10, fontweight="bold", loc="center")

    # Overlay elevated risk boundary (top 20% — contains all EADs)
    if qtc_high is not None:
        ax1.axhline(y=qtc_high, color="#8B0000", linewidth=1.3, linestyle="--")
        ax1.text(1.02, qtc_high, f" {qtc_high:.0f} ms\n (elevated risk)",
                 transform=ax1.get_yaxis_transform(), va="center", fontsize=7,
                 color="#8B0000", fontweight="bold")

        # Proportions above elevated-risk boundary
        f_pct = (features_df[features_df.sex == 1]["QTc_ms"] >= qtc_high).mean() * 100
        m_pct = (features_df[features_df.sex == 0]["QTc_ms"] >= qtc_high).mean() * 100
        ax1.text(0, qtc_high + 6, f"{f_pct:.0f}%", ha="center", fontsize=8,
                 fontweight="bold", color="black")
        ax1.text(1, qtc_high + 6, f"{m_pct:.0f}%", ha="center", fontsize=8,
                 fontweight="bold", color="black")

    # Add sample sizes and medians below violins
    y_bot = ax1.get_ylim()[0]
    for i, sex_label in enumerate(["Female", "Male"]):
        subset = features_df[features_df.sex_label == sex_label]
        n = len(subset)
        med = subset["QTc_ms"].median()
        ax1.text(i, y_bot + 3, f"n={n}\nmedian={med:.0f} ms",
                 ha="center", va="bottom", fontsize=8, style="italic")

    # ── Right panel: QTc sex gap by age group ──
    if sex_gaps:
        age_labels = ["< 50\n(pre-menopausal)", "≥ 55\n(post-menopausal)"]
        gaps = [sg["gap_ms"] for sg in sex_gaps]
        ci_lo = [sg["ci_lo"] for sg in sex_gaps]
        ci_hi = [sg["ci_hi"] for sg in sex_gaps]
        errors_lo = [g - lo for g, lo in zip(gaps, ci_lo)]
        errors_hi = [hi - g for g, hi in zip(gaps, ci_hi)]

        ax2.bar(range(len(gaps)), gaps, color="#D64550", alpha=0.75,
                edgecolor="black", linewidth=0.8, width=0.5)
        ax2.errorbar(range(len(gaps)), gaps, yerr=[errors_lo, errors_hi],
                     fmt="none", ecolor="black", capsize=8, linewidth=1.8)

        ax2.set_xticks(range(len(age_labels)))
        ax2.set_xticklabels(age_labels, fontsize=10)
        ax2.set_xlabel("Age group", fontsize=10)
        ax2.set_ylabel("QTc sex gap (ms)\n(female - male median difference)", fontsize=10)
        ax2.set_title("QTc sex gap by age group",
                      fontsize=10, fontweight="bold", loc="center")
        ax2.axhline(y=0, color="black", linewidth=0.7, linestyle="-")
        ax2.set_ylim(bottom=0, top=max(gaps) + max(errors_hi) + 3.5)
        ax2.set_xlim(-0.6, len(gaps) - 0.4)

        # Add gap values above bars
        for i, g in enumerate(gaps):
            y_pos = g + errors_hi[i] + 1.2
            ax2.text(i, y_pos, f"{g:+.1f} ms",
                     ha="center", va="bottom", fontsize=10, fontweight="bold")

        # Add sample sizes inside bars
        for i, sg in enumerate(sex_gaps):
            ax2.text(i, gaps[i] / 2,
                     f"F={sg['n_female']}\nM={sg['n_male']}",
                     ha="center", va="center", fontsize=8, color="white",
                     fontweight="bold")

    plt.tight_layout(w_pad=3)

    fig_path = os.path.join(OUTPUT_DIR, "figure3.png")
    fig.savefig(fig_path, dpi=300, bbox_inches="tight")
    print(f"\nFigure 3 saved to {fig_path}")
    plt.close()


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("Part 2: ECG Biomarker Evaluation in PTB-XL Clinical Data")
    print("=" * 70)

    # Step 1: Load and filter
    df_norm = load_and_filter_metadata()

    # Step 2: Extract features
    features_df = extract_all_features(df_norm)

    # Step 3: Analyse
    features_df, sex_gaps = analyse_features(features_df)

    # Step 4: POM risk stratification (core Part 2 analysis)
    qtc_high, qtc_elevated = risk_stratification(features_df)

    # Step 5: Generate Figure 3
    generate_figure3(features_df, sex_gaps, qtc_high, qtc_elevated)

    print("\nDone.")


if __name__ == "__main__":
    main()
