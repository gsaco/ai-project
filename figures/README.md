# GDP responses in Figure 1

The introduction plots cumulative changes in log real GDP per capita at 0, 5, 10, and 15 years. The thesis project is Gabriel Saco’s *Choques de Libertad Económica: Evidencia Global de Efectos Asimétricos y No Lineales*, the title given on the research proposal. Figure 2 and Table 2 of the unpublished manuscript compiled July 30, 2026 (`economic-freedom/paper.pdf`) contain the graph and the estimates. The corresponding LaTeX labels are `fig:main-symmetric-asymmetric` and `tab:asymmetric-main`. A one-point EFW change at each of two successive five-year observations loads on the current and lagged coefficients. The first panel imposes symmetry. The second estimates improvements and deteriorations separately. The inner bands give country-clustered 95% pointwise intervals. The outer bands give 95% simultaneous sup-t intervals across the four horizons within each path.

| Years | Symmetric response | Improvement | Deterioration | Pointwise p for equal magnitudes | Observations |
|---:|---:|---:|---:|---:|---:|
| 0 | 0.084 | 0.069 | −0.111 | 0.482 | 1,109 |
| 5 | 0.156 | 0.099 | −0.274 | 0.029 | 946 |
| 10 | 0.177 | 0.082 | −0.358 | 0.004 | 759 |
| 15 | 0.148 | 0.096 | −0.247 | 0.170 | 635 |

The deterioration regressor is signed. A one-unit deterioration multiplies its fitted slope by −1 and reverses the order of the confidence endpoints. At ten years the loss exceeds the gain by 0.276 log points. The p-values come from direct within-regression tests of slope equality that account for covariance between slopes.

## Rebuild the manuscript figure

Run `python code/verify.py` from the repository root with the [project dependencies](../code/README.md). The [plotting code](../code/thesis_figure.py) joins the [four original Stata result frames](../code/data/thesis-irfs/) by shock and horizon. It verifies the rounded estimates, sample counts, equality tests, and ordering of interval endpoints. It writes a [replication plot](../paper/figures/thesis-irfs.pdf) and the [LaTeX values](../paper/tables/thesis-irf-values.tex) from the full-precision exports. The displayed difference is computed before rounding.

## Original estimation

On November 19, 2026 the baseline was rerun in Stata 18 using the thesis file `economic-freedom/code/experiment3.do` (SHA-256 `bdebe432f0a41a00d41061d4d0cbdee8a174c9ebefdef80092207eb5dc86d48e`). The source baseline uses seed 9758329 and 20,000 draws for the simultaneous bands. The original manuscript and panel inputs reside in the author's separate thesis project. The analysis here can be reproduced from the included result frames without that project.

To repeat the estimation with the thesis inputs, run the source from its first line through the creation of the named graph `paper_main_figure` (line 3321 in this version), with the script's input paths pointing to the thesis data. Its baseline output is under `output_experiments/panel_chainlinked/advisor_reparam_sign_specific_controls_clean`. Immediately after the graph command, export the graph and the four live frames in the same Stata session.

```stata
graph export "stata-original.pdf", name(paper_main_figure) replace
foreach fr in sym_results sym_supt_results asym_results asym_supt_results {
    frame `fr': export delimited using "`fr'.csv" if shock == "shock1", replace
}
```

The native graph rerun matched the [archived thesis PDF](paper_main_figure.pdf) byte for byte. That PDF and its [Stata PNG](paper_main_figure.png) are preserved for the proposal, slides and repository overview. They originate from `economic-freedom/code/figures_paper/experiment3_panel_chainlinked_sign_specific_controls`. Figure 1 in the manuscript uses the plot generated from the four result frames in the original graph layout.

| Archived Stata export | SHA-256 |
|---|---|
| PDF | `db74e6c2dd2fbbd8194fa97b46759e503e8c973a4c1c10dbe3058e00a83846cd` |
| PNG | `ac1131f1c7c8068b7cb5e81ea42ffc903fab68f1eae5bb89fa4ad61ff7bdaddf` |
