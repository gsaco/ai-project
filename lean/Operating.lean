import Saco26InstitutionalRestart.MainTheorems

/-! Checked algebraic and optimization content for the paper's operating-input lemma. -/

open Set

namespace Saco26InstitutionalRestart

noncomputable section

lemma inputStar_foc (m : Model) {s : ℝ} (hs : 0 < s) :
    m.alpha * m.A * Real.rpow s (1 - m.alpha) *
        Real.rpow (inputStar m s) (m.alpha - 1) = m.w := by
  let b := m.alpha * m.A / m.w
  let e := 1 / (1 - m.alpha)
  have hb : 0 < b := by dsimp [b]; exact technologyBase_pos m
  have he : e * (m.alpha - 1) = -1 := by
    dsimp [e]
    field_simp [ne_of_gt (sub_pos.mpr m.alpha_lt_one)]
    ring
  have hs_cancel : Real.rpow s (1 - m.alpha) * Real.rpow s (m.alpha - 1) = 1 := by
    calc
      Real.rpow s (1 - m.alpha) * Real.rpow s (m.alpha - 1) =
          Real.rpow s ((1 - m.alpha) + (m.alpha - 1)) :=
        (Real.rpow_add hs (1 - m.alpha) (m.alpha - 1)).symm
      _ = 1 := by norm_num
  have hbpow : Real.rpow (Real.rpow b e) (m.alpha - 1) = b⁻¹ := by
    calc
      Real.rpow (Real.rpow b e) (m.alpha - 1) =
          Real.rpow b (e * (m.alpha - 1)) :=
        (Real.rpow_mul hb.le e (m.alpha - 1)).symm
      _ = Real.rpow b (-1) := by rw [he]
      _ = b⁻¹ := Real.rpow_neg_one b
  unfold inputStar
  change m.alpha * m.A * Real.rpow s (1 - m.alpha) *
    Real.rpow (s * Real.rpow b e) (m.alpha - 1) = m.w
  have hmul := Real.mul_rpow (z := m.alpha - 1) hs.le (Real.rpow_nonneg hb.le e)
  rw [show Real.rpow (s * Real.rpow b e) (m.alpha - 1) =
      Real.rpow s (m.alpha - 1) * Real.rpow (Real.rpow b e) (m.alpha - 1) from hmul]
  rw [hbpow]
  calc
    m.alpha * m.A * Real.rpow s (1 - m.alpha) *
        (Real.rpow s (m.alpha - 1) * b⁻¹) =
        m.alpha * m.A *
          (Real.rpow s (1 - m.alpha) * Real.rpow s (m.alpha - 1)) * b⁻¹ := by ring
    _ = m.alpha * m.A * b⁻¹ := by rw [hs_cancel, mul_one]
    _ = m.w := by
      dsimp [b]
      field_simp [m.alpha_pos.ne', m.A_pos.ne', m.w_pos.ne']

lemma inputStar_output (m : Model) {s : ℝ} (hs : 0 < s) :
    m.A * Real.rpow s (1 - m.alpha) * Real.rpow (inputStar m s) m.alpha =
      operatingOutput m s := by
  let b := m.alpha * m.A / m.w
  let e := 1 / (1 - m.alpha)
  have hb : 0 < b := by dsimp [b]; exact technologyBase_pos m
  have he : e * m.alpha = m.alpha / (1 - m.alpha) := by
    dsimp [e]
    ring
  have hs_power : Real.rpow s (1 - m.alpha) * Real.rpow s m.alpha = s := by
    calc
      Real.rpow s (1 - m.alpha) * Real.rpow s m.alpha =
          Real.rpow s ((1 - m.alpha) + m.alpha) :=
        (Real.rpow_add hs (1 - m.alpha) m.alpha).symm
      _ = s := by norm_num [Real.rpow_one]
  have hbpow : Real.rpow (Real.rpow b e) m.alpha =
      Real.rpow b (m.alpha / (1 - m.alpha)) := by
    calc
      Real.rpow (Real.rpow b e) m.alpha = Real.rpow b (e * m.alpha) :=
        (Real.rpow_mul hb.le e m.alpha).symm
      _ = _ := by rw [he]
  unfold inputStar operatingOutput
  change m.A * Real.rpow s (1 - m.alpha) *
      Real.rpow (s * Real.rpow b e) m.alpha =
    s * m.A * Real.rpow b (m.alpha / (1 - m.alpha))
  have hmul := Real.mul_rpow (z := m.alpha) hs.le (Real.rpow_nonneg hb.le e)
  rw [show Real.rpow (s * Real.rpow b e) m.alpha =
      Real.rpow s m.alpha * Real.rpow (Real.rpow b e) m.alpha from hmul]
  rw [hbpow]
  calc
    m.A * Real.rpow s (1 - m.alpha) *
        (Real.rpow s m.alpha * Real.rpow b (m.alpha / (1 - m.alpha))) =
      m.A * (Real.rpow s (1 - m.alpha) * Real.rpow s m.alpha) *
        Real.rpow b (m.alpha / (1 - m.alpha)) := by ring
    _ = s * m.A * Real.rpow b (m.alpha / (1 - m.alpha)) := by rw [hs_power]; ring

lemma inputStar_wage_bill (m : Model) {s : ℝ} (hs : 0 < s) :
    m.w * inputStar m s = m.alpha * operatingOutput m s := by
  have hx := inputStar_pos m hs
  have hfoc := inputStar_foc m hs
  have hxpow : Real.rpow (inputStar m s) (m.alpha - 1) * inputStar m s =
      Real.rpow (inputStar m s) m.alpha := by
    calc
      Real.rpow (inputStar m s) (m.alpha - 1) * inputStar m s =
          Real.rpow (inputStar m s) (m.alpha - 1) *
            Real.rpow (inputStar m s) 1 := by
              congr 1
              exact (Real.rpow_one (inputStar m s)).symm
      _ = Real.rpow (inputStar m s) ((m.alpha - 1) + 1) :=
        (Real.rpow_add hx (m.alpha - 1) 1).symm
      _ = Real.rpow (inputStar m s) m.alpha := by ring_nf
  have houtput := inputStar_output m hs
  calc
    m.w * inputStar m s =
        (m.alpha * m.A * Real.rpow s (1 - m.alpha) *
          Real.rpow (inputStar m s) (m.alpha - 1)) * inputStar m s := by rw [hfoc]
    _ = m.alpha *
        (m.A * Real.rpow s (1 - m.alpha) * Real.rpow (inputStar m s) m.alpha) := by
      rw [← hxpow]
      ring
    _ = m.alpha * operatingOutput m s := by rw [houtput]

lemma inputStar_payoff (m : Model) {s : ℝ} (hs : 0 < s) :
    rawOperatingPayoff m s (inputStar m s) = operatingProfit m s := by
  unfold rawOperatingPayoff operatingProfit
  rw [inputStar_output m hs, inputStar_wage_bill m hs]
  ring

lemma rawOperatingPayoff_hasDerivAt (m : Model) {s x : ℝ} (hx : x ≠ 0) :
    HasDerivAt (rawOperatingPayoff m s)
      (m.alpha * m.A * Real.rpow s (1 - m.alpha) *
        x ^ (m.alpha - 1) - m.w) x := by
  have hp := Real.hasDerivAt_rpow_const (p := m.alpha) (Or.inl hx)
  have hrev := hp.const_mul (m.A * Real.rpow s (1 - m.alpha))
  have hw := (hasDerivAt_id x).mul_const m.w
  have h := ((hrev.sub hw).sub_const m.F).sub_const m.c0
  have hfun : rawOperatingPayoff m s = fun y : ℝ =>
      m.A * Real.rpow s (1 - m.alpha) * (y ^ m.alpha) - y * m.w - m.F - m.c0 := by
    funext y
    unfold rawOperatingPayoff
    change m.A * Real.rpow s (1 - m.alpha) * (y ^ m.alpha) - m.w * y - m.F - m.c0 =
      m.A * Real.rpow s (1 - m.alpha) * (y ^ m.alpha) - y * m.w - m.F - m.c0
    ring
  rw [hfun]
  convert h using 1 <;>
    simp only [Pi.sub_apply, Pi.smul_apply, smul_eq_mul, id_eq, one_mul] <;> ring

lemma rawOperatingPayoff_continuous (m : Model) {s : ℝ} :
    Continuous (rawOperatingPayoff m s) := by
  have hp : Continuous (fun x : ℝ => Real.rpow x m.alpha) :=
    Real.continuous_rpow_const m.alpha_pos.le
  have hrev : Continuous (fun x : ℝ =>
      m.A * Real.rpow s (1 - m.alpha) * Real.rpow x m.alpha) :=
    continuous_const.mul hp
  have hw : Continuous (fun x : ℝ => m.w * x) := continuous_const.mul continuous_id
  simpa only [rawOperatingPayoff] using ((hrev.sub hw).sub continuous_const).sub continuous_const

lemma inputStar_isMaxOn (m : Model) {s : ℝ} (hs : 0 < s) :
    IsMaxOn (rawOperatingPayoff m s) (Ici 0) (inputStar m s) := by
  have hxstar := inputStar_pos m hs
  have hcont := rawOperatingPayoff_continuous m (s := s)
  have hdiffLow : DifferentiableOn ℝ (rawOperatingPayoff m s) (Ioo 0 (inputStar m s)) := by
    intro x hx
    exact (rawOperatingPayoff_hasDerivAt m hx.1.ne').differentiableAt.differentiableWithinAt
  have hdiffHigh : DifferentiableOn ℝ (rawOperatingPayoff m s) (Ioi (inputStar m s)) := by
    intro x hx
    exact (rawOperatingPayoff_hasDerivAt m (ne_of_gt (lt_trans hxstar hx))).differentiableAt.differentiableWithinAt
  have hK : 0 < m.alpha * m.A * Real.rpow s (1 - m.alpha) := by
    exact mul_pos (mul_pos m.alpha_pos m.A_pos) (Real.rpow_pos_of_pos hs _)
  have hfoc := inputStar_foc m hs
  change m.alpha * m.A * Real.rpow s (1 - m.alpha) *
    (inputStar m s) ^ (m.alpha - 1) = m.w at hfoc
  apply isMaxOn_Ici_of_deriv hcont.continuousAt hcont.continuousAt hdiffLow hdiffHigh
  · intro x hx
    rw [(rawOperatingPayoff_hasDerivAt m hx.1.ne').deriv]
    have hp := Real.rpow_lt_rpow_of_neg hx.1 hx.2 (sub_neg.mpr m.alpha_lt_one)
    have hmul := mul_lt_mul_of_pos_left hp hK
    linarith
  · intro x hx
    rw [(rawOperatingPayoff_hasDerivAt m (ne_of_gt (lt_trans hxstar hx))).deriv]
    have hp := Real.rpow_lt_rpow_of_neg hxstar hx (sub_neg.mpr m.alpha_lt_one)
    have hmul := mul_lt_mul_of_pos_left hp hK
    linarith

/-- Full unique global optimum over nonnegative inputs for Lemma 1. -/
theorem operating_optimum (m : Model) {s : ℝ} (hs : 0 < s) :
    (∀ x, 0 ≤ x → rawOperatingPayoff m s x ≤ rawOperatingPayoff m s (inputStar m s)) ∧
    (∀ x, 0 ≤ x →
      (rawOperatingPayoff m s x = rawOperatingPayoff m s (inputStar m s) ↔
        x = inputStar m s)) ∧
    m.alpha * m.A * Real.rpow s (1 - m.alpha) *
        Real.rpow (inputStar m s) (m.alpha - 1) = m.w ∧
    m.A * Real.rpow s (1 - m.alpha) * Real.rpow (inputStar m s) m.alpha =
      operatingOutput m s ∧
    rawOperatingPayoff m s (inputStar m s) = operatingProfit m s := by
  have hxstar := inputStar_pos m hs
  have hcont := rawOperatingPayoff_continuous m (s := s)
  have hK : 0 < m.alpha * m.A * Real.rpow s (1 - m.alpha) := by
    exact mul_pos (mul_pos m.alpha_pos m.A_pos) (Real.rpow_pos_of_pos hs _)
  have hfoc := inputStar_foc m hs
  change m.alpha * m.A * Real.rpow s (1 - m.alpha) *
    (inputStar m s) ^ (m.alpha - 1) = m.w at hfoc
  have hderivPos : ∀ x ∈ Ioo 0 (inputStar m s),
      0 < deriv (rawOperatingPayoff m s) x := by
    intro x hx
    rw [(rawOperatingPayoff_hasDerivAt m hx.1.ne').deriv]
    have hp := Real.rpow_lt_rpow_of_neg hx.1 hx.2 (sub_neg.mpr m.alpha_lt_one)
    have hmul := mul_lt_mul_of_pos_left hp hK
    linarith
  have hderivNeg : ∀ x ∈ Ioi (inputStar m s),
      deriv (rawOperatingPayoff m s) x < 0 := by
    intro x hx
    rw [(rawOperatingPayoff_hasDerivAt m (ne_of_gt (lt_trans hxstar hx))).deriv]
    have hp := Real.rpow_lt_rpow_of_neg hxstar hx (sub_neg.mpr m.alpha_lt_one)
    have hmul := mul_lt_mul_of_pos_left hp hK
    linarith
  have hmono : StrictMonoOn (rawOperatingPayoff m s) (Icc 0 (inputStar m s)) := by
    apply strictMonoOn_of_deriv_pos (convex_Icc 0 (inputStar m s)) hcont.continuousOn
    simpa only [interior_Icc, hxstar] using hderivPos
  have hanti : StrictAntiOn (rawOperatingPayoff m s) (Ici (inputStar m s)) := by
    apply strictAntiOn_of_deriv_neg (convex_Ici (inputStar m s)) hcont.continuousOn
    simpa only [interior_Ici] using hderivNeg
  have hmax := inputStar_isMaxOn m hs
  refine ⟨fun x hx => hmax hx, ?_, inputStar_foc m hs, inputStar_output m hs,
    inputStar_payoff m hs⟩
  intro x hx
  constructor
  · intro heq
    rcases lt_trichotomy x (inputStar m s) with hlt | he | hgt
    · have hstrict := hmono ⟨hx, hlt.le⟩ ⟨hxstar.le, le_rfl⟩ hlt
      linarith
    · exact he
    · have hstrict := hanti (mem_Ici.mpr le_rfl) (mem_Ici.mpr hgt.le) hgt
      linarith
  · rintro rfl
    rfl

/-- Lemma 1 under exactly its A1--A2 numerical assumptions.  The optimizer's
signature contains no restart-cost parameter, which formalizes the stated independence. -/
theorem operating_optimum_A1_A2 (e : OperatingEnvironment) {s : ℝ} (hs : 0 < s) :
    (∀ x, 0 ≤ x →
      rawOperatingPayoffAt e s x ≤ rawOperatingPayoffAt e s (operatingInputStar e s)) ∧
    (∀ x, 0 ≤ x →
      (rawOperatingPayoffAt e s x = rawOperatingPayoffAt e s (operatingInputStar e s) ↔
        x = operatingInputStar e s)) ∧
    e.alpha * e.A * Real.rpow s (1 - e.alpha) *
        Real.rpow (operatingInputStar e s) (e.alpha - 1) = e.w ∧
    operatingInputStar e s =
      s * Real.rpow (e.alpha * e.A / e.w) (1 / (1 - e.alpha)) ∧
    rawOperatingOutputAt e s (operatingInputStar e s) = operatingOutputAt e s ∧
    operatingOutputAt e s =
      s * e.A * Real.rpow (e.alpha * e.A / e.w) (e.alpha / (1 - e.alpha)) ∧
    rawOperatingPayoffAt e s (operatingInputStar e s) = operatingProfitAt e s ∧
    operatingProfitAt e s = (1 - e.alpha) * operatingOutputAt e s - e.F - e.c0 := by
  have h := operating_optimum e.asModel hs
  rcases h with ⟨hmax, hunique, hfoc, houtput, hprofit⟩
  refine ⟨?_, ?_, ?_, rfl, ?_, rfl, ?_, rfl⟩
  · simpa [OperatingEnvironment.asModel, rawOperatingPayoffAt, operatingInputStar,
      rawOperatingPayoff, inputStar] using hmax
  · simpa [OperatingEnvironment.asModel, rawOperatingPayoffAt, operatingInputStar,
      rawOperatingPayoff, inputStar] using hunique
  · simpa [OperatingEnvironment.asModel, operatingInputStar, inputStar] using hfoc
  · simpa [OperatingEnvironment.asModel, rawOperatingOutputAt, operatingInputStar,
      operatingOutputAt, inputStar, operatingOutput] using houtput
  · simpa [OperatingEnvironment.asModel, rawOperatingPayoffAt, operatingInputStar,
      operatingOutputAt, operatingProfitAt, rawOperatingPayoff, inputStar, operatingProfit,
      operatingOutput] using hprofit

end

end Saco26InstitutionalRestart
