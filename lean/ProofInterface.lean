import Saco26InstitutionalRestart.PaperInterface
import Saco26InstitutionalRestart.Operating
import Saco26InstitutionalRestart.Results

/-! Exact-type checked endpoints for the six source-facing specifications. -/

namespace Saco26InstitutionalRestart

theorem lemma1_operating_optimum_proof : lemma1_operating_optimumSpec := by
  intro e s hs _
  exact operating_optimum_A1_A2 e hs

theorem lemma2_restored_state_values_and_delays_proof :
    lemma2_restored_state_values_and_delaysSpec := by
  intro m hviable
  exact restored_state_values_and_delays m hviable

theorem proposition1_persistent_strict_asymmetry_proof :
    proposition1_persistent_strict_asymmetrySpec := by
  intro m hviable hadverse hkappa
  have hmain : PersistentConditions m := ⟨hviable, hadverse, hkappa⟩
  have hpaths := persistent_strict_asymmetry_paths m hmain
  have hfree := free_restart_asymmetry_paths m hmain
  have hout := persistent_and_free_output_identities m
  rcases hout with ⟨hL0, hG0, hstrict, hLlater, hGlater, hfree0, hfreelater⟩
  have hfreeOutputs :
      let m0 := m.withKappa 0 (le_refl 0)
      actualOutput m0 .unchanged alwaysActive 0 -
          actualOutput m0 .adverse closeThenRestart 0 = q0 m0 ∧
        (∀ t, actualOutput m0 .unchanged alwaysActive (t + 1) -
          actualOutput m0 .adverse closeThenRestart (t + 1) = 0) ∧
        (∀ t, actualOutput m0 .favorable alwaysActive (t + 1) -
          actualOutput m0 .unchanged alwaysActive (t + 1) = 0) := by
    simpa [Model.withKappa, actualOutput, impactUsableShare] using
      And.intro hfree0 (And.intro hfreelater hGlater)
  exact ⟨hpaths, ⟨hL0, hG0, hstrict, hLlater, hGlater⟩, hfree,
    hfreeOutputs⟩

theorem proposition2_complete_closure_threshold_proof :
    proposition2_complete_closure_thresholdSpec := by
  intro m hviable
  have hthreshold := complete_adverse_closure_threshold m hviable
  have hbehavior := adverse_impact_choice_behavior m hviable
  have hrestored := restored_state_values_and_delays m hviable
  rcases hrestored with ⟨_, _, _, hrestart, hinactive, htie⟩
  refine ⟨hthreshold, hbehavior.1, hbehavior.2.1, hbehavior.2.2,
    hrestart, hinactive, htie, optimalProfile_nonempty m hviable, ?_⟩
  intro p
  exact any_optimal_profile_weak_asymmetry m hviable p

theorem proposition3_cheap_suspension_proof : proposition3_cheap_suspensionSpec := by
  intro m hviable hadverse hkappa h hh0 hh
  have hmain : PersistentConditions m := ⟨hviable, hadverse, hkappa⟩
  have hchoice := cheap_suspension_unique_actions m hmain hh0 hh
  have hresume := suspension_output_and_resumption m hviable
  rcases hresume with ⟨hzero, hlater, hactive⟩
  have hnormal0 : actualOutput m .unchanged alwaysActive 0 = q0 m := by
    simp [actualOutput, impactUsableShare, alwaysActive]
    exact operatingOutput_s0 m
  have hnormalLater : ∀ t, actualOutput m .unchanged alwaysActive (t + 1) = q0 m := by
    intro t
    simp [actualOutput, alwaysActive]
    exact operatingOutput_s0 m
  have hfavorableLater : ∀ t, actualOutput m .favorable alwaysActive (t + 1) = q0 m := by
    intro t
    simp [actualOutput, alwaysActive]
    exact operatingOutput_s0 m
  refine ⟨hchoice, hzero, hlater, hactive, ?_, ?_, ?_⟩
  · rw [hnormal0, hzero]
    ring
  · intro t
    rw [hnormalLater t, hlater t]
    ring
  · intro t
    rw [hfavorableLater t, hnormalLater t]
    ring

theorem corollary1_positive_totals_and_logs_proof :
    corollary1_positive_totals_and_logsSpec := by
  intro m hviable hadverse hkappa B N hB hN
  exact positive_totals_logs_and_perCapita m ⟨hviable, hadverse, hkappa⟩ hB hN

end Saco26InstitutionalRestart
