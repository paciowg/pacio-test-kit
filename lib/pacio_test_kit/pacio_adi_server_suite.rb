require_relative 'error_handling_group'

module PacioTestKit
  class PacioADIServerSuite < Inferno::TestSuite
    id :pacio_adi_server
    title 'PACIO ADI Server Test Suite'
    description 'PACIO Advance Directives Server Test Suite'

    input :url,
          title: 'FHIR Server Base URL'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    fhir_client do
      url :url
      oauth_credentials :credentials
    end

    fhir_resource_validator do
      igs 'hl7.fhir.us.pacio-adi'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    group do
      group from: :pacio_error_handling
    end
  end
end
