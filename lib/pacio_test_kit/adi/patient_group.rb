require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PatientGroup < Inferno::TestGroup
      title 'Patient Tests'
      id :pacio_adi_patient
      description %(
        Verify support for the server capabilities required by the
        US Core Patient Profile
      )
      optional

      config options: {
        resource_type: 'Patient',
        profile: 'USCOREPatient'
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
    end
  end
end