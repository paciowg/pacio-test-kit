require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module PFE
    class DeviceUseStatementGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'DeviceUseStatement Tests'
      id :pacio_pfe_device_use_statement
      short_description %(
        Verify support for the server capabilities required by the PACIO PFE Use of Device Profile.
      )
      description %(

      # Background

      The PACIO PFE Device Use Statement Profile tests verify that the system under test is able to provide
      correct responses for DeviceUseStatement queries. These queries must contain resources conforming to the
      Device Use Statement Profile as specified in the PACIO Personal Functioning and Engagement (PFE) IG
      v2.0.0 Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for DeviceUseStatement
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the Device Use Statement Profile. Each
      element is checked against terminology binding and cardinality requirements. Elements with a required binding
      are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
      the test will fail.

      ## Must Support
      TODO

      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit
      optional

      config options: {
        resource_type: 'DeviceUseStatement',
        profile: 'PFEUseOfDevice'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct DeviceUseStatement resource from DeviceUseStatement read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :device_use_statement_resource_ids,
                 optional: true,
                 title: 'ID(s) for PFEUseOfDevice resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'DeviceUseStatement Resources returned in previous tests conform to the PFEUseOfDevice profile',
           description: ERB.new(File.read(File.join(
                                            'lib', 'docs', 'validation_test_description.md.erb'
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
