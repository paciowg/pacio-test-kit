require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class ServiceRequestGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'ServiceRequest Tests'
      id :pacio_pfe_service_request
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Service Request Profile.
      )
      description %(

      # Background

      The PACIO PFE Service Request Profile tests verify that the system under test is able to provide
      correct responses for ServiceRequest queries. These queries must contain resources conforming to the
      Service Request Profile as specified in the PACIO Personal Functioning and Engagement (PFE) IG
      v2.0.0 Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for ServiceRequest
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the Service Request Profile. Each
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
        resource_type: 'ServiceRequest',
        profile: 'PFEServiceRequest'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct ServiceRequest resource from ServiceRequest read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :service_request_resource_ids,
                 optional: true,
                 title: 'ID(s) for PFEServiceRequest resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'ServiceRequest Resources returned in previous tests conform to the PFEServiceRequest profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
