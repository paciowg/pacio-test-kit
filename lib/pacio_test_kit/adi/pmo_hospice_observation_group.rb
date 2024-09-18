require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PMOHospiceObservationGroup < Inferno::TestGroup
      title 'ADI PMO Hospice Observation Tests'
      id :pacio_adi_pmo_hospice_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI PMO Hospice Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIPMOHospiceObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_hospice_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOHospiceObservation resources present on the server'
               }
             }
           }
    end
  end
end
