require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PMOParticipantObservationGroup < Inferno::TestGroup
      title 'ADI PMO Participant Observation Tests'
      id :pacio_adi_pmo_participant_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI PMO Participant Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIPMOParticipantObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_participant_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOParticipantObservation resources present on the server'
               }
             }
           }
    end
  end
end
