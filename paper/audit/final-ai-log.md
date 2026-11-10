# AI-assisted contributions and author adjudication

The October raw conversation remains unchanged at the start of `prompts.md`; the supplied final-stage export is appended verbatim. `prompts-final.md` also retains the shorter record prepared during development. This table distinguishes an AI contribution, an executable or analytic check, and my own assessment. A successful automated check is not my personal verdict.

| Contribution | Claim | Verification prepared | My independent verdict |
|---|---|---|---|
| Input optimization | The FOC gives a unique global optimum; output is linear in usable property | Derivatives and boundary argument in Lemma 1; symbolic and numerical checks | Pending |
| Closing and reopening | Date-zero closure value is beta max{V − kappa, 0} | Lemma 2, arbitrary delay and repeated-switching argument; enumerated paths with a stationary tail; worksheet | “I accept it.” — November 9; clarified November 10: I suspected an error in the max–min equivalence, which my handwritten calculation confirmed |
| Strict asymmetry | The three stated inequalities imply permanent adverse closure and strict loss–gain dominance | Proposition 1 proof and matched free-restart calculation | Pending |
| Switching regions | Closure threshold depends on min{kappa, V}; higher restart cost can discourage current closure | Proposition 2 and 168-point independent enumeration | Pending |
| Suspension | If preservation costs less than beta V, suspension removes persistence | Proposition 3 and 151 preservation-cost checks | Pending |
| Positive totals and logs | Strict level asymmetry implies strict log asymmetry for the specified positive totals | Corollary 1 proof and numerical checks within the proposition region | Pending |
| Generic uniqueness helper | AI initially allowed beta = 0 while claiming a unique entire activity path; a counterexample refutes that helper | [Original repair report](ai-beta-zero-finding.md); correction uses the paper's existing beta > 0 restriction | Pending independent reconstruction and verdict |
| Formalization | Only the actually checked declarations and audited scope support a Lean verification claim | AppliedModelingLib run against a pinned paper; exact check report and source map | Pending author review of the scope |

The selected independent check is the second row. My [original handwritten revision](../../hand/final/handwritten-revision-2026-11-09.png) and [verbatim verdict](../../hand/final/verdict.md) were supplied on November 9, 2026. The photograph explicitly ranks delayed reopening when V > kappa and records the maximum-value and closure-comparison formulas. It does not separately work out the equality, V < kappa, or beta = 0 cases. My acceptance is not represented as an independent handwritten proof of those omitted cases or as adjudication of every other AI contribution.

On November 10, I identified the specific doubt: the equivalence between the max and min expressions in the continuation-minus-closure calculation. The [assessment record](../../hand/final/verdict.md) preserves my original wording and the identity shown in my handwritten work. This clarifies my verdict on that step; the other pending rows remain separate.
