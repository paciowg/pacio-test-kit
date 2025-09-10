require_relative '../common_tests/create_test'
require_relative '../common_tests/read_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module TOC
    class TOCCompositionGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'TOC Composition Tests'
      id :pacio_toc_composition_group
      short_description %(
        Verify support for the server capabilities required by the PACIO TOC Composition Profile.
      )
      description %(

      # Background

      The PACIO TOC Composition Profile tests verify that the system under test is able to provide
      correct responses for TOC Composition queries. These queries must contain resources conforming to the
      TOC Composition Profile as specified in the PACIO Transitions of Care (TOC) IG v1.0.0-ballot Implementation Guide.

      # Testing Methodology

      ## Creating
      The create test will perform a required create interaction associated with this resource, where the
      user supplies the JSON resource. The test first validates the user's inputted resource, and skips
      the test if there is no resource provided or if it is the incorrect type. Once the resource is created, the
      resource type, expected resource metadata, and response headers are validated in the response.

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for TOC Composition
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Updating
      The update interaction uses the previously read resource(s) retrieved from the read interaction. The test first
      validates that a successful read request was made in previous tests, and the first
      resource from the successful read requests is selected for the update test. If the resource can not be found from
      a previous successful read request, the update test will skip. Update is applied to the resource by changing
      the status field of the resource, which can be values of "final", "amended", or "entered-in-error".
      The updated status is determined by which status value can produce a change in status for the output resource.
      The updated resource is validated for resource type, consistent id value of input resource and updated resource,
      changing status, and correct metadata.

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the TOC Composition Profile. Each
      element is checked against terminology binding and cardinality requirements. Elements with a required binding
      are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
      the test will fail.

      ## Must Support
      Each profile contains elements marked as "must support". This test sequence expects to see each of these elements
      at least once. If at least one cannot be found, the test will fail. The resource returned from the first read
      is used for this test.

      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit
      optional

      config options: {
        resource_type: 'Composition',
        profile: 'TOCComposition'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct TOC Composition resource from TOC Composition create interaction',
           optional: true,
           config: {
             inputs: {
               resource_input: {
                 name: :composition_resource_input,
                 type: 'textarea',
                 title: 'TOC Composition resource to create on the server.',
                 description: 'If leave blank, this test will be skipped.'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct TOC Composition resource from TOC Composition read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :composition_resource_ids,
                 optional: true,
                 title: 'ID(s) for TOC Composition resources present on the server',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Composition resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_update,
           title: 'Server supports updating Composition resource',
           optional: true,
           config: {
             options: {
               element_to_update: :status,
               element_values: ['final', 'amended', 'entered-in-error']
             }
           }

      test from: :pacio_resource_validation,
           title: 'TOC Composition Resources returned in previous tests conform to the TOC Composition profile',
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
