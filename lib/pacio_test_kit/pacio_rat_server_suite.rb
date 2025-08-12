module PacioTestKit
  class PacioRATServerSuite < Inferno::TestSuite
    id :pacio_rat_server
    title 'PACIO Re-Assessment Timepoints Server Test Suite'
    description 'PACIO Re-Assessment Timepoints Server Test Suite'
    ig_url 'https://hl7.org/fhir/us/pacio-rt/'
    source_code_url 'https://github.com/paciowg/pacio-test-kit'
    download_url 'https://github.com/paciowg/pacio-test-kit'
    report_issue_url 'https://github.com/paciowg/pacio-test-kit/issues'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    fhir_resource_validator do
      igs 'hl7.fhir.us.pacio-rt'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end
  end
end
