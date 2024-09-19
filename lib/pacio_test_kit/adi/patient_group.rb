require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

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
