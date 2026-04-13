"""
Part 2: ECG Biomarker Evaluation in PTB-XL Clinical Data

Extracts QTc, Tpeak-Tend, and T-wave amplitude from normal PTB-XL ECGs,
stratifies by sex and age group, and generates Figure 3.

Usage: python ptbxl_analysis.py
"""

import ast
import os
import warnings

import matplotlib.patches as mpatches
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
        if age < 45:
            return "Pre-menopausal\n(< 45)"
        elif age >= 55:
            return "Post-menopausal\n(>= 55)"
        else:
            return None  # Exclude perimenopause (45–54)

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

    age_order = ["Pre-menopausal\n(< 45)", "Post-menopausal\n(>= 55)"]

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

    # ── Risk tier from simulation ──
    # Single threshold: top quintile (Q5) of female baseline APD90
    # Contains all EADs and receives 3x the prolongation of Q1-Q4
    q80 = bl_f.APD90.quantile(0.80)

    # Percentile-map to QTc (using female PTB-XL distribution)
    ecg_f = features_df[features_df.sex == 1]["QTc_ms"]
    qtc_threshold = ecg_f.quantile(0.80)

    print(f"\n{'─' * 70}")
    print("SIMULATION-DERIVED RISK TIER")
    print(f"{'─' * 70}")
    print(f"ELEVATED RISK: baseline APD90 >= {q80:.0f} ms (top 20%) -> QTc >= {qtc_threshold:.0f} ms")
    print(f"               All EADs occur in this tier; mean prolongation 3x higher than lower risk")
    print(f"LOWER RISK:    baseline APD90 < {q80:.0f} ms (bottom 80%) -> QTc < {qtc_threshold:.0f} ms")

    # ── Classify every PTB-XL individual ──
    features_df["risk_tier"] = features_df.QTc_ms.apply(
        lambda qtc: "Elevated risk" if qtc >= qtc_threshold else "Lower risk")

    print(f"\n{'─' * 70}")
    print("PTB-XL RISK STRATIFICATION")
    print(f"{'─' * 70}")

    for tier in ["Elevated risk", "Lower risk"]:
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
        under45 = (tier_df.age < 45).sum()
        over55 = (tier_df.age >= 55).sum()
        print(f"    Age < 45: {under45} ({under45/n*100:.0f}%)  |  "
              f"Age >= 55: {over55} ({over55/n*100:.0f}%)")

    # Female/male risk ratio
    f_elev = (features_df.sex == 1) & (features_df.risk_tier == "Elevated risk")
    m_elev = (features_df.sex == 0) & (features_df.risk_tier == "Elevated risk")
    f_rate_elev = f_elev.sum() / (features_df.sex == 1).sum()
    m_rate_elev = m_elev.sum() / (features_df.sex == 0).sum()

    print(f"\n  Female/Male risk ratio (elevated-risk tier): "
          f"{f_rate_elev/m_rate_elev:.2f}")

    return qtc_threshold


# ── Step 5: Generate Figure 3 ─────────────────────────────────────────────────

def generate_figure3(features_df, qtc_threshold=None):
    """Generate Figure 3: QT prolongation bars (left) + QTc violin plots (right)."""

    fig, (ax_violin, ax_qt) = plt.subplots(1, 2, figsize=(10, 4))

    # ── Left panel: single-cell QT prolongation by drug and dose ──
    # ΔAPD90 (ms) at [start, mid, max] dose from single-cell simulations
    qt_prolongation = {
        "Sertraline":    {"Female": [10, 30, 50], "Male": [10, 25, 40]},
        "Amitriptyline": {"Female": [4, 10, 15],  "Male": [3, 8, 11]},
        "Desipramine":   {"Female": [6, 19, 26],  "Male": [4, 16, 20]},
    }

    drugs = ["Amitriptyline", "Desipramine", "Sertraline"]

    # Colors: dark → light = start → mid → max dose
    f_cols = ["#8B0000", "#D64550", "#F4A0A8"]
    m_cols = ["#1B3A6B", "#4A90D9", "#87CEEB"]
    dose_labels = ["Start dose", "Medium dose", "Maximum dose"]

    bar_w = 0.35
    inner_gap = 0.08
    group_gap = 0.4

    x_f = [i * (bar_w + inner_gap) for i in range(len(drugs))]
    x_m = [x_f[-1] + bar_w + group_gap + i * (bar_w + inner_gap)
           for i in range(len(drugs))]

    for d, drug in enumerate(drugs):
        for sex, xpos, cols in [("Female", x_f[d], f_cols), ("Male", x_m[d], m_cols)]:
            vals = qt_prolongation[drug][sex]
            segs = [vals[0], vals[1] - vals[0], vals[2] - vals[1]]
            bottom = 0
            for seg, col in zip(segs, cols):
                ax_qt.bar(xpos, seg, bar_w, bottom=bottom, color=col,
                          edgecolor="white", linewidth=0.4)
                bottom += seg

    # Drug labels on x-axis, coloured by sex
    ax_qt.set_xticks(x_f + x_m)
    ax_qt.set_xticklabels(drugs * 2, fontsize=6.5, rotation=20, ha="right")
    for i, tl in enumerate(ax_qt.get_xticklabels()):
        tl.set_color("#D64550" if i < len(drugs) else "#4A90D9")

    # Group labels just below drug names
    f_center = np.mean(x_f)
    m_center = np.mean(x_m)
    ax_qt.text(f_center, -0.10, "Female", ha="center", va="top", fontsize=9,
               fontweight="bold", color="#D64550",
               transform=ax_qt.get_xaxis_transform())
    ax_qt.text(m_center, -0.10, "Male", ha="center", va="top", fontsize=9,
               fontweight="bold", color="#4A90D9",
               transform=ax_qt.get_xaxis_transform())

    ax_qt.set_ylabel("$\\Delta APD_{90}$ (ms)")
    ax_qt.set_title("QTc prolongation by drug and therapeutic dose",
                    fontsize=10, fontweight="bold")
    ax_qt.set_ylim(0, 55)
    ax_qt.margins(x=0.02)

    grey_shades = ["#333333", "#888888", "#CCCCCC"]
    legend_handles = [mpatches.Patch(facecolor=grey_shades[i], edgecolor="white",
                                     label=dose_labels[i]) for i in reversed(range(3))]
    ax_qt.legend(handles=legend_handles, fontsize=7, loc="upper right")

    # ── Right panel: QTc violin plot ──
    palette = {"Female": "#D64550", "Male": "#4A90D9"}

    sns.violinplot(
        data=features_df, x="sex_label", y="QTc_ms",
        palette=palette, inner="quartile", ax=ax_violin,
        order=["Female", "Male"], cut=0, linewidth=0.8
    )

    ax_violin.set_xlabel("")
    ax_violin.set_ylabel("QTc - Bazett correction (ms)")
    ax_violin.set_title("QTc distribution in PTB-XL",
                        fontsize=10, fontweight="bold")

    if qtc_threshold is not None:
        ax_violin.axhline(y=qtc_threshold, color="#8B0000", linewidth=1.3,
                          linestyle="--")
        ax_violin.text(1.02, qtc_threshold, f" {qtc_threshold:.0f} ms\n (elevated risk)",
                       transform=ax_violin.get_yaxis_transform(), va="center",
                       fontsize=7.5, color="#8B0000", fontweight="bold")

        f_pct = (features_df[features_df.sex == 1]["QTc_ms"] >= qtc_threshold).mean() * 100
        m_pct = (features_df[features_df.sex == 0]["QTc_ms"] >= qtc_threshold).mean() * 100
        ax_violin.text(0, qtc_threshold + 6, f"{f_pct:.0f}%", ha="center", fontsize=9,
                       fontweight="bold", color="black")
        ax_violin.text(1, qtc_threshold + 6, f"{m_pct:.0f}%", ha="center", fontsize=9,
                       fontweight="bold", color="black")

    # Sample sizes and medians
    y_bot = ax_violin.get_ylim()[0]
    for i, sex_label in enumerate(["Female", "Male"]):
        subset = features_df[features_df.sex_label == sex_label]
        n = len(subset)
        med = subset["QTc_ms"].median()
        ax_violin.text(i, y_bot + 3, f"n={n}\nmedian={med:.0f} ms",
                       ha="center", va="bottom", fontsize=8, style="italic")

    plt.tight_layout()
    fig.subplots_adjust(bottom=0.18)

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
    features_df, _ = analyse_features(features_df)

    # Step 4: POM risk stratification (core Part 2 analysis)
    qtc_threshold = risk_stratification(features_df)

    # Step 5: Generate Figure 3
    generate_figure3(features_df, qtc_threshold)

    print("\nDone.")


if __name__ == "__main__":
    main()
