<h1 align="center">Temporary Institutional Shocks, Firm Closure, and Costly Reopening</h1>

<p align="center">
  <strong>Gabriel Saco</strong><br>
  Professor Alexander Quispe · Universidad del Pacífico<br>
  <sub>AI and Economic Modeling · Track B · Final paper · November 24, 2026</sub>
</p>

<p align="center"><strong><a href="paper/paper.pdf">Read the final paper</a></strong> · <a href="paper/paper.tex">LaTeX source</a></p>

<p align="center">
  <a href="slides/final.pdf"><img src="figures/final-button.svg" width="230" alt="Read the final presentation PDF"></a>
  <a href="https://gsaco.github.io/ai-project/slides/final.html"><img src="figures/presentation-button.svg" width="286" alt="Open the interactive presentation"></a>
  <a href="proposal/proposal.pdf"><img src="figures/proposal-button.svg" width="160" alt="Read the proposal PDF"></a>
  <a href="slides/topic.pdf"><img src="figures/slides-button.svg" width="160" alt="Read the slides PDF"></a>
</p>

<p align="center">
  <a href="https://chatgpt.com/s/cx_6acbfdd3fe208191925b8c885b7b051e">AI conversation</a> &nbsp;·&nbsp;
  <a href="prompts.md">Raw prompts</a> &nbsp;·&nbsp;
  <a href="proposal/topic-checklist.md">Reading and build guide</a>
</p>


---

> **Question** · Can equal temporary institutional improvements and deteriorations generate unequal output gains and losses?

<p align="center"><a href="figures/paper_main_figure.pdf"><img src="figures/paper_main_figure.png" width="600" alt="Motivating thesis evidence: GDP responses with symmetry imposed and asymmetry allowed."></a></p>

*Thesis evidence motivating the model. [Measurement and confidence bands](figures/README.md).*

## Model and conditional result

The initially active firm chooses activity $`a_t\in\{0,1\}`$ and input $`x_t\geq0`$; input is zero when closed. Usable property is $`s_t\bar k`$, with fixed $`\bar k=1`$. Output price is one:

```math
\max_{\{a_t,x_t\}}\sum_{t\geq0}\beta^t
\left[As_t^{1-\alpha}x_t^\alpha-wx_t-(F+c_0)a_t-\kappa a_t(1-a_{t-1})\right].
```

Maintain $`A,w,F>0`$, $`c_0\geq0`$, $`0<\alpha,\beta<1`$, and $`a_{-1}=1`$. All prices, technology and costs are fixed across paths. Financing is available; input does not affect future states. Closure is free, has no salvage, preserves physical property and dismantles the organization. Inactivity pays zero; every restart costs $`\kappa\geq0`$. The main model excludes organization-preserving suspension, entry and reallocation.

At date zero compare $`s_0-d`$, $`s_0`$ and $`s_0+d`$, with $`0<d<s_0`$ and $`s_0+d\leq1`$. All paths return permanently to $`s_0`$ at date one, as known in advance; $`c=c_0`$ throughout.

The input FOC is $`\alpha As^{1-\alpha}x^{\alpha-1}=w`$. It yields $`q(s)=sA(\alpha A/w)^{\alpha/(1-\alpha)}`$ and $`\pi(s,c_0)=(1-\alpha)q(s)-F-c_0`$. Write $`q_0=q(s_0)`$, $`\pi_0=\pi(s_0,c_0)`$ and $`\pi_-=\pi(s_0-d,c_0)`$.

**Proposition 1.** Under these maintained assumptions, if

```math
\pi_0>0,\qquad \pi_-+\beta V<0,\qquad \kappa>V,
\qquad V=\frac{\pi_0}{1-\beta},
```

only the adverse firm closes, and it never restarts. Relative to no change, impact loss $`q_0`$ exceeds gain $`(d/s_0)q_0`$; later the loss remains $`q_0`$ and the gain is zero. With free restarting the same impact closure occurs, but production recovers at date one. With a milder restriction, a higher rebuilding cost can keep the firm open in the first place. **Proposition 2** quantifies the incentive. The value of preserving the organization is $`\beta\min\{\kappa,V\}`$, which stops growing once rebuilding costs reach the value of the restored business. Affordable suspension at $`h<\beta V`$ removes persistence under the conditions of Proposition 1.

## Materials and status

| Material | Files | Status |
|:--|:--|:--|
| Final paper | [PDF](paper/paper.pdf) · [LaTeX](paper/paper.tex) | 14 pages through the conclusion. Appendix C reproduces the two original photographs. |
| Final presentation | [PDF](slides/final.pdf) · [LaTeX](slides/final.tex) · [Interactive HTML](https://gsaco.github.io/ai-project/slides/final.html) · [Quarto](slides/final.qmd) | 26 talk slides + 3 backups; handwritten revision and acceptance included |
| Numerical checks | [Instructions](code/README.md) · [Results](code/output/verification.json) | Four manuscript figures and two model tables reproduced. Includes the original Stata estimates and four exact decision cutoffs. |
| Lean | [Final proof record](paper/audit/lean-run.md) · [Proof files](lean/ProofInterface.lean) | Six numbered results and the joint-to-reduced proof compile. Full build, paper-scoped fast check, and ten axiom inspections passed on November 26. [Current verification](paper/audit/final-paper-lean-check.txt). |
| Independent review | [Worksheet](hand/final/independent-check.md) · [Adjudication record](paper/audit/final-ai-log.md) | Author's slide correction, handwritten max–min check, and verdicts recorded. Two handwritten pages cover input choice, restart values and the main decision thresholds. [Handwritten coverage](hand/README.md). |
| October submission | [Proposal](proposal/proposal.pdf) · [Topic PDF](slides/topic.pdf) · [Interactive topic](https://gsaco.github.io/ai-project/slides/topic.html) | Preserved earlier submission |
| AI collaboration | [Raw conversation log](prompts.md) | AI explanations distinguished from my own assessment |

The [interactive final presentation](https://gsaco.github.io/ai-project/slides/final.html) is self-contained: download it and open it in a browser. The [course checklist](paper/audit/final-presentation-checklist.md) maps the eight required presentation points to slides; the [November presentation review](paper/audit/branch-review.md) records work at that stage. The final submission includes the paper, both presentation decks, reproducible numerical checks, Lean proofs, handwritten derivations, and the AI collaboration record. Entry, heterogeneous-firm equilibrium, and empirical calibration are extensions beyond this paper’s scope. [Course requirements](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/7).
