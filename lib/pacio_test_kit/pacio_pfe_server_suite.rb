module PacioTestKit
  class PacioPFEServerSuite < Inferno::TestSuite
    id :pacio_pfe_server
    title 'PACIO PFE Server Test Suite'
    description 'PACIO Personal Functioning and Engagement Server Test Suite'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    fhir_resource_validator do
      igs('igs/pfe-package.tgz', 'hl7.fhir.us.core')

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end
  end
end
