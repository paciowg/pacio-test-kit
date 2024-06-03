module PacioTestKit
  class PacioSPLASHServerSuite < Inferno::TestSuite
    id :pacio_splash_server
    title 'PACIO SPLASH Server Test Suite'
    description 'PACIO Speech Language Swallowing Cognitive Communication and Hearing Server Test Suite'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    fhir_resource_validator do
      igs('hl7.fhir.us.pacio-splasch', 'hl7.fhir.us.core')

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end
  end
end
