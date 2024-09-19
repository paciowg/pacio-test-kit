require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/create_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_category_date_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_code_date_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_category_status_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_code_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_category_search_test'
require_relative '../common_tests/observation_diagnostic_report_search//patient_search_test'

module PacioTestKit
  module PFE
    class ClinicalTestObservationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

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
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Observation resource from Observation create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :clinical_test_observation_resource_input,
                 title: 'PFEClinicalTestObservation resource to create on the server'
               }
             }
           }
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
      test from: :patient_search_test,
           title: 'Server returns valid results for Observation search by patient'
      test from: :patient_code_search_test,
           title: 'Server returns valid results for Observation search by patient + code'
      test from: :patient_category_search_test,
           title: 'Server returns valid results for Observation search by patient + category'
      test from: :patient_category_date_search_test,
           title: 'Server returns valid results for Observation search by patient + category + date'
      test from: :patient_category_status_search_test,
           title: 'Server returns valid results for Observation search by patient + category + status',
           optional: true
      test from: :patient_code_date_search_test,
           title: 'Server returns valid results for Observation search by patient + code + date',
           optional: true

      test from: :pacio_resource_update

      test from: :pacio_resource_validation,
           title: 'Observation Resources returned in previous tests conform to the PFEClinicalTestObservation profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
