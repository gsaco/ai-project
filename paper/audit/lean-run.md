# Formal verification of the final paper

The six numbered results and the equivalence of the primitive and reduced optimization problems compiled together on November 19, 2026. The latter proof accounts for feasible input paths with arbitrarily large losses. A joint optimum exists under the paper's normal-viability assumption. The paper-scoped fast check passed. Full independent certification of the correspondence between the formalization and the manuscript remains outstanding. [Build output, source hashes and axiom inspection](joint-reduction-check.txt)

The [November 26 verification](final-paper-lean-check.txt) records the current manuscript and PDF fingerprints, hashes of every Lean source and the combined root module, a fresh proof build, the required fast check, and all ten axiom inspections. All checks passed against proof files identical to the submitted files; the six numbered statements and assumptions A1–A6 match the original formalized manuscript byte-for-byte. The [full build output](final-paper-lean-build-nov26.txt) preserves the compiler messages. The archived generated package matches the original copy manifest. The final package adds JointReduction.lean.

## What the new proof establishes

For any of the three shock paths, fix an arbitrary sequence of operating and closure decisions. The discounted reduced payoff is summable. Each feasible input choice can only lower the period's payoff relative to the conditional optimum. Taking limits gives a finite joint value or a value of minus infinity. Setting the input to its conditional optimum on operating dates attains the reduced payoff on that same activity path.

| Claim in the final paper | Declaration in the joint reduction |
|---|---|
| Discounted primitive partial sums converge to their stated extended-real value | `jointValue_is_limit` |
| The primitive and reduced programs have the same supremum | `joint_reduction` |
| A plan maximizes the primitive program exactly when its activity path is optimal and it attains that path's reduced payoff | `jointPlan_optimal_iff` |
| An optimum exists under normal viability on each shock path | `jointMaximum_exists` |

The new file uses the original period payoffs, feasible activity paths, and operating optimum. The six existing theorem statements and proofs use the same source bytes as the November 8 inspection. The final TeX also preserves the exact text of the six numbered statements and assumptions A1–A6. The combined check of the six original and four new declarations reported only `propext`, `Classical.choice`, and `Quot.sound`. [Joint reduction](../../lean/JointReduction.lean) · [Original source hashes](endpoint-axioms-result.json) · [Current check](joint-reduction-check.txt)

## Reproduction

The November 19 build used Lean `v4.30.0-rc2` and an isolated checkout at the archived local AppliedModelingLib revision `e7787eaad6c962d2727ab92e0a76d7d710000980`. To reconstruct that environment from the upstream base, check out `194edcc95df74806a39b961d10dedddc6e730cce` and apply the [recorded patch](applied-modeling-lib-local.patch). Install the library's pinned dependencies. Copy the contents of the project's [Lean folder](../../lean/) into `papers/Saco26InstitutionalRestart/`. Copy the [combined root module](Saco26InstitutionalRestart.lean) into `papers/Saco26InstitutionalRestart.lean`. From the library root run

```sh
lake build +Saco26InstitutionalRestart
python3 scripts/paper_contribution.py check Saco26InstitutionalRestart --fast
```

To inspect the axiom dependencies, create a Lean file with the `import` and `#print axioms` lines in the [November 19 check record](joint-reduction-check.txt) and pass it to `lake env lean`. The fast check builds the statement interface and checks isolation. The full build compiles the proofs.

## November 8 records

The original run used the [merged paper at a15ed978](https://github.com/gsaco/ai-project/tree/a15ed978282156ba72928ad23940860cccda6f28), `gpt-5.6-sol` at `xhigh`, and the library environment above. The saved [source hashes](source-version.json), [environment record](formalization-environment.json), and [copy manifest](lean-copy-manifest.json) identify that earlier snapshot.

The [original proof build](lean-proof-build.txt), [fast check](lean-fast-check-result.json), and [axiom inspection](endpoint-axioms-check.txt) cover the six numbered results. The [preliminary source review](preliminary-lean-review.md) recorded twelve matches. The extended independent audit [stopped](audit-stop-record.json) before certification. The new mathematical proof addresses the joint-program gap named in those historical reports. The [author's assessment](final-ai-log.md) records the separate personal review.
