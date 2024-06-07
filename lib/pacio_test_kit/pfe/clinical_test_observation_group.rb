module PacioTestKit
  module PFE
    class ClinicalTestObservationGroup < Inferno::TestGroup
      title 'Clinical Test Observation Tests'
      id :pacio_pfe_clinical_test_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Clinical Test Observation Profile.
      )
      description 'TODO: Add description.'
      run_as_group
    end
  end
end
