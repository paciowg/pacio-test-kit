require_relative '../common_tests/create_test'
require_relative '../common_tests/read_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
require_relative '../common_tests/patient_match_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module TOC
    class TOCPatientGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Patient Tests'
      id :pacio_toc_patient_group
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
      The update is applied by changing the gender field of the resource,
      which can be values of "male", "female", "other", or "unknown".
      The updated status is chosen based on which value can produce a valid change for the output resource.
      This updated resource is then sent to the server to perform the update.
      The response is validated for HTTP status, resource type, consistent resource ID with the input, updated status,
      and correct metadata.

      ## Searching
      The search test performs each required search associated with this resource.
      Searches are executed using the following parameters:
        * `id`
        * `_id`
        * `identifier`
        * `name`
        * `birthdate + name`

      ### Search Parameters
      Each search request is validated for HTTP status, response structure, and correctness of returned results.
      The test checks that the response contains the expected resource type and that returned resources match the
      search criteria.
      If no matching resources are found, the search test will fail.

      ## Profile Validation
      Each resource returned from the read and search requests is expected to conform to the
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
      optional

      config options: {
        resource_type: 'Patient',
        profile: 'USCorePatient'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct Patient resource from Patient create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :patient_resource_input,
                 type: 'textarea',
                 title: 'Patient resource to create on the server'
               }
             }
           }

      test from: :pacio_resource_read,
           title: 'Server returns correct Patient resource from Patient read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :patient_resource_ids,
                 optional: true,
                 title: 'ID(s) for TOC Patient resources present on the server',
                 description: 'If providing multiple IDs, separate them by a comma and a space. ' \
                              'e.g. id_1, id_2, id_3. If leaving blank, test will use the resource id from ' \
                              'Patient resource created by previous test.'
               }
             }
           }

      test from: :pacio_resource_update,
           title: 'Server supports updating Composition resource',
           config: {
             options: {
               element_to_update: :gender,
               element_values: ['male', 'female', 'other', 'unknown']
             }
           }

      test from: :patient_id_search_test,
           title: 'Server returns valid results for Patient search by _id'
      test from: :identifier_search_test,
           title: 'Server returns valid results for Patient search by identifier'
      test from: :patient_name_search_test,
           title: 'Server returns valid results for Patient search by name'
      test from: :patient_birthdate_name_search_test,
           title: 'Server returns valid results for Patient search by birthdate + name'
      # These following tests are currently mandatory in the TOC ballot, but I believe
      # the requirements are not appropriate.
      # - Patient gender and birthdate searches return an excessively large number of patients,
      # which burdens both the server (in generating results) and the client (in processing them).
      # - Patient family name and given name searches are already covered by the more general patient name search.
      # I raised these concerns with the TOC author, who agreed to reconsider the requirements in the next release.
      # To maintain a clear mapping between this test suite and the TOC IG requirements, the tests are retained
      # here but commented out, so readers understand why these requirements appear absent.
      # test from: :patient_birthdate_search_test,
      #      title: 'Server returns valid results for Patient search by birthdate'
      # test from: :patient_family_search_test,
      #      title: 'Server returns valid results for Patient search by family'
      # test from: :patient_given_search_test,
      #      title: 'Server returns valid results for Patient search by given'
      # test from: :patient_gender_search_test,
      #      title: 'Server returns valid results for Patient search by gender'

      test from: :pacio_resource_validation,
           title: 'Patient Resources returned in previous tests conform to the TOC Patient profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )

      test from: :pacio_resource_must_support,
           title: 'All must support elements are provided in the Patient resources returned'

      test from: :patient_match_test
    end
  end
end
