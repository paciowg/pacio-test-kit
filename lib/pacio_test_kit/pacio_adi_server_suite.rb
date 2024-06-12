module PacioTestKit
  class PacioADIServerSuite < Inferno::TestSuite
    id :pacio_adi_server
    title 'PACIO ADI Server Test Suite'
    description 'PACIO Advance Directives Server Test Suite'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    fhir_resource_validator do
      igs 'hl7.fhir.us.pacio-adi'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end
  end
end
