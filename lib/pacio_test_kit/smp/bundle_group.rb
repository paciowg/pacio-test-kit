require_relative '../pacio_profiles'

module PacioTestKit
  module SMP
    class BundleGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'SMP Bundle Tests'
      id :pacio_smp_bundle
      short_description 'Verify support for the server capabilities required by the FHIR Bundle resource type.'
      description %(
        # Background

        The PACIO SMP Bundle Medication List Profile tests verify that the system under test is able to provide
        correct responses for Bundle queries. These queries must contain resources conforming to the
        Bundle Medication List Profile as specified in the PACIO Standardized Medication Profile (SMP) IG
        v1.0.0 Implementation Guide.

        # Testing Methodology

        ## Reading
        The read interaction will perform required read associated with ID(s) provided by a user for Bundle
        resources present on the server. The resources returned from the read requests are validated on status,
        resource JSON structure, resource type, and matching ID values to the user provided ID(s).

        ## Creating
        The create test will perform a required create interaction associated with this resource, where the
        user supplies the JSON resource. The test first validates the user's inputted resource, and skips
        the test if there is no resource provided or if it is the incorrect type. Once the resource is created, the
        resource type, expected resource metadata, and response headers are validated in the response.

        ## Profile Validation
        Each resource returned from the first read is expected to conform to the Bundle Medication List Profile. Each
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
        resource_type: 'Bundle',
        profile: 'SMPBundle'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Bundle resource from Bundle create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :bundle_resource_input,
                 type: 'textarea',
                 title: 'SMPBundle resource to create on the server.'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct Bundle resource from Bundle read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :bundle_resource_ids,
                 optional: true,
                 title: 'ID(s) for SMPBundle resources present on the server.',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Bundle resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_validation,
           title: 'Bundle resources returned in previous tests conform to the SMPBundle profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the Bundle resources returned'
    end
  end
end
