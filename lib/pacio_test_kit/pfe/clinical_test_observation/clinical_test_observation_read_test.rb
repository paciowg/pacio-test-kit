require_relative '../../interactions_test'

module PacioTestKit
  module PFE
    class ClinicalTestObservationReadTest < Inferno::Test
      include PacioTestKit::InteractionsTest

      title 'Server returns correct Observation resource from Observation read interaction'
      id :pacio_pfe_clinical_test_observation_read
      description 'A server SHALL support the Observation read interaction.'

      input :clinical_test_observation_ids,
            title: 'ID(s) for Clinical Test Observation resources present in the server',
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
