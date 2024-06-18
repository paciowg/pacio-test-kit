require_relative '../common_tests/read_test'
require_relative 'clinical_test_observation/clinical_test_observation_create_test'
require_relative 'clinical_test_observation/clinical_test_observation_update_test'
require_relative 'clinical_test_observation/clinical_test_observation_validation_test'

module PacioTestKit
  module PFE
    class ClinicalTestObservationGroup < Inferno::TestGroup
      title 'Clinical Test Observation Tests'
      id :pacio_pfe_clinical_test_observation
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Clinical Test Observation Profile.
      )
      description 'TODO: Add description.'

      config options: {
        resource_type: 'Observation',
        profile: 'PFEClinicalTestObservation'
      }
      run_as_group

      test from: :pacio_pfe_clinical_test_observation_create
      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from Observation read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :clinical_test_observation_resource_ids,
                 title: 'ID(s) for PFEClinicalTestObservation resources present on the server'
               }
             }
           }
      test from: :pacio_pfe_clinical_test_observation_update
      test from: :pacio_pfe_clinical_test_observation_validation
    end
  end
end
