require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_category_date_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_code_date_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_category_status_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_code_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_category_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_search_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class DiagnosticReportNarrativeHistoryGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Diagnostic Report Narrative History Tests'
      id :pacio_pfe_diagnostic_report_narrative_history
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Narrative History of Status Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'DiagnosticReport',
        profile: 'PFENarrativeHistoryOfStatus'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct DiagnosticReport resource from DiagnosticReport create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :narrative_history_diagnostic_report_resource_input,
                 title: 'PFENarrativeHistoryOfStatus resource to create on the server'
               }
             }
           }
      test from: :pacio_resource_read,
           title: 'Server returns correct DiagnosticReport resource from DiagnosticReport read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :diagnostic_report_narrative_history_resource_ids,
                 title: 'ID(s) for PFENarrativeHistoryOfStatus resources present on the server'
               }
             }
           }

      test from: :patient_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient'
      test from: :patient_code_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + code'
      test from: :patient_category_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + category'
      test from: :patient_category_date_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + category + date'
      test from: :patient_category_status_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + category + status',
           optional: true
      test from: :patient_code_date_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + code + date',
           optional: true
      test from: :pacio_resource_update

      test from: :pacio_resource_validation,
           title: 'DiagnosticReport Resources returned in previous tests conform to the ' \
                  'PFENarrativeHistoryOfStatus profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
