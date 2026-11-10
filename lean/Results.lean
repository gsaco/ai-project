import Saco26InstitutionalRestart.MainTheorems

/-!
# Paper-level switching, asymmetry, suspension, and logarithm results

These theorems sit on the arbitrary-path Bellman proof in `MainTheorems`.
They concern the paper's reduced activity problem.  They do not assert that
the unoptimized joint input/activity program has itself been formalized.
-/

open scoped BigOperators Topology

namespace Saco26InstitutionalRestart

noncomputable section

lemma inactiveValue_eq_activeValue_sub_min (m : Model) (hviable : NormallyViable m) :
    inactiveValue m = activeValue m - min m.kappa (activeValue m) := by
  have hV := (activeValue_pos m hviable).le
  rcases le_total m.kappa (activeValue m) with hk | hk
  · rw [min_eq_left hk, inactiveValue, max_eq_left]
    linarith
  · rw [min_eq_right hk, inactiveValue, max_eq_right (sub_nonpos.mpr hk), sub_self]

lemma restored_inactive_delayedRestart_optimal_of_eq
    {pi beta kappa : ℝ} (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1)
    (hkappa : 0 ≤ kappa) (heq : kappa = pi / (1 - beta)) (n : ℕ) :
    restoredPathValue pi beta kappa false (delayedRestart n) =
      max (pi / (1 - beta) - kappa) 0 := by
  rw [← show restoredPotential (pi / (1 - beta))
      (max (pi / (1 - beta) - kappa) 0) false =
      max (pi / (1 - beta) - kappa) 0 by simp [restoredPotential]]
  rw [restoredPathValue_eq_potential_iff_slack_zero hpi hbeta0 hbeta1 hkappa]
  intro t
  have hid := generic_activeValue_identity (pi := pi) hbeta1
  have hW : max (pi / (1 - beta) - kappa) 0 = 0 := by simp [heq]
  cases t with
  | zero =>
      by_cases hn : n ≤ 0
      · have hn0 : n = 0 := Nat.eq_zero_of_le_zero hn
        subst n
        simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
          delayedRestart, hW, heq]
        linarith
      · simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
          delayedRestart, hn, hW]
  | succ t =>
      by_cases hp : n ≤ t
      · have hc : n ≤ t + 1 := le_trans hp (Nat.le_succ t)
        simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
          delayedRestart, hp, hc, hW]
        linarith
      · by_cases hc : n ≤ t + 1
        · simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
            delayedRestart, hp, hc, hW, heq]
          linarith
        · simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
            delayedRestart, hp, hc, hW]

lemma restored_inactive_never_optimal_of_eq
    {pi beta kappa : ℝ} (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1)
    (hkappa : 0 ≤ kappa) (heq : kappa = pi / (1 - beta)) :
    restoredPathValue pi beta kappa false alwaysInactive =
      max (pi / (1 - beta) - kappa) 0 := by
  have hkgt_or_eq : pi / (1 - beta) ≤ kappa := heq.ge
  have hW : max (pi / (1 - beta) - kappa) 0 = 0 := max_eq_right (sub_nonpos.mpr hkgt_or_eq)
  rw [hW]
  simp [restoredPathValue, alwaysInactive, stateBefore, periodPayoff]

/-- A path's full shock value is bounded by its date-zero action value. -/
lemma shockPathValue_le_impactChoice (m : Model) (hviable : NormallyViable m)
    (j : Shock) (a : ActivityPath) :
    shockPathValue m j a ≤
      if a 0 then impactContinueValue m j else impactClosureValue m := by
  have htail := restoredPathValue_le_potential hviable m.beta_pos.le m.beta_lt_one
    m.kappa_nonneg (a 0) (fun t => a (t + 1))
  by_cases h0 : a 0 = true
  · have ht : restoredPathValue (pi0 m) m.beta m.kappa true (fun t => a (t + 1)) ≤
        activeValue m := by simpa only [h0, restoredPotential] using htail
    have hmul := mul_le_mul_of_nonneg_left ht m.beta_pos.le
    unfold shockPathValue impactContinueValue
    rw [h0]
    simpa [periodPayoff] using add_le_add_left hmul (impactProfit m j)
  · have hfalse : a 0 = false := Bool.eq_false_of_not_eq_true h0
    have ht : restoredPathValue (pi0 m) m.beta m.kappa false (fun t => a (t + 1)) ≤
        inactiveValue m := by simpa only [hfalse, restoredPotential] using htail
    have hmul := mul_le_mul_of_nonneg_left ht m.beta_pos.le
    unfold shockPathValue impactClosureValue
    rw [hfalse]
    simpa [periodPayoff] using hmul

lemma shockPathValue_alwaysActive (m : Model) (hviable : NormallyViable m) (j : Shock) :
    shockPathValue m j alwaysActive = impactContinueValue m j := by
  have htail := (restored_active_optimal_iff hviable m.beta_pos m.beta_lt_one
    m.kappa_nonneg alwaysActive).2 rfl
  have htail' : restoredPathValue (pi0 m) m.beta m.kappa true (fun _ => true) =
      activeValue m := by simpa only [alwaysActive] using htail
  simp [shockPathValue, impactContinueValue, alwaysActive, periodPayoff, htail']

lemma shockPathValue_alwaysInactive_of_gt (m : Model) (hviable : NormallyViable m)
    (hkgt : activeValue m < m.kappa) (j : Shock) :
    shockPathValue m j alwaysInactive = impactClosureValue m := by
  have htail := (restored_inactive_optimal_iff_inactive hviable m.beta_pos
    m.beta_lt_one m.kappa_nonneg hkgt alwaysInactive).2 rfl
  have htail' : restoredPathValue (pi0 m) m.beta m.kappa false (fun _ => false) =
      inactiveValue m := by simpa only [alwaysInactive] using htail
  simp [shockPathValue, impactClosureValue, alwaysInactive, periodPayoff, htail']

lemma shockPathValue_closeThenRestart_of_lt (m : Model) (hviable : NormallyViable m)
    (hklt : m.kappa < activeValue m) (j : Shock) :
    shockPathValue m j closeThenRestart = impactClosureValue m := by
  have htail := (restored_inactive_optimal_iff_active hviable m.beta_pos
    m.beta_lt_one m.kappa_nonneg hklt alwaysActive).2 rfl
  have htail' : restoredPathValue (pi0 m) m.beta m.kappa false (fun _ => true) =
      inactiveValue m := by simpa only [alwaysActive] using htail
  simp [shockPathValue, impactClosureValue, closeThenRestart, periodPayoff, htail']

lemma shockPathValue_alwaysInactive_of_eq (m : Model) (hviable : NormallyViable m)
    (hkeq : m.kappa = activeValue m) (j : Shock) :
    shockPathValue m j alwaysInactive = impactClosureValue m := by
  have htail := restored_inactive_never_optimal_of_eq hviable m.beta_pos
    m.beta_lt_one m.kappa_nonneg hkeq
  have htail' : restoredPathValue (pi0 m) m.beta m.kappa false (fun _ => false) =
      inactiveValue m := by simpa only [activeValue, inactiveValue] using htail
  simp [shockPathValue, impactClosureValue, alwaysInactive, periodPayoff, htail']

/-- Continuing is globally optimal whenever its impact value weakly dominates closure. -/
lemma shock_active_isOptimal_of_le (m : Model) (hviable : NormallyViable m) (j : Shock)
    (hchoice : impactClosureValue m ≤ impactContinueValue m j) :
    IsShockOptimal m j alwaysActive := by
  intro a
  have hbound := shockPathValue_le_impactChoice m hviable j a
  have hvalue := shockPathValue_alwaysActive m hviable j
  by_cases h0 : a 0 = true
  · simpa [h0, hvalue] using hbound
  · have hf : a 0 = false := Bool.eq_false_of_not_eq_true h0
    simp [hf] at hbound
    rw [hvalue]
    exact hbound.trans hchoice

/-- A canonical closing plan attains the closure value in every restart-cost region. -/
lemma shock_closing_optimal_exists (m : Model) (hviable : NormallyViable m) (j : Shock)
    (hchoice : impactContinueValue m j ≤ impactClosureValue m) :
    ∃ a, IsShockOptimal m j a ∧ a 0 = false ∧
      shockPathValue m j a = impactClosureValue m := by
  have attainer_isOptimal (a : ActivityPath)
      (hvalue : shockPathValue m j a = impactClosureValue m) : IsShockOptimal m j a := by
    intro b
    have hbound := shockPathValue_le_impactChoice m hviable j b
    by_cases h0 : b 0 = true
    · simp [h0] at hbound
      rw [hvalue]
      exact hbound.trans hchoice
    · have hf : b 0 = false := Bool.eq_false_of_not_eq_true h0
      simpa [hf, hvalue] using hbound
  rcases lt_trichotomy m.kappa (activeValue m) with hklt | hkeq | hkgt
  · have hv := shockPathValue_closeThenRestart_of_lt m hviable hklt j
    exact ⟨closeThenRestart, attainer_isOptimal closeThenRestart hv, rfl, hv⟩
  · have hv := shockPathValue_alwaysInactive_of_eq m hviable hkeq j
    exact ⟨alwaysInactive, attainer_isOptimal alwaysInactive hv, rfl, hv⟩
  · have hv := shockPathValue_alwaysInactive_of_gt m hviable hkgt j
    exact ⟨alwaysInactive, attainer_isOptimal alwaysInactive hv, rfl, hv⟩

lemma shock_active_unique (m : Model) (hviable : NormallyViable m) (j : Shock)
    (hchoice : impactClosureValue m < impactContinueValue m j) (a : ActivityPath) :
    shockPathValue m j a = shockPathValue m j alwaysActive ↔ a = alwaysActive := by
  have hbest := shockPathValue_alwaysActive m hviable j
  constructor
  · intro heq
    by_cases h0 : a 0 = true
    · have hav : shockPathValue m j a = impactContinueValue m j := heq.trans hbest
      have hmul : m.beta * restoredPathValue (pi0 m) m.beta m.kappa true
          (fun t => a (t + 1)) = m.beta * activeValue m := by
        unfold shockPathValue impactContinueValue at hav
        rw [h0] at hav
        simp only [periodPayoff, Bool.true_eq, if_true, Bool.false_eq_true, Bool.not_true,
          Bool.true_and, if_false, sub_zero] at hav
        linarith
      have htailEq : restoredPathValue (pi0 m) m.beta m.kappa true
          (fun t => a (t + 1)) = activeValue m :=
        mul_left_cancel₀ m.beta_pos.ne' hmul
      have htail : (fun t => a (t + 1)) = alwaysActive :=
        (restored_active_optimal_iff hviable m.beta_pos m.beta_lt_one
          m.kappa_nonneg _).1 htailEq
      funext t
      cases t with
      | zero => simpa [alwaysActive] using h0
      | succ t => simpa [alwaysActive] using congrFun htail t
    · have hbound := shockPathValue_le_impactChoice m hviable j a
      have hfalse : a 0 = false := Bool.eq_false_of_not_eq_true h0
      simp [hfalse] at hbound
      rw [heq, hbest] at hbound
      linarith
  · rintro rfl
    rfl

lemma shock_inactive_unique_of_gt (m : Model) (hviable : NormallyViable m)
    (hkgt : activeValue m < m.kappa) (j : Shock)
    (hchoice : impactContinueValue m j < impactClosureValue m) (a : ActivityPath) :
    shockPathValue m j a = shockPathValue m j alwaysInactive ↔ a = alwaysInactive := by
  have hbest := shockPathValue_alwaysInactive_of_gt m hviable hkgt j
  constructor
  · intro heq
    by_cases h0 : a 0 = true
    · have hbound := shockPathValue_le_impactChoice m hviable j a
      simp [h0] at hbound
      rw [heq, hbest] at hbound
      linarith
    · have hfalse : a 0 = false := Bool.eq_false_of_not_eq_true h0
      have hav : shockPathValue m j a = impactClosureValue m := heq.trans hbest
      have hmul : m.beta * restoredPathValue (pi0 m) m.beta m.kappa false
          (fun t => a (t + 1)) = m.beta * inactiveValue m := by
        unfold shockPathValue impactClosureValue at hav
        rw [hfalse] at hav
        simp only [periodPayoff, Bool.false_eq_true, if_false, Bool.not_false,
          Bool.false_and, sub_self, zero_add] at hav
        exact hav
      have htailEq : restoredPathValue (pi0 m) m.beta m.kappa false
          (fun t => a (t + 1)) = inactiveValue m :=
        mul_left_cancel₀ m.beta_pos.ne' hmul
      have htail : (fun t => a (t + 1)) = alwaysInactive :=
        (restored_inactive_optimal_iff_inactive hviable m.beta_pos m.beta_lt_one
          m.kappa_nonneg hkgt _).1 htailEq
      funext t
      cases t with
      | zero => simpa [alwaysInactive] using hfalse
      | succ t => simpa [alwaysInactive] using congrFun htail t
  · rintro rfl
    rfl

lemma shock_closeThenRestart_unique_of_lt (m : Model) (hviable : NormallyViable m)
    (hklt : m.kappa < activeValue m) (j : Shock)
    (hchoice : impactContinueValue m j < impactClosureValue m) (a : ActivityPath) :
    shockPathValue m j a = shockPathValue m j closeThenRestart ↔ a = closeThenRestart := by
  have hbest := shockPathValue_closeThenRestart_of_lt m hviable hklt j
  constructor
  · intro heq
    by_cases h0 : a 0 = true
    · have hbound := shockPathValue_le_impactChoice m hviable j a
      simp [h0] at hbound
      rw [heq, hbest] at hbound
      linarith
    · have hfalse : a 0 = false := Bool.eq_false_of_not_eq_true h0
      have hav : shockPathValue m j a = impactClosureValue m := heq.trans hbest
      have hmul : m.beta * restoredPathValue (pi0 m) m.beta m.kappa false
          (fun t => a (t + 1)) = m.beta * inactiveValue m := by
        unfold shockPathValue impactClosureValue at hav
        rw [hfalse] at hav
        simp only [periodPayoff, Bool.false_eq_true, if_false, Bool.not_false,
          Bool.false_and, sub_self, zero_add] at hav
        exact hav
      have htailEq : restoredPathValue (pi0 m) m.beta m.kappa false
          (fun t => a (t + 1)) = inactiveValue m :=
        mul_left_cancel₀ m.beta_pos.ne' hmul
      have htail : (fun t => a (t + 1)) = alwaysActive :=
        (restored_inactive_optimal_iff_active hviable m.beta_pos m.beta_lt_one
          m.kappa_nonneg hklt _).1 htailEq
      funext t
      cases t with
      | zero => simpa [closeThenRestart] using hfalse
      | succ t => simpa [closeThenRestart, alwaysActive] using congrFun htail t
  · rintro rfl
    rfl

lemma shock_active_isUniqueOptimal (m : Model) (hviable : NormallyViable m) (j : Shock)
    (hchoice : impactClosureValue m < impactContinueValue m j) :
    IsShockOptimal m j alwaysActive ∧
      ∀ a, IsShockOptimal m j a → a = alwaysActive := by
  have hvalue := shockPathValue_alwaysActive m hviable j
  have hopen : IsShockOptimal m j alwaysActive := by
    intro a
    have hbound := shockPathValue_le_impactChoice m hviable j a
    by_cases h0 : a 0 = true
    · simpa [h0, hvalue] using hbound
    · have hf : a 0 = false := Bool.eq_false_of_not_eq_true h0
      simp [hf] at hbound
      rw [hvalue]
      linarith
  constructor
  · exact hopen
  · intro a ha
    apply (shock_active_unique m hviable j hchoice a).1
    apply le_antisymm
    · exact hopen a
    · exact ha alwaysActive

lemma shock_inactive_isUniqueOptimal_of_gt (m : Model) (hviable : NormallyViable m)
    (hkgt : activeValue m < m.kappa) (j : Shock)
    (hchoice : impactContinueValue m j < impactClosureValue m) :
    IsShockOptimal m j alwaysInactive ∧
      ∀ a, IsShockOptimal m j a → a = alwaysInactive := by
  have hvalue := shockPathValue_alwaysInactive_of_gt m hviable hkgt j
  have hopen : IsShockOptimal m j alwaysInactive := by
    intro a
    have hbound := shockPathValue_le_impactChoice m hviable j a
    by_cases h0 : a 0 = true
    · simp [h0] at hbound
      rw [hvalue]
      linarith
    · have hf : a 0 = false := Bool.eq_false_of_not_eq_true h0
      simpa [hf, hvalue] using hbound
  constructor
  · exact hopen
  · intro a ha
    apply (shock_inactive_unique_of_gt m hviable hkgt j hchoice a).1
    apply le_antisymm
    · exact hopen a
    · exact ha alwaysInactive

lemma shock_closeThenRestart_isUniqueOptimal_of_lt (m : Model) (hviable : NormallyViable m)
    (hklt : m.kappa < activeValue m) (j : Shock)
    (hchoice : impactContinueValue m j < impactClosureValue m) :
    IsShockOptimal m j closeThenRestart ∧
      ∀ a, IsShockOptimal m j a → a = closeThenRestart := by
  have hvalue := shockPathValue_closeThenRestart_of_lt m hviable hklt j
  have hopen : IsShockOptimal m j closeThenRestart := by
    intro a
    have hbound := shockPathValue_le_impactChoice m hviable j a
    by_cases h0 : a 0 = true
    · simp [h0] at hbound
      rw [hvalue]
      linarith
    · have hf : a 0 = false := Bool.eq_false_of_not_eq_true h0
      simpa [hf, hvalue] using hbound
  constructor
  · exact hopen
  · intro a ha
    apply (shock_closeThenRestart_unique_of_lt m hviable hklt j hchoice a).1
    apply le_antisymm
    · exact hopen a
    · exact ha closeThenRestart

/-- Source-level operational content of Proposition 2's strict and tie cases. -/
theorem adverse_impact_choice_behavior (m : Model) (hviable : NormallyViable m) :
    (impactClosureValue m < impactContinueValue m .adverse →
      IsShockOptimal m .adverse alwaysActive ∧
        ∀ a, IsShockOptimal m .adverse a → a = alwaysActive) ∧
    (impactContinueValue m .adverse < impactClosureValue m →
      (∃ a, IsShockOptimal m .adverse a ∧ a 0 = false) ∧
        ∀ a, IsShockOptimal m .adverse a → a 0 = false) ∧
    (impactContinueValue m .adverse = impactClosureValue m →
      IsShockOptimal m .adverse alwaysActive ∧
        ∃ a, IsShockOptimal m .adverse a ∧ a 0 = false) := by
  refine ⟨?_, ?_, ?_⟩
  · exact fun h => shock_active_isUniqueOptimal m hviable .adverse h
  · intro hclose
    obtain ⟨b, hb, hb0, hbvalue⟩ :=
      shock_closing_optimal_exists m hviable .adverse hclose.le
    refine ⟨⟨b, hb, hb0⟩, ?_⟩
    intro a ha
    by_contra hnot
    have htrue : a 0 = true := Bool.eq_true_of_not_eq_false hnot
    have hbound := shockPathValue_le_impactChoice m hviable .adverse a
    simp [htrue] at hbound
    have hbest := ha b
    rw [hbvalue] at hbest
    linarith
  · intro heq
    constructor
    · exact shock_active_isOptimal_of_le m hviable .adverse heq.ge
    · obtain ⟨a, ha, ha0, _⟩ :=
        shock_closing_optimal_exists m hviable .adverse heq.le
      exact ⟨a, ha, ha0⟩

lemma normal_impact_continue_gt_close (m : Model) (hviable : NormallyViable m) :
    impactClosureValue m < impactContinueValue m .unchanged := by
  have hW := inactiveValue_le_activeValue m hviable
  have hV := activeValue_pos m hviable
  have hbetaV : m.beta * activeValue m < activeValue m := by
    nlinarith [mul_pos (sub_pos.mpr m.beta_lt_one) hV]
  have hbetaW : m.beta * inactiveValue m ≤ m.beta * activeValue m :=
    mul_le_mul_of_nonneg_left hW m.beta_pos.le
  unfold impactClosureValue impactContinueValue impactProfit
  rw [activeValue_identity]
  linarith

lemma favorable_impact_continue_gt_close (m : Model) (hviable : NormallyViable m) :
    impactClosureValue m < impactContinueValue m .favorable := by
  have hn := normal_impact_continue_gt_close m hviable
  have hp := piPlus_gt_pi0 m
  unfold impactContinueValue impactProfit at hn ⊢
  linarith

/-- The complete restored-state content of Lemma 2, including arbitrary paths and tie delays. -/
theorem restored_state_values_and_delays (m : Model) (hviable : NormallyViable m) :
    (∀ a, restoredPathValue (pi0 m) m.beta m.kappa true a ≤ activeValue m) ∧
    (restoredPathValue (pi0 m) m.beta m.kappa true alwaysActive = activeValue m) ∧
    (∀ a, restoredPathValue (pi0 m) m.beta m.kappa false a ≤ inactiveValue m) ∧
    (m.kappa < activeValue m →
      ∀ a, restoredPathValue (pi0 m) m.beta m.kappa false a = inactiveValue m ↔
        a = alwaysActive) ∧
    (activeValue m < m.kappa →
      ∀ a, restoredPathValue (pi0 m) m.beta m.kappa false a = inactiveValue m ↔
        a = alwaysInactive) ∧
    (m.kappa = activeValue m →
      (∀ n, restoredPathValue (pi0 m) m.beta m.kappa false (delayedRestart n) =
        inactiveValue m) ∧
      restoredPathValue (pi0 m) m.beta m.kappa false alwaysInactive = inactiveValue m) := by
  have hactive := (restored_active_optimal_iff hviable m.beta_pos m.beta_lt_one
    m.kappa_nonneg alwaysActive).2 rfl
  refine ⟨?_, hactive, ?_, ?_, ?_, ?_⟩
  · intro a
    simpa [activeValue, restoredPotential] using
      restoredPathValue_le_potential hviable m.beta_pos.le m.beta_lt_one
        m.kappa_nonneg true a
  · intro a
    simpa [activeValue, inactiveValue, restoredPotential] using
      restoredPathValue_le_potential hviable m.beta_pos.le m.beta_lt_one
        m.kappa_nonneg false a
  · intro hk a
    simpa [activeValue, inactiveValue] using
      restored_inactive_optimal_iff_active hviable m.beta_pos m.beta_lt_one
        m.kappa_nonneg hk a
  · intro hk a
    simpa [activeValue, inactiveValue] using
      restored_inactive_optimal_iff_inactive hviable m.beta_pos m.beta_lt_one
        m.kappa_nonneg hk a
  · intro hk
    constructor
    · intro n
      simpa [activeValue, inactiveValue] using
        restored_inactive_delayedRestart_optimal_of_eq hviable m.beta_pos
          m.beta_lt_one m.kappa_nonneg hk n
    · simpa [activeValue, inactiveValue] using
        restored_inactive_never_optimal_of_eq hviable m.beta_pos m.beta_lt_one
          m.kappa_nonneg hk

/-- Proposition 1's unique costly-restart paths, proved against all infinite paths. -/
theorem persistent_strict_asymmetry_paths (m : Model) (h : PersistentConditions m) :
    (IsShockOptimal m .adverse alwaysInactive ∧
      ∀ a, IsShockOptimal m .adverse a → a = alwaysInactive) ∧
    (IsShockOptimal m .unchanged alwaysActive ∧
      ∀ a, IsShockOptimal m .unchanged a → a = alwaysActive) ∧
    (IsShockOptimal m .favorable alwaysActive ∧
      ∀ a, IsShockOptimal m .favorable a → a = alwaysActive) := by
  rcases h with ⟨hviable, hadverse, hkgt⟩
  have hW : inactiveValue m = 0 := by
    unfold inactiveValue
    exact max_eq_right (sub_nonpos.mpr hkgt.le)
  have hadverseChoice : impactContinueValue m .adverse < impactClosureValue m := by
    unfold impactContinueValue impactClosureValue impactProfit
    rw [hW]
    simpa using hadverse
  exact ⟨shock_inactive_isUniqueOptimal_of_gt m hviable hkgt .adverse hadverseChoice,
    shock_active_isUniqueOptimal m hviable .unchanged
      (normal_impact_continue_gt_close m hviable),
    shock_active_isUniqueOptimal m hviable .favorable
      (favorable_impact_continue_gt_close m hviable)⟩

/-- Proposition 1's free-restart comparison changes only `κ` to zero. -/
theorem free_restart_asymmetry_paths (m : Model) (h : PersistentConditions m) :
    let m0 := m.withKappa 0 (le_refl 0)
    (IsShockOptimal m0 .adverse closeThenRestart ∧
      ∀ a, IsShockOptimal m0 .adverse a → a = closeThenRestart) ∧
    (IsShockOptimal m0 .unchanged alwaysActive ∧
      ∀ a, IsShockOptimal m0 .unchanged a → a = alwaysActive) ∧
    (IsShockOptimal m0 .favorable alwaysActive ∧
      ∀ a, IsShockOptimal m0 .favorable a → a = alwaysActive) := by
  rcases h with ⟨hviable, hadverse, hkgt⟩
  let m0 := m.withKappa 0 (le_refl 0)
  have hviable0 : NormallyViable m0 := by simpa [m0, Model.withKappa] using hviable
  have hV : 0 < activeValue m := activeValue_pos m hviable
  have hV0 : activeValue m0 = activeValue m := by simp [m0]
  have hklt0 : m0.kappa < activeValue m0 := by simpa [m0] using hV
  have hpiMinusNeg : piMinus m < 0 := by
    have hbV : 0 < m.beta * activeValue m := mul_pos m.beta_pos hV
    linarith
  have hadverseChoice0 : impactContinueValue m0 .adverse < impactClosureValue m0 := by
    have hW0 : inactiveValue m0 = activeValue m0 := by
      unfold inactiveValue
      rw [max_eq_left]
      · simp [m0]
      · simpa [m0] using hV.le
    unfold impactContinueValue impactClosureValue impactProfit
    rw [hW0]
    have hpi : piMinus m0 = piMinus m := by simp [m0]
    linarith
  exact ⟨shock_closeThenRestart_isUniqueOptimal_of_lt m0 hviable0 hklt0 .adverse
      hadverseChoice0,
    shock_active_isUniqueOptimal m0 hviable0 .unchanged
      (normal_impact_continue_gt_close m0 hviable0),
    shock_active_isUniqueOptimal m0 hviable0 .favorable
      (favorable_impact_continue_gt_close m0 hviable0)⟩

/-- Exact level-loss identities in Proposition 1, including the free-restart recovery path. -/
theorem persistent_and_free_output_identities (m : Model) :
    actualOutput m .unchanged alwaysActive 0 -
        actualOutput m .adverse alwaysInactive 0 = q0 m ∧
    actualOutput m .favorable alwaysActive 0 -
        actualOutput m .unchanged alwaysActive 0 = q0 m * (m.d / m.s0) ∧
    q0 m > q0 m * (m.d / m.s0) ∧
    (∀ t, actualOutput m .unchanged alwaysActive (t + 1) -
        actualOutput m .adverse alwaysInactive (t + 1) = q0 m) ∧
    (∀ t, actualOutput m .favorable alwaysActive (t + 1) -
        actualOutput m .unchanged alwaysActive (t + 1) = 0) ∧
    actualOutput m .unchanged alwaysActive 0 -
        actualOutput m .adverse closeThenRestart 0 = q0 m ∧
    (∀ t, actualOutput m .unchanged alwaysActive (t + 1) -
        actualOutput m .adverse closeThenRestart (t + 1) = 0) := by
  have hq := q0_pos m
  have hdr : m.d / m.s0 < 1 := (div_lt_one m.s0_pos).2 m.d_lt_s0
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simp [actualOutput, impactUsableShare, alwaysActive, alwaysInactive]
    exact operatingOutput_s0 m
  · simp [actualOutput, impactUsableShare, alwaysActive]
    rw [operatingOutput_plus]
    rw [show operatingOutput m m.s0 = q0 m from rfl]
    ring
  · nlinarith [mul_pos hq (sub_pos.mpr hdr)]
  · intro t
    simp [actualOutput, impactUsableShare, alwaysActive, alwaysInactive]
    exact operatingOutput_s0 m
  · intro t
    simp [actualOutput, impactUsableShare, alwaysActive]
  · simp [actualOutput, impactUsableShare, alwaysActive, closeThenRestart]
    exact operatingOutput_s0 m
  · intro t
    simp [actualOutput, impactUsableShare, alwaysActive, closeThenRestart]

lemma adverse_choice_gap (m : Model) (hviable : NormallyViable m) :
    impactContinueValue m .adverse - impactClosureValue m =
      pi0 m - (1 - m.alpha) * q0 m * (m.d / m.s0) +
        m.beta * min m.kappa (activeValue m) := by
  unfold impactContinueValue impactClosureValue impactProfit
  rw [piMinus_formula, inactiveValue_eq_activeValue_sub_min m hviable]
  ring

/-- Proposition 2's strict, reverse, and equality threshold comparisons. -/
theorem complete_adverse_closure_threshold (m : Model) (hviable : NormallyViable m) :
    (impactContinueValue m .adverse < impactClosureValue m ↔
      pi0 m + m.beta * min m.kappa (activeValue m) <
        (1 - m.alpha) * q0 m * (m.d / m.s0)) ∧
    (impactClosureValue m < impactContinueValue m .adverse ↔
      (1 - m.alpha) * q0 m * (m.d / m.s0) <
        pi0 m + m.beta * min m.kappa (activeValue m)) ∧
    (impactContinueValue m .adverse = impactClosureValue m ↔
      (1 - m.alpha) * q0 m * (m.d / m.s0) =
        pi0 m + m.beta * min m.kappa (activeValue m)) := by
  have hgap := adverse_choice_gap m hviable
  constructor
  · constructor <;> intro h <;> linarith
  constructor
  · constructor <;> intro h <;> linarith
  · constructor <;> intro h <;> linarith

/-- The paper's three matched experiments always admit a jointly optimal profile. -/
theorem optimalProfile_nonempty (m : Model) (hviable : NormallyViable m) :
    Nonempty (OptimalProfile m) := by
  have hn := (shock_active_isUniqueOptimal m hviable .unchanged
    (normal_impact_continue_gt_close m hviable)).1
  have hf := (shock_active_isUniqueOptimal m hviable .favorable
    (favorable_impact_continue_gt_close m hviable)).1
  rcases le_total (impactClosureValue m) (impactContinueValue m .adverse) with hopen | hclose
  · exact ⟨{
      adverse := alwaysActive
      unchanged := alwaysActive
      favorable := alwaysActive
      adverse_optimal := shock_active_isOptimal_of_le m hviable .adverse hopen
      unchanged_optimal := hn
      favorable_optimal := hf }⟩
  · obtain ⟨a, ha, _, _⟩ := shock_closing_optimal_exists m hviable .adverse hclose
    exact ⟨{
      adverse := a
      unchanged := alwaysActive
      favorable := alwaysActive
      adverse_optimal := ha
      unchanged_optimal := hn
      favorable_optimal := hf }⟩
/-- Proposition 2's weak matched asymmetry for every globally optimal selection, including ties. -/
theorem any_optimal_profile_weak_asymmetry (m : Model) (hviable : NormallyViable m)
    (p : OptimalProfile m) :
    (∀ t, outputLoss m p t ≥ outputGain m p t ∧ outputGain m p t ≥ 0) ∧
    (outputLoss m p 0 > outputGain m p 0 ↔ p.adverse 0 = false) ∧
    (∀ t, outputLoss m p (t + 1) > outputGain m p (t + 1) ↔
      p.adverse (t + 1) = false) := by
  have hn : p.unchanged = alwaysActive :=
    (shock_active_isUniqueOptimal m hviable .unchanged
      (normal_impact_continue_gt_close m hviable)).2 p.unchanged p.unchanged_optimal
  have hf : p.favorable = alwaysActive :=
    (shock_active_isUniqueOptimal m hviable .favorable
      (favorable_impact_continue_gt_close m hviable)).2 p.favorable p.favorable_optimal
  have hq : 0 < q0 m := q0_pos m
  have hdr0 : 0 < m.d / m.s0 := div_pos m.d_pos m.s0_pos
  have hdr1 : m.d / m.s0 < 1 := (div_lt_one m.s0_pos).2 m.d_lt_s0
  have hgain : 0 < q0 m * (m.d / m.s0) := mul_pos hq hdr0
  have hloss : q0 m * (m.d / m.s0) < q0 m := by
    nlinarith [mul_pos hq (sub_pos.mpr hdr1)]
  constructor
  · intro t
    cases t with
    | zero =>
        cases ha : p.adverse 0 <;>
          simp [outputLoss, outputGain, actualOutput, hn, hf, alwaysActive,
            impactUsableShare, ha]
        · rw [operatingOutput_plus]
          rw [show operatingOutput m m.s0 = q0 m from rfl]
          constructor <;> nlinarith
        · rw [operatingOutput_minus, operatingOutput_plus]
          rw [show operatingOutput m m.s0 = q0 m from rfl]
          constructor <;> nlinarith
    | succ t =>
        cases ha : p.adverse (t + 1) <;>
          simp [outputLoss, outputGain, actualOutput, hn, hf, alwaysActive,
            impactUsableShare, ha] <;> rw [operatingOutput_s0] <;> linarith
  · constructor
    · cases ha : p.adverse 0 with
      | false =>
          simp only [eq_self, iff_true]
          simp [outputLoss, outputGain, actualOutput, impactUsableShare,
            hn, hf, alwaysActive, ha]
          rw [operatingOutput_plus, operatingOutput_s0]
          nlinarith
      | true =>
          simp only [Bool.true_eq_false, iff_false]
          intro hs
          simp [outputLoss, outputGain, actualOutput, impactUsableShare,
            hn, hf, alwaysActive, ha] at hs
          rw [operatingOutput_minus, operatingOutput_plus, operatingOutput_s0] at hs
          nlinarith
    · intro t
      cases ha : p.adverse (t + 1) <;>
        simp [outputLoss, outputGain, actualOutput, hn, hf, alwaysActive,
          impactUsableShare, ha] <;> rw [operatingOutput_s0] <;> linarith

/-- Proposition 3: the preservation action is uniquely best under the paper's strict conditions. -/
theorem cheap_suspension_unique_actions (m : Model) (hmain : PersistentConditions m)
    {h : ℝ} (hh0 : 0 ≤ h) (hh : h < m.beta * activeValue m) :
    IsUniqueBestImpactAction m h .adverse .suspend ∧
    IsUniqueBestImpactAction m h .unchanged .operate ∧
    IsUniqueBestImpactAction m h .favorable .operate := by
  rcases hmain with ⟨hviable, hadverse, hkgt⟩
  have hV := activeValue_pos m hviable
  have hW : inactiveValue m = 0 := by
    unfold inactiveValue
    exact max_eq_right (sub_nonpos.mpr hkgt.le)
  have hspos : 0 < -h + m.beta * activeValue m := by linarith
  have hnclose := normal_impact_continue_gt_close m hviable
  have hfclose := favorable_impact_continue_gt_close m hviable
  have hp := piPlus_gt_pi0 m
  have hpi0 : 0 < pi0 m := hviable
  have hpiPlus : 0 < piPlus m := lt_trans hviable hp
  constructor
  · unfold IsUniqueBestImpactAction
    intro other
    cases other with
    | operate =>
        constructor
        · unfold suspensionActionValue impactContinueValue impactProfit
          linarith
        · intro heq
          unfold suspensionActionValue impactContinueValue impactProfit at heq
          exfalso
          linarith
    | close =>
        constructor
        · unfold suspensionActionValue impactClosureValue
          rw [hW]
          linarith
        · intro heq
          unfold suspensionActionValue impactClosureValue at heq
          rw [hW] at heq
          exfalso
          linarith
    | suspend => exact ⟨le_refl _, fun _ => rfl⟩
  constructor
  · unfold IsUniqueBestImpactAction
    intro other
    cases other with
    | operate => exact ⟨le_refl _, fun _ => rfl⟩
    | close =>
        constructor
        · exact hnclose.le
        · intro heq
          exact False.elim ((ne_of_lt hnclose) heq)
    | suspend =>
        constructor
        · change -h + m.beta * activeValue m ≤ pi0 m + m.beta * activeValue m
          linarith
        · intro heq
          change -h + m.beta * activeValue m =
            pi0 m + m.beta * activeValue m at heq
          exfalso
          linarith
  · unfold IsUniqueBestImpactAction
    intro other
    cases other with
    | operate => exact ⟨le_refl _, fun _ => rfl⟩
    | close =>
        constructor
        · exact hfclose.le
        · intro heq
          exact False.elim ((ne_of_lt hfclose) heq)
    | suspend =>
        constructor
        · change -h + m.beta * activeValue m ≤ piPlus m + m.beta * activeValue m
          linarith
        · intro heq
          change -h + m.beta * activeValue m =
            piPlus m + m.beta * activeValue m at heq
          exfalso
          linarith

theorem suspension_output_and_resumption (m : Model) (hviable : NormallyViable m) :
    suspendedThenResumedOutput m 0 = 0 ∧
    (∀ t, suspendedThenResumedOutput m (t + 1) = q0 m) ∧
    restoredPathValue (pi0 m) m.beta m.kappa true alwaysActive = activeValue m := by
  refine ⟨by simp [suspendedThenResumedOutput], ?_, ?_⟩
  · intro t
    simp [suspendedThenResumedOutput]
  · exact (restored_active_optimal_iff hviable m.beta_pos m.beta_lt_one
      m.kappa_nonneg alwaysActive).2 rfl

lemma log_asymmetry_of_level_gap {Ym Y0 Yp : ℝ}
    (hm : 0 < Ym) (h0 : 0 < Y0) (hp : 0 < Yp)
    (hgap : Yp - Y0 < Y0 - Ym) :
    Real.log Y0 - Real.log Ym > Real.log Yp - Real.log Y0 := by
  have hprod : Ym * Yp < Y0 ^ 2 := by
    nlinarith [sq_nonneg (Ym - Yp)]
  have hlog := Real.strictMonoOn_log (mul_pos hm hp) (sq_pos_of_pos h0) hprod
  rw [Real.log_mul hm.ne' hp.ne', pow_two, Real.log_mul h0.ne' h0.ne'] at hlog
  linarith

/-- Corollary 1 for the proposition's unique costly-restart output paths. -/
theorem positive_totals_logs_and_perCapita (m : Model) (hmain : PersistentConditions m)
    {B N : ℝ} (hB : 0 < B) (hN : 0 < N) :
    ∀ t,
      (0 < cohortTotal B N m .adverse alwaysInactive t ∧
        0 < cohortTotal B N m .unchanged alwaysActive t ∧
        0 < cohortTotal B N m .favorable alwaysActive t) ∧
      (Real.log (cohortTotal B N m .unchanged alwaysActive t) -
          Real.log (cohortTotal B N m .adverse alwaysInactive t) >
        Real.log (cohortTotal B N m .favorable alwaysActive t) -
          Real.log (cohortTotal B N m .unchanged alwaysActive t)) ∧
      (∀ P, 0 < P →
        Real.log (perCapitaTotal B N P m .unchanged alwaysActive t) -
            Real.log (perCapitaTotal B N P m .adverse alwaysInactive t) >
          Real.log (perCapitaTotal B N P m .favorable alwaysActive t) -
            Real.log (perCapitaTotal B N P m .unchanged alwaysActive t)) := by
  intro t
  have hq := q0_pos m
  have hdr0 : 0 < m.d / m.s0 := div_pos m.d_pos m.s0_pos
  have hdr1 : m.d / m.s0 < 1 := (div_lt_one m.s0_pos).2 m.d_lt_s0
  have hgain : 0 < q0 m * (m.d / m.s0) := mul_pos hq hdr0
  have hloss : q0 m * (m.d / m.s0) < q0 m := by
    nlinarith [mul_pos hq (sub_pos.mpr hdr1)]
  cases t with
  | zero =>
      have hplus := operatingOutput_plus m
      have hYm : 0 < cohortTotal B N m .adverse alwaysInactive 0 := by
        simp [cohortTotal, actualOutput, alwaysInactive, hB]
      have hY0 : 0 < cohortTotal B N m .unchanged alwaysActive 0 := by
        simp [cohortTotal, actualOutput, alwaysActive, impactUsableShare]
        rw [operatingOutput_s0]
        nlinarith [mul_pos hN hq]
      have hYp : 0 < cohortTotal B N m .favorable alwaysActive 0 := by
        simp [cohortTotal, actualOutput, alwaysActive, impactUsableShare]
        rw [hplus]
        nlinarith [mul_pos hN hq, mul_pos hN hgain]
      have hgap : cohortTotal B N m .favorable alwaysActive 0 -
          cohortTotal B N m .unchanged alwaysActive 0 <
          cohortTotal B N m .unchanged alwaysActive 0 -
            cohortTotal B N m .adverse alwaysInactive 0 := by
        simp [cohortTotal, actualOutput, alwaysActive, alwaysInactive, impactUsableShare]
        rw [hplus, operatingOutput_s0]
        nlinarith [mul_pos hN (sub_pos.mpr hloss)]
      refine ⟨⟨hYm, hY0, hYp⟩, log_asymmetry_of_level_gap hYm hY0 hYp hgap, ?_⟩
      intro P hP
      apply log_asymmetry_of_level_gap
      · exact div_pos hYm hP
      · exact div_pos hY0 hP
      · exact div_pos hYp hP
      · unfold perCapitaTotal
        simpa [sub_div] using (div_lt_div_iff_of_pos_right hP).2 hgap
  | succ t =>
      have hYm : 0 < cohortTotal B N m .adverse alwaysInactive (t + 1) := by
        simp [cohortTotal, actualOutput, alwaysInactive, hB]
      have hY0 : 0 < cohortTotal B N m .unchanged alwaysActive (t + 1) := by
        simp [cohortTotal, actualOutput, alwaysActive]
        rw [operatingOutput_s0]
        nlinarith [mul_pos hN hq]
      have hYp : 0 < cohortTotal B N m .favorable alwaysActive (t + 1) := by
        simpa [cohortTotal, actualOutput, alwaysActive] using hY0
      have hgap : cohortTotal B N m .favorable alwaysActive (t + 1) -
          cohortTotal B N m .unchanged alwaysActive (t + 1) <
          cohortTotal B N m .unchanged alwaysActive (t + 1) -
            cohortTotal B N m .adverse alwaysInactive (t + 1) := by
        simp [cohortTotal, actualOutput, alwaysActive, alwaysInactive]
        rw [operatingOutput_s0]
        nlinarith [mul_pos hN hq]
      refine ⟨⟨hYm, hY0, hYp⟩, log_asymmetry_of_level_gap hYm hY0 hYp hgap, ?_⟩
      intro P hP
      apply log_asymmetry_of_level_gap
      · exact div_pos hYm hP
      · exact div_pos hY0 hP
      · exact div_pos hYp hP
      · unfold perCapitaTotal
        simpa [sub_div] using (div_lt_div_iff_of_pos_right hP).2 hgap

end

end Saco26InstitutionalRestart
