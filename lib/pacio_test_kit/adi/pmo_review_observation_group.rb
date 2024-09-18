require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PMOReviewObservationGroup < Inferno::TestGroup
      title 'ADI PMO Review Observation Tests'
      id :pacio_adi_pmo_review_observation
      description %(
        Verify support for the server capabilities required by the
        PACIO ADI PMO Review Observation Profile
      )
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIPMOReviewObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_review_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOReviewObservation resources present on the server'
               }
             }
           }
    end
  end
end
