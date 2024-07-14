require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class SingleObservationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Single Observation Tests'
      id :pacio_pfe_single_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Single Observation Profile.
      )
      description 'TODO: Add description'

      config options: {
        resource_type: 'Observation',
        profile: 'PFESingleObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from Observation read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :single_observation_resource_ids,
                 title: 'ID(s) for PFESingleObservation resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Observation Resources returned in previous tests conform to the PFESingleObservation profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
