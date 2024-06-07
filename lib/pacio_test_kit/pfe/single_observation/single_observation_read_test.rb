require_relative '../../interactions_test'

module PacioTestKit
  module PFE
    class SingleObservationReadTest < Inferno::Test
      include PacioTestKit::InteractionsTest

      title 'Server returns correct Observation resource from Observation read interaction'
      id :pacio_pfe_single_observation_read
      description 'A server SHALL support the Observation read interaction.'

      input :single_observation_ids,
            title: 'ID(s) for Single Observation resources present in the server',
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
