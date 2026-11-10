# Independent check: closing while retaining the option to reopen

This is an AI-prepared worksheet, not Gabriel's handwritten derivation or verdict.

## Claim to check

At date zero, closing is worth beta max{V − kappa, 0}, not always zero. Here V = pi0/(1 − beta), pi0 > 0, and 0 < beta < 1. The firm knows that normal conditions return permanently at date one.

## Work through this by hand

1. Write the cash flows from restarting at date one: pay kappa at date one and receive pi0 at dates one, two, three, … . Sum their value at date one, obtaining V − kappa. State why the geometric series converges.
2. Restart instead at date 1+n, n a nonnegative integer. Discount the same cash flows to date one: beta^n(V − kappa). Explain why any path that ever reopens has a first reopening date: dates are nonnegative integers.
3. Include never restarting, with value zero. Separate V − kappa > 0, V − kappa = 0, and V − kappa < 0. In the negative case, delayed negative values approach zero, but the never-restart choice actually attains zero.
4. Explain why repeated reopening and closing cannot improve the value: restored operating profit is positive, and closure would forgo positive profits and possibly require another nonnegative restart payment.
5. Convert the maximum date-one value to date zero: multiply by beta once. Closing has zero current payoff because closure is free, produces nothing, avoids operating costs, and has no salvage payment. Compare it with continuing, piMinus + beta V.
6. Check two examples using pi0 = 0.01 and beta = 0.9. For kappa = 0, closing is worth 0.09. For kappa = 0.4, it is worth zero. With d = 0.2, continuing is worth −0.06 in both examples.
7. Give your own assessment: Is the claim correct? Which tempting shortcut would be incorrect? Which assumptions are essential? Describe how your calculation changed or confirmed your view.
8. Check a concrete error found in an AI-generated Lean helper: it allowed beta = 0 while claiming uniqueness of the entire future activity path. At beta = 0, show that two paths with the same current action but different later actions have equal discounted value. Explain why the paper's existing strict condition beta > 0 rules out this counterexample. This is a correction to the generated helper, not a new assumption added to the paper.

## Materials for the final slide

Save or attach legible photographs/scans of your own derivation, and provide your verdict in your own words. Suggested filenames: derivation-01.png (or .pdf) and verdict.md. Keep names and notes legible at presentation size. The slide must show actual handwritten work; this worksheet cannot substitute for it.

Status updated November 9, 2026: the original handwritten revision and the author's verbatim verdict, ‘I accept it,’ are supplied. The worksheet remains the original AI-prepared guide; the photograph does not independently write out every case requested above.
