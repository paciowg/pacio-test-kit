require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class ParticipantRelatedPersonGroup < Inferno::TestGroup
      title 'ADI Participant Related Person Tests'
      id :pacio_adi_participant_related_person
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Participant Profile
      )
      optional

      config options: {
        resource_type: 'RelatedPerson',
        profile: 'ADIParticipant'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct RelatedPerson resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :participant_related_person_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIParticipant RelatedPerson resources present on the server'
               }
             }
           }
    end
  end
end
