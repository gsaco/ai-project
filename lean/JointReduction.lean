import Saco26InstitutionalRestart.Operating
import Saco26InstitutionalRestart.Results
import Mathlib.Topology.Algebra.InfiniteSum.Real
import Mathlib.Topology.Instances.EReal.Lemmas

/-! Reduction of the joint problem (1) to the binary activity problem (6).
Raw inputs can generate arbitrarily large losses. Values are limits of
discounted partial sums in the extended reals, including minus infinity. -/

open Filter
open scoped BigOperators Topology

namespace Saco26InstitutionalRestart

noncomputable section

/-- Feasibility in A3. Every plan starts from the same initially active firm. -/
structure JointPlan where
  activity : ActivityPath
  input : ℕ → ℝ
  input_nonneg : ∀ t, 0 ≤ input t
  input_closed : ∀ t, activity t = false → input t = 0

def usableAt (m : Model) (j : Shock) : ℕ → ℝ
  | 0 => impactUsableShare m j
  | _ + 1 => m.s0

private theorem usableAt_pos (m : Model) (j : Shock) (t : ℕ) : 0 < usableAt m j t := by
  cases t with
  | zero => cases j <;> simp only [usableAt, impactUsableShare]
            · exact usableMinus_pos m
            · exact m.s0_pos
            · exact add_pos m.s0_pos m.d_pos
  | succ t => exact m.s0_pos

/-- The primitive discounted cash flow from (1). Revenue is evaluated at the
chosen input even when the firm is closed (feasibility then forces zero). -/
def jointTerm (m : Model) (j : Shock) (p : JointPlan) (t : ℕ) : ℝ :=
  m.beta ^ t * (m.A * (usableAt m j t) ^ (1 - m.alpha) * (p.input t) ^ m.alpha -
    m.w * p.input t - (if p.activity t then m.F + m.c0 else 0) -
    (if p.activity t && !(stateBefore true p.activity t) then m.kappa else 0))

/-- Discounted cash flow from (6) before separating the restored tail. -/
def reducedTerm (m : Model) (j : Shock) (a : ActivityPath) (t : ℕ) : ℝ :=
  m.beta ^ t * periodPayoff (operatingProfit m (usableAt m j t)) m.kappa
    (stateBefore true a t) (a t)

private theorem stateBefore_tail (a : ActivityPath) (t : ℕ) :
    stateBefore true a (t + 1) = stateBefore (a 0) (fun n => a (n + 1)) t := by
  cases t <;> rfl

theorem reducedTerm_hasSum (m : Model) (j : Shock) (a : ActivityPath) :
    HasSum (reducedTerm m j a) (shockPathValue m j a) := by
  let tail : ActivityPath := fun n => a (n + 1)
  have h := (restoredPayoff_summable m.beta_pos.le m.beta_lt_one (a 0) tail
    (pi := pi0 m) (kappa := m.kappa)).hasSum.mul_left m.beta
  have hs : HasSum (fun n => reducedTerm m j a (n + 1))
      (m.beta * restoredPathValue (pi0 m) m.beta m.kappa (a 0) tail) := by
    simpa only [reducedTerm, usableAt, stateBefore_tail, pow_succ', mul_assoc,
      restoredPathValue, pi0, tail] using h
  have h0 : reducedTerm m j a 0 = periodPayoff (impactProfit m j) m.kappa true (a 0) := by
    cases j <;> simp [reducedTerm, usableAt, impactUsableShare, impactProfit, stateBefore,
      piMinus, piPlus, pi0]
  simpa only [h0, shockPathValue, tail] using hs.zero_add

private theorem jointTerm_as_operating (m : Model) (j : Shock) (p : JointPlan) (t : ℕ) :
    jointTerm m j p t = m.beta ^ t * periodPayoff
      (rawOperatingPayoff m (usableAt m j t) (p.input t)) m.kappa
      (stateBefore true p.activity t) (p.activity t) := by
  cases ha : p.activity t with
  | false => simp [jointTerm, periodPayoff, ha, p.input_closed t ha, Real.zero_rpow m.alpha_pos.ne']
  | true => simp [jointTerm, periodPayoff, ha, rawOperatingPayoff, sub_add_eq_sub_sub]

private theorem jointTerm_le (m : Model) (j : Shock) (p : JointPlan) (t : ℕ) :
    jointTerm m j p t ≤ reducedTerm m j p.activity t := by
  rw [jointTerm_as_operating, reducedTerm]
  apply mul_le_mul_of_nonneg_left _ (pow_nonneg m.beta_pos.le t)
  apply sub_le_sub_right
  cases ha : p.activity t with
  | false => simp
  | true =>
    simp only [if_true]
    rw [← inputStar_payoff m (usableAt_pos m j t)]
    exact inputStar_isMaxOn m (usableAt_pos m j t) (p.input_nonneg t)

/-- Choose the static optimal input on each active date of this very path. -/
def optimizedPlan (m : Model) (j : Shock) (a : ActivityPath) : JointPlan where
  activity := a
  input t := if a t then inputStar m (usableAt m j t) else 0
  input_nonneg t := by split <;> first | exact (inputStar_pos m (usableAt_pos m j t)).le | exact le_rfl
  input_closed t h := by simp [h]

private theorem optimizedTerm_eq (m : Model) (j : Shock) (a : ActivityPath) (t : ℕ) :
    jointTerm m j (optimizedPlan m j a) t = reducedTerm m j a t := by
  rw [jointTerm_as_operating]
  cases ha : a t <;> simp [optimizedPlan, reducedTerm, periodPayoff, ha,
    inputStar_payoff m (usableAt_pos m j t)]

open Classical in
/-- For feasible plans the only alternative to a finite sum is divergence to
minus infinity. The next theorem proves this interpretation from partial sums. -/
def jointValue (m : Model) (j : Shock) (p : JointPlan) : EReal :=
  if Summable (jointTerm m j p) then ((∑' t, jointTerm m j p t : ℝ) : EReal) else ⊥

theorem jointValue_is_limit (m : Model) (j : Shock) (p : JointPlan) :
    Tendsto (fun n => ((∑ t ∈ Finset.range n, jointTerm m j p t : ℝ) : EReal))
      atTop (𝓝 (jointValue m j p)) := by
  by_cases hj : Summable (jointTerm m j p)
  · simpa [jointValue, hj] using EReal.tendsto_coe.mpr hj.hasSum.tendsto_sum_nat
  rw [jointValue, if_neg hj]
  let reduced := reducedTerm m j p.activity
  let raw := jointTerm m j p
  let gap := fun t => reduced t - raw t
  have hr := reducedTerm_hasSum m j p.activity
  have hgap : ¬Summable gap := by
    intro hg
    exact hj (by simpa [gap, reduced, raw] using hr.summable.sub hg)
  have hdiv := (not_summable_iff_tendsto_nat_atTop_of_nonneg
    (fun t => sub_nonneg.mpr (jointTerm_le m j p t))).mp hgap
  apply EReal.tendsto_nhds_bot_iff_real.mpr
  intro bound
  let limit := shockPathValue m j p.activity
  have hu := hr.tendsto_sum_nat.eventually_lt_const (show limit < limit + 1 by linarith)
  filter_upwards [hu, hdiv.eventually_ge_atTop (limit + 1 - bound)] with n hn hg
  apply EReal.coe_lt_coe_iff.mpr
  rw [Finset.sum_sub_distrib] at hg
  linarith

theorem jointValue_le_reduced (m : Model) (j : Shock) (p : JointPlan) :
    jointValue m j p ≤ (shockPathValue m j p.activity : EReal) := by
  unfold jointValue
  split_ifs with h
  · apply EReal.coe_le_coe_iff.mpr
    have hr := reducedTerm_hasSum m j p.activity
    rw [← hr.tsum_eq]
    exact h.tsum_le_tsum (jointTerm_le m j p) hr.summable
  · exact bot_le

theorem optimizedPlan_value (m : Model) (j : Shock) (a : ActivityPath) :
    jointValue m j (optimizedPlan m j a) = (shockPathValue m j a : EReal) := by
  have h : jointTerm m j (optimizedPlan m j a) = reducedTerm m j a :=
    funext (optimizedTerm_eq m j a)
  have hr := reducedTerm_hasSum m j a
  simp [jointValue, h, hr.summable, hr.tsum_eq]

/-- The original and reduced programs have the same supremum, with no
boundedness or summability assumption on the firm's chosen inputs. -/
theorem joint_reduction (m : Model) (j : Shock) :
    (⨆ p : JointPlan, jointValue m j p) =
      ⨆ a : ActivityPath, (shockPathValue m j a : EReal) := by
  apply le_antisymm
  · exact iSup_le fun p => (jointValue_le_reduced m j p).trans
      (le_iSup (fun a : ActivityPath => (shockPathValue m j a : EReal)) p.activity)
  · refine iSup_le fun a => ?_
    rw [← optimizedPlan_value m j a]
    exact le_iSup _ (optimizedPlan m j a)

/-- A joint maximizer must choose an optimal activity path and attain its
reduced payoff. Both conditions together are also sufficient. -/
theorem jointPlan_optimal_iff (m : Model) (j : Shock) (p : JointPlan) :
    (∀ q : JointPlan, jointValue m j q ≤ jointValue m j p) ↔
      IsShockOptimal m j p.activity ∧ jointValue m j p = (shockPathValue m j p.activity : EReal) := by
  constructor
  · intro h
    have hval := le_antisymm (jointValue_le_reduced m j p)
      (by simpa only [optimizedPlan_value] using h (optimizedPlan m j p.activity))
    refine ⟨fun b => ?_, hval⟩
    have hb := h (optimizedPlan m j b)
    rw [optimizedPlan_value, hval] at hb
    exact EReal.coe_le_coe_iff.mp hb
  · rintro ⟨h, hval⟩ q
    rw [hval]
    exact (jointValue_le_reduced m j q).trans (EReal.coe_le_coe_iff.mpr (h q.activity))

/-- Under normal viability each of the paper's three joint programs attains a maximum. -/
theorem jointMaximum_exists (m : Model) (hv : NormallyViable m) (j : Shock) :
    ∃ p : JointPlan, ∀ q : JointPlan, jointValue m j q ≤ jointValue m j p := by
  obtain ⟨profile⟩ := optimalProfile_nonempty m hv
  have lift (a : ActivityPath) (ha : IsShockOptimal m j a) :
      ∀ q, jointValue m j q ≤ jointValue m j (optimizedPlan m j a) :=
    (jointPlan_optimal_iff m j _).2 ⟨ha, optimizedPlan_value m j a⟩
  cases j with
  | adverse => exact ⟨_, lift _ profile.adverse_optimal⟩
  | unchanged => exact ⟨_, lift _ profile.unchanged_optimal⟩
  | favorable => exact ⟨_, lift _ profile.favorable_optimal⟩

end
end Saco26InstitutionalRestart
