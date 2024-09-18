require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PersonalInterventionPreferenceObservationGroup < Inferno::TestGroup
      title 'ADI Personal Intervention Preference Observation Tests'
      id :pacio_adi_personal_intervention_preference_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Personal Intervention Preference Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIPersonalInterventionPreference'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :personal_intervention_preference_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPersonalInterventionPreference resources present on the server'
               }
             }
           }
    end
  end
end
