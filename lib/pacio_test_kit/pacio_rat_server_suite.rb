module PacioTestKit
  class PacioRATServerSuite < Inferno::TestSuite
    id :pacio_rat_server
    title 'PACIO Re-Assessment Timepoints Server Test Suite'
    description 'PACIO Re-Assessment Timepoints Server Test Suite'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    fhir_resource_validator do
      igs('igs/rat-package.tgz', 'hl7.fhir.us.core')

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end
  end
end
