# Partial formalization: checks and remaining work

The six exact-type endpoints in `ProofInterface.lean` compile. Their propositions are exposed as transparent specifications in `PaperInterface.lean`. The results concern the conditional input problem and the reduced activity problem; they do not claim verification of the complete original joint optimization problem.

## Executed checks

- The registered paper target compiled successfully (3,320 jobs).
- An independent `#print axioms` check of all six endpoints exited zero. It reported only `propext`, `Classical.choice`, and `Quot.sound`; no `sorryAx` or custom axiom.
- `python3 scripts/paper_contribution.py check Saco26InstitutionalRestart --fast` passed, exit code 0, on November 8, 2026 (Lima). It checks the statement build, paper isolation, and whitespace; it does not constitute the full source-correspondence audit. The complete proof build and axiom inspection are separate checks.
- A context-isolated preliminary source-to-Spec review found 12 matches and no mismatches or uncertain rows. This is a diagnostic review, not a terminal acceptance receipt.

## Coverage boundary

The source first optimizes the variable input at each date and then solves the binary activity problem. Lean verifies the conditional input optimizer and the reduced infinite-horizon activity results separately. It has not proved that their combination solves the original joint problem over all feasible input/activity plans, including unoptimized plans with value minus infinity. This is an open formalization obligation, not an additional economic assumption.

The formal endpoints retain the source's strict `0 < beta < 1`. An early AI-generated helper allowed beta to be zero while claiming uniqueness of the entire path. That helper was corrected: with zero discounting future choices cannot be uniquely ranked. The paper already excludes that case; the correction does not narrow its stated parameter domain.

## Audit status

The extended graph-based source audit was stopped before certification after the author requested a simpler, understandable deliverable. No final accepted graph, terminal source audit, or complete-validation report was produced. The local status remains `partially formalized`. Historical intake templates and unfilled audit sidecars do not establish verification.

The paper used for the run is the November 8 version at GitHub merge `a15ed978282156ba72928ad23940860cccda6f28`. AppliedModelingLib base is `194edcc95df74806a39b961d10dedddc6e730cce`, with recorded local macOS compatibility and extraction-timeout changes. The actual formalization used `gpt-5.6-sol` at `xhigh`, with `leanprover/lean4:v4.30.0-rc2`.

The author's handwritten derivation and personal assessment remain pending. Automated checks are not a substitute for that assessment.
