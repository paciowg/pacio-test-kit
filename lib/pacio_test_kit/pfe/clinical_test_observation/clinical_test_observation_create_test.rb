require_relative '../../interactions_test'

module PacioTestKit
  module PFE
    class ClinicalTestObservationCreateTest < Inferno::Test
      include PacioTestKit::InteractionsTest

      title 'Server allows creating an Observation resource'
      id :pacio_pfe_clinical_test_observation_create
      description 'A server SHALL support the Observation create interaction.'

      run do
        omit 'Not yet implemented'
      end
    end
  end
end
