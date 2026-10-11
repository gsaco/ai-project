# Economic freedom and firm entry–exit decisions

**Gabriel Saco** · Professor Alexander Quispe  
AI and Economic Modeling · **Track B: the model behind my thesis** · October 2026

[![Open the interactive presentation](figures/presentation-button.svg)](https://gsaco.github.io/ai-project/slides/topic.html)

[Read the proposal](proposal/proposal.pdf) · [Download the slides](slides/topic.pdf) · [AI conversation](https://chatgpt.com/s/cx_6acbfdd3fe208191925b8c885b7b051e) · [Raw prompts](prompts.md)

> **Research question** · Can costly restarting make losses from institutional deterioration exceed gains from equal improvements?

<p align="center">
  <a href="figures/paper_main_figure.pdf"><img src="figures/paper_main_figure.png" width="660" alt="Thesis estimates of cumulative log GDP-per-capita responses: symmetry imposed on the left and asymmetry allowed on the right, with confidence bands."></a>
</p>

*Thesis evidence motivating the model: cumulative log GDP-per-capita responses, with symmetry imposed (left) and asymmetry allowed (right). [Measurement and confidence bands](figures/README.md).*

## Model and experiment

Normalize fixed property to $`\bar{k}=1`$. Institutions determine its usable share $`s`$ and recurring overhead $`c_0`$. The initially active firm chooses whether to operate, $`a_t\in\{0,1\}`$, and input $`x_t\geq0`$, with $`x_t=0`$ when closed:

```math
\max_{\{a_t,x_t\}_{t\geq0}}\;\sum_{t=0}^{\infty}\beta^t
\bigl[As_t^{1-\alpha}x_t^\alpha-wx_t-(F+c_0)a_t-\kappa a_t(1-a_{t-1})\bigr].
```

Productivity $`A`$, input price $`w`$, and ordinary overhead $`F`$ are positive; $`c_0\geq0`$, $`0<\alpha,\beta<1`$, and $`a_{-1}=1`$. **Baseline:** free restarting, $`\kappa=0`$. **Extension:** a sunk restart cost, $`\kappa>0`$. Closure is free, preserves property, and dismantles the organization. Financing is available; suspension that preserves the organization is excluded.

Compare $`s_0-d`$, $`s_0`$, and $`s_0+d`$ at date 0, where $`0<d<s_0`$ and $`s_0+d\leq1`$. All paths return permanently to $`s_0`$ from date 1, as known in advance. All other parameters remain fixed.

## Conditional result

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
\pi_0>0,\qquad \pi_-+\beta V<0,\qquad \kappa>\pi_++\beta V.
```

Deterioration causes permanent closure; the other paths stay open. Identical inactive owners facing the same setup cost stay out. The impact loss $`q_0`$ exceeds the gain $`(d/s_0)q_0`$; thereafter the loss remains $`q_0`$ while the gain vanishes. Costly restarting changes **full recovery into a persistent shortfall**. The proposal contains a proof outline; numerical checks support the illustration, not a general proof.

## Literature, plan, and risk

I apply Dixit’s established sunk-cost mechanism to institutional changes. The [literature review](proposal/literature-check.md) records inspected sources, unavailable materials, and the contribution. I will prove the optimizer and switching comparisons, simulate alternative shocks, and formalize the results in Lean. **Cheap suspension is the principal risk:** it can eliminate persistence.

## Deliverables and status

| Component | Files and current status |
|:--|:--|
| **Topic proposal** | [PDF](proposal/proposal.pdf) · [LaTeX](proposal/proposal.tex) — four pages, 11 pt, one-inch margins |
| **Topic presentation** | [Live](https://gsaco.github.io/ai-project/slides/topic.html) · [PDF](slides/topic.pdf) · [LaTeX](slides/topic.tex) — 14 slides, 20-minute plan |
| **Verification** | [Code](code/README.md) — 10 Python checks and 13 presentation-model checks pass |
| **Final paper and slides** | [Paper](paper/paper.pdf) · [source](paper/paper.tex) · [bibliography](paper/references.bib) · [deck](slides/final.pdf) · [source](slides/final.tex) — progress files; final work pending |
| **Proofs and AI record** | [Lean](lean/README.md) · [hand derivations](hand/README.md) — planned; [raw conversation](prompts.md) recorded; my independent adjudication remains pending |

[Build guide and topic coverage](proposal/topic-checklist.md) · [Homework instructions](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/7)

**Submission pending:** pull request, merge into `main`, and repository-link comment. **Deadline:** October 13, 22:00 Lima. **Presentation:** October 14, 07:55–08:15.
