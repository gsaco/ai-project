import Saco26InstitutionalRestart.Model

/-!
# Checked results for Saco (2026)

The main proof engine is a Bellman-potential decomposition for arbitrary
infinite activity paths. Every discounted path value equals its initial
potential minus a convergent sum of nonnegative Bellman slacks.
-/

open scoped BigOperators Topology
open Filter Set

namespace Saco26InstitutionalRestart

noncomputable section

lemma one_sub_beta_pos (m : Model) : 0 < 1 - m.beta := sub_pos.mpr m.beta_lt_one

lemma one_sub_beta_ne (m : Model) : 1 - m.beta ≠ 0 := (one_sub_beta_pos m).ne'

lemma usableMinus_pos (m : Model) : 0 < m.s0 - m.d := sub_pos.mpr m.d_lt_s0

lemma technologyBase_pos (m : Model) : 0 < m.alpha * m.A / m.w :=
  div_pos (mul_pos m.alpha_pos m.A_pos) m.w_pos

lemma inputStar_pos (m : Model) {s : ℝ} (hs : 0 < s) : 0 < inputStar m s := by
  unfold inputStar
  exact mul_pos hs (Real.rpow_pos_of_pos (technologyBase_pos m) _)

lemma operatingOutput_pos (m : Model) {s : ℝ} (hs : 0 < s) : 0 < operatingOutput m s := by
  unfold operatingOutput
  exact mul_pos (mul_pos hs m.A_pos) (Real.rpow_pos_of_pos (technologyBase_pos m) _)

lemma q0_pos (m : Model) : 0 < q0 m := operatingOutput_pos m m.s0_pos

lemma operatingOutput_s0 (m : Model) : operatingOutput m m.s0 = q0 m := rfl

lemma activeValue_pos (m : Model) (hviable : NormallyViable m) : 0 < activeValue m := by
  unfold activeValue
  exact div_pos hviable (one_sub_beta_pos m)

lemma inactiveValue_nonneg (m : Model) : 0 ≤ inactiveValue m := by
  simp [inactiveValue]

lemma inactiveValue_le_activeValue (m : Model) (hviable : NormallyViable m) :
    inactiveValue m ≤ activeValue m := by
  unfold inactiveValue
  refine max_le ?_ (activeValue_pos m hviable).le
  linarith [m.kappa_nonneg]

lemma operatingOutput_linear (m : Model) (s r : ℝ) :
    operatingOutput m (s + r) = operatingOutput m s + operatingOutput m r := by
  unfold operatingOutput
  ring

lemma operatingOutput_minus (m : Model) :
    operatingOutput m (m.s0 - m.d) = q0 m - q0 m * (m.d / m.s0) := by
  unfold q0 operatingOutput
  field_simp [m.s0_pos.ne']

lemma operatingOutput_plus (m : Model) :
    operatingOutput m (m.s0 + m.d) = q0 m + q0 m * (m.d / m.s0) := by
  unfold q0 operatingOutput
  field_simp [m.s0_pos.ne']

lemma piMinus_formula (m : Model) :
    piMinus m = pi0 m - (1 - m.alpha) * q0 m * (m.d / m.s0) := by
  unfold piMinus pi0
  simp only [operatingProfit]
  rw [operatingOutput_minus]
  rw [show operatingOutput m m.s0 = q0 m from rfl]
  ring

lemma piPlus_formula (m : Model) :
    piPlus m = pi0 m + (1 - m.alpha) * q0 m * (m.d / m.s0) := by
  unfold piPlus pi0
  simp only [operatingProfit]
  rw [operatingOutput_plus]
  rw [show operatingOutput m m.s0 = q0 m from rfl]
  ring

lemma piPlus_gt_pi0 (m : Model) : pi0 m < piPlus m := by
  rw [piPlus_formula]
  have hα : 0 < 1 - m.alpha := sub_pos.mpr m.alpha_lt_one
  have hq : 0 < q0 m := q0_pos m
  have hdr : 0 < m.d / m.s0 := div_pos m.d_pos m.s0_pos
  nlinarith [mul_pos (mul_pos hα hq) hdr]

lemma activeValue_identity (m : Model) : pi0 m + m.beta * activeValue m = activeValue m := by
  unfold activeValue
  field_simp [one_sub_beta_ne m]
  ring

lemma generic_activeValue_identity {pi beta : ℝ} (hbeta : beta < 1) :
    pi + beta * (pi / (1 - beta)) = pi / (1 - beta) := by
  have hne : 1 - beta ≠ 0 := (sub_pos.mpr hbeta).ne'
  field_simp [hne]
  ring

private lemma periodPayoff_abs_le (pi kappa : ℝ) (previous current : Bool) :
    |periodPayoff pi kappa previous current| ≤ |pi| + |kappa| := by
  cases previous <;> cases current <;>
    simp [periodPayoff, abs_nonneg, abs_sub] <;>
    exact add_nonneg (abs_nonneg pi) (abs_nonneg kappa)

lemma restoredPayoff_summable {pi beta kappa : ℝ} (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1)
    (prior : Bool) (a : ActivityPath) :
    Summable (fun t : ℕ => beta ^ t * periodPayoff pi kappa (stateBefore prior a t) (a t)) := by
  refine ((summable_geometric_of_lt_one hbeta0 hbeta1).mul_right (|pi| + |kappa|)).of_norm_bounded ?_
  intro t
  rw [Real.norm_eq_abs, abs_mul, abs_pow, abs_of_nonneg hbeta0]
  exact mul_le_mul_of_nonneg_left
    (periodPayoff_abs_le pi kappa (stateBefore prior a t) (a t)) (pow_nonneg hbeta0 t)

private lemma potential_abs_le (V W : ℝ) (state : Bool) :
    |restoredPotential V W state| ≤ |V| + |W| := by
  cases state <;> simp [restoredPotential, abs_nonneg]

private lemma discountedPotential_summable {beta V W : ℝ} (hbeta0 : 0 ≤ beta)
    (hbeta1 : beta < 1) (prior : Bool) (a : ActivityPath) :
    Summable (fun t : ℕ => beta ^ t * restoredPotential V W (stateBefore prior a t)) := by
  refine ((summable_geometric_of_lt_one hbeta0 hbeta1).mul_right (|V| + |W|)).of_norm_bounded ?_
  intro t
  rw [Real.norm_eq_abs, abs_mul, abs_pow, abs_of_nonneg hbeta0]
  exact mul_le_mul_of_nonneg_left
    (potential_abs_le V W (stateBefore prior a t)) (pow_nonneg hbeta0 t)

private lemma discountedSlack_eq_telescope_sub_payoff
    (pi beta kappa V W : ℝ) (prior : Bool) (a : ActivityPath) (t : ℕ) :
    discountedSlack pi beta kappa V W prior a t =
      (beta ^ t * restoredPotential V W (stateBefore prior a t) -
        beta ^ (t + 1) * restoredPotential V W (stateBefore prior a (t + 1))) -
      beta ^ t * periodPayoff pi kappa (stateBefore prior a t) (a t) := by
  simp only [discountedSlack, bellmanSlack, stateBefore]
  rw [pow_succ]
  ring

private lemma discountedPotential_telescope_tsum
    {beta V W : ℝ} (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1)
    (prior : Bool) (a : ActivityPath) :
    ∑' t : ℕ, (beta ^ t * restoredPotential V W (stateBefore prior a t) -
      beta ^ (t + 1) * restoredPotential V W (stateBefore prior a (t + 1))) =
      restoredPotential V W prior := by
  let g : ℕ → ℝ := fun t => beta ^ t * restoredPotential V W (stateBefore prior a t)
  have hg : Summable g := discountedPotential_summable hbeta0 hbeta1 prior a
  have htail : Summable (fun t : ℕ => g (t + 1)) := by
    simpa [Nat.succ_eq_add_one] using hg.comp_injective Nat.succ_injective
  change ∑' t : ℕ, (g t - g (t + 1)) = _
  rw [hg.tsum_sub htail, hg.tsum_eq_zero_add]
  simp [g, stateBefore]

lemma discountedSlack_summable {pi beta kappa V W : ℝ}
    (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1) (prior : Bool) (a : ActivityPath) :
    Summable (discountedSlack pi beta kappa V W prior a) := by
  have hg := discountedPotential_summable (V := V) (W := W) hbeta0 hbeta1 prior a
  have htail : Summable (fun t : ℕ =>
      beta ^ (t + 1) * restoredPotential V W (stateBefore prior a (t + 1))) := by
    simpa only [Function.comp_apply, Nat.succ_eq_add_one] using
      hg.comp_injective Nat.succ_injective
  have htelescope : Summable (fun t : ℕ =>
      beta ^ t * restoredPotential V W (stateBefore prior a t) -
        beta ^ (t + 1) * restoredPotential V W (stateBefore prior a (t + 1))) :=
    hg.sub htail
  have hp := restoredPayoff_summable (pi := pi) (kappa := kappa) hbeta0 hbeta1 prior a
  exact (htelescope.sub hp).congr fun t =>
    (discountedSlack_eq_telescope_sub_payoff pi beta kappa V W prior a t).symm

lemma restoredPathValue_eq_potential_sub_slack {pi beta kappa V W : ℝ}
    (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1) (prior : Bool) (a : ActivityPath) :
    restoredPathValue pi beta kappa prior a = restoredPotential V W prior -
      ∑' t : ℕ, discountedSlack pi beta kappa V W prior a t := by
  have hs := discountedSlack_summable (pi := pi) (kappa := kappa) (V := V) (W := W)
    hbeta0 hbeta1 prior a
  have hg := discountedPotential_summable (V := V) (W := W) hbeta0 hbeta1 prior a
  have htail : Summable (fun t : ℕ =>
      beta ^ (t + 1) * restoredPotential V W (stateBefore prior a (t + 1))) := by
    simpa only [Function.comp_apply, Nat.succ_eq_add_one] using
      hg.comp_injective Nat.succ_injective
  have htelescope : Summable (fun t : ℕ =>
      beta ^ t * restoredPotential V W (stateBefore prior a t) -
        beta ^ (t + 1) * restoredPotential V W (stateBefore prior a (t + 1))) :=
    hg.sub htail
  unfold restoredPathValue
  rw [← discountedPotential_telescope_tsum hbeta0 hbeta1 prior a]
  rw [← htelescope.tsum_sub hs]
  apply tsum_congr
  intro t
  rw [discountedSlack_eq_telescope_sub_payoff]
  ring

lemma bellmanSlack_nonneg {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (prior : Bool) (a : ActivityPath) (t : ℕ) :
    0 ≤ bellmanSlack pi beta kappa (pi / (1 - beta))
      (max (pi / (1 - beta) - kappa) 0) prior a t := by
  let V := pi / (1 - beta)
  let W := max (V - kappa) 0
  have hden : 0 < 1 - beta := sub_pos.mpr hbeta1
  have hV : 0 < V := div_pos hpi hden
  have hW0 : 0 ≤ W := by simp [W]
  have hWV : W ≤ V := by
    dsimp [W]
    refine max_le ?_ hV.le
    linarith
  have hid : pi + beta * V = V := generic_activeValue_identity hbeta1
  have hbeta_le_one : beta ≤ 1 := hbeta1.le
  have hone_sub_beta : 0 ≤ 1 - beta := sub_nonneg.mpr hbeta_le_one
  have hVmK_le_W : V - kappa ≤ W := by
    exact le_max_left _ _
  have hbetaW_le_betaV : beta * W ≤ beta * V :=
    mul_le_mul_of_nonneg_left hWV hbeta0
  have hbetaV_le_V : beta * V ≤ V := by
    exact mul_le_of_le_one_left hV.le hbeta_le_one
  unfold bellmanSlack
  cases hprev : stateBefore prior a t <;> cases hcur : a t
  · have hd : 0 ≤ W - beta * W := by
      have hp := mul_nonneg hone_sub_beta hW0
      nlinarith
    simp only [restoredPotential, periodPayoff, Bool.false_eq_true, if_false,
      Bool.not_false, Bool.false_and, sub_self, zero_add]
    change 0 ≤ W - beta * W
    exact hd
  · have hd : 0 ≤ W - ((pi - kappa) + beta * V) := by linarith
    change 0 ≤ W - ((pi - kappa) + beta * V)
    exact hd
  · have hd : 0 ≤ V - beta * W := by linarith
    simpa [restoredPotential, periodPayoff] using hd
  · have hd : 0 ≤ V - (pi + beta * V) := by linarith
    simpa [restoredPotential, periodPayoff] using hd

lemma discountedSlack_nonneg {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (prior : Bool) (a : ActivityPath) (t : ℕ) :
    0 ≤ discountedSlack pi beta kappa (pi / (1 - beta))
      (max (pi / (1 - beta) - kappa) 0) prior a t :=
  mul_nonneg (pow_nonneg hbeta0 t)
    (bellmanSlack_nonneg hpi hbeta0 hbeta1 hkappa prior a t)

lemma restoredPathValue_le_potential {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 ≤ beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (prior : Bool) (a : ActivityPath) :
    restoredPathValue pi beta kappa prior a ≤
      restoredPotential (pi / (1 - beta)) (max (pi / (1 - beta) - kappa) 0) prior := by
  rw [restoredPathValue_eq_potential_sub_slack hbeta0 hbeta1]
  exact sub_le_self _ (tsum_nonneg fun t => discountedSlack_nonneg
    hpi hbeta0 hbeta1 hkappa prior a t)

lemma restoredPathValue_eq_potential_iff_slack_zero {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (prior : Bool) (a : ActivityPath) :
    restoredPathValue pi beta kappa prior a =
        restoredPotential (pi / (1 - beta)) (max (pi / (1 - beta) - kappa) 0) prior ↔
      ∀ t, bellmanSlack pi beta kappa (pi / (1 - beta))
        (max (pi / (1 - beta) - kappa) 0) prior a t = 0 := by
  let V := pi / (1 - beta)
  let W := max (V - kappa) 0
  have hs := discountedSlack_summable (pi := pi) (kappa := kappa) (V := V) (W := W)
    hbeta0.le hbeta1 prior a
  have hnonneg : ∀ t, 0 ≤ discountedSlack pi beta kappa V W prior a t :=
    fun t => discountedSlack_nonneg hpi hbeta0.le hbeta1 hkappa prior a t
  constructor
  · intro hvalue t
    have hsum : (∑' n, discountedSlack pi beta kappa V W prior a n) = 0 := by
      rw [restoredPathValue_eq_potential_sub_slack hbeta0.le hbeta1] at hvalue
      change restoredPotential V W prior -
        ∑' n, discountedSlack pi beta kappa V W prior a n = restoredPotential V W prior at hvalue
      linarith
    by_contra hne
    have hposSlack : 0 < bellmanSlack pi beta kappa V W prior a t :=
      lt_of_le_of_ne (bellmanSlack_nonneg hpi hbeta0.le hbeta1 hkappa prior a t) (Ne.symm hne)
    have hpos : 0 < discountedSlack pi beta kappa V W prior a t := by
      exact mul_pos (pow_pos hbeta0 t) hposSlack
    have := hs.tsum_pos hnonneg t hpos
    linarith
  · intro hslack
    rw [restoredPathValue_eq_potential_sub_slack hbeta0.le hbeta1]
    have hzero : ∀ t, discountedSlack pi beta kappa V W prior a t = 0 := by
      intro t
      change beta ^ t * bellmanSlack pi beta kappa (pi / (1 - beta))
        (max (pi / (1 - beta) - kappa) 0) prior a t = 0
      rw [hslack t, mul_zero]
    have htsum : (∑' t, discountedSlack pi beta kappa V W prior a t) = 0 := by
      calc
        (∑' t, discountedSlack pi beta kappa V W prior a t) = ∑' _ : ℕ, (0 : ℝ) :=
          tsum_congr hzero
        _ = 0 := tsum_zero
    change restoredPotential V W prior -
      ∑' t, discountedSlack pi beta kappa V W prior a t = restoredPotential V W prior
    rw [htsum, sub_zero]

private lemma tight_active_forces_active {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (a : ActivityPath)
    (htight : ∀ t, bellmanSlack pi beta kappa (pi / (1 - beta))
      (max (pi / (1 - beta) - kappa) 0) true a t = 0) :
    a = alwaysActive := by
  let V := pi / (1 - beta)
  let W := max (V - kappa) 0
  have hV : 0 < V := div_pos hpi (sub_pos.mpr hbeta1)
  have hW : W ≤ V := by
    dsimp [W]
    refine max_le ?_ hV.le
    linarith
  have hbetaW_lt_V : beta * W < V := by
    calc
      beta * W ≤ beta * V := mul_le_mul_of_nonneg_left hW hbeta0.le
      _ < V := by nlinarith [mul_pos (sub_pos.mpr hbeta1) hV]
  funext t
  induction t with
  | zero =>
      cases h : a 0 with
      | false =>
          have ht := htight 0
          simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore, h] at ht
          dsimp [V, W] at hbetaW_lt_V
          exact False.elim (by linarith)
      | true => simp [alwaysActive, h]
  | succ t iht =>
      have hprev : a t = true := by simpa [alwaysActive] using iht
      cases h : a (t + 1) with
      | false =>
          have ht := htight (t + 1)
          simp [bellmanSlack, stateBefore, hprev, h, restoredPotential, periodPayoff] at ht
          dsimp [V, W] at hbetaW_lt_V
          exact False.elim (by linarith)
      | true => simp [alwaysActive, h]

lemma restored_active_optimal_iff {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (a : ActivityPath) :
    restoredPathValue pi beta kappa true a = pi / (1 - beta) ↔ a = alwaysActive := by
  rw [← show restoredPotential (pi / (1 - beta)) (max (pi / (1 - beta) - kappa) 0) true =
      pi / (1 - beta) by simp [restoredPotential]]
  rw [restoredPathValue_eq_potential_iff_slack_zero hpi hbeta0 hbeta1 hkappa]
  constructor
  · exact tight_active_forces_active hpi hbeta0 hbeta1 hkappa a
  · rintro rfl t
    have hid := generic_activeValue_identity (pi := pi) hbeta1
    cases t <;> simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
      alwaysActive] <;> linarith

private lemma tight_inactive_forces_active {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (hklt : kappa < pi / (1 - beta)) (a : ActivityPath)
    (htight : ∀ t, bellmanSlack pi beta kappa (pi / (1 - beta))
      (max (pi / (1 - beta) - kappa) 0) false a t = 0) :
    a = alwaysActive := by
  let V := pi / (1 - beta)
  let W := max (V - kappa) 0
  have hW : max (pi / (1 - beta) - kappa) 0 = pi / (1 - beta) - kappa :=
    max_eq_left (sub_nonneg.mpr hklt.le)
  have hWdef : W = V - kappa := by simpa [W, V] using hW
  have hVWpos : 0 < (1 - beta) * W := by
    exact mul_pos (sub_pos.mpr hbeta1) (by dsimp [W, V]; rw [hW]; linarith)
  have hV : 0 < V := div_pos hpi (sub_pos.mpr hbeta1)
  have hWle : W ≤ V := by rw [hWdef]; linarith
  have hbetaW_lt_V : beta * W < V := by
    calc
      beta * W ≤ beta * V := mul_le_mul_of_nonneg_left hWle hbeta0.le
      _ < V := by nlinarith [mul_pos (sub_pos.mpr hbeta1) hV]
  funext t
  induction t with
  | zero =>
      cases h : a 0 with
      | false =>
          have ht := htight 0
          simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore, h, hW] at ht
          dsimp [W, V] at hVWpos
          exact False.elim (by nlinarith)
      | true => simp [alwaysActive, h]
  | succ t iht =>
      have hprev : a t = true := by simpa [alwaysActive] using iht
      cases h : a (t + 1) with
      | false =>
          have ht := htight (t + 1)
          simp [bellmanSlack, stateBefore, hprev, h, restoredPotential, periodPayoff] at ht
          dsimp [V, W] at hbetaW_lt_V
          exact False.elim (by linarith)
      | true => simp [alwaysActive, h]

private lemma tight_inactive_forces_inactive {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (hkgt : pi / (1 - beta) < kappa) (a : ActivityPath)
    (htight : ∀ t, bellmanSlack pi beta kappa (pi / (1 - beta))
      (max (pi / (1 - beta) - kappa) 0) false a t = 0) :
    a = alwaysInactive := by
  let V := pi / (1 - beta)
  let W := max (V - kappa) 0
  have hW : max (pi / (1 - beta) - kappa) 0 = 0 := max_eq_right (sub_nonpos.mpr hkgt.le)
  have hWdef : W = 0 := by simpa [W, V] using hW
  have hid : pi + beta * V = V := generic_activeValue_identity hbeta1
  funext t
  induction t with
  | zero =>
      cases h : a 0 with
      | false => simp [alwaysInactive, h]
      | true =>
          have ht := htight 0
          simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore, h, hW] at ht
          dsimp [V] at hid
          exact False.elim (by linarith)
  | succ t iht =>
      have hprev : a t = false := by simpa [alwaysInactive] using iht
      cases h : a (t + 1) with
      | false => simp [alwaysInactive, h]
      | true =>
          have ht := htight (t + 1)
          simp [bellmanSlack, stateBefore, hprev, h, restoredPotential, periodPayoff, hW] at ht
          dsimp [V] at hid
          exact False.elim (by linarith)

lemma restored_inactive_optimal_iff_active {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (hklt : kappa < pi / (1 - beta)) (a : ActivityPath) :
    restoredPathValue pi beta kappa false a = max (pi / (1 - beta) - kappa) 0 ↔
      a = alwaysActive := by
  rw [← show restoredPotential (pi / (1 - beta)) (max (pi / (1 - beta) - kappa) 0) false =
      max (pi / (1 - beta) - kappa) 0 by simp [restoredPotential]]
  rw [restoredPathValue_eq_potential_iff_slack_zero hpi hbeta0 hbeta1 hkappa]
  constructor
  · exact tight_inactive_forces_active hpi hbeta0 hbeta1 hkappa hklt a
  · rintro rfl t
    have hW : max (pi / (1 - beta) - kappa) 0 = pi / (1 - beta) - kappa :=
      max_eq_left (sub_nonneg.mpr hklt.le)
    have hid := generic_activeValue_identity (pi := pi) hbeta1
    cases t with
    | zero =>
        simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore, alwaysActive, hW]
        linarith
    | succ t =>
        simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore, alwaysActive]
        linarith

lemma restored_inactive_optimal_iff_inactive {pi beta kappa : ℝ}
    (hpi : 0 < pi) (hbeta0 : 0 < beta) (hbeta1 : beta < 1) (hkappa : 0 ≤ kappa)
    (hkgt : pi / (1 - beta) < kappa) (a : ActivityPath) :
    restoredPathValue pi beta kappa false a = max (pi / (1 - beta) - kappa) 0 ↔
      a = alwaysInactive := by
  rw [← show restoredPotential (pi / (1 - beta)) (max (pi / (1 - beta) - kappa) 0) false =
      max (pi / (1 - beta) - kappa) 0 by simp [restoredPotential]]
  rw [restoredPathValue_eq_potential_iff_slack_zero hpi hbeta0 hbeta1 hkappa]
  constructor
  · exact tight_inactive_forces_inactive hpi hbeta0 hbeta1 hkappa hkgt a
  · rintro rfl t
    have hW : max (pi / (1 - beta) - kappa) 0 = 0 := max_eq_right (sub_nonpos.mpr hkgt.le)
    cases t <;> simp [bellmanSlack, restoredPotential, periodPayoff, stateBefore,
      alwaysInactive, hW]

end

end Saco26InstitutionalRestart
