require_relative '../common_tests/read_test'
require_relative '../common_tests/create_test'
require_relative '../common_tests/update_test'
require_relative '../common_tests/validation_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_category_date_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_code_date_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_category_status_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_code_search_test'
require_relative '../common_tests/observation_diagnostic_report_search/patient_category_search_test'
require_relative '../common_tests/patient_search_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class DiagnosticReportNarrativeHistoryGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'Diagnostic Report Narrative History Tests'
      id :pacio_pfe_diagnostic_report_narrative_history
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Narrative History of Status Profile.
      )
      description %(

      # Background

      The PACIO PFE Diagnostic Report Narrative History Profile tests verify that the system under test is able to
      provide correct responses for DiagnosticReport queries. These queries must contain resources conforming to the
      Diagnostic Report Narrative History Profile as specified in the PACIO Personal Functioning and Engagement (PFE) IG
      v2.0.0 Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for DiagnosticReport
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
        * patient
        * patient + code
        * patient + category
        * patient + category + date
        * patient + category + status
        * patient + code + date

      ### Search Parameters
      The update interaction uses the previously read resource(s) retrieved from the read interaction. The test first
      validates that a successful read request was made in previous tests, and the first
      resource from the successful read requests is selected for the update test. If the resource can not be found from
      a previous successful read request, the update test will skip.

      ### Search Validation
      Inferno will retrieve up to the first 20 bundle pages of the reply for the DiagnosticReport resources and save
      them for subsequent tests. The resources are checked to ensure they are the correct resource type.

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the Diagnostic Report Narrative History
      Profile. Each element is checked against terminology binding and cardinality requirements. Elements with a
      required binding are validated against their bound ValueSet. If a code/system in the element is not part of
      the ValueSet, then the test will fail.

      ## Must Support
      Each profile contains elements marked as "must support". This test sequence expects to see each of these elements
      at least once. If at least one cannot be found, the test will fail. The resource returned from the first read
      is used for this test.

      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit
      optional

      config options: {
        resource_type: 'DiagnosticReport',
        profile: 'PFENarrativeHistoryOfStatus'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_create,
           title: 'Server creates correct DiagnosticReport resource from DiagnosticReport create interaction',
           config: {
             inputs: {
               resource_input: {
                 name: :narrative_history_diagnostic_report_resource_input,
                 title: 'PFENarrativeHistoryOfStatus resource to create on the server'
               }
             }
           }
      test from: :pacio_resource_read,
           title: 'Server returns correct DiagnosticReport resource from DiagnosticReport read interaction',
           config: {
             inputs: {
               resource_ids: {
                 name: :diagnostic_report_narrative_history_resource_ids,
                 title: 'ID(s) for PFENarrativeHistoryOfStatus resources present on the server'
               }
             }
           }

      test from: :patient_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient'
      test from: :patient_code_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + code'
      test from: :patient_category_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + category'
      test from: :patient_category_date_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + category + date'
      test from: :patient_category_status_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + category + status',
           optional: true
      test from: :patient_code_date_search_test,
           title: 'Server returns valid results for DiagnosticReport search by patient + code + date',
           optional: true
      test from: :pacio_resource_update

      test from: :pacio_resource_validation,
           title: 'DiagnosticReport Resources returned in previous tests conform to the ' \
                  'PFENarrativeHistoryOfStatus profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
