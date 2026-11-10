# Lean formalization run

Six formal counterparts compile, and the professor's required fast check passed. Full source-correspondence certification is incomplete. The formalization covers the conditional input problem and the reduced infinite-horizon activity model; it does not yet prove their equivalence to the original joint optimization problem.

## Source and environment

- Merged paper: `a15ed978282156ba72928ad23940860cccda6f28`, through [PR 9](https://github.com/gsaco/ai-project/pull/9).
- Exact paper hashes: [source-version.json](source-version.json). The current paper adds a reporting appendix and updates the author-evidence status; [body preservation](source-body-preservation.json) records that all mathematical statements, assumptions, and proofs are unchanged.
- AppliedModelingLib base: `194edcc95df74806a39b961d10dedddc6e730cce`; local run HEAD and patch hash: [environment record](formalization-environment.json).
- Actual agent: `gpt-5.6-sol`, `xhigh`; Lean `leanprover/lean4:v4.30.0-rc2`.
- Paper identifier: `Saco26InstitutionalRestart`.

The initial pull fetched upstream but refused to overwrite unrelated local changes. An isolated worktree at the fetched revision preserved the original checkout. Existing downloaded dependencies were reused.

## Actual outcomes

- [Full proof build](lean-proof-build.txt): successful, all six endpoints compiled.
- [Required fast check](lean-fast-check.txt): exit 0; [machine-readable outcome](lean-fast-check-result.json). The command checks the statement build and isolation. It does not itself establish the proof-body or full semantic coverage claims; those require the separate proof build and further review.
- [Independent axiom inspection](endpoint-axioms-check.txt): all six endpoints report only `propext`, `Classical.choice`, and `Quot.sound`, with no `sorryAx` or custom axiom. [Source hashes](endpoint-axioms-result.json) match the packaged Lean files.
- [Preliminary source review](preliminary-lean-review.md): 12 matches, no mismatches or uncertain rows. This context-isolated review is diagnostic, not a terminal acceptance receipt.
- [Stop record](audit-stop-record.json): the author requested simplification if the longer code/audit work did not finish. The extended audit stopped before certification. No accepted final semantic audit is claimed.

The remaining formal gap is the joint-to-reduced program equivalence, including unoptimized feasible plans with value minus infinity. No additional economic condition was imposed to complete the six formal counterparts. The source already assumes strictly positive discounting.

## Reproduce the checked development

Use the base AppliedModelingLib revision above in a separate checkout. Apply [the exact local patch](applied-modeling-lib-local.patch), copy the project's entire `lean/` folder to `papers/Saco26InstitutionalRestart/`, and copy [the root module](Saco26InstitutionalRestart.lean) to `papers/Saco26InstitutionalRestart.lean`. Restore the pinned source bytes from the identified paper when a source audit requires ignored local inputs. Install dependencies using the library's documented setup, then run:

```sh
lake build +Saco26InstitutionalRestart
python3 scripts/paper_contribution.py check Saco26InstitutionalRestart --fast
```

The patch registers the target, records the engine revision, avoids an unsupported macOS address-space operation while retaining Lean's memory limit, and raises an extraction timeout. It changes no economic statement. Focused subprocess tests are retained in [the test output](lean-environment-tests.txt).

The generated paper folder is copied verbatim, including its own `.gitignore`; [the manifest](lean-copy-manifest.json) checks every copied byte. Build caches are excluded from Git without force-adding ignored source inputs. Generated plans and unfinished audit sidecars remain provenance, not certification.

## Independent author review

The [beta-zero finding](ai-beta-zero-finding.md) refutes an early AI-generated uniqueness helper, not the paper's strict discount assumption. The [original handwritten closure-value derivation](../../hand/final/handwritten-revision-2026-11-09.png) and [verbatim acceptance](../../hand/final/verdict.md) were supplied on November 9, 2026. The full handwritten appendix and reasoned assessments of other AI contributions remain open. The copied Lean folder records the earlier formalization run; its historical author-evidence status is not the current presentation status.
