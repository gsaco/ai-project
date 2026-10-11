# Empirical motivation figure

The empirical figure from my thesis is included as the original PDF and matching
Stata-exported PNG. Both files are copied without changes from my `economic-freedom` research repository, at:

`code/figures_paper/experiment3_panel_chainlinked_sign_specific_controls`

The PDF is included in the proposal and Beamer presentation. The PNG is embedded
in the standalone Quarto/Reveal.js presentation. Both panels, axes, colors,
legends, confidence bands, and scale are preserved. Panel headings and notes
are typeset outside the figure.

Interpretation verified against `economic-freedom/paper.tex`, the figure
`fig:main-symmetric-asymmetric`, and `code/experiment3.do`:

- Outcome: cumulative log real GDP per capita response.
- Left: symmetry imposed; right: separate improvement and deterioration paths.
- Horizon labels: 0, 5, 10, and 15 years.
- Responses use the paper's combined current-plus-lagged one-point EFW change
  interpretation, not a calibrated model period or a change in usable property.
- Inner bands: 95% country-clustered pointwise confidence intervals.
- Outer bands: 95% simultaneous sup-t bands.
- The figure motivates the model; it does not establish its mechanism.

SHA-256:

- `pdf`: `db74e6c2dd2fbbd8194fa97b46759e503e8c973a4c1c10dbe3058e00a83846cd`
- `png`: `ac1131f1c7c8068b7cb5e81ea42ffc903fab68f1eae5bb89fa4ad61ff7bdaddf`
