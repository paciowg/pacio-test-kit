require_relative 'pacio_profiles'
require_relative 'smp/patient_group'
require_relative 'smp/bundle_group'
require_relative 'smp/medication_group'
require_relative 'smp/medication_list_group'
require_relative 'smp/medication_administration_group'
require_relative 'smp/medication_statement_group'

module PacioTestKit
  class PacioSMPServerSuite < Inferno::TestSuite
    include PacioTestKit::PacioProfiles

    id :pacio_smp_server
    title 'PACIO SMP Server Suite v1.0.0'
    description 'PACIO Standardized Medication Profile Server Test Suite'
    ig_url 'https://hl7.org/fhir/us/smp/STU1/'
    source_code_url 'https://github.com/paciowg/pacio-test-kit'
    download_url 'https://github.com/paciowg/pacio-test-kit'
    report_issue_url 'https://github.com/paciowg/pacio-test-kit/issues'

    input :url,
          title: 'FHIR Server Base URL'

    fhir_client do
      url :url
    end

    GENERAL_MESSAGE_FILTERS = [
      /\A\S+: \S+: URL value '.*' does not resolve/,
      /\A\S+: \S+.meta.source: No definition could be found for URL value/
    ].freeze

    fhir_resource_validator do
      igs 'hl7.fhir.us.smp#1.0.0', 'hl7.fhir.us.core#6.1.0'

      message_filters = GENERAL_MESSAGE_FILTERS

      exclude_message do |message|
        message_filters.any? { |filter| filter.match? message.message }
      end
    end

    config(
      options: {
        ig: 'SMP',
        ig_version: '1.0.0',
        capability_statement_url: 'http://hl7.org/fhir/us/smp/CapabilityStatement/smp-server',
        supported_resources: SMP_RESOURCES.keys,
        required_profiles: SMP_RESOURCES.values.flatten
      }
    )

    group do
      title 'SMP FHIR API'

      group from: :capability_statement do
        description ERB.new(File.read(
                              File.expand_path('../docs/capability_statement_group_description.md.erb', __dir__)
                            )).result_with_hash(config:)
      end

      group from: :pacio_smp_patient_group
      group from: :pacio_smp_bundle
      group from: :pacio_smp_medication
      group from: :pacio_smp_medication_list
      group from: :pacio_smp_medication_administration
      group from: :pacio_smp_medication_statement
    end
  end
end
