require_relative '../../interactions_test'

module PacioTestKit
  module PFE
    class ClinicalTestObservationUpdateTest < Inferno::Test
      include PacioTestKit::InteractionsTest

      title 'Server allows Updating an Observation resource'
      id :pacio_pfe_clinical_test_observation_update
      description 'A server SHALL support the Observation update interaction.'

      run do
        omit 'Not yet implemented'
      end
    end
  end
end
