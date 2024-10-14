require_relative '../common_tests/read_test'

module PacioTestKit
  module ADI
    class PMOHospiceObservationGroup < Inferno::TestGroup
      title 'ADI PMO Hospice Observation Tests'
      id :pacio_adi_pmo_hospice_observation
      short_description %(
        Verify support for the server capabilities required by the
        PACIO ADI PMO Hospice Observation Profile
      )
      description %(

      # Background

      The PACIO ADI PMO Hospice Observation Profile tests verify that the system under test is able to provide
      correct responses for Observation queries. These queries must contain resources conforming to the
      PMO Hospice Observation Profile as specified in the PACIO Advance Directive Interoperability (ADI) IG
      v2.1.0 Implementation Guide.

      # Testing Methodology

      ## Reading
      The read interaction will perform required read associated with ID(s) provided by a user for Observation
      resources present on the server. The resources returned from the read requests are validated on status,
      resource JSON structure, resource type, and matching ID values to the user provided ID(s).

      ## Profile Validation
      Each resource returned from the first read is expected to conform to the PMO Hospice Observation Profile. Each
      element is checked against terminology binding and cardinality requirements. Elements with a required binding
      are validated against their bound ValueSet. If a code/system in the element is not part of the ValueSet, then
      the test will fail.

      ## Must Support
      TODO

      )
      # description adapted from US-Core-Test-Kit groups: https://github.com/inferno-framework/us-core-test-kit
      optional

      config options: {
        resource_type: 'Observation',
        profile: 'ADIPMOHospiceObservation'
      }
      run_as_group
      input_order :url

      test from: :pacio_resource_read,
           title: 'Server returns correct Observation resource from read interaction',
           optional: true,
           config: {
             inputs: {
               resource_ids: {
                 name: :pmo_hospice_observation_resource_ids,
                 optional: true,
                 title: 'ID(s) for ADIPMOHospiceObservation resources present on the server'
               }
             }
           }
    end
  end
end
