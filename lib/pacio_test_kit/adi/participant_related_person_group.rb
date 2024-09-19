require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class ParticipantRelatedPersonGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      test from: :pacio_resource_validation,
           title: 'RelatedPerson Resources returned in previous tests conform to the ADIParticipant profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
