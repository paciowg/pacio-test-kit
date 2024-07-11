require_relative '../../validation_test'

module PacioTestKit
  module PFE
    class ClinicalTestObservationValidationTest < Inferno::Test
      include PacioTestKit::ValidationTest

      title %(
        Observation resources returned during previous tests conform to the PACIO PFE Clinical Test Observation Profile
      )
      id :pacio_pfe_clinical_test_observation_validation
      description 'TODO: Add description.'

      def tag
        'clinical_test_observation'
      end

      run do
        omit 'Not yet implemented'
      end
    end
  end
end
