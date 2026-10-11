# Interactive topic presentation

Open `../topic.html` in a browser. The standalone file embeds fonts, equations, logo, and figures; external reference links alone require internet. Its editable source is `../topic.qmd`. The PDF companion uses the same 14-slide narrative and static versions of the two diagrams.

## Structure and timing

The five homework points appear in order: question (1–2), baseline/model (3–6), FOC/conjecture/comparison (7–12), literature check (13), plan and risks (14). The experiment setup precedes the switching decisions, and the literature review precedes the research plan. [Coverage and 20-minute plan](../../proposal/topic-checklist.md).

## Design and interaction

The palette remains blue `#223F91`, turquoise `#008A92`, orange `#D45D00`, and white, with Libre Franklin headings and Source Sans 3 text. All content is visible immediately; there are no fragments or animated slide transitions.

Slide 9 (`channels`) varies usable property `s` and institutional overhead `c`. Slide 12 (`experiment`) compares small shocks, free restarting, and costly restarting, and allows changes to `d` and `kappa`. Output is conditional on operating in the first diagram and actual output in the second. The examples are illustrative, not calibrated to calendar time or GDP estimates. Presets 2 and 3 use the same shock and change only restart cost.

## Maintained conditions

The initially active firm faces equal one-period shocks with `0 < d < s0` and `s0 + d <= 1`. Restoration is known and permanent from date 1. The experiment holds `c=c0`, technology, and prices fixed. Closing is free, preserves property, and dismantles the organization; financing is available and organization-preserving suspension is excluded. These conditions precede the switching decisions.

The conditional input FOC is unchanged because rebuilding costs do not depend on input. The conjecture also requires `pi0 > 0`, `piMinus + beta*V < 0`, and `kappa > piPlus + beta*V`. The last inequality both prevents restart and excludes entry by an identical inactive owner. Outside this region the explorer still uses the full closure value `beta*max(V-kappa,0)`.

## Build and verification

From the repository root:

```sh
python3 code/verify.py
node slides/reveal/model.test.js
quarto render slides/topic.qmd --to revealjs
node slides/reveal/verify-deck.cjs
```

The Python runner creates static model figures. The browser model is `model.js`; tests compare its examples with the Python exports. `verify-deck.cjs` requires Playwright and Chromium, opens an isolated HTML copy offline, checks all slides/equations and bounds at two viewport sizes, and operates both diagrams. The empirical figure from my thesis has its provenance in `../../figures/README.md`.

[The project guide](../../proposal/topic-checklist.md) records build instructions, source dependencies, topic coverage, and presentation timing. Lean formalization remains future work.

## Public presentation

[Open the presentation on GitHub Pages](https://gsaco.github.io/ai-project/slides/topic.html). Pages publishes the root of `codex/topic-collateral-asymmetry`; pushing an updated `slides/topic.html` to that branch updates the public deck. The root `index.html` redirects visitors to the slides, and `.nojekyll` preserves the generated HTML without Jekyll processing.
