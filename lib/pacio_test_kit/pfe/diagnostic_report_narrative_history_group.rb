require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
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
      test from: :pacio_resource_update
      test from: :pacio_resource_validation,
           title: 'DiagnosticReport Resources returned in previous tests conform to the ' \
                  'PFENarrativeHistoryOfStatus profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
