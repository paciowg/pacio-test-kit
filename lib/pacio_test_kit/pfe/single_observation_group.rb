require_relative 'single_observation/single_observation_read_test'
require_relative 'single_observation/single_observation_validation_test'

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

      test from: :pacio_pfe_single_observation_read
      test from: :pacio_pfe_single_observation_validation
    end
  end
end
