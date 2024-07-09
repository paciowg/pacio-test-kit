require_relative '../common_tests/read_test'
require_relative 'collection_observation/collection_observation_validation_test'

module PacioTestKit
  module PFE
    class CollectionObservationGroup < Inferno::TestGroup
      title 'Collection Observation Tests'
      id :pacio_pfe_collection_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Collection Profile.
      )
      description 'TODO: Add description.'

      config options: {
        resource_type: 'Observation',
        profile: 'PFECollection'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from Observation read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :collection_observation_resource_ids,
                 title: 'ID(s) for PFECollection resources present on the server'
               }
             }
           }
      test from: :pacio_pfe_collection_observation_validation
    end
  end
end
