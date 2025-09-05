require_relative 'pacio_profiles'
require_relative 'toc/toc_bundle_group'
require_relative 'toc/toc_composition_group'
require_relative 'toc/toc_organization_group'
require_relative 'toc/toc_patient_group'

module PacioTestKit
  class PacioTOCServerSuite < Inferno::TestSuite
    include PacioTestKit::PacioProfiles

    id :pacio_toc_server
    title 'PACIO TOC Server Suite v1.0.0-ballot'
    description 'PACIO Transitions of Care Server Test Suite'
    ig_url 'http://hl7.org/fhir/us/pacio-toc'
    source_code_url 'https://github.com/paciowg/pacio-test-kit'
    download_url 'https://github.com/paciowg/pacio-test-kit'
    report_issue_url 'https://github.com/paciowg/pacio-test-kit/issues'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    fhir_resource_validator do
      igs 'hl7.fhir.us.pacio-toc#1.0.0-ballot'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    config(
      options: {
        ig: 'TOC',
        ig_version: '1.0.0-ballot',
        capability_statement_url: 'http://hl7.org/fhir/us/pacio-toc/CapabilityStatement/toc',
        supported_resources: TOC_RESOURCES.keys,
        required_profiles: TOC_RESOURCES.values.flatten
      }
    )

    group do
      title 'PFE FHIR TOC'

      group from: :capability_statement do
        description ERB.new(File.read(
                              File.expand_path('../docs/capability_statement_group_description.md.erb', __dir__)
                            )).result_with_hash(config:)
      end

      group from: :pacio_toc_bundle_group
      group from: :pacio_toc_composition_group
      group from: :pacio_toc_organization_group
      group from: :pacio_toc_patient_group

      # QWERTY TODO: uncomment below after completing the appropriate test group files
      # group from: :pacio_toc_error_handling_group
      # group from: :pacio_toc_must_support_group
    end
  end
end
