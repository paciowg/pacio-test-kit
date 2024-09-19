require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class DiagnosticReportNoteExchangeGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      input_order :url

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
      test from: :pacio_resource_validation,
           title: 'DiagnosticReport Resources returned in previous tests conform to the ' \
                  'PFEDiagnosticReportNoteExchange profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
