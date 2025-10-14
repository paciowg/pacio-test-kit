require_relative '../pacio_profiles'
require_relative '../common_tests/patient_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_code_search_test'
require_relative 'retrieve_test'
require_relative 'submit_test'

module PacioTestKit
  module SMP
    class MedicationListGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'SMP Medication List Tests'
      id :pacio_smp_medication_list
      short_description 'Verify support for the server capabilities required by the FHIR List resource type.'
      description %(
        # Background

        The PACIO SMP Medication List Profile tests verify that the system under test is able to provide
        correct responses for List queries. These queries must contain resources conforming to the
        Medication List Profile as specified in the PACIO Standardized Medication Profile (SMP) IG
        v1.0.0 Implementation Guide.

        # Testing Methodology

        ## Reading
        The read interaction will perform required read associated with ID(s) provided by a user for List
        resources present on the server. The resources returned from the read requests are validated on status,
        resource JSON structure, resource type, and matching ID values to the user provided ID(s).

        ## Creating
        The create test will perform a required create interaction associated with this resource, where the
        user supplies the JSON resource. The test first validates the user's inputted resource, and skips
        the test if there is no resource provided or if it is the incorrect type. Once the resource is created, the
        resource type, expected resource metadata, and response headers are validated in the response.

        ## Updating
        The update interaction uses the previously read resource(s) retrieved from the read interaction. The test first
        validates that a successful read request was made in previous tests, and the first resource from the successful
        read requests is selected for the update test. If the resource can not be found from a previous successful read
        request, the update test will skip. Update is applied to the resource by changing the status field of the
        resource, which can be values of "current", "retired", or "entered-in-error". The updated status is determined
        by which status value can produce a change in status for the output resource. The updated resource is validated
        for resource type, consistent id value of input resource and updated resource, changing status, and correct
        metadata.

        ## Searching
        The search tests will perform each required search associated with this resource. This test will perform
        searches with the following parameters:
          * patient
          * patient + code

        ### Search Parameters
        The update interaction uses the previously read resource(s) retrieved from the read interaction. The test first
        validates that a successful read request was made in previous tests, and the first
        resource from the successful read requests is selected for the update test. If the resource can not be found
        from a previous successful read request, the update test will skip.

        ### Search Validation
        Inferno will retrieve up to the first 20 bundle pages of the reply for the List resources and save them
        for subsequent tests. The resources are checked to ensure they are the correct resource type.

        ## Profile Validation
        Each resource returned from the first read is expected to conform to the Medication List Profile. Each
        element is checked against terminology binding and cardinality requirements. Elements with a required binding
        are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
        the test will fail.

        ## Must Support
        Each profile contains elements marked as "must support". This test sequence expects to see each of these
        elements at least once. If at least one cannot be found, the test will fail. The resource returned from the
        first read is used for this test.
      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit

      config options: {
        resource_type: 'List',
        profile: 'SMPMedicationList'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct List resource from List create interaction',
           optional: true,
           config: {
             inputs: {
               resource_input: {
                 name: :medication_list_resource_input,
                 type: 'textarea',
                 title: 'SMPMedicationList resource to create on the server.'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct List resource from List read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :medication_list_resource_ids,
                 optional: true,
                 title: 'ID(s) for SMPMedicationList resources present on the server.',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'List resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_update,
           title: 'Server supports updating an existing List resource',
           optional: true,
           config: {
             options: {
               element_to_update: :status,
               element_values: ['current', 'retired', 'entered-in-error']
             }
           }

      test from: :patient_search_test,
           title: 'Server returns valid results for List search by patient'
      test from: :patient_code_search_test,
           title: 'Server returns valid results for List search by patient + code'

      test from: :pacio_resource_validation,
           title: 'List Resources returned in previous tests conform to the SMPMedicationList profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the List resources returned'

      test from: :pacio_smp_operation_retrieve_test, optional: true
      test from: :pacio_smp_operation_submit_test, optional: true
    end
  end
end
