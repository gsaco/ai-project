# Economic freedom and firm entry–exit decisions

**Gabriel Saco · Track B: thesis model · Professor Alexander Quispe**  
AI and Economic Modeling · Topic stage · October 2026

[![Interactive presentation — HTML](figures/presentation-button.svg)](slides/topic.html)

[Proposal PDF](proposal/proposal.pdf) · [Slides PDF](slides/topic.pdf) · [Shared AI conversation](https://chatgpt.com/s/cx_6acbf869e28c819197601b5a0bfac041)

<sub>The interactive deck is a standalone HTML file. On GitHub, download it and open it in a browser to use the diagrams.</sub>

**1 · Question and Track B.** Can costly restarting make losses from institutional deterioration exceed gains from equal improvements? I develop a firm model behind my thesis.

<p align="center">
  <a href="figures/paper_main_figure.pdf"><img src="figures/paper_main_figure.png" width="620" alt="Thesis estimates of cumulative log real GDP per capita responses: symmetry imposed on the left, and improvement and deterioration estimated separately on the right, with confidence bands."></a>
</p>

<sub>Thesis: cumulative log GDP-per-capita responses. Left: symmetry imposed; right: asymmetry allowed. [Shock definition and confidence bands](figures/README.md). The figure motivates the mechanism.</sub>

**2 · Model and baseline.** Normalize fixed property to $\bar k=1$; $s$ is its usable share. The initially open firm chooses activity $a_t\in\{0,1\}$ and input $x_t\geq0$ ($x_t=0$ when closed) to maximize

$$\sum_{t=0}^{\infty}\beta^t\left[As_t^{1-\alpha}x_t^\alpha-wx_t-(F+c_0)a_t-\kappa a_t(1-a_{t-1})\right].$$

Productivity $A$, input price $w$, and ordinary overhead $F$ are positive; institutional overhead $c_0\geq0$; $0<\alpha,\beta<1$; and $a_{-1}=1$. **Baseline:** $\kappa=0$. **Extension:** sunk restart cost $\kappa>0$. Closure is free, preserves property, and dismantles the organization. Financing is available; organization-preserving suspension is excluded. Compare $s_0-d$, $s_0$, and $s_0+d$ at date 0, with $0<d<s_0$ and $s_0+d\leq1$. All paths return permanently to $s_0$ from date 1, as known in advance; all other parameters stay fixed.

**3 · Expected result.** The FOC stays $\alpha As^{1-\alpha}x^{\alpha-1}=w$: restarting costs are independent of input. Define $q(s)=sA(\alpha A/w)^{\alpha/(1-\alpha)}$, $\pi(s,c)=(1-\alpha)q(s)-F-c$, $q_0=q(s_0)$, $\pi_0=\pi(s_0,c_0)$, $\pi_\pm=\pi(s_0\pm d,c_0)$, and $V=\pi_0/(1-\beta)$. My conjecture requires

$$\pi_0>0,\qquad \pi_-+\beta V<0,\qquad \kappa>\pi_++\beta V.$$

Deterioration causes permanent closure; the other paths stay open. Identical inactive owners facing the same setup cost stay out. Impact loss $q_0$ exceeds gain $(d/s_0)q_0$; thereafter loss remains $q_0$ while gain vanishes. Costly restarting changes the baseline’s **full recovery into a persistent shortfall**. A proof outline and numerical checks support this conditional conjecture.

**4 · Literature.** I apply Dixit’s established mechanism to institutional changes. The [review](proposal/literature-check.md) records inspected papers and appendices, unavailable materials, and the proposed contribution.

**5 · Plan and risk.** I will prove the optimizer and switching comparisons, simulate alternative shocks, and formalize the results in Lean. **Cheap suspension** can eliminate persistence.

| Required component | Project status |
|---|---|
| [Topic document: source](proposal/proposal.tex) / [PDF](proposal/proposal.pdf) | Four pages; 11 pt; one-inch margins |
| [Topic slides: source](slides/topic.tex) / [PDF](slides/topic.pdf) / [interactive](slides/topic.html) | 14 slides; 20-minute plan; five topic points in order |
| [Final paper](paper/paper.tex) · [bibliography](paper/references.bib) · [PDF](paper/paper.pdf) | Progress document; final paper remains future work |
| [Final slides: source](slides/final.tex) / [PDF](slides/final.pdf) | Planning deck; final presentation remains future work |
| [Code and verification](code/README.md) | 10 Python checks and 13 presentation-model checks pass |
| [Lean](lean/README.md) · [handwritten derivations](hand/README.md) | Planned; proofs and scans remain future work |
| [Raw prompts and AI responses](prompts.md) | Conversation recorded; my independent adjudication is pending |

[Build guide and topic coverage](proposal/topic-checklist.md) · [Homework](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/7). **Submission pending:** branch → PR → merge and repository-link comment. Deadline: **October 13, 22:00 Lima**. Presentation: October 14, 07:55–08:15.
