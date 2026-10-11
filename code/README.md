# Topic-stage verification

Run from the repository root:

```sh
python3 -m pip install -r code/requirements.txt
python3 code/verify.py
```

The runner checks this project's firm model and exits unsuccessfully if an assertion fails. It generates `code/output/verification.json`, `slides/figures/topic_examples.json`, and the two model PDFs used in the topic deck.

- Symbolically differentiates the primitive operating objective.
- Checks the input solution against a numerical grid and the FOC.
- Reproduces the illustration: normal output 0.80, normal profit 0.01, adverse profit −0.15, favorable profit 0.17, and normal value 0.10.
- Tests small shocks, free restart, costly restart, and the overhead channel.
- Independently enumerates all activity paths for four periods, with an exact stationary continuation value, across 324 scenario problems. Compares their maximum values with the closure/restart solution.
- Checks the loss–gain and positive-aggregate log comparisons inside the conjecture region.
- Checks that a cheap organization-preserving suspension option defeats permanent closure in the illustration.

`firm_model.py` supplies the Python model. The browser model remains in `slides/reveal/model.js`; its own tests and a cross-version comparison guard their agreement. The empirical figure in `figures/` comes from my thesis; its provenance is recorded there. This runner verifies the theoretical model and does not replicate the empirical estimates.

These finite calculations support the topic conjecture. They are not proofs over all parameter values, a completed final-paper replication, or Lean verification.
