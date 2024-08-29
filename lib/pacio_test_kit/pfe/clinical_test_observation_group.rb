require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/create_test'


require_relative '../common_tests/search_type_test'

require_relative '../common_tests/update_test'


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

      

      test from: :pacio_resource_search_type,
           title: 'Server returns correct Observation resource from Observation search-type interaction',
           config: {
             inputs: {
               patient: {
                 name: :patient,
                 title: 'Patient search-type parameter for searching resources present on the server.',
                 optional: true
               },
               category: {
                 name: :category,
                 title: 'Category search-type parameter for searching resources present on the server.',
                 optional: true
               },
               code: {
                 name: :code,
                 title: 'Code search-type parameter for searching resources present on the server.',
                 optional: true
               },
               date: {
                 name: :date,
                 title: 'Date search-type parameter for searching resources present on the server.',
                 optional: true
               }
             }
           }

      test from: :pacio_resource_update

      test from: :pacio_resource_validation,
           title: 'Observation Resources returned in previous tests conform to the PFEClinicalTestObservation profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
