require_relative '../common_tests/read_test'

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

      config options: {
        resource_type: 'Condition',
        profile: 'PFEConditionEncounterDiagnosis'
      }
      run_as_group

      test from: :pacio_resource_read,
           title: 'Server returns correct Condition resource from Condition read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :condition_encounter_diagnosis_resource_ids,
                 title: 'ID(s) for PFEConditionEncounterDiagnosis resources present on the server'
               }
             }
           }
    end
  end
end
