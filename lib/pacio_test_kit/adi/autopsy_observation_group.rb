require_relative '../common_tests/read_test'
require_relative '../common_tests/validation_test'
require_relative '../pacio_profiles'

module PacioTestKit
  module ADI
    class AutopsyObservationGroup < Inferno::TestGroup
      include PacioTestKit::PacioProfiles

      title 'ADI Autopsy Observation Tests'
      id :pacio_adi_autopsy_observation
      short_description %(
        Verify support for the server capabilities required by the
        PACIO ADI Autopsy Observation Profile
      )
      description %(

      # Background

      The PACIO ADI Autopsy Observation Profile tests verify that the system under test is able to provide
      correct responses for Observation queries. These queries must contain resources conforming to the
      Autopsy Observation Profile as specified in the PACIO Advance Directive Interoperability (ADI) IG
      v2.1.0 Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for Observation
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the Autopsy Observation Profile. Each
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
        resource_type: 'Observation',
        profile: 'ADIAutopsyObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :autopsy_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIAutopsyObservation resources present on the server'
               }
             }
           }
      test from: :pacio_resource_validation,
           title: 'Observation Resources returned in previous tests conform to the ADIAutopsyObservation profile',
           description: ERB.new(File.read(File.expand_path(
                                            '../../docs/validation_test_description.md.erb', __dir__
                                          ))).result_with_hash(
                                            config:,
                                            pacio_profiles: PACIO_PROFILES
                                          )
    end
  end
end
