module PacioTestKit
  module PFE
    class DiagnosticReportGroup < Inferno::TestGroup
      title 'DiagnosticReport Tests'
      id :pacio_pfe_diagnostic_report
      short_description 'Verify support for the server capabilities required by the PACIO PFE DiagnosticReport Profile.'
      description 'TODO: Add description.'
      optional
      run_as_group
    end
  end
end
