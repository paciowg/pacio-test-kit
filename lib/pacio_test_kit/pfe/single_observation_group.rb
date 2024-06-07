module PacioTestKit
  module PFE
    class SingleObservationGroup < Inferno::TestGroup
      title 'Single Observation Tests'
      id :pacio_pfe_single_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Single Observation Profile.
      )
      description 'TODO: Add description'
      run_as_group
    end
  end
end
