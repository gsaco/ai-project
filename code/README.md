# Reproducing the model checks

From the repository root, with Python 3.12+ and Node.js 18+ installed:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r code/requirements.txt
python code/verify.py
```

The single entry point fails on an unsuccessful assertion or browser-model check. It generates the paper's two tables in `paper/tables/`, its three figures in `paper/figures/`, and the final deck's figures in `slides/final-assets/`.

The checks cover:

- The symbolic FOC and second derivative, plus the closed-form optimum against numerical input grids.
- Normal output 0.80, profit 0.01, adverse profit −0.15, favorable profit 0.17, and restored value 0.10.
- Small shocks, free restart, costly restart, and fixed institutional overhead.
- All four-date activity paths in 324 scenario problems, using an exact stationary tail; conditional level and positive-total log comparisons.
- All five-date activity paths at 168 parameter points, checked against the complete closure threshold and weak asymmetry.
- Delayed restarting at 200 candidate dates plus never restarting; tie cases; a case in which higher restart cost discourages current closure.
- Suspension at 151 preservation costs, including its threshold and expensive-preservation rejection.
- The four shock and rebuilding-cost pairs, the three discount factors, and exact rational comparisons at and on both sides of the shock, restart, suspension, and discount cutoffs.
- The 13 existing JavaScript model tests, plus agreement between JavaScript and Python at all 168 final parameter points and 151 suspension costs.

`firm_model.py` and `slides/reveal/model.js` implement the model. Both compare action values after removing the common discounted value of continued operation and apply the same roundoff convention. `paper_results.py` independently checks the manuscript examples with rational arithmetic. `final_analysis.py` reproduces the presentation figures and checks; `check_browser_model.cjs` verifies the final cross-language comparisons. Results are recorded in `code/output/verification.json` and `code/output/final-verification.json`.

The finite grids can expose algebra, implementation, and timing errors. They do not prove statements over all real parameters or verify the infinite-horizon argument in Lean. The stationary tail uses the analytically derived restored-state value. Neither the grids nor the illustrations estimate an EFW effect, calibrate a GDP response, or solve entry and heterogeneous-firm equilibrium. The empirical motivating figure has separate provenance in `figures/README.md`.
