require_relative 'pfe/clinical_test_observation_group'
require_relative 'pfe/collection_observation_group'
require_relative 'pfe/condition_encounter_diagnosis_group'
require_relative 'pfe/condition_problems_group'
require_relative 'pfe/device_use_statement_group'
require_relative 'pfe/diagnostic_report_narrative_history_group'
require_relative 'pfe/diagnostic_report_note_exchange_group'
require_relative 'pfe/goal_group'
require_relative 'pfe/service_request_group'
require_relative 'pfe/single_observation_group'

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

    group from: :pacio_pfe_single_observation
    group from: :pacio_pfe_clinical_test_observation
    group from: :pacio_pfe_collection_observation
    group from: :pacio_pfe_condition_encounter_diagnosis
    group from: :pacio_pfe_condition_problems
    group from: :pacio_pfe_diagnostic_report_narrative_history
    group from: :pacio_pfe_diagnostic_report_note_exchange
    group from: :pacio_pfe_device_use_statement
    group from: :pacio_pfe_goal
    group from: :pacio_pfe_service_request
  end
end
