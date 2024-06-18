require_relative '../common_tests/read_test'

module PacioTestKit
  module PFE
    class DiagnosticReportNoteExchangeGroup < Inferno::TestGroup
      title 'DiagnosticReport Note Exchange Tests'
      id :pacio_pfe_diagnostic_report_note_exchange
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE
        Diagnostic Report Note Exchange Profile.
      )
      description 'TODO: Add description.'
      optional

      config options: {
        resource_type: 'DiagnosticReport',
        profile: 'PFEDiagnosticReportNoteExchange'
      }
      run_as_group

      test from: :pacio_resource_read,
           title: 'Server returns correct DiagnosticReport resource from DiagnosticReport read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :diagnostic_report_note_exchange_resource_ids,
                 title: 'ID(s) for PFEDiagnosticReportNoteExchange resources present on the server'
               }
             }
           }
    end
  end
end
