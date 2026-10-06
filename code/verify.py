"""Symbolic and numerical check of Proposition 1 of the template's toy model.

    python3 code/verify.py

Writes code/output/effort_check.csv and code/figures/effort_check.pdf, and
exits with an error if the closed form and the grid search disagree by more
than the grid resolution. Replace the toy model with yours; keep the idea that
the script *fails* when the paper's claim does not hold.
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import sympy as sp

HERE = Path(__file__).resolve().parent
(HERE / "output").mkdir(exist_ok=True)
(HERE / "figures").mkdir(exist_ok=True)

# --- 1. Symbolic: first-order condition, second-order condition, comparative static
a, c, e = sp.symbols("a c e", positive=True)
objective = a * e - c * e**2 / 2
e_star = sp.solve(sp.diff(objective, e), e)
assert e_star == [a / c], f"unexpected stationary point: {e_star}"
soc = sp.diff(objective, e, 2)
assert soc == -c, f"unexpected second derivative: {soc}"
static = sp.diff(e_star[0], a)
assert sp.simplify(static - 1 / c) == 0
print(f"symbolic   e* = {e_star[0]},  d2/de2 = {soc},  de*/da = {static}")

# --- 2. Numerical: grid search over e for a set of (a, c)
grid = np.linspace(0.0, 10.0, 200_001)          # resolution 5e-5
step = grid[1] - grid[0]
rows = []
for c_val in (0.5, 1.0, 2.0):
    for a_val in np.linspace(0.5, 3.0, 11):
        payoff = a_val * grid - c_val * grid**2 / 2
        rows.append({"a": a_val, "c": c_val,
                     "e_grid": grid[np.argmax(payoff)],
                     "e_closed_form": a_val / c_val})
table = pd.DataFrame(rows)
table["abs_gap"] = (table["e_grid"] - table["e_closed_form"]).abs()
table.to_csv(HERE / "output" / "effort_check.csv", index=False)

worst = table["abs_gap"].max()
print(f"numerical  {len(table)} parameter pairs, largest |gap| = {worst:.2e} "
      f"(grid step {step:.0e})")
if worst > step:
    raise SystemExit("FAIL: grid search and closed form disagree")

# --- 3. Figure used by paper/paper.tex and slides/final.tex
fig, ax = plt.subplots(figsize=(6.0, 3.6))
for c_val, group in table.groupby("c"):
    line, = ax.plot(group["a"], group["e_closed_form"], lw=1.6,
                    label=f"$c={c_val:g}$")
    ax.plot(group["a"], group["e_grid"], "o", ms=4, color=line.get_color())
ax.set_xlabel("productivity with AI, $a$")
ax.set_ylabel("optimal effort, $e^*$")
ax.legend(frameon=False, title="closed form (line), grid search (marker)")
ax.spines[["top", "right"]].set_visible(False)
fig.tight_layout()
fig.savefig(HERE / "figures" / "effort_check.pdf")
print("OK: wrote code/output/effort_check.csv and code/figures/effort_check.pdf")
