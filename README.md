<h1 align="center">Economic freedom and firm entry–exit decisions</h1>

<p align="center">
  <strong>Gabriel Saco</strong><br>
  Professor Alexander Quispe · Universidad del Pacífico<br>
  <sub>AI and Economic Modeling · Track B · Topic presentation · October 2026</sub>
</p>

<p align="center">
  <a href="https://gsaco.github.io/ai-project/slides/topic.html"><img src="figures/presentation-button.svg" width="286" alt="Open the interactive presentation"></a>
  <a href="proposal/proposal.pdf"><img src="figures/proposal-button.svg" width="160" alt="Read the proposal PDF"></a>
  <a href="slides/topic.pdf"><img src="figures/slides-button.svg" width="160" alt="Read the slides PDF"></a>
</p>

<p align="center">
  <a href="https://chatgpt.com/s/cx_6acbfdd3fe208191925b8c885b7b051e">AI conversation</a> &nbsp;·&nbsp;
  <a href="prompts.md">Raw prompts</a> &nbsp;·&nbsp;
  <a href="proposal/topic-checklist.md">Reading and build guide</a>
</p>

---

> **Research question** · Can costly restarting make losses from institutional deterioration exceed gains from equal improvements?

<p align="center">
  <a href="figures/paper_main_figure.pdf"><img src="figures/paper_main_figure.png" width="660" alt="Thesis estimates of cumulative log GDP-per-capita responses: symmetry imposed on the left and asymmetry allowed on the right, with confidence bands."></a>
</p>

*Thesis evidence motivating the model: cumulative log GDP-per-capita responses, with symmetry imposed (left) and asymmetry allowed (right). [Measurement and confidence bands](figures/README.md).*

## 01 · Model and experiment

Normalize fixed property to $`\bar{k}=1`$. Institutions determine its usable share $`s\in(0,1]`$ and recurring overhead $`c_0`$. The initially active firm chooses whether to operate, $`a_t\in\{0,1\}`$, and input $`x_t\geq0`$, with $`x_t=0`$ when closed:

```math
\max_{\{a_t,x_t\}_{t\geq0}}\;\sum_{t=0}^{\infty}\beta^t
\bigl[As_t^{1-\alpha}x_t^\alpha-wx_t-(F+c_0)a_t-\kappa a_t(1-a_{t-1})\bigr].
```

Productivity $`A`$, input price $`w`$, and ordinary overhead $`F`$ are positive; $`c_0\geq0`$, $`0<\alpha,\beta<1`$, and $`a_{-1}=1`$. **Baseline:** free restarting, $`\kappa=0`$. **Extension:** a sunk restart cost, $`\kappa>0`$. Closure is free, preserves property, and dismantles the organization. Financing is available; suspension that preserves the organization is excluded.

Compare $`s_0-d`$, $`s_0`$, and $`s_0+d`$ at date 0, where $`0<d<s_0`$ and $`s_0+d\leq1`$. All paths return permanently to $`s_0`$ from date 1, as known in advance. All other parameters remain fixed.

## 02 · Conditional result

Restart costs do not depend on input, so the **FOC is unchanged**:

```math
\alpha As^{1-\alpha}x^{\alpha-1}=w.
```

Define operating output, profit, and continuation value:

```math
\begin{aligned}
q(s)&=sA\left(\frac{\alpha A}{w}\right)^{\alpha/(1-\alpha)},
&\pi(s,c)&=(1-\alpha)q(s)-F-c,\\
q_0&=q(s_0), &\pi_0&=\pi(s_0,c_0),\\
\pi_\pm&=\pi(s_0\pm d,c_0), &V&=\frac{\pi_0}{1-\beta}.
\end{aligned}
```

Under the assumptions above, my conjecture requires:

```math
\pi_0>0,\qquad \pi_-+\beta V<0,\qquad \kappa>V.
```

Deterioration causes permanent closure; the other paths stay open. The impact loss $`q_0`$ exceeds the gain $`(d/s_0)q_0`$; thereafter the loss remains $`q_0`$ while the gain vanishes. Costly restarting changes **full recovery into a persistent shortfall**. The proposal contains a proof outline; numerical checks support the illustration, not a general proof.

## 03 · Literature and research plan

I apply Dixit’s established sunk-cost mechanism to institutional changes. The [literature review](proposal/literature-check.md) records inspected sources, unavailable materials, and the contribution. I will prove the optimizer and switching comparisons, simulate alternative shocks, and formalize the results in Lean. **Cheap suspension is the principal risk:** it can eliminate persistence.

## 04 · Repository guide

| Material | Read or explore | Status |
|:--|:--|:--|
| **Topic proposal** | [PDF](proposal/proposal.pdf) · [LaTeX](proposal/proposal.tex) | Four pages; model, derivations, and conjecture |
| **Topic presentation** | [Interactive](https://gsaco.github.io/ai-project/slides/topic.html) · [PDF](slides/topic.pdf) · [LaTeX](slides/topic.tex) | 14 slides; 20-minute plan |
| **Verification** | [Code and checks](code/README.md) | 10 Python checks and 13 presentation-model checks pass |
| **Final paper** | [PDF](paper/paper.pdf) · [LaTeX](paper/paper.tex) · [References](paper/references.bib) | Research outline; development continues |
| **Final presentation** | [PDF](slides/final.pdf) · [LaTeX](slides/final.tex) | Planning deck |
| **Formal and hand proofs** | [Lean plan](lean/README.md) · [Derivation plan](hand/README.md) | Future work |
| **AI collaboration** | [Raw conversation](prompts.md) | Recorded; my independent adjudication remains pending |

<sub>Topic-stage research: the current result is a conditional conjecture with a proof outline and reproducible checks. Complete proofs, Lean formalization, and the final paper remain future work. <a href="https://github.com/alexanderquispe/AI-Econ-Modeling/issues/7">Course requirements</a>.</sub>
