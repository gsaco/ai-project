# Term project — template

**Artificial Intelligence and Economic Modeling · UP 2026-II**

> **This is the template for the term project.** Press **Use this template**,
> name your repository **`ai-project`**, and replace the content. Every project
> in the course has this structure, so that anyone can open any repository and
> find the paper, the slides, the code and the Lean proofs in the same place.
>
> Dates, page limits and what is graded are in the
> [project issue](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/7)
> of the course repository. **Delete this block and the next two sections when
> you write your own README.**

## What goes where

One repository for the whole project: it grows from the topic presentation to
the final paper.

| Path | What it holds | Needed for |
|---|---|---|
| `README.md` | One page: the question, the model, the main result with all its conditions, and the status of the project | always |
| `proposal/proposal.tex` · `.pdf` | The topic document, **2–4 pages** | topic presentation |
| `slides/topic.tex` · `.pdf` | Deck for the 20-minute topic presentation | topic presentation |
| `slides/final.tex` · `.pdf` | Deck for the final presentation | final presentation |
| `paper/paper.tex` · `references.bib` · `paper.pdf` | The final paper, **8–20 pages**, in LaTeX with its compiled PDF | final paper |
| `code/` | Simulations and symbolic checks; `code/verify.py` runs them all and **fails** if a claim does not hold | final paper |
| `lean/` | The Lean formalization of **your** paper, generated with AppliedModelingLib | final paper |
| `hand/` | The handwritten appendix: every derivation, step by step | final paper |
| `prompts.md` | Your prompts and the relevant answers, raw | always |
| `.github/workflows/build.yml` | Compiles the PDFs and runs `code/verify.py` on every push | — leave it as it is |

Keep the file names. If a script, figure or section needs more files, add them
inside the folder where they belong.

Work as in the weekly repositories: **branch → pull request → merge**. Nothing
is written directly to `main`, and what is graded is what is on `main` at the
deadline.

## Building

```bash
python3 -m pip install -r code/requirements.txt
python3 code/verify.py                      # checks + figures

cd paper    && latexmk -pdf paper.tex       # or: tectonic paper.tex
cd proposal && latexmk -pdf proposal.tex
cd slides   && latexmk -pdf topic.tex final.tex
```

**Commit the compiled PDFs** next to their sources. The workflow in
`.github/workflows/` recompiles everything from source on every push: the
green check on your repository is the evidence that the PDF you committed is
the one your LaTeX produces. If the check is red, the Actions tab shows the
LaTeX error.

Every orange **Replace** box in the PDFs is an instruction to you. A submitted
document has none left.

## The Lean component

The target is that **every numbered result of your paper is stated and proved
in Lean**, with no `sorry` and no hypothesis that smuggles in the conclusion.
It is the same workflow as in the weekly repositories, pointed at your own
paper instead of a published one.

1. Merge the version of `paper/paper.pdf` you want formalized and copy the
   commit hash.
2. From the root of your [AppliedModelingLib](https://gargnikhil.com/AppliedModelingLib/)
   clone (`git pull` first), with the same agent configuration as in the weekly
   repositories, give the agent this task:

   ```text
   Please formalize my own paper, an unpublished manuscript with no arXiv
   record: https://github.com/<your-user>/ai-project/blob/<commit>/paper/paper.pdf
   (pinned at commit <commit>), using the paper-formalization skill and
   workflow in this repository.
   Use <Surname>26<ShortTitle> as the paper folder.
   ```

3. Run the paper-scoped check and keep its output:

   ```bash
   python3 scripts/paper_contribution.py check <Surname>26<ShortTitle> --fast
   ```

4. Copy the **entire** generated `papers/<Surname>26<ShortTitle>/` folder,
   exactly as generated, into this repository as `lean/`. Stage it with
   `git add lean/` and respect the generated `.gitignore` — never `git add -f`.
5. Fill in the *Lean formalization* appendix of the paper: one row per numbered
   result, the Lean declaration that proves it, and its status.

If you change a proposition after the run, the Lean folder no longer matches
the paper: run the workflow again. If a result is still open at the deadline,
say exactly which one and what blocks it — an honest partial result is graded,
a hidden gap is not.

---

# Your title

**Replace everything below with your own README — one page.**

*Track A (extension of …) or Track B (thesis model).*

## The question

## The model

The agent's problem, written formally: what is maximised, over which variable,
under which constraints.

## The main result, with all its conditions

## Status

| Component | State |
|---|---|
| Topic document and slides | |
| Final slides | |
| Paper | |
| Simulations (`python3 code/verify.py`) | |
| Lean (`check --fast` result, paper commit formalized) | |
| Handwritten appendix | |
