require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'
require_relative 'single_observation/single_observation_validation_test'

module PacioTestKit
  module PFE
    class SingleObservationGroup < Inferno::TestGroup
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

      test from: :pacio_resource_create,
           title: 'Server creates correct Observation resource from Observation create interaction',
           config: {
             inputs: {
               resource_inputs: {
                 name: :single_observation_resource_list,
                 title: 'Default resource for PFESingleObservation to create on the server'
               }
             }
           }
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
      test from: :pacio_pfe_single_observation_validation
    end
  end
end
