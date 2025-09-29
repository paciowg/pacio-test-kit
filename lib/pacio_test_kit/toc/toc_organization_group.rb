require_relative '../common_tests/create_test'
require_relative '../common_tests/read_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
module PacioTestKit
  module TOC
    class TOCOrganizationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Organization Tests'
      id :pacio_toc_organization_group
      short_description %(
        Verify support for the server capabilities required by the US Core Organization Profile.
      )
      description %(
      # Background

      The US Core Organization Profile tests verify that the system under test can provide correct responses to
      Organization queries.
      These queries must contain resources conforming to the US Core Organization Profile as specified in the
      US Core Implementation Guide Implementation Guide v6.1.0.

      # Testing Methodology

      ## Creating
      The create test performs a required create interaction associated with this resource, where the user supplies the
      JSON resource.
      The test first validates the user-provided resource and skips the test if no resource is provided
      or if it is of the incorrect type.
      Once the resource is created, the response is validated for resource type, expected metadata,
      and response headers.

      ## Reading
      The read interaction performs a required read operation using ID(s) provided by the user for Bundle resources
      present on the server. Multiple IDs can be provided.
      If no ID is provided, the read test uses the resource created in the create test.
      The response returned from the read request is validated for HTTP status, JSON structure, resource type,
      and matching ID values with the user-provided ID(s).

      ## Updating
      The update interaction uses the previously read resource(s) retrieved from the read test.
      The test first validates that a successful read request was made in previous tests,
      and the first resource from those requests is selected for the update test.
      If the resource cannot be found from a previous successful read, the update test will be skipped.
      The update is applied by changing the name field of the resource, which can be values of "Test Organization",
      or "Test Organization 2"
      The updated status is chosen based on which value can produce a valid change for the output resource.
      This updated resource is then sent to the server to perform the update.
      The response is validated for HTTP status, resource type, consistent resource ID with the input, updated status,
      and correct metadata.

      ## Profile Validation
      Each resource returned from the initial read is expected to conform to the The US Core Organization Profile .
      Each element is checked against terminology binding and cardinality requirements.
      Elements with a required binding are validated against their bound ValueSet.
      If a code/system in an element is not part of the ValueSet, the test will fail.

      ## Must Support
      The The US Core Organization Profile contains elements marked as "must support."
      This test sequence requires that each of these elements appears at least once.
      If any required element is missing, the test will fail.
      The resource returned from the first read is used for this test.
      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit

      config options: {
        resource_type: 'Organization',
        profile: 'USCoreOrganization'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Organization resource from Organization create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :organization_resource_input,
                 type: 'textarea',
                 title: 'Organization resource to create on the server'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct Organization resource from Organization read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :organization_resource_ids,
                 optional: true,
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Organization resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_update,
           title: 'Server supports updating Composition resource',
           optional: true,
           config: {
             options: {
               element_to_update: :name,
               element_values: ['Test Organization', 'Test Organization 2']
             }
           }

      test from: :pacio_resource_validation,
           title: 'Organization Resources returned in previous tests conform to the TOC Organization profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the Composition resources returned'
    end
  end
end
