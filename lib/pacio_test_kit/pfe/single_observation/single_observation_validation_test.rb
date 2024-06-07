require_relative '../../validation_test'

module PacioTestKit
  module PFE
    class SingleObservationValidationTest < Inferno::Test
      include PacioTestKit::ValidationTest

      title 'Observation resources returned during previous tests conform to the PACIO PFE Single Observation Profile'
      id :pacio_pfe_single_observation_validation
      description 'TODO'

      def tag
        'single_observation'
      end

      run do
        omit 'Not yet implemented'
      end
    end
  end
end
