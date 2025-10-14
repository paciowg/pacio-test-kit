require_relative '../pacio_profiles'

module PacioTestKit
  module SMP
    class MedicationStatementGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'SMP MedicationStatement Tests'
      id :pacio_smp_medication_statement
      short_description %(
        Verify support for the server capabilities required by the FHIR MedicationStatement resource type.
      )
      description %(
        # Background

        The PACIO SMP MedicationStatement Profile tests verify that the system under test is able to provide
        correct responses for MedicationStatement queries. These queries must contain resources conforming to the
        MedicationStatement Profile as specified in the PACIO Standardized Medication Profile (SMP) IG
        v1.0.0 Implementation Guide.

        # Testing Methodology

        ## Reading
        The read interaction will perform required read associated with ID(s) provided by a user for
        MedicationStatement resources present on the server. The resources returned from the read requests are
        validated on status, resource JSON structure, resource type, and matching ID values to the user provided ID(s).

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
        resource, which can be values of "active", "completed", "entered-in-error", "intended", "stopped", "on-hold",
        "unknown", or "not-taken". The updated status is determined by which status value can produce a change in status
        for the output resource. The updated resource is validated for resource type, consistent id value of input
        resource and updated resource, changing status, and correct metadata.

        ## Profile Validation
        Each resource returned from the first read is expected to conform to the MedicationStatement Profile. Each
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
        resource_type: 'MedicationStatement',
        profile: 'SMPMedicationStatement'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct MedicationStatement resource from MedicationStatement create ' \
                  'interaction',
           optional: true,
           config: {
             inputs: {
               resource_input: {
                 name: :medication_statement_resource_input,
                 type: 'textarea',
                 title: 'SMPMedicationStatement resource to create on the server.'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct MedicationStatement resource from MedicationStatement read ' \
                  'interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :medication_statement_resource_ids,
                 optional: true,
                 title: 'ID(s) for SMPMedicationStatement resources present on the server.',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'MedicationStatement resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_update,
           title: 'Server supports updating an existing MedicationStatement resource',
           optional: true,
           config: {
             options: {
               element_to_update: :status,
               element_values: %w[active completed entered-in-error intended stopped on-hold unknown not-taken]
             }
           }

      test from: :pacio_resource_validation,
           title: 'MedicationStatement Resources returned in previous tests conform to the ' \
                  'SMPMedicationStatement profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the MedicationStatement resources returned'
    end
  end
end
