require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'
require_relative '../common_tests/create_test'
require_relative '../common_tests/update_test'

module PacioTestKit
  module ADI
    class OrganizationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Organization Tests'
      id :pacio_adi_organization
      short_description %(
        Verify support for the server capabilities required by the
        US Core Organization Profile
      )
      description %(

      # Background

      The PACIO ADI Organization Profile tests verify that the system under test is able to provide
      correct responses for Organization queries. These queries must contain resources conforming to the
      Organization Profile as specified in the PACIO Advance Directive Interoperability (ADI) IG
      v2.0.0-ballot Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for Organization
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Creating
      The create test will perform a required create interaction associated with this resource, where the
      user supplies the JSON resource. The test first validates the user's inputted resource, and skips
      the test if there is no resource provided or if it is the incorrect type. Once the resource is created, the
      resource type, expected resource metadata, and response headers are validated in the response.

      ## Updating
      The update interaction uses the previously read resource(s) retrieved from the read interaction. The test first
      validates that a successful read request was made in previous tests, and the first
      resource from the successful read requests is selected for the update test. If the resource can not be found from
      a previous successful read request, the update test will skip. Update is applied to the resource by changing
      the status field of the resource, which can be values of "final" or "cancelled". The updated status is determined
      by which status value can produce a change in status for the output resource. The updated resource is validated
      for resource type, consistent id value of input resource and updated resource, changing status, and correct
      metadata.

      ## Searching
      The search test will perform each required search associated with this resource. This test will perform
      searches with the following parameters:
        * id

      ### Search Parameters
      The update interaction uses the previously read resource(s) retrieved from the read interaction. The test first
      validates that a successful read request was made in previous tests, and the first
      resource from the successful read requests is selected for the update test. If the resource can not be found from
      a previous successful read request, the update test will skip.

      ### Search Validation
      Inferno will retrieve up to the first 20 bundle pages of the reply for the Organization resources and save them
      for subsequent tests. The resources are checked to ensure they are the correct resource type.

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the Organization Profile. Each
      element is checked against terminology binding and cardinality requirements. Elements with a required binding
      are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
      the test will fail.

      ## Must Support
      Each profile contains elements marked as "must support". This test sequence expects to see each of these elements
      at least once. If at least one cannot be found, the test will fail. The resource returned from the first read
      is used for this test.

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
                 title: 'Organization resource to create on the server'
               }
             }
           }
      test from: :pacio_resource_read,
           title: 'Server returns correct Organization resource from read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :organization_resource_ids,
                 title: 'ID(s) for Organization resources present on the server'
               }
             }
           }
      test from: :pacio_resource_update,
           title: 'Server supports updating an existing Organization resource',
           config: {
             options: {
               element_to_update: :name,
               element_values: ['Test Organization', 'Test Organization 2']
             }
           }
      test from: :pacio_resource_validation,
           title: 'Organization Resources returned in previous tests conform to the US Core Organization profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
