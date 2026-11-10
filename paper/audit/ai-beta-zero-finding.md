# AI-generated helper error: zero discounting

This is an AI proof-repair report, not the author's verdict. The paper already assumes 0 < beta < 1. Requiring strict positivity in the helper aligns it with the source rather than adding a paper assumption. The original report is retained below, including its then-current failed-build status; the final run outcome is recorded separately.

I could not produce a compliant green build because the fixed uniqueness statements are false when `β = 0`, which their hypotheses permit (`0 ≤ β`).

Lean-checked counterexamples:

- `π = 1, β = 0, κ = 0`, inactive prior: operating only at date zero attains `V - κ = 1` but is not `alwaysActive`.
- `π = 1, β = 0, κ = 2`, inactive prior: remaining inactive at date zero and operating later attains `0` but is not `alwaysInactive`.
- The active-state uniqueness result fails analogously.

The counterexamples compiled cleanly with `LEAN_NUM_THREADS=1 lake env lean --stdin` (exit code 0).

I repaired several independent seams in [MainTheorems.lean](/tmp/efw-applied-final/papers/Saco26InstitutionalRestart/MainTheorems.lean): explicit `rpow` positivity, output algebra, payoff bounds, `Summable.tsum_sub`, tail summability, and the infinite Bellman telescope. `Model.lean` was unchanged.

Final forced-build status:

```text
$ LEAN_NUM_THREADS=1 lake build +Saco26InstitutionalRestart.MainTheorems
✖ [3314/3314] Building Saco26InstitutionalRestart.MainTheorems
error: Lean exited with code 1
error: build failed
```

Following the `econcs-prover` guardrail for a false target, I stopped rather than introduce an unsound proof. Completion requires authorizing strict positivity `0 < β` in the generic uniqueness layer—already guaranteed by `Model.beta_pos`—or weakening the `β = 0` conclusions. Both are currently forbidden by the stated contract.