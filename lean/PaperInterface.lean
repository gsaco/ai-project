import Saco26InstitutionalRestart.Model
import Saco26InstitutionalRestart.Assumptions

/-!
# Paper Interface: Economic freedom and firm entry--exit decisions

The six transparent specifications below follow the six numbered claims in the
pinned eight-page working paper. They describe the paper's conditional
one-period input problem and its reduced infinite-horizon Boolean activity
problem. They do **not** assert that Lean has proved the reduction from the
paper's joint input/activity program (1) to the reduced program (2).
-/

namespace Saco26InstitutionalRestart

/-- Lemma 1 (Operating optimum), under exactly the numerical content of A1--A2.
Restart cost is absent from both the conditional objective and optimizer. -/
def lemma1_operating_optimumSpec : Prop :=
  ∀ (e : OperatingEnvironment) {s : ℝ}, 0 < s → s ≤ 1 →
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
    operatingProfitAt e s = (1 - e.alpha) * operatingOutputAt e s - e.F - e.c0

/-- Lemma 2 (Restored-state values and delayed restarting), over arbitrary
infinite Boolean activity paths, including all delayed-restart ties. -/
def lemma2_restored_state_values_and_delaysSpec : Prop :=
  ∀ (m : Model), NormallyViable m →
    (∀ a, restoredPathValue (pi0 m) m.beta m.kappa true a ≤ activeValue m) ∧
    restoredPathValue (pi0 m) m.beta m.kappa true alwaysActive = activeValue m ∧
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
      restoredPathValue (pi0 m) m.beta m.kappa false alwaysInactive = inactiveValue m)

/-- Proposition 1 (Persistent strict asymmetry), including the otherwise
identical free-restart comparison and all stated output identities. -/
def proposition1_persistent_strict_asymmetrySpec : Prop :=
  ∀ (m : Model),
    NormallyViable m →
    piMinus m + m.beta * activeValue m < 0 →
    activeValue m < m.kappa →
    ((IsShockOptimal m .adverse alwaysInactive ∧
        ∀ a, IsShockOptimal m .adverse a → a = alwaysInactive) ∧
      (IsShockOptimal m .unchanged alwaysActive ∧
        ∀ a, IsShockOptimal m .unchanged a → a = alwaysActive) ∧
      (IsShockOptimal m .favorable alwaysActive ∧
        ∀ a, IsShockOptimal m .favorable a → a = alwaysActive)) ∧
    (actualOutput m .unchanged alwaysActive 0 -
        actualOutput m .adverse alwaysInactive 0 = q0 m ∧
      actualOutput m .favorable alwaysActive 0 -
        actualOutput m .unchanged alwaysActive 0 = q0 m * (m.d / m.s0) ∧
      q0 m > q0 m * (m.d / m.s0) ∧
      (∀ t, actualOutput m .unchanged alwaysActive (t + 1) -
        actualOutput m .adverse alwaysInactive (t + 1) = q0 m) ∧
      (∀ t, actualOutput m .favorable alwaysActive (t + 1) -
        actualOutput m .unchanged alwaysActive (t + 1) = 0)) ∧
    (let m0 := m.withKappa 0 (le_refl 0);
      (IsShockOptimal m0 .adverse closeThenRestart ∧
        ∀ a, IsShockOptimal m0 .adverse a → a = closeThenRestart) ∧
      (IsShockOptimal m0 .unchanged alwaysActive ∧
        ∀ a, IsShockOptimal m0 .unchanged a → a = alwaysActive) ∧
      (IsShockOptimal m0 .favorable alwaysActive ∧
        ∀ a, IsShockOptimal m0 .favorable a → a = alwaysActive)) ∧
    (let m0 := m.withKappa 0 (le_refl 0);
      actualOutput m0 .unchanged alwaysActive 0 -
          actualOutput m0 .adverse closeThenRestart 0 = q0 m0 ∧
        (∀ t, actualOutput m0 .unchanged alwaysActive (t + 1) -
          actualOutput m0 .adverse closeThenRestart (t + 1) = 0) ∧
        (∀ t, actualOutput m0 .favorable alwaysActive (t + 1) -
          actualOutput m0 .unchanged alwaysActive (t + 1) = 0))

/-- Proposition 2 (Complete closure threshold and weak asymmetry), including
both strict directions, equality, post-closure switching, and arbitrary
globally optimal tie selections. -/
def proposition2_complete_closure_thresholdSpec : Prop :=
  ∀ (m : Model), NormallyViable m →
    ((impactContinueValue m .adverse < impactClosureValue m ↔
        pi0 m + m.beta * min m.kappa (activeValue m) <
          (1 - m.alpha) * q0 m * (m.d / m.s0)) ∧
      (impactClosureValue m < impactContinueValue m .adverse ↔
        (1 - m.alpha) * q0 m * (m.d / m.s0) <
          pi0 m + m.beta * min m.kappa (activeValue m)) ∧
      (impactContinueValue m .adverse = impactClosureValue m ↔
        (1 - m.alpha) * q0 m * (m.d / m.s0) =
          pi0 m + m.beta * min m.kappa (activeValue m))) ∧
    (impactClosureValue m < impactContinueValue m .adverse →
      IsShockOptimal m .adverse alwaysActive ∧
        ∀ a, IsShockOptimal m .adverse a → a = alwaysActive) ∧
    (impactContinueValue m .adverse < impactClosureValue m →
      (∃ a, IsShockOptimal m .adverse a ∧ a 0 = false) ∧
        ∀ a, IsShockOptimal m .adverse a → a 0 = false) ∧
    (impactContinueValue m .adverse = impactClosureValue m →
      IsShockOptimal m .adverse alwaysActive ∧
        ∃ a, IsShockOptimal m .adverse a ∧ a 0 = false) ∧
    (m.kappa < activeValue m →
      ∀ a, restoredPathValue (pi0 m) m.beta m.kappa false a = inactiveValue m ↔
        a = alwaysActive) ∧
    (activeValue m < m.kappa →
      ∀ a, restoredPathValue (pi0 m) m.beta m.kappa false a = inactiveValue m ↔
        a = alwaysInactive) ∧
    (m.kappa = activeValue m →
      (∀ n, restoredPathValue (pi0 m) m.beta m.kappa false (delayedRestart n) =
        inactiveValue m) ∧
      restoredPathValue (pi0 m) m.beta m.kappa false alwaysInactive = inactiveValue m) ∧
    Nonempty (OptimalProfile m) ∧
    (∀ p : OptimalProfile m,
      (∀ t, outputLoss m p t ≥ outputGain m p t ∧ outputGain m p t ≥ 0) ∧
      (outputLoss m p 0 > outputGain m p 0 ↔ p.adverse 0 = false) ∧
      (∀ t, outputLoss m p (t + 1) > outputGain m p (t + 1) ↔
        p.adverse (t + 1) = false))

/-- Proposition 3 (Cheap suspension removes persistence). `suspend` is a
date-zero action worth `-h + βV`; `suspendedThenResumedOutput` explicitly
records its zero-impact, active-from-date-one output semantics. -/
def proposition3_cheap_suspensionSpec : Prop :=
  ∀ (m : Model),
    NormallyViable m →
    piMinus m + m.beta * activeValue m < 0 →
    activeValue m < m.kappa →
    ∀ {h : ℝ}, 0 ≤ h → h < m.beta * activeValue m →
      (IsUniqueBestImpactAction m h .adverse .suspend ∧
        IsUniqueBestImpactAction m h .unchanged .operate ∧
        IsUniqueBestImpactAction m h .favorable .operate) ∧
      suspendedThenResumedOutput m 0 = 0 ∧
      (∀ t, suspendedThenResumedOutput m (t + 1) = q0 m) ∧
      restoredPathValue (pi0 m) m.beta m.kappa true alwaysActive = activeValue m ∧
      (actualOutput m .unchanged alwaysActive 0 -
        suspendedThenResumedOutput m 0 = q0 m) ∧
      (∀ t, actualOutput m .unchanged alwaysActive (t + 1) -
        suspendedThenResumedOutput m (t + 1) = 0) ∧
      (∀ t, actualOutput m .favorable alwaysActive (t + 1) -
        actualOutput m .unchanged alwaysActive (t + 1) = 0)

/-- Corollary 1 (Positive totals and logs), for the costly-restart paths in
Proposition 1 and a common positive population in the per-capita comparison. -/
def corollary1_positive_totals_and_logsSpec : Prop :=
  ∀ (m : Model),
    NormallyViable m →
    piMinus m + m.beta * activeValue m < 0 →
    activeValue m < m.kappa →
    ∀ {B N : ℝ}, 0 < B → 0 < N → ∀ t,
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
            Real.log (perCapitaTotal B N P m .unchanged alwaysActive t))

end Saco26InstitutionalRestart
