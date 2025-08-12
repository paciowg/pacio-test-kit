require_relative 'pacio_profiles'
require_relative 'custom_groups/capability_statement_group'
require_relative 'pfe/clinical_test_observation_group'
require_relative 'pfe/collection_observation_group'
require_relative 'pfe/condition_encounter_diagnosis_group'
require_relative 'pfe/condition_problems_group'
require_relative 'pfe/device_use_statement_group'
require_relative 'pfe/diagnostic_report_narrative_history_group'
require_relative 'pfe/diagnostic_report_note_exchange_group'
require_relative 'error_handling_group'
require_relative 'pfe/goal_group'
require_relative 'pfe/nutrition_order_group'
require_relative 'pfe/service_request_group'
require_relative 'pfe/single_observation_group'

module PacioTestKit
  class PacioPFEServerSuite < Inferno::TestSuite
    include PacioTestKit::PacioProfiles

    id :pacio_pfe_server
    title 'PACIO PFE Server Suite v2.0.0-ballot'
    description 'PACIO Personal Functioning and Engagement Server Test Suite'
    ig_url 'http://hl7.org/fhir/us/pacio-pfe'
    source_code_url 'https://github.com/paciowg/pacio-test-kit'
    download_url 'https://github.com/paciowg/pacio-test-kit'
    report_issue_url 'https://github.com/paciowg/pacio-test-kit/issues'

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
      igs 'hl7.fhir.us.pacio-pfe#2.0.0-ballot'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    config(
      options: {
        ig: 'PFE',
        ig_version: '2.0.0-ballot',
        capability_statement_url: 'http://hl7.org/fhir/us/pacio-pfe/CapabilityStatement/pacio-pfe-cap',
        supported_resources: PFE_RESOURCES.keys,
        required_profiles: PFE_RESOURCES.values.flatten
      }
    )

    group do
      title 'PFE FHIR API'

      group from: :capability_statement do
        description ERB.new(File.read(
                              File.expand_path('../docs/capability_statement_group_description.md.erb', __dir__)
                            )).result_with_hash(config:)
      end
      group from: :pacio_pfe_clinical_test_observation
      group from: :pacio_pfe_single_observation
      group from: :pacio_pfe_collection_observation
      group from: :pacio_pfe_condition_encounter_diagnosis
      group from: :pacio_pfe_condition_problems
      group from: :pacio_pfe_diagnostic_report_narrative_history
      group from: :pacio_pfe_diagnostic_report_note_exchange
      group from: :pacio_pfe_device_use_statement
      group from: :pacio_pfe_goal
      group from: :pacio_pfe_nutrition_order
      group from: :pacio_pfe_service_request
      group from: :pacio_error_handling
    end
  end
end
