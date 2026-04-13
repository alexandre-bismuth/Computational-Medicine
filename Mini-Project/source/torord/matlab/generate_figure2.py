"""
Figure 2: Biomarker Correlation + Rate Dependence

Left panel:  Scatter of baseline APD90 vs drug-induced APD90 under sertraline
             (30 female red, 30 male blue), EAD models highlighted.
Right panel: EAD incidence (%) at sertraline max dose across BCL 600, 1000, 1200 ms
             for female vs male, showing reverse use-dependence.

Usage: python generate_figure2.py
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import pandas as pd

# ── Paths ──
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
POM_DIR = os.path.join(SCRIPT_DIR, "POM_results")
FIG_DIR = os.path.join(POM_DIR, "figures")
os.makedirs(FIG_DIR, exist_ok=True)

# ── Colours ──
RED = "#D64550"
BLUE = "#4A90D9"
RED_DARK = "#8B0000"
BLUE_DARK = "#1B3A6B"

# ── Load data ──
bl_f = pd.read_csv(os.path.join(POM_DIR, "baseline_female.csv"))
bl_m = pd.read_csv(os.path.join(POM_DIR, "baseline_male.csv"))
sert_f = pd.read_csv(os.path.join(POM_DIR, "sertraline_female.csv"))
sert_m = pd.read_csv(os.path.join(POM_DIR, "sertraline_male.csv"))

# ── Left panel data: baseline APD90 vs drug APD90 ──
bl_f_apd = bl_f[["model_id", "APD90"]].rename(columns={"APD90": "bl_APD90"})
bl_m_apd = bl_m[["model_id", "APD90"]].rename(columns={"APD90": "bl_APD90"})

drug_f = sert_f[["model_id", "APD90", "EAD"]].rename(columns={"APD90": "drug_APD90"})
drug_m = sert_m[["model_id", "APD90", "EAD"]].rename(columns={"APD90": "drug_APD90"})

merged_f = bl_f_apd.merge(drug_f, on="model_id")
merged_m = bl_m_apd.merge(drug_m, on="model_id")

# ── Right panel data: EAD incidence by BCL (user-verified counts) ──
# Female EAD counts from visual inspection of AP traces:
#   BCL 600:  0/30,  BCL 1000: 2/30,  BCL 1200: 4/30
# Male: 0/30 at all BCLs (no male BCL variation files; male has no EADs)
bcl_values = [600, 1000, 1200]
hr_labels = ["100 bpm\n(BCL 600)", "60 bpm\n(BCL 1000)", "50 bpm\n(BCL 1200)"]
female_ead_pct = [0 / 30 * 100, 2 / 30 * 100, 4 / 30 * 100]
male_ead_pct = [0, 0, 0]

# ── Figure ──
fig, (ax2, ax1) = plt.subplots(1, 2, figsize=(10, 4.5))

# ── Right panel: scatter ──
# Non-EAD models
f_no = merged_f[merged_f.EAD == 0]
m_no = merged_m[merged_m.EAD == 0]
ax1.scatter(f_no.bl_APD90, f_no.drug_APD90, c=RED, alpha=0.6, s=35,
            edgecolors="white", linewidths=0.4, zorder=2)
ax1.scatter(m_no.bl_APD90, m_no.drug_APD90, c=BLUE, alpha=0.6, s=35,
            edgecolors="white", linewidths=0.4, zorder=2)

# EAD models (larger, star marker)
f_ead = merged_f[merged_f.EAD == 1]
m_ead = merged_m[merged_m.EAD == 1]
if len(f_ead) > 0:
    ax1.scatter(f_ead.bl_APD90, f_ead.drug_APD90, c=RED_DARK, s=90,
                marker="*", edgecolors="black", linewidths=0.5, zorder=3,
                label=f"Female EAD (n={len(f_ead)})")
if len(m_ead) > 0:
    ax1.scatter(m_ead.bl_APD90, m_ead.drug_APD90, c=BLUE_DARK, s=90,
                marker="*", edgecolors="black", linewidths=0.5, zorder=3,
                label=f"Male EAD (n={len(m_ead)})")

# Identity line
lims = [min(ax1.get_xlim()[0], ax1.get_ylim()[0]),
        max(ax1.get_xlim()[1], ax1.get_ylim()[1])]
ax1.plot(lims, lims, "--", color="grey", linewidth=0.7, alpha=0.5, zorder=1)

ax1.set_xlabel("Baseline APD$_{90}$ (ms)")
ax1.set_ylabel("Drug-induced APD$_{90}$ (ms)")
ax1.set_title("Biomarker correlation\nfor sertraline at 0.328 µM", fontsize=10, fontweight="bold")

# Legend
f_patch = mpatches.Patch(color=RED, alpha=0.6, label="Female (n=30)")
m_patch = mpatches.Patch(color=BLUE, alpha=0.6, label="Male (n=30)")
handles = [f_patch, m_patch]
if len(f_ead) > 0:
    handles.append(plt.Line2D([0], [0], marker="*", color="w",
                               markerfacecolor=RED_DARK, markersize=10,
                               markeredgecolor="black", markeredgewidth=0.5,
                               label=f"Female EAD (n={len(f_ead)})"))
ax1.legend(handles=handles, fontsize=7, loc="lower right")

# ── Right panel: female EAD incidence by BCL ──
x = np.arange(len(bcl_values))
width = 0.5

bars_f = ax2.bar(x, female_ead_pct, width, color=RED, alpha=0.75,
                 edgecolor="white", linewidth=0.5)

ax2.set_xticks(x)
ax2.set_xticklabels(hr_labels, fontsize=8)
ax2.set_ylabel("EAD incidence (%)")
ax2.set_title("Incidence of female EAD at different BCL\nfor sertraline at 0.328 µM",
              fontsize=10, fontweight="bold")
ax2.set_ylim(0, max(female_ead_pct) * 1.6 if max(female_ead_pct) > 0 else 5)

plt.tight_layout()

fig_path = os.path.join(FIG_DIR, "figure2.png")
fig.savefig(fig_path, dpi=300, bbox_inches="tight")
print(f"Figure 2 saved to {fig_path}")
plt.close()
