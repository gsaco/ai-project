# Topic presentation: reading and build guide

Reference: [homework issue #7](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/7), checked 11 October 2026. Scope: topic presentation. Final-paper requirements remain future work.

## Coverage in order

| Topic item | Proposal | Both topic decks |
|---|---|---|
| Question and Track B | Section 1 | Slides 1–2 |
| Baseline, changed assumption, complete problem | Section 2 | Slides 3–6 |
| Expected FOC, conditional conjecture, direction of change | Section 3 | Slides 7–12 |
| Literature search and findings | Section 4 | Slide 13 |
| Proof, simulation, Lean, most fragile step | Section 5 | Slide 14 |

The proposal is four pages, 11 pt, with one-inch margins. The static PDF and interactive deck share the same 14-slide sequence. The cover links the repository. Equations are typeset, slide transitions and fragments are disabled, and controls only update the two diagrams. The literature review distinguishes the sources reviewed from materials still to be obtained.

## Rebuild locally

```sh
python3 -m pip install -r code/requirements.txt
python3 code/verify.py
node slides/reveal/model.test.js
quarto render slides/topic.qmd --to revealjs
(cd proposal && latexmk -pdf proposal.tex)
(cd slides && latexmk -pdf topic.tex && latexmk -pdf final.tex)
(cd paper && latexmk -pdf paper.tex)
node slides/reveal/verify-deck.cjs
```

Tectonic is also supported for each TeX file when run in that file's directory. Quarto is needed only to rebuild the HTML. The browser check additionally needs Playwright and Chromium. Generated PDFs remain next to the sources. Figures, logo, fonts, and browser assets must accompany the source files. The course workflow in `.github/workflows/build.yml` is unchanged.

## Build validation: 11 October 2026

All four PDFs compile with Tectonic, and Quarto renders the standalone interactive deck. The proposal has four pages with one-inch margins. The topic PDF has 14 slides in 16:9 format. The final TeX passes have no unresolved references or overfull boxes. All PDF pages have been visually inspected.

The model checks pass: 10 Python checks, including 324 enumerated switching problems, and 13 browser-model checks. The HTML also passes offline rendering, equation, navigation, diagram, and layout checks at two viewport sizes. These checks support reproducibility; my independent adjudication and formal proofs remain pending.

The equivalent Tectonic commands, run from each source directory, are `tectonic -X compile proposal.tex`, `tectonic -X compile topic.tex`, `tectonic -X compile paper.tex`, and `tectonic -X compile final.tex`. Local previews and layout-audit files are excluded from version control.

## Twenty-minute topic slot

| Slides | Minutes | Purpose |
|---|---:|---|
| 1–3 | 2.5 | Question, empirical pattern, institutional channels |
| 4–6 | 3.5 | Technology, matched experiment, complete firm problem |
| 7–8 | 2.5 | FOC and profit derivation |
| 9 | 1 | Isolate the two channels interactively |
| 10–11 | 3 | Closure, restarting, and conjecture |
| 12 | 1.5 | Free versus costly restart |
| 13 | 1.5 | Established results and contribution |
| 14 | 1.5 | Plan and risk |
| Discussion | 3 | Total slot: 20 minutes |

## Research records and later work

`README.md` gives the model, full conditions, and status. `prompts.md` preserves the raw conversation export, including my prompts and the corresponding AI responses. My independent adjudication remains pending. The paper and final deck are explicitly labelled project-specific progress files; they are not final deliverables. Lean proofs and handwritten scans remain unfinished.

The [public interactive presentation](https://gsaco.github.io/ai-project/slides/topic.html) supplements the required LaTeX and PDF deck. The course build workflow compiles all four PDFs and runs the model checks on GitHub.
