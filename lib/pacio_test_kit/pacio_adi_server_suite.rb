require_relative 'pacio_profiles'
require_relative 'custom_groups/capability_statement_group'

module PacioTestKit
  class PacioADIServerSuite < Inferno::TestSuite
    include PacioTestKit::PacioProfiles

    id :pacio_adi_server
    title 'PACIO ADI v2.1.0 Server Test Suite'
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

    config(
      options: {
        ig: 'ADI',
        ig_version: '2.1.0',
        capability_statement_url: 'http://hl7.org/fhir/us/pacio-adi/CapabilityStatement/adi',
        supported_resources: ADI_RESOURCES.keys,
        required_profiles: ADI_RESOURCES.values.flatten
      }
    )

    group do
      title 'ADI FHIR API'

      group from: :capability_statement do
        description ERB.new(File.read(
                              File.expand_path('../docs/capability_statement_group_description.md.erb', __dir__)
                            )).result_with_hash(config:)
      end
    end
  end
end
