require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'

module PacioTestKit
  module PFE
    class DiagnosticReportNarrativeHistoryGroup < Inferno::TestGroup
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
               resource_inputs: {
                 name: :narrative_history_diagnostic_report_resource_list,
                 title: 'Resources(s) for PFENarrativeHistoryOfStatus resources created on the server'
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
    end
  end
end
