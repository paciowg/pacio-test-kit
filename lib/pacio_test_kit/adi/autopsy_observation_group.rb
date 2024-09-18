require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class AutopsyObservationGroup < Inferno::TestGroup
      title 'ADI Autopsy Observation Tests'
      id :pacio_adi_autopsy_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Autopsy Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIAutopsyObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :autopsy_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIAutopsyObservation resources present on the server'
               }
             }
           }
    end
  end
end
