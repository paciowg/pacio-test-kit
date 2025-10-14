require_relative '../common_tests/read_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module SMP
    class PatientGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'US Core Patient Tests'
      id :pacio_smp_patient_group
      short_description %(
        Verify support for the server capabilities required by the US Core Patient Profile.
      )
      description %(
        # Background

        The US Core Patient Profile tests verify that the system under test can provide correct responses to
        Patient queries.
        These queries must contain resources conforming to the US Core Patient Profile as specified in the
        US Core Implementation Guide Implementation Guide v6.1.0.

        # Testing Methodology

        ## Reading
        The read interaction performs a required read operation using ID(s) provided by the user for Bundle resources
        present on the server. Multiple IDs can be provided.
        The response returned from the read request is validated for HTTP status, JSON structure, resource type,
        and matching ID values with the user-provided ID(s).

        ## Profile Validation
        Each resource returned from the read requests is expected to conform to the
        The US Core Patient Profile.
        Each element is checked against terminology binding and cardinality requirements.
        Elements with a required binding are validated against their bound ValueSet.
        If a code/system in an element is not part of the ValueSet, the test will fail.

        ## Must Support
        The The US Core Patient Profile contains elements marked as "must support."
        This test sequence requires that each of these elements appears at least once.
        If any required element is missing, the test will fail.
        The resource returned from the first read is used for this test.
      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit

      config options: {
        resource_type: 'Patient',
        profile: 'USCorePatient'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Patient resource from Patient read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :patient_resource_ids,
                 optional: false,
                 title: 'ID(s) for US Core Patient resources present on the server',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Patient resource created by previous test.'
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

      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the Patient resources returned'
    end
  end
end
