# Economic freedom and firm entry–exit decisions

This folder contains the Lean development for Gabriel Saco's November 8, 2026 working paper. It checks the conditional input choice and the reduced infinite-horizon activity problem, including every possible delayed restart.

**Status: partially formalized.** All six statement/proof endpoints compile without `sorry`. The required paper-scoped fast check passed with exit code 0. That check is not a complete source-correspondence certification. The extended audit was stopped before certification; its preliminary independent review is diagnostic only.

The remaining mathematical coverage gap is the equivalence between the original joint input/activity program and the reduced activity program, including feasible plans with infinite discounted losses. No additional economic assumption was introduced to close the six endpoints; the strict discount condition is already in the paper.

## Results

The transparent statements are in [PaperInterface.lean](PaperInterface.lean); every endpoint below is in [ProofInterface.lean](ProofInterface.lean), under namespace `Saco26InstitutionalRestart`.

| Paper result | Checked endpoint | Main proof development |
|---|---|---|
| Lemma 1: operating optimum | `lemma1_operating_optimum_proof` | [Operating.lean](Operating.lean) |
| Lemma 2: restored values and delays | `lemma2_restored_state_values_and_delays_proof` | [MainTheorems.lean](MainTheorems.lean) |
| Proposition 1: persistent strict asymmetry | `proposition1_persistent_strict_asymmetry_proof` | [Results.lean](Results.lean) |
| Proposition 2: complete closure threshold | `proposition2_complete_closure_threshold_proof` | [Results.lean](Results.lean) |
| Proposition 3: cheap suspension | `proposition3_cheap_suspension_proof` | [Results.lean](Results.lean) |
| Corollary 1: positive totals and logs | `corollary1_positive_totals_and_logs_proof` | [Results.lean](Results.lean) |

See [the partial-run record](docs/PARTIAL_RUN_REPORT.md) for the checks and their limits. The earlier plan and source/audit files remain as provenance; incomplete templates are not acceptance receipts.

## Reproduction

This folder is copied verbatim from `papers/Saco26InstitutionalRestart` in the matching AppliedModelingLib checkout. It is not a standalone Lake project. Restore it under that path, use the matching root module and recorded environment patch, then run:

```sh
lake build +Saco26InstitutionalRestart
python3 scripts/paper_contribution.py check Saco26InstitutionalRestart --fast
```

Pinned paper: [merge a15ed978](https://github.com/gsaco/ai-project/blob/a15ed978282156ba72928ad23940860cccda6f28/paper/paper.pdf). Exact source hashes and the reproduction patch accompany the working paper in `paper/audit/` in the project repository.
