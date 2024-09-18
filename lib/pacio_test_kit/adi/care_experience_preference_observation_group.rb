require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class CareExperiencePreferenceObservationGroup < Inferno::TestGroup
      title 'ADI Care Experience Preference Observation Tests'
      id :pacio_adi_care_experience_preference_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Care Experience Preference Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADICareExperiencePreference'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :care_experience_preference_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADICareExperiencePreference resources present on the server'
               }
             }
           }
    end
  end
end
