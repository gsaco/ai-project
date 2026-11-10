Draft semantic preflight result: all 12 queued rows match their archival source meanings. This is only a repair-screen verdict, not an acceptance credential, audit receipt, or closure evidence.

1. `source-declaration:Saco26InstitutionalRestart.Model:model_A1_A6_and_reduced_problem` — `matches`  
   The fields reproduce the A1–A5 primitives and restrictions: positive technology, prices and overhead; nonnegative institutional cost and restart cost; \(0<\alpha<1\); admissible \(s_0\pm d\); and \(0<\beta<1\). A6’s \(0<\pi_0\) restriction is represented separately by the displayed `NormallyViable` predicate and is imposed by every displayed result requiring A1–A6. Thus the broader reusable `Model` carrier specializes to the complete source domain.

2. `source-declaration:Saco26InstitutionalRestart.OperatingEnvironment:model_A1_A6_and_reduced_problem` — `matches`  
   The structure contains exactly the A1–A2 primitives and sign restrictions needed for conditional input optimization. The usable-share conditions \(0<s\le1\) are supplied by the lemma’s binders, while omission of restart cost correctly reflects the source’s statement that the conditional operating optimum is independent of it.

3. `source-declaration:Saco26InstitutionalRestart.cohortTotal:fixed_cohort_aggregation` — `matches`  
   `cohortTotal B N ... = B + N * actualOutput ...` is exactly \(Y_t^j=B+Ny_t^j\). The definition is harmlessly more general in \(B,N\); the corollary restricts both to be positive and uses the same values across all three paths.

4. `source-declaration:Saco26InstitutionalRestart.perCapitaTotal:fixed_cohort_aggregation` — `matches`  
   The target divides the common cohort total by one shared population \(P\), exactly implementing the source’s common-population per-capita comparison. The corollary supplies \(P>0\).

5. `source-declaration:Saco26InstitutionalRestart.suspendedThenResumedOutput:suspension_extension_model` — `matches`  
   The value is zero at date zero and \(q_0\) at every later date, matching suspension with no impact output followed by costless resumption when the normal state is restored at date one.

6. `source-declaration:Saco26InstitutionalRestart.suspensionActionValue:suspension_extension_model` — `matches`  
   Operating receives \(\pi_j+\beta V\), closure receives \(\beta W\), and suspension receives \(-h+\beta V\). These are precisely the three date-zero alternatives described by the extension.

7. `source-result:Saco26InstitutionalRestart.corollary1_positive_totals_and_logsSpec` — `matches`  
   The premises reproduce Proposition 1’s strict region. For every date and common \(B,N>0\), the target establishes positivity of all three totals and the exact strict log-loss comparison. Its per-capita clause uses any common \(P>0\), which also covers date-varying populations provided they remain identical across paths at each date.

8. `source-result:Saco26InstitutionalRestart.lemma1_operating_optimumSpec` — `matches`  
   Over the source domain \(x\ge0\) and \(0<s\le1\), the target states global optimality and uniqueness, the exact FOC, the closed-form optimizer, optimized output, and optimized profit. Restart cost is absent from the operating environment, matching the independence claim.

9. `source-result:Saco26InstitutionalRestart.lemma2_restored_state_values_and_delaysSpec` — `matches`  
   The upper bounds and attaining paths identify \(V\) and \(W=\max\{V-\kappa,0\}\) as the restored-state values. Equality is characterized uniquely by immediate restart when \(V>\kappa\) and permanent inactivity when \(V<\kappa\); at equality, every delayed restart and never restarting attain the same value.

10. `source-result:Saco26InstitutionalRestart.proposition1_persistent_strict_asymmetrySpec` — `matches`  
    The target has the exact strict premises and uniquely selects permanent adverse inactivity and continued normal/favorable operation. It gives the impact formulas, persistent adverse loss, and zero later gain. The `withKappa 0` model changes only restart cost and uniquely selects closing then reopening for the adverse path; the displayed output definitions and preserved primitives also entail the source’s unchanged free-baseline impact gain.

11. `source-result:Saco26InstitutionalRestart.proposition2_complete_closure_thresholdSpec` — `matches`  
    The three equivalences reproduce the closure, operation, and equality regions using  
    \[
    (1-\alpha)q_0(d/s_0)
    \quad\text{versus}\quad
    \pi_0+\beta\min\{\kappa,V\}.
    \]
    The target also supplies the corresponding impact choices, all three post-restoration \(\kappa/V\) regions, existence of optimal profiles, weak asymmetry for every optimal selection, and strictness exactly when the adverse path is closed.

12. `source-result:Saco26InstitutionalRestart.proposition3_cheap_suspensionSpec` — `matches`  
    Under Proposition 1’s strict assumptions and \(0\le h<\beta V\), suspension is the unique adverse impact action while operation is uniquely best for the normal and favorable shocks. The target gives zero adverse impact output, restoration to \(q_0\) from date one, impact loss \(q_0\), and zero later losses and gains.

Counts:

- `matches`: 12
- `mismatch`: 0
- `uncertain`: 0
- `needs_maintainer_clarification`: 0

Mismatches or uncertainties: none.