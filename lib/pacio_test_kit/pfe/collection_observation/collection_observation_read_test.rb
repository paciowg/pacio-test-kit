require_relative '../../interactions_test'

module PacioTestKit
  module PFE
    class CollectionObservationReadTest < Inferno::Test
      include PacioTestKit::InteractionsTest

      title 'Server returns correct Observation resource from Observation read interaction'
      id :pacio_pfe_collection_observation_read
      description 'A server SHALL support the Observation read interaction.'

      input :collection_observation_ids,
            title: 'ID(s) for Collection Observation resources present in the server',
            description: 'If providing multiple IDs, separate them by a comma and a space. e.g. id_1, id_2, id_3'

      def resource_type
        'Observation'
      end

      run do
        omit 'Not yet implemented'
      end
    end
  end
end
