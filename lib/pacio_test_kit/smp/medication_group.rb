require_relative '../pacio_profiles'

module PacioTestKit
  module SMP
    class MedicationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'SMP Medication Tests'
      id :pacio_smp_medication
      short_description 'Verify support for the server capabilities required by the FHIR Medication resource type.'
      description %(
        # Background

        The PACIO SMP Medication Profile tests verify that the system under test is able to provide
        correct responses for Medication queries. These queries must contain resources conforming to the
        Medication Profile as specified in the PACIO Standardized Medication Profile (SMP) IG
        v1.0.0 Implementation Guide.

        # Testing Methodology

        ## Reading
        The read interaction will perform required read associated with ID(s) provided by a user for Medication
        resources present on the server. The resources returned from the read requests are validated on status,
        resource JSON structure, resource type, and matching ID values to the user provided ID(s).

        ## Creating
        The create test will perform a required create interaction associated with this resource, where the
        user supplies the JSON resource. The test first validates the user's inputted resource, and skips
        the test if there is no resource provided or if it is the incorrect type. Once the resource is created, the
        resource type, expected resource metadata, and response headers are validated in the response.

        ## Profile Validation
        Each resource returned from the first read is expected to conform to the Medication Profile. Each
        element is checked against terminology binding and cardinality requirements. Elements with a required binding
        are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
        the test will fail.

        ## Must Support
        Each profile contains elements marked as "must support". This test sequence expects to see each of these
        elements at least once. If at least one cannot be found, the test will fail. The resource returned from the
        first read is used for this test.
      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit

      optional
      config options: {
        resource_type: 'Medication',
        profile: 'SMPMedication'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Medication resource from Medication create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :medication_resource_input,
                 type: 'textarea',
                 title: 'SMPMedication resource to create on the server.'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct Medication resource from Medication read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :medication_resource_ids,
                 optional: true,
                 title: 'ID(s) for SMPMedication resources present on the server.',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Medication resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_validation,
           title: 'Medication resources returned in previous tests conform to the SMPMedication profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the Medication resources returned'
    end
  end
end
