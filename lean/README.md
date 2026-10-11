# Planned formalization

Lean formalization remains future work. My first targets are:

1. State parameter ranges and the known institutional paths.
2. Prove the value identity `(1 - beta) * V = pi0` and the switching comparisons.
3. Prove that delay cannot improve on immediate profitable restarting or make a negative stationary restart value profitable.
4. Establish the conditional output inequalities, then the optimizer and positive-aggregate log result.

For the final paper, I will use AppliedModelingLib with a pinned paper commit and place the complete generated paper folder here, preserving its ignore rules. I will record the declarations, exact assumptions, paper commit, and verification output. Each numbered result is a formalization target; proofs must contain no `sorry`, and unresolved results will be marked open. Numerical checks are recorded separately from Lean proofs.
