module PacioTestKit
  module PFE
    class ConditionEncounterDiagnosisGroup < Inferno::TestGroup
      title 'Condition Encounter Diagnostic Tests'
      id :pacio_pfe_condition_encounter_diagnosis
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Condition Encounter Diagnosis Profile.
      )
      description 'TODO: Add description.'
      optional
      run_as_group
    end
  end
end
