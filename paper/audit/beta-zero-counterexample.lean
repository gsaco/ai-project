import Saco26InstitutionalRestart.Model

-- AI-assisted diagnostic, outside the paper's maintained beta > 0 domain.
-- This is not Gabriel's independent handwritten evaluation.
open Saco26InstitutionalRestart

def activeOnlyNow (t : ℕ) : Bool := decide (t = 0)
def inactiveOnlyNow (t : ℕ) : Bool := decide (0 < t)

example : restoredPathValue 1 0 0 false activeOnlyNow = 1 := by
  simp [restoredPathValue, activeOnlyNow, periodPayoff, stateBefore]

example : activeOnlyNow ≠ alwaysActive := by
  intro h
  have ht := congrFun h 1
  simp [activeOnlyNow, alwaysActive] at ht

example : restoredPathValue 1 0 2 false inactiveOnlyNow = 0 := by
  unfold restoredPathValue
  calc
    _ = ∑' (_t : ℕ), (0 : ℝ) := by
      apply tsum_congr
      intro t
      cases t with
      | zero => simp [inactiveOnlyNow, periodPayoff, stateBefore]
      | succ n => simp
    _ = 0 := by simp

example : inactiveOnlyNow ≠ alwaysInactive := by
  intro h
  have ht := congrFun h 1
  simp [inactiveOnlyNow, alwaysInactive] at ht
