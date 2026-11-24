# Reproducing the model checks

From the repository root, with Python 3.12+ and Node.js 18+ installed:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r code/requirements.txt
python code/verify.py
```

The command rebuilds all four manuscript figures, both model tables, and the presentation figures. For Figure 1 it checks the digest of the archived Stata PDF and draws the displayed graph in its original layout from the exported slopes and both sets of interval endpoints. It writes the statistics quoted in the introduction directly to LaTeX. The original inputs and estimation instructions are described in the [figure record](../figures/README.md).

The checks cover:

- The first and second derivatives, the optimal input against numerical grids, and the input bill implied by the first-order condition. In the normal example, the bill is 0.40 on revenue of 0.80.
- Normal output 0.80, profit 0.01, adverse profit −0.15, favorable profit 0.17, and restored value 0.10.
- Small shocks, free restart, costly restart, and fixed institutional overhead.
- The severe-shock impact loss split between reduced production and closure, and the positive-total example in which all incumbents operate and symmetric changes in levels yield asymmetric log changes.
- All four-date activity paths in 324 scenario problems, using an exact stationary tail; conditional level and positive-total log comparisons.
- All five-date activity paths at 168 parameter points, checked against the complete closure threshold and weak asymmetry.
- Delayed restarting at 200 candidate dates plus never restarting; tie cases; a case in which higher restart cost discourages current closure.
- Suspension at 151 preservation costs, including its threshold and expensive-preservation rejection.
- The four shock and rebuilding-cost pairs, the three discount factors, and exact rational comparisons at and on both sides of the shock, restart, suspension, and discount cutoffs.
- The 13 existing JavaScript model tests, plus agreement between JavaScript and Python at all 168 final parameter points and 151 suspension costs.

`firm_model.py` and `slides/reveal/model.js` implement the model. Both compare action values after removing the common discounted value of continued operation and apply the same roundoff convention. `paper_results.py` independently checks the manuscript examples with rational arithmetic. `final_analysis.py` reproduces the presentation figures and checks; `check_browser_model.cjs` verifies the final cross-language comparisons. Results are recorded in `code/output/verification.json` and `code/output/final-verification.json`.

The finite grids can expose algebra, implementation, and timing errors. They do not prove statements over all real parameters or verify the infinite-horizon argument in Lean. The stationary tail uses the analytically derived restored-state value. Neither the grids nor the illustrations estimate an EFW effect, calibrate a GDP response, or solve entry and heterogeneous-firm equilibrium. The empirical motivating figure has separate provenance in `figures/README.md`.
