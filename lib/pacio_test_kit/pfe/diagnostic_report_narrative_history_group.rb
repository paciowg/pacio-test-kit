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
      run_as_group
    end
  end
end
