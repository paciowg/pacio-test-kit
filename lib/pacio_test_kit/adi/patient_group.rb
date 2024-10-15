require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient__id_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_birthdate_family_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_birthdate_name_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_birthdate_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_deathdate_family_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_family_gender_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_family_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_gender_name_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_gender_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_given_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_identifier_search_test'
require_relative '../common_tests/adi_search_tests/patient_search_tests/patient_name_search_test'
require_relative '../common_tests/adi_search_tests/id_search_test'

module PacioTestKit
  module ADI
    class PatientGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Patient Tests'
      id :pacio_adi_patient
      description %(
        Verify support for the server capabilities required by the
        US Core Patient Profile
      )
      optional

      config options: {
        resource_type: 'Patient',
        profile: 'USCorePatient'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Patient resource from read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :patient_resource_ids,
                 title: 'ID(s) for Patient resources present on the server'
               }
             }
           }
      test from: :patient_id_search_test,
           title: 'Server returns valid results for Patient search by _id'
      test from: :patient_birthdate_family_search_test,
           title: 'Server returns valid results for Patient search by birthdate + family',
           optional: true
      test from: :patient_birthdate_name_search_test,
           title: 'Server returns valid results for Patient search by birthdate + name'
      test from: :patient_birthdate_search_test,
           title: 'Server returns valid results for Patient search by birthdate'
      test from: :patient_deathdate_family_search_test,
           title: 'Server returns valid results for Patient search by deathdate + family',
           optional: true
      test from: :patient_family_gender_search_test,
           title: 'Server returns valid results for Patient search by family + gender',
           optional: true
      test from: :patient_family_search_test,
           title: 'Server returns valid results for Patient search by family'
      test from: :patient_gender_name_search_test,
           title: 'Server returns valid results for Patient search by gender + name'
      test from: :patient_gender_search_test,
           title: 'Server returns valid results for Patient search by gender'
      test from: :patient_given_search_test,
           title: 'Server returns valid results for Patient search by given'
      test from: :patient_identifier_search_test,
           title: 'Server returns valid results for Patient search by identifier'
      test from: :patient_name_search_test,
           title: 'Server returns valid results for Patient search by name'
      test from: :pacio_resource_validation,
           title: 'Patient Resources returned in previous tests conform to the US Core Patient profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
