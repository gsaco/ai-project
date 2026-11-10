import Mathlib.Analysis.Calculus.DerivativeTest
import Mathlib.Analysis.Convex.SpecificFunctions.Pow
import Mathlib.Analysis.Normed.Group.InfiniteSum
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Monotone
import Mathlib.Analysis.SpecialFunctions.Pow.Deriv
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Tactic

/-!
# Economic freedom and firm entry--exit decisions: model

This file gives the paper-local source model used by the six numbered results.
The switching layer is an infinite-horizon model over arbitrary Boolean
activity paths.  It is not a finite-horizon simulation and it does not assume
that a path has at most one restart.
-/

open scoped BigOperators Topology
open Filter Set

namespace Saco26InstitutionalRestart

noncomputable section

/-- Source primitives and their maintained numerical restrictions (A1--A6). -/
structure Model where
  A : ℝ
  w : ℝ
  F : ℝ
  c0 : ℝ
  alpha : ℝ
  s0 : ℝ
  d : ℝ
  beta : ℝ
  kappa : ℝ
  A_pos : 0 < A
  w_pos : 0 < w
  F_pos : 0 < F
  c0_nonneg : 0 ≤ c0
  alpha_pos : 0 < alpha
  alpha_lt_one : alpha < 1
  s0_pos : 0 < s0
  d_pos : 0 < d
  d_lt_s0 : d < s0
  s0_add_d_le_one : s0 + d ≤ 1
  beta_pos : 0 < beta
  beta_lt_one : beta < 1
  kappa_nonneg : 0 ≤ kappa

/-- Exactly the A1--A2 primitives needed by the paper's conditional operating lemma. -/
structure OperatingEnvironment where
  A : ℝ
  w : ℝ
  F : ℝ
  c0 : ℝ
  alpha : ℝ
  A_pos : 0 < A
  w_pos : 0 < w
  F_pos : 0 < F
  c0_nonneg : 0 ≤ c0
  alpha_pos : 0 < alpha
  alpha_lt_one : alpha < 1

/-- A proof adapter whose dynamic fields are fixed harmlessly; paper-facing operating
statements quantify only over `OperatingEnvironment`, so they do not assume A3--A6. -/
def OperatingEnvironment.asModel (e : OperatingEnvironment) : Model where
  A := e.A
  w := e.w
  F := e.F
  c0 := e.c0
  alpha := e.alpha
  s0 := 1 / 2
  d := 1 / 4
  beta := 1 / 2
  kappa := 0
  A_pos := e.A_pos
  w_pos := e.w_pos
  F_pos := e.F_pos
  c0_nonneg := e.c0_nonneg
  alpha_pos := e.alpha_pos
  alpha_lt_one := e.alpha_lt_one
  s0_pos := by norm_num
  d_pos := by norm_num
  d_lt_s0 := by norm_num
  s0_add_d_le_one := by norm_num
  beta_pos := by norm_num
  beta_lt_one := by norm_num
  kappa_nonneg := le_rfl

/-- Conditional input choice using only A1--A2 primitives.  Restart cost is absent. -/
def operatingInputStar (e : OperatingEnvironment) (s : ℝ) : ℝ :=
  s * Real.rpow (e.alpha * e.A / e.w) (1 / (1 - e.alpha))

/-- Conditional output using only A1--A2 primitives. -/
def operatingOutputAt (e : OperatingEnvironment) (s : ℝ) : ℝ :=
  s * e.A * Real.rpow (e.alpha * e.A / e.w) (e.alpha / (1 - e.alpha))

/-- Conditional optimized profit using only A1--A2 primitives. -/
def operatingProfitAt (e : OperatingEnvironment) (s : ℝ) : ℝ :=
  (1 - e.alpha) * operatingOutputAt e s - e.F - e.c0

/-- The unoptimized one-period A1--A2 operating payoff. -/
def rawOperatingPayoffAt (e : OperatingEnvironment) (s x : ℝ) : ℝ :=
  e.A * Real.rpow s (1 - e.alpha) * Real.rpow x e.alpha - e.w * x - e.F - e.c0

/-- Physical output before input optimization in the A1--A2 operating problem. -/
def rawOperatingOutputAt (e : OperatingEnvironment) (s x : ℝ) : ℝ :=
  e.A * Real.rpow s (1 - e.alpha) * Real.rpow x e.alpha

/-- Replace only the restart cost, as in the paper's free-restart comparison. -/
def Model.withKappa (m : Model) (k : ℝ) (hk : 0 ≤ k) : Model where
  A := m.A
  w := m.w
  F := m.F
  c0 := m.c0
  alpha := m.alpha
  s0 := m.s0
  d := m.d
  beta := m.beta
  kappa := k
  A_pos := m.A_pos
  w_pos := m.w_pos
  F_pos := m.F_pos
  c0_nonneg := m.c0_nonneg
  alpha_pos := m.alpha_pos
  alpha_lt_one := m.alpha_lt_one
  s0_pos := m.s0_pos
  d_pos := m.d_pos
  d_lt_s0 := m.d_lt_s0
  s0_add_d_le_one := m.s0_add_d_le_one
  beta_pos := m.beta_pos
  beta_lt_one := m.beta_lt_one
  kappa_nonneg := hk

@[simp] lemma Model.withKappa_kappa (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    (m.withKappa k hk).kappa = k := rfl

@[simp] lemma Model.withKappa_beta (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    (m.withKappa k hk).beta = m.beta := rfl

/-- Conditional input choice displayed in Lemma 1. -/
def inputStar (m : Model) (s : ℝ) : ℝ :=
  s * Real.rpow (m.alpha * m.A / m.w) (1 / (1 - m.alpha))

/-- Conditional output after input optimization. -/
def operatingOutput (m : Model) (s : ℝ) : ℝ :=
  s * m.A * Real.rpow (m.alpha * m.A / m.w) (m.alpha / (1 - m.alpha))

/-- Conditional operating profit after input optimization. -/
def operatingProfit (m : Model) (s : ℝ) : ℝ :=
  (1 - m.alpha) * operatingOutput m s - m.F - m.c0

/-- The unoptimized one-period Cobb--Douglas operating payoff. -/
def rawOperatingPayoff (m : Model) (s x : ℝ) : ℝ :=
  m.A * Real.rpow s (1 - m.alpha) * Real.rpow x m.alpha - m.w * x - m.F - m.c0

/-- Normal output `q₀`. -/
def q0 (m : Model) : ℝ := operatingOutput m m.s0

/-- Normal optimized operating profit `π₀`. -/
def pi0 (m : Model) : ℝ := operatingProfit m m.s0

/-- Adverse optimized operating profit `π₋`. -/
def piMinus (m : Model) : ℝ := operatingProfit m (m.s0 - m.d)

/-- Favorable optimized operating profit `π₊`. -/
def piPlus (m : Model) : ℝ := operatingProfit m (m.s0 + m.d)

/-- The maintained A6 viability condition. -/
def NormallyViable (m : Model) : Prop := 0 < pi0 m

/-- Restored active value `V = π₀/(1-β)`. -/
def activeValue (m : Model) : ℝ := pi0 m / (1 - m.beta)

/-- Restored inactive value `W = max {V-κ,0}`. -/
def inactiveValue (m : Model) : ℝ := max (activeValue m - m.kappa) 0

@[simp] lemma q0_withKappa (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    q0 (m.withKappa k hk) = q0 m := rfl

@[simp] lemma pi0_withKappa (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    pi0 (m.withKappa k hk) = pi0 m := rfl

@[simp] lemma piMinus_withKappa (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    piMinus (m.withKappa k hk) = piMinus m := rfl

@[simp] lemma piPlus_withKappa (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    piPlus (m.withKappa k hk) = piPlus m := rfl

@[simp] lemma activeValue_withKappa (m : Model) (k : ℝ) (hk : 0 ≤ k) :
    activeValue (m.withKappa k hk) = activeValue m := rfl

/-- Activity paths are unrestricted infinite Boolean sequences. -/
abbrev ActivityPath := ℕ → Bool

/-- State immediately before a period, including the supplied date-minus-one state. -/
def stateBefore (prior : Bool) (a : ActivityPath) : ℕ → Bool
  | 0 => prior
  | n + 1 => a n

/-- One-period reduced payoff, including a closed-to-open restart charge. -/
def periodPayoff (pi kappa : ℝ) (previous current : Bool) : ℝ :=
  (if current then pi else 0) - (if current && !previous then kappa else 0)

/-- Infinite discounted payoff of an arbitrary restored-state activity path. -/
def restoredPathValue (pi beta kappa : ℝ) (prior : Bool) (a : ActivityPath) : ℝ :=
  ∑' t : ℕ, beta ^ t * periodPayoff pi kappa (stateBefore prior a t) (a t)

/-- Bellman potential attached to the active/inactive organizational state. -/
def restoredPotential (V W : ℝ) (state : Bool) : ℝ := if state then V else W

/-- One-period Bellman slack. -/
def bellmanSlack (pi beta kappa V W : ℝ) (prior : Bool) (a : ActivityPath)
    (t : ℕ) : ℝ :=
  restoredPotential V W (stateBefore prior a t) -
    (periodPayoff pi kappa (stateBefore prior a t) (a t) +
      beta * restoredPotential V W (a t))

/-- Discounted Bellman slack. -/
def discountedSlack (pi beta kappa V W : ℝ) (prior : Bool) (a : ActivityPath)
    (t : ℕ) : ℝ :=
  beta ^ t * bellmanSlack pi beta kappa V W prior a t

/-- The path that operates in every period. -/
def alwaysActive : ActivityPath := fun _ => true

/-- The path that remains inactive in every period. -/
def alwaysInactive : ActivityPath := fun _ => false

/-- Restart after exactly `n` restored periods of inactivity, then remain active. -/
def delayedRestart (n : ℕ) : ActivityPath := fun t => decide (n ≤ t)

/-- Close at impact, restart at date one, and remain active. -/
def closeThenRestart : ActivityPath
  | 0 => false
  | _ + 1 => true

/-- A path is optimal in a restored state when it attains the Bellman potential. -/
def IsRestoredOptimal (m : Model) (prior : Bool) (a : ActivityPath) : Prop :=
  restoredPathValue (pi0 m) m.beta m.kappa prior a =
    restoredPotential (activeValue m) (inactiveValue m) prior

inductive Shock
  | adverse
  | unchanged
  | favorable
  deriving DecidableEq, Repr

/-- Optimized date-zero profit for a matched adverse, unchanged, or favorable shock. -/
def impactProfit (m : Model) : Shock → ℝ
  | .adverse => piMinus m
  | .unchanged => pi0 m
  | .favorable => piPlus m

/-- Date-zero usable property for a matched shock. -/
def impactUsableShare (m : Model) : Shock → ℝ
  | .adverse => m.s0 - m.d
  | .unchanged => m.s0
  | .favorable => m.s0 + m.d

/-- Full reduced payoff: the impact period followed by an arbitrary restored tail. -/
def shockPathValue (m : Model) (j : Shock) (a : ActivityPath) : ℝ :=
  periodPayoff (impactProfit m j) m.kappa true (a 0) +
    m.beta * restoredPathValue (pi0 m) m.beta m.kappa (a 0) (fun t => a (t + 1))

/-- Global optimality over all infinite activity paths in one shock experiment. -/
def IsShockOptimal (m : Model) (j : Shock) (a : ActivityPath) : Prop :=
  ∀ b : ActivityPath, shockPathValue m j b ≤ shockPathValue m j a

/-- Actual output along a shock path. -/
def actualOutput (m : Model) (j : Shock) (a : ActivityPath) (t : ℕ) : ℝ :=
  if a t then
    operatingOutput m (if t = 0 then impactUsableShare m j else m.s0)
  else 0

/-- Output generated by the paper's date-zero suspension extension: no impact
output, followed by costless restoration of the active organization at date one. -/
def suspendedThenResumedOutput (m : Model) (t : ℕ) : ℝ :=
  if t = 0 then 0 else q0 m

/-- A jointly optimal selection for the three matched experiments. -/
structure OptimalProfile (m : Model) where
  adverse : ActivityPath
  unchanged : ActivityPath
  favorable : ActivityPath
  adverse_optimal : IsShockOptimal m .adverse adverse
  unchanged_optimal : IsShockOptimal m .unchanged unchanged
  favorable_optimal : IsShockOptimal m .favorable favorable

def outputLoss (m : Model) (p : OptimalProfile m) (t : ℕ) : ℝ :=
  actualOutput m .unchanged p.unchanged t - actualOutput m .adverse p.adverse t

def outputGain (m : Model) (p : OptimalProfile m) (t : ℕ) : ℝ :=
  actualOutput m .favorable p.favorable t - actualOutput m .unchanged p.unchanged t

/-- Fixed-cohort total used only in the paper's logarithm corollary. -/
def cohortTotal (B N : ℝ) (m : Model) (j : Shock) (a : ActivityPath) (t : ℕ) : ℝ :=
  B + N * actualOutput m j a t

/-- Per-capita version when all matched paths share population `P`. -/
def perCapitaTotal (B N P : ℝ) (m : Model) (j : Shock) (a : ActivityPath) (t : ℕ) : ℝ :=
  cohortTotal B N m j a t / P

/-- The three strict hypotheses used by Proposition 1, with A6 represented by `NormallyViable`. -/
def PersistentConditions (m : Model) : Prop :=
  NormallyViable m ∧ piMinus m + m.beta * activeValue m < 0 ∧ m.kappa > activeValue m

/-- Continuation value at impact when the firm operates. -/
def impactContinueValue (m : Model) (j : Shock) : ℝ :=
  impactProfit m j + m.beta * activeValue m

/-- Closure value at impact, including the option to restart after restoration. -/
def impactClosureValue (m : Model) : ℝ := m.beta * inactiveValue m

inductive ImpactAction
  | operate
  | close
  | suspend
  deriving DecidableEq, Repr

/-- Impact value when cheap suspension is available only at date zero. -/
def suspensionActionValue (m : Model) (h : ℝ) (j : Shock) : ImpactAction → ℝ
  | .operate => impactContinueValue m j
  | .close => impactClosureValue m
  | .suspend => -h + m.beta * activeValue m

/-- A unique maximizer over the three date-zero actions. -/
def IsUniqueBestImpactAction (m : Model) (h : ℝ) (j : Shock) (choice : ImpactAction) : Prop :=
  ∀ other, suspensionActionValue m h j other ≤ suspensionActionValue m h j choice ∧
    (suspensionActionValue m h j other = suspensionActionValue m h j choice → other = choice)

end

end Saco26InstitutionalRestart
