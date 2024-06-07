require_relative '../../validation_test'

module PacioTestKit
  module PFE
    class CollectionObservationValidationTest < Inferno::Test
      include PacioTestKit::ValidationTest

      title 'Observation resources returned during previous tests conform to the PACIO PFE Collection Profile'
      id :pacio_pfe_collection_observation_validation
      description 'TODO'

      def tag
        'collection_observation'
      end

      run do
        omit 'Not yet implemented'
      end
    end
  end
end
