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
      run_as_group
    end
  end
end
