require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class ParticipantConsentGroup < Inferno::TestGroup
      title 'ADI Participant Consent Tests'
      id :pacio_adi_participant_consent
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI Participant Consent Profile
      )
      optional

      config options: {
        resource_type: 'Consent',
        profile: 'ADIParticipantConsent'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Consent resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :participant_consent_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIParticipantConsent resources present on the server'
               }
             }
           }
    end
  end
end
